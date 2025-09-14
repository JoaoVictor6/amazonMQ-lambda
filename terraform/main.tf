terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  
  endpoints {
    apigateway       = "http://localhost:4566"
    cloudformation   = "http://localhost:4566"
    cloudwatch       = "http://localhost:4566"
    dynamodb         = "http://localhost:4566"
    ec2              = "http://localhost:4566"
    es               = "http://localhost:4566"
    firehose         = "http://localhost:4566"
    iam              = "http://localhost:4566"
    kinesis          = "http://localhost:4566"
    lambda           = "http://localhost:4566"
    rds              = "http://localhost:4566"
    redshift         = "http://localhost:4566"
    route53          = "http://localhost:4566"
    
    mq               = "http://localhost:4566"
    secretsmanager   = "http://localhost:4566"
    ses              = "http://localhost:4566"
    sns              = "http://localhost:4566"
    sqs              = "http://localhost:4566"
    ssm              = "http://localhost:4566"
    stepfunctions    = "http://localhost:4566"
    sts              = "http://localhost:4566"
  }
}

resource "aws_mq_broker" "amazon_mq" {
  broker_name        = "poc-amazon-mq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.15.0"
  host_instance_type = "mq.t2.micro"
  user {
    username = "admin"
    password = "supersecretpassword"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "A policy for the Lambda functions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "mq:SendMessage"
        ]
        Effect   = "Allow"
        Resource = aws_mq_broker.amazon_mq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "emissor" {
  function_name = "emissor"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  filename      = "../lambdas/emissor.zip"
  source_code_hash = filebase64sha256("../lambdas/emissor.zip")
}

resource "aws_lambda_function" "receptor_principal" {
  function_name = "receptor-principal"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  filename      = "../lambdas/receptor-principal.zip"
  source_code_hash = filebase64sha256("../lambdas/receptor-principal.zip")
}

resource "aws_lambda_function" "receptor_obsoletos" {
  function_name = "receptor-obsoletos"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  filename      = "../lambdas/receptor-obsoletos.zip"
  source_code_hash = filebase64sha256("../lambdas/receptor-obsoletos.zip")
}

resource "aws_cloudwatch_event_rule" "edicao_de_proposta_rule" {
  name        = "edicao-de-proposta-rule"
  description = "Rule to capture edicao-de-proposta events"
  event_pattern = jsonencode({
    "source" : ["aws.mq"],
    "detail-type" : ["MQ Broker Message"],
    "detail" : {
      "destination" : ["edicao-de-proposta"]
    }
  })
}

resource "aws_cloudwatch_event_target" "receptor_principal_target" {
  rule      = aws_cloudwatch_event_rule.edicao_de_proposta_rule.name
  target_id = "receptor-principal"
  arn       = aws_lambda_function.receptor_principal.arn
}

resource "aws_cloudwatch_event_rule" "edicao_de_proposta_obsoletos_rule" {
  name        = "edicao-de-proposta-obsoletos-rule"
  description = "Rule to capture edicao-de-proposta with isObsoleto = true"
  event_pattern = jsonencode({
    "source" : ["aws.mq"],
    "detail-type" : ["MQ Broker Message"],
    "detail" : {
      "destination" : ["edicao-de-proposta"],
      "body" : {
        "isObsoleto" : [true]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "receptor_obsoletos_target" {
  rule      = aws_cloudwatch_event_rule.edicao_de_proposta_obsoletos_rule.name
  target_id = "receptor-obsoletos"
  arn       = aws_lambda_function.receptor_obsoletos.arn
}