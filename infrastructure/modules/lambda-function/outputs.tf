# Lambda Function Module Outputs

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.function.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.function.qualified_arn
}

output "function_version" {
  description = "Latest published version of Lambda function"
  value       = aws_lambda_function.function.version
}

output "function_last_modified" {
  description = "Date Lambda function was last modified"
  value       = aws_lambda_function.function.last_modified
}

output "function_source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file"
  value       = aws_lambda_function.function.source_code_hash
}

output "function_source_code_size" {
  description = "Size in bytes of the function .zip file"
  value       = aws_lambda_function.function.source_code_size
}

output "execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for Lambda function"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for Lambda function"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

output "function_url" {
  description = "HTTP URL endpoint for Lambda function (if enabled)"
  value       = var.enable_function_url ? aws_lambda_function_url.function_url[0].function_url : null
}

output "function_url_creation_date" {
  description = "Creation date of the Lambda function URL"
  value       = var.enable_function_url ? aws_lambda_function_url.function_url[0].creation_time : null
}

output "alias_arn" {
  description = "ARN of the Lambda alias (if created)"
  value       = var.alias_name != null ? aws_lambda_alias.function_alias[0].arn : null
}

output "alias_invoke_arn" {
  description = "Invoke ARN of the Lambda alias (if created)"
  value       = var.alias_name != null ? aws_lambda_alias.function_alias[0].invoke_arn : null
}

output "layer_arn" {
  description = "ARN of the Lambda layer (if created)"
  value       = var.layer_config != null ? aws_lambda_layer_version.layer[0].arn : null
}

output "layer_version" {
  description = "Version of the Lambda layer (if created)"
  value       = var.layer_config != null ? aws_lambda_layer_version.layer[0].version : null
}

output "invoke_arn" {
  description = "Invoke ARN to be used with API Gateway"
  value       = aws_lambda_function.function.invoke_arn
}

# Outputs for monitoring and debugging
output "runtime" {
  description = "Runtime environment of the Lambda function"
  value       = aws_lambda_function.function.runtime
}

output "timeout" {
  description = "Timeout of the Lambda function in seconds"
  value       = aws_lambda_function.function.timeout
}

output "memory_size" {
  description = "Memory size of the Lambda function in MB"
  value       = aws_lambda_function.function.memory_size
}

output "handler" {
  description = "Handler of the Lambda function"
  value       = aws_lambda_function.function.handler
}

output "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for the Lambda function"
  value       = aws_lambda_function.function.reserved_concurrent_executions
}

# EventBridge schedule outputs (if configured)
output "schedule_rule_arn" {
  description = "ARN of the EventBridge rule for scheduled execution"
  value       = var.schedule_expression != null ? aws_cloudwatch_event_rule.schedule[0].arn : null
}

output "schedule_expression" {
  description = "Schedule expression for Lambda function"
  value       = var.schedule_expression
}