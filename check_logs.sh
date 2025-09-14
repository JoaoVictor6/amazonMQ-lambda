#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export LOCALSTACK_HOST=localhost.localstack.cloud

echo "Checking logs for receptor-principal..."
aws --endpoint-url=http://localhost:4566 logs get-log-events --log-group-name /aws/lambda/receptor-principal --log-stream-name-prefix \$(aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/receptor-principal --query 'logStreams[0].logStreamName' --output text) --query 'events[0].message'

echo "Checking logs for receptor-obsoletos..."
aws --endpoint-url=http://localhost:4566 logs get-log-events --log-group-name /aws/lambda/receptor-obsoletos --log-stream-name-prefix \$(aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/receptor-obsoletos --query 'logStreams[0].logStreamName' --output text) --query 'events[0].message'

echo "Logs checked."
