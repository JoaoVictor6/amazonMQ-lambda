#!/bin/bash

exec > >(tee test.sh.log) 2>&1

set -e

echo "Starting LocalStack..."
docker compose up -d

echo "Waiting for LocalStack to be ready..."
sleep 30

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export LOCALSTACK_HOST=localhost.localstack.cloud

echo "Initializing Terraform..."
cd terraform
terraform init

echo "Applying Terraform changes..."
terraform apply -auto-approve

cd ..

echo "Invoking emissor Lambda function..."
aws --endpoint-url=http://localhost:4566 lambda invoke --function-name emissor --payload '{}' response.json

echo "Checking logs..."
aws --endpoint-url=http://localhost:4566 logs get-log-events --log-group-name /aws/lambda/receptor-principal --log-stream-name-prefix \$(aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/receptor-principal --query 'logStreams[0].logStreamName' --output text) --query 'events[0].message'
aws --endpoint-url=http://localhost:4566 logs get-log-events --log-group-name /aws/lambda/receptor-obsoletos --log-stream-name-prefix \$(aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/receptor-obsoletos --query 'logStreams[0].logStreamName' --output text) --query 'events[0].message'

echo "Destroying Terraform resources..."
cd terraform
terraform destroy -auto-approve

cd ..

echo "Stopping LocalStack..."
docker compose down
