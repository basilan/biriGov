# Healthcare AI Governance Agent - Simplified Steel-Thread Infrastructure
# Direct AWS resources for Phase 1 deployment

terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# Local variables
locals {
  project_name = "healthcare-ai-governance"
  lambda_function_name = "${local.project_name}-claims-validator"
  s3_bucket_name       = "${local.project_name}-storage-${random_id.bucket_suffix.hex}"
  dynamodb_table_name  = "${local.project_name}-claims"
}

# Generate random suffix for globally unique resource names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Data sources for existing AWS resources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# DynamoDB table for claims metadata
resource "aws_dynamodb_table" "claims_table" {
  name           = local.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "claimId"

  attribute {
    name = "claimId"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = local.common_tags
}

# S3 bucket for document storage
resource "aws_s3_bucket" "storage_bucket" {
  bucket = local.s3_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "storage_versioning" {
  bucket = aws_s3_bucket.storage_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage_encryption" {
  bucket = aws_s3_bucket.storage_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "storage_lifecycle" {
  bucket = aws_s3_bucket.storage_bucket.id

  rule {
    id     = "demo_cleanup"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.auto_cleanup_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.auto_cleanup_days
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "storage_cors" {
  bucket = aws_s3_bucket.storage_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# IAM role for Lambda function - temporarily disabled, will use existing role
# resource "aws_iam_role" "lambda_execution_role" {
#   name = "${local.lambda_function_name}-execution-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
#
#   tags = local.common_tags
# }
#
# # IAM policy for Lambda function
# resource "aws_iam_role_policy" "lambda_policy" {
#   name = "${local.lambda_function_name}-policy"
#   role = aws_iam_role.lambda_execution_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "dynamodb:GetItem",
#           "dynamodb:PutItem",
#           "dynamodb:UpdateItem",
#           "dynamodb:Query",
#           "dynamodb:Scan"
#         ]
#         Resource = aws_dynamodb_table.claims_table.arn
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject"
#         ]
#         Resource = "${aws_s3_bucket.storage_bucket.arn}/*"
#       }
#     ]
#   })
# }

# Create basic Lambda execution role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.lambda_function_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create Lambda deployment package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../apps/api/src"
  output_path = "./lambda-deployment.zip"
  excludes    = ["**/__pycache__", "**/*.pyc", "**/tests"]
}

# Lambda function
resource "aws_lambda_function" "claims_validator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = local.lambda_function_name
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "handlers.claims_validator.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.11"
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.claims_table.name
      S3_BUCKET_NAME      = aws_s3_bucket.storage_bucket.id
      COST_BUDGET_LIMIT   = var.cost_budget_limit
      USE_MOCK_AI         = "true"
      LOG_LEVEL          = "INFO"
    }
  }

  tags = local.common_tags
}

# API Gateway
resource "aws_api_gateway_rest_api" "claims_api" {
  name        = "${local.project_name}-api"
  description = "Healthcare AI Governance API for claims validation"
  tags        = local.common_tags
}

resource "aws_api_gateway_resource" "claims_resource" {
  rest_api_id = aws_api_gateway_rest_api.claims_api.id
  parent_id   = aws_api_gateway_rest_api.claims_api.root_resource_id
  path_part   = "claims"
}

resource "aws_api_gateway_method" "claims_post" {
  rest_api_id   = aws_api_gateway_rest_api.claims_api.id
  resource_id   = aws_api_gateway_resource.claims_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.claims_api.id
  resource_id = aws_api_gateway_resource.claims_resource.id
  http_method = aws_api_gateway_method.claims_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.claims_validator.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.claims_validator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.claims_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "claims_deployment" {
  depends_on = [
    aws_api_gateway_method.claims_post,
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.claims_api.id
  stage_name  = var.api_stage_name
}

# Budget alert for cost control - temporarily disabled
# resource "aws_budgets_budget" "demo_cost_alert" {
#   name         = "${local.project_name}-demo-budget"
#   budget_type  = "COST"
#   limit_amount = var.cost_budget_limit
#   limit_unit   = "USD"
#   time_unit    = "DAILY"
#
#   cost_filter {
#     name = "Tag"
#     values = ["Project:${local.project_name}"]
#   }
#
#   notification {
#     comparison_operator        = "GREATER_THAN"
#     threshold                 = 80
#     threshold_type            = "PERCENTAGE"
#     notification_type         = "ACTUAL"
#     subscriber_email_addresses = [var.alert_email]
#   }
# }