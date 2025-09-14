#!/bin/bash

set -e

./start_localstack.sh
./apply_terraform.sh
./invoke_lambda.sh
./check_logs.sh
./destroy_terraform.sh
./stop_localstack.sh

echo "All tasks completed."
