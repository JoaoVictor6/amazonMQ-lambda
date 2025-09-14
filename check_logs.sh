#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export LOCALSTACK_HOST=localhost.localstack.cloud

echo "Checking logs for receptor-principal..."
echo "Describing log streams for receptor-principal..."
aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/receptor-principal --output json
LOG_STREAM_NAME_PRINCIPAL=$(aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/receptor-principal --query 'logStreams[0].logStreamName' --output text)
echo "Log Stream Name (Principal): $LOG_STREAM_NAME_PRINCIPAL"
aws --endpoint-url=http://localhost:4566 logs get-log-events --log-group-name /aws/lambda/receptor-principal --log-stream-name "$LOG_STREAM_NAME_PRINCIPAL" --query 'events[0].message'

echo "Checking logs for receptor-obsoletos..."
echo "Describing log streams for receptor-obsoletos..."
aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/receptor-obsoletos --output json
LOG_STREAM_NAME_OBSOLETOS=$(aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/receptor-obsoletos --query 'logStreams[0].logStreamName' --output text)
echo "Log Stream Name (Obsoletos): $LOG_STREAM_NAME_OBSOLETOS"
aws --endpoint-url=http://localhost:4566 logs get-log-events --log-group-name /aws/lambda/receptor-obsoletos --log-stream-name "$LOG_STREAM_NAME_OBSOLETOS" --query 'events[0].message'

echo "Logs checked."
