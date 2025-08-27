# Healthcare AI Governance Agent - Terraform Outputs
# Output values for integration with application deployment

output "lambda_function_arn" {
  description = "ARN of the claims validator Lambda function"
  value       = module.claims_validator_lambda.function_arn
}

output "lambda_function_name" {
  description = "Name of the claims validator Lambda function"
  value       = module.claims_validator_lambda.function_name
}

output "lambda_function_url" {
  description = "Function URL for direct Lambda invocation (if enabled)"
  value       = module.claims_validator_lambda.function_url
  sensitive   = false
}

output "api_gateway_url" {
  description = "Base URL of the API Gateway for frontend integration"
  value       = module.api_gateway.api_gateway_url
}

output "api_gateway_stage_url" {
  description = "Full stage URL of the API Gateway"
  value       = module.api_gateway.stage_url
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = module.api_gateway.execution_arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting and document storage"
  value       = module.s3_storage.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_storage.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket for static website hosting"
  value       = module.s3_storage.bucket_domain_name
}

output "s3_bucket_website_endpoint" {
  description = "Website endpoint of the S3 bucket"
  value       = module.s3_storage.website_endpoint
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution for cache invalidation"
  value       = module.cloudfront_distribution.distribution_id
}

output "cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution for Route53 integration"
  value       = module.cloudfront_distribution.hosted_zone_id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for claims storage"
  value       = module.dynamodb_claims_table.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb_claims_table.table_arn
}

output "dynamodb_table_stream_arn" {
  description = "ARN of the DynamoDB table stream (if enabled)"
  value       = module.dynamodb_claims_table.stream_arn
}

# Cost monitoring outputs
output "budget_name" {
  description = "Name of the AWS Budget for cost monitoring"
  value       = aws_budgets_budget.demo_cost_alert.name
}

output "budget_limit" {
  description = "Budget limit amount in USD"
  value       = aws_budgets_budget.demo_cost_alert.limit_amount
}

# Environment configuration outputs
output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name for this deployment"
  value       = var.environment
}

# Integration endpoints for frontend configuration
output "frontend_config" {
  description = "Configuration object for frontend integration"
  value = {
    api_base_url    = module.api_gateway.api_gateway_url
    cloudfront_url  = "https://${module.cloudfront_distribution.domain_name}"
    aws_region      = var.aws_region
    environment     = var.environment
  }
  sensitive = false
}

# Deployment validation outputs
output "deployment_info" {
  description = "Deployment information for validation and troubleshooting"
  value = {
    deployed_at     = timestamp()
    terraform_version = "1.5.7"
    aws_region      = var.aws_region
    environment     = var.environment
    auto_cleanup_at = local.cleanup_timestamp
    cost_budget     = var.cost_budget_limit
  }
  sensitive = false
}