#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export LOCALSTACK_HOST=localhost.localstack.cloud

echo "Destroying Terraform resources..."
cd terraform
terraform destroy -auto-approve

cd ..

echo "Terraform resources destroyed."
