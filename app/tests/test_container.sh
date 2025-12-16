#!/bin/bash

# Test script to verify Docker Compose is running correctly

set -e

COMPOSE_FILE="Docker-compose.yml"
PROJECT_NAME="testing-vitals-ai-droneswarm"

echo "Testing Docker Compose setup..."

# Check if docker-compose.yml exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "ERROR: $COMPOSE_FILE not found"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running"
    exit 1
fi

# Start services
echo "Starting Docker Compose services..."
docker-compose up -d

# Wait for services to start
sleep 10

# Check if all services are running
echo "Checking service status..."
SERVICES=$(docker-compose ps --services)
FAILED_SERVICES=""

for service in $SERVICES; do
    if ! docker-compose ps "$service" | grep -q "Up"; then
        FAILED_SERVICES="$FAILED_SERVICES $service"
    fi
done

if [ -n "$FAILED_SERVICES" ]; then
    echo "ERROR: The following services failed to start:$FAILED_SERVICES"
    docker-compose logs
    docker-compose down
    exit 1
fi

# Check if containers are healthy (if health checks are defined)
echo "Checking container health..."
UNHEALTHY=$(docker-compose ps | grep -c "unhealthy" || true)
if [ "$UNHEALTHY" -gt 0 ]; then
    echo "WARNING: Some containers are unhealthy"
    docker-compose ps
fi

echo "SUCCESS: All Docker Compose services are running correctly"

# Cleanup
echo "Stopping services..."
docker-compose down

echo "Test completed successfully"