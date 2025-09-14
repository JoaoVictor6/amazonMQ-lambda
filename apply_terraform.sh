#!/bin/bash

set -e

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

echo "Terraform applied successfully."
