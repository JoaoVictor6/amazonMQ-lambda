#!/bin/bash

exec > >(tee test.sh.log) 2>&1

set -e

echo "Starting LocalStack..."
docker compose up -d

echo "Waiting for LocalStack to be ready..."
sleep 60

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
