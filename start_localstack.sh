#!/bin/bash

set -e

echo "Starting LocalStack..."
docker compose up -d

echo "Waiting for LocalStack to be healthy..."
for i in $(seq 1 10); do
    HEALTH_OUTPUT=$(curl -s http://localhost:4566/health)
    if echo "$HEALTH_OUTPUT" | grep -q '"status": "running"'; then
        echo "LocalStack is healthy."
        break
    else
        echo "LocalStack not healthy yet. Retrying in 5 seconds..."
        sleep 5
    fi
    if [ $i -eq 10 ]; then
        echo "LocalStack did not become healthy within the timeout. Exiting."
        echo "Last LocalStack Health Output: $HEALTH_OUTPUT"
        exit 1
    fi
done

echo "LocalStack started and healthy."
