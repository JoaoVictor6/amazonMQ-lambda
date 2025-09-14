#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export LOCALSTACK_HOST=localhost.localstack.cloud

echo "Invoking emissor Lambda function..."
aws --endpoint-url=http://localhost:4566 lambda invoke --function-name emissor --payload '{}' response.json

echo "Emissor Lambda invoked."
