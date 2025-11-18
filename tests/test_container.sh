#!/usr/bin/env bash
set -e

echo "Waiting for container startup..."
sleep 3

# Example: check if service is running on port 8080
if curl -fs http://localhost:8080/health; then
    echo "Container is running and passed health check."
else
    echo "Container failed health check."
    exit 1
fi

