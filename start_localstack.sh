#!/bin/bash

set -e

echo "Starting LocalStack..."
docker compose up -d

echo "Waiting for LocalStack SQS to be ready..."
for i in $(seq 1 20); do
    if aws --endpoint-url=http://localhost:4566 sqs list-queues > /dev/null 2>&1; then
        echo "LocalStack SQS is ready."
        break
    else
        echo "LocalStack SQS not ready yet. Retrying in 5 seconds..."
        sleep 5
    fi
    if [ $i -eq 20 ]; then
        echo "LocalStack SQS did not become ready within the timeout. Exiting."
        exit 1
    fi
done

echo "LocalStack started and healthy."
