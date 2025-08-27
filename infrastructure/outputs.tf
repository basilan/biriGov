# Healthcare AI Governance Agent - Terraform Outputs
# Infrastructure endpoints and identifiers for frontend integration

# Lambda Function Outputs
output "lambda_function_arn" {
  description = "ARN of the claims validation Lambda function"
  value       = aws_lambda_function.claims_validator.arn
}

output "lambda_function_name" {
  description = "Name of the claims validation Lambda function"
  value       = aws_lambda_function.claims_validator.function_name
}

# API Gateway Outputs
output "api_gateway_url" {
  description = "Base URL of the API Gateway"
  value       = aws_api_gateway_rest_api.claims_api.execution_arn
}

output "api_gateway_stage_url" {
  description = "Deployed stage URL for API Gateway"
  value       = "https://${aws_api_gateway_rest_api.claims_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_deployment.claims_deployment.stage_name}"
}

output "api_gateway_execution_arn" {
  description = "Execution ARN for API Gateway"
  value       = aws_api_gateway_rest_api.claims_api.execution_arn
}

# S3 Bucket Outputs
output "s3_bucket_name" {
  description = "Name of the S3 storage bucket"
  value       = aws_s3_bucket.storage_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 storage bucket"
  value       = aws_s3_bucket.storage_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.storage_bucket.bucket_domain_name
}

# DynamoDB Table Outputs
output "dynamodb_table_name" {
  description = "Name of the DynamoDB claims table"
  value       = aws_dynamodb_table.claims_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB claims table"
  value       = aws_dynamodb_table.claims_table.arn
}

# Cost monitoring outputs - temporarily disabled
# output "budget_name" {
#   description = "Name of the AWS Budget for cost monitoring"
#   value       = aws_budgets_budget.demo_cost_alert.name
# }

# output "budget_limit" {
#   description = "Budget limit amount in USD"
#   value       = aws_budgets_budget.demo_cost_alert.limit_amount
# }

# Environment configuration outputs
output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name for this deployment"
  value       = var.environment
}

# Frontend Configuration Output
output "frontend_config" {
  description = "Configuration values for frontend deployment"
  value = {
    api_base_url    = "https://${aws_api_gateway_rest_api.claims_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_deployment.claims_deployment.stage_name}"
    aws_region      = data.aws_region.current.name
    bucket_name     = aws_s3_bucket.storage_bucket.id
    environment     = var.environment
    cost_limit      = var.cost_budget_limit
  }
}

# Deployment Information
output "deployment_info" {
  description = "Key deployment information"
  value = {
    project_name     = local.project_name
    aws_region       = data.aws_region.current.name
    aws_account_id   = data.aws_caller_identity.current.account_id
    deployment_time  = timestamp()
    cleanup_days     = var.auto_cleanup_days
    environment      = var.environment
  }
}