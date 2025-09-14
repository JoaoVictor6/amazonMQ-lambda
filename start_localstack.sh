#!/bin/bash

set -e

echo "Starting LocalStack..."
docker compose up -d

echo "Waiting for LocalStack services (Lambda, EventBridge, MQ) to be ready..."
for i in $(seq 1 20); do
    LAMBDA_READY=$(aws --endpoint-url=http://localhost:4566 lambda list-functions > /dev/null 2>&1; echo $?)
    EVENTS_READY=$(aws --endpoint-url=http://localhost:4566 events list-rules > /dev/null 2>&1; echo $?)
    MQ_READY=$(aws --endpoint-url=http://localhost:4566 mq list-brokers > /dev/null 2>&1; echo $?)

    if [ $LAMBDA_READY -eq 0 ] && [ $EVENTS_READY -eq 0 ] && [ $MQ_READY -eq 0 ]; then
        echo "LocalStack services are ready."
        break
    else
        echo "LocalStack services not ready yet. Retrying in 5 seconds..."
        sleep 5
    fi
    if [ $i -eq 20 ]; then
        echo "LocalStack services did not become ready within the timeout. Exiting."
        exit 1
    fi
done

echo "LocalStack started and healthy."
