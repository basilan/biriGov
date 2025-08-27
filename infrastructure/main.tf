# Healthcare AI Governance Agent - Main Infrastructure
# Implements steel-thread foundation with complete lifecycle management

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

# Local variables for resource tagging and configuration
locals {
  project_name = "healthcare-ai-governance"
  environment  = "demo"
  
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "terraform"
    Owner       = "healthcare-ai-demo"
    CostCenter  = "demonstration"
    AutoCleanup = "true"
    CreatedBy   = "healthcare-ai-governance-agent"
  }
  
  # Resource names with consistent naming convention
  lambda_function_name = "${local.project_name}-claims-validator"
  api_gateway_name     = "${local.project_name}-api"
  s3_bucket_name       = "${local.project_name}-storage-${random_id.bucket_suffix.hex}"
  dynamodb_table_name  = "${local.project_name}-claims"
  cloudfront_origin_id = "${local.project_name}-frontend"
}

# Generate random suffix for globally unique resource names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Data sources for existing AWS resources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Lambda function for claims validation
module "claims_validator_lambda" {
  source = "./modules/lambda-function"
  
  function_name = local.lambda_function_name
  description   = "Healthcare claims validation using AI"
  runtime       = "python3.11"
  handler       = "handlers.claims_validator.lambda_handler"
  timeout       = 300
  memory_size   = 1024
  
  # Source code configuration
  source_path = "../apps/api/src"
  
  # Environment variables
  environment_variables = {
    DYNAMODB_TABLE_NAME = module.dynamodb_claims_table.table_name
    S3_BUCKET_NAME      = module.s3_storage.bucket_name
    COST_BUDGET_LIMIT   = var.cost_budget_limit
    LOG_LEVEL          = "INFO"
  }
  
  # IAM permissions
  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      resources = [module.dynamodb_claims_table.table_arn]
    },
    {
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      resources = ["${module.s3_storage.bucket_arn}/*"]
    },
    {
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  ]
  
  tags = local.common_tags
}

# DynamoDB table for claims metadata
module "dynamodb_claims_table" {
  source = "./modules/dynamodb-table"
  
  table_name = local.dynamodb_table_name
  
  # Hash key for claim lookup
  hash_key = "claimId"
  hash_key_type = "S"
  
  # Global secondary index for status-based queries
  global_secondary_indexes = [
    {
      name            = "StatusIndex"
      hash_key        = "status"
      projection_type = "ALL"
    }
  ]
  
  # Auto-cleanup configuration
  ttl_attribute_name = "expiresAt"
  ttl_enabled       = true
  
  # Point-in-time recovery for audit requirements
  point_in_time_recovery_enabled = true
  
  tags = local.common_tags
}

# S3 bucket for document storage and frontend hosting
module "s3_storage" {
  source = "./modules/s3-bucket"
  
  bucket_name = local.s3_bucket_name
  
  # Enable versioning for audit trail
  versioning_enabled = true
  
  # Lifecycle rules for cost control
  lifecycle_rules = [
    {
      id     = "demo_cleanup"
      status = "Enabled"
      
      expiration = [
        {
          days = 1  # Auto-delete after 1 day for demo cost control
        }
      ]
      
      noncurrent_version_expiration = [
        {
          noncurrent_days = 1
        }
      ]
    }
  ]
  
  # CORS configuration for frontend access
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
      allowed_origins = ["*"]  # Restrict in production
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
  
  # Static website hosting for React frontend
  website_configuration = {
    index_document = "index.html"
    error_document = "error.html"
  }
  
  tags = local.common_tags
}

# API Gateway for Lambda integration
module "api_gateway" {
  source = "./modules/api-gateway"
  
  api_name        = local.api_gateway_name
  api_description = "Healthcare AI Governance API for claims validation"
  
  # Lambda integration
  lambda_function_arn  = module.claims_validator_lambda.function_arn
  lambda_function_name = module.claims_validator_lambda.function_name
  
  # CORS configuration
  cors_configuration = {
    allow_credentials = false
    allow_headers    = ["content-type", "x-amz-date", "authorization", "x-api-key"]
    allow_methods    = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins    = ["*"]  # Restrict in production
    expose_headers   = []
    max_age         = 86400
  }
  
  # Stage configuration
  stage_name = "demo"
  
  tags = local.common_tags
}

# CloudFront distribution for global content delivery
module "cloudfront_distribution" {
  source = "./modules/cloudfront-distribution"
  
  origin_id = local.cloudfront_origin_id
  
  # S3 origin for frontend static files
  s3_origin_domain_name = module.s3_storage.bucket_domain_name
  s3_origin_access_control_id = module.s3_storage.origin_access_control_id
  
  # Default cache behavior
  default_cache_behavior = {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.cloudfront_origin_id
    compress              = true
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
    }
  }
  
  # Geographic restrictions (none for demo)
  geo_restriction = {
    restriction_type = "none"
  }
  
  # Custom error pages
  custom_error_responses = [
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 0
    }
  ]
  
  tags = local.common_tags
}

# CloudWatch budget alert for cost control
resource "aws_budgets_budget" "demo_cost_alert" {
  name         = "${local.project_name}-demo-budget"
  budget_type  = "COST"
  limit_amount = var.cost_budget_limit
  limit_unit   = "USD"
  time_unit    = "DAILY"
  
  cost_filters = {
    Tag = ["Project:${local.project_name}"]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 45
    threshold_type            = "ABSOLUTE_VALUE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}