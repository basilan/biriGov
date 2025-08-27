# API Gateway Module Outputs

output "api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_name" {
  description = "Name of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api.name
}

output "api_arn" {
  description = "ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api.arn
}

output "api_root_resource_id" {
  description = "Resource ID of the API Gateway root resource"
  value       = aws_api_gateway_rest_api.api.root_resource_id
}

output "api_created_date" {
  description = "Creation date of the API Gateway"
  value       = aws_api_gateway_rest_api.api.created_date
}

output "api_execution_arn" {
  description = "Execution ARN part to be used in Lambda permissions"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.deployment.id
}

output "deployment_created_date" {
  description = "Creation date of the API Gateway deployment"
  value       = aws_api_gateway_deployment.deployment.created_date
}

output "deployment_description" {
  description = "Description of the API Gateway deployment"
  value       = aws_api_gateway_deployment.deployment.description
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.stage_name
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.arn
}

output "stage_deployment_id" {
  description = "Deployment ID of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.deployment_id
}

output "invoke_url" {
  description = "Invoke URL of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "stage_url" {
  description = "URL of the API Gateway stage (alias for invoke_url)"
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "api_gateway_url" {
  description = "Base URL of the API Gateway (alias for invoke_url)"
  value       = aws_api_gateway_stage.stage.invoke_url
}

# Resource and method outputs
output "proxy_resource_id" {
  description = "ID of the proxy resource"
  value       = aws_api_gateway_resource.proxy.id
}

output "proxy_resource_path" {
  description = "Path of the proxy resource"
  value       = aws_api_gateway_resource.proxy.path
}

output "proxy_resource_path_part" {
  description = "Path part of the proxy resource"
  value       = aws_api_gateway_resource.proxy.path_part
}

# Lambda integration outputs
output "lambda_integration_uri" {
  description = "URI of the Lambda integration"
  value       = aws_api_gateway_integration.lambda_integration.uri
}

output "lambda_function_arn" {
  description = "ARN of the integrated Lambda function"
  value       = var.lambda_function_arn
}

output "lambda_function_name" {
  description = "Name of the integrated Lambda function"
  value       = var.lambda_function_name
}

# CORS configuration outputs
output "cors_enabled" {
  description = "Whether CORS is enabled for the API"
  value       = var.cors_configuration != null
}

output "cors_configuration" {
  description = "CORS configuration for the API"
  value       = var.cors_configuration
  sensitive   = false
}

# Access logging outputs
output "access_log_group_name" {
  description = "Name of the CloudWatch log group for access logs"
  value       = var.access_log_destination_arn != null ? aws_cloudwatch_log_group.api_gateway_logs[0].name : null
}

output "access_log_group_arn" {
  description = "ARN of the CloudWatch log group for access logs"
  value       = var.access_log_destination_arn != null ? aws_cloudwatch_log_group.api_gateway_logs[0].arn : null
}

output "access_log_destination_arn" {
  description = "Destination ARN for access logs"
  value       = var.access_log_destination_arn
}

output "xray_tracing_enabled" {
  description = "Whether X-Ray tracing is enabled"
  value       = aws_api_gateway_stage.stage.xray_tracing_enabled
}

# Cache configuration outputs
output "cache_cluster_enabled" {
  description = "Whether cache cluster is enabled"
  value       = aws_api_gateway_stage.stage.cache_cluster_enabled
}

output "cache_cluster_size" {
  description = "Size of the cache cluster"
  value       = aws_api_gateway_stage.stage.cache_cluster_size
}

# Authorizer outputs
output "authorizer_id" {
  description = "ID of the API Gateway authorizer"
  value       = var.authorizer_configuration != null ? aws_api_gateway_authorizer.authorizer[0].id : null
}

output "authorizer_name" {
  description = "Name of the API Gateway authorizer"
  value       = var.authorizer_configuration != null ? aws_api_gateway_authorizer.authorizer[0].name : null
}

# API Key outputs
output "api_key_id" {
  description = "ID of the API key"
  value       = var.create_api_key ? aws_api_gateway_api_key.api_key[0].id : null
}

output "api_key_value" {
  description = "Value of the API key"
  value       = var.create_api_key ? aws_api_gateway_api_key.api_key[0].value : null
  sensitive   = true
}

output "api_key_name" {
  description = "Name of the API key"
  value       = var.create_api_key ? aws_api_gateway_api_key.api_key[0].name : null
}

# Usage Plan outputs
output "usage_plan_id" {
  description = "ID of the usage plan"
  value       = var.usage_plan_configuration != null ? aws_api_gateway_usage_plan.usage_plan[0].id : null
}

output "usage_plan_name" {
  description = "Name of the usage plan"
  value       = var.usage_plan_configuration != null ? aws_api_gateway_usage_plan.usage_plan[0].name : null
}

output "usage_plan_arn" {
  description = "ARN of the usage plan"
  value       = var.usage_plan_configuration != null ? aws_api_gateway_usage_plan.usage_plan[0].arn : null
}

# Stage configuration outputs
output "stage_variables" {
  description = "Stage variables for the deployment stage"
  value       = aws_api_gateway_stage.stage.variables
  sensitive   = true
}

output "client_certificate_id" {
  description = "Client certificate ID for the stage"
  value       = aws_api_gateway_stage.stage.client_certificate_id
}

output "documentation_version" {
  description = "Documentation version for the stage"
  value       = aws_api_gateway_stage.stage.documentation_version
}

# Integration configuration outputs
output "integration_timeout_milliseconds" {
  description = "Integration timeout in milliseconds"
  value       = var.integration_timeout_milliseconds
}

output "binary_media_types" {
  description = "Binary media types supported by the API"
  value       = aws_api_gateway_rest_api.api.binary_media_types
}

output "minimum_compression_size" {
  description = "Minimum compression size for the API"
  value       = aws_api_gateway_rest_api.api.minimum_compression_size
}

# API Gateway policy outputs
output "api_policy_json" {
  description = "API policy JSON"
  value       = var.api_policy_json
  sensitive   = true
}

output "endpoint_configuration" {
  description = "Endpoint configuration for the API"
  value       = aws_api_gateway_rest_api.api.endpoint_configuration
}