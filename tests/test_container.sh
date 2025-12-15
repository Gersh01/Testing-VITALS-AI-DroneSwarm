#!/usr/bin/env bash
set -euo pipefail

# Test script for docker compose services under app/Docker-compose.yml
# - Builds (if not already built), brings up services, verifies they are running
# - Performs a simple health check against Postgres if present
# - Prints logs on failure

COMPOSE_FILE="app/Docker-compose.yml"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Using compose file: $COMPOSE_FILE"

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed or not in PATH" >&2
    exit 1
fi

echo "Docker version:"; docker version || true
echo "Docker Compose version:"; docker compose version || true

if [ ! -f "$PROJECT_DIR/$COMPOSE_FILE" ]; then
    echo "Compose file not found at $PROJECT_DIR/$COMPOSE_FILE" >&2
    exit 1
fi

cd "$PROJECT_DIR"

echo "Building services..."
docker compose -f "$COMPOSE_FILE" build

echo "Starting services..."
docker compose -f "$COMPOSE_FILE" up -d

echo "Waiting for services to initialize..."
sleep 20

echo "Listing services and status:"
docker compose -f "$COMPOSE_FILE" ps

services=$(docker compose -f "$COMPOSE_FILE" ps --services)
if [ -z "$services" ]; then
    echo "No services found in compose file" >&2
    docker compose -f "$COMPOSE_FILE" logs || true
    exit 1
fi

echo "Verifying service containers are running..."
for svc in $services; do
    cid=$(docker compose -f "$COMPOSE_FILE" ps -q "$svc")
    if [ -z "$cid" ]; then
        echo "Service $svc has no container ID" >&2
        docker compose -f "$COMPOSE_FILE" logs "$svc" || true
        exit 1
    fi
    state=$(docker inspect -f '{{.State.Status}}' "$cid")
    echo "- $svc ($cid) status: $state"
    if [ "$state" != "running" ]; then
        echo "Service $svc is not running (status=$state)" >&2
        docker compose -f "$COMPOSE_FILE" logs "$svc" || true
        exit 1
    fi
done

# Optional health check for Postgres database service if defined
if echo "$services" | grep -q '^database$'; then
    echo "Running Postgres health check..."
    db_cid=$(docker compose -f "$COMPOSE_FILE" ps -q database)
    if ! docker exec "$db_cid" pg_isready -q; then
        echo "Postgres is not ready" >&2
        docker compose -f "$COMPOSE_FILE" logs database || true
        exit 1
    fi
    echo "Postgres is ready."
fi

echo "All services are running and basic checks passed."
exit 0

