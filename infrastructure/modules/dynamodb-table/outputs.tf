# DynamoDB Table Module Outputs

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.table.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.table.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.table.id
}

output "hash_key" {
  description = "Hash key of the DynamoDB table"
  value       = aws_dynamodb_table.table.hash_key
}

output "range_key" {
  description = "Range key of the DynamoDB table"
  value       = aws_dynamodb_table.table.range_key
}

output "billing_mode" {
  description = "Billing mode of the DynamoDB table"
  value       = aws_dynamodb_table.table.billing_mode
}

output "read_capacity" {
  description = "Read capacity of the DynamoDB table"
  value       = aws_dynamodb_table.table.read_capacity
}

output "write_capacity" {
  description = "Write capacity of the DynamoDB table"
  value       = aws_dynamodb_table.table.write_capacity
}

output "stream_arn" {
  description = "ARN of the DynamoDB table stream"
  value       = aws_dynamodb_table.table.stream_arn
}

output "stream_label" {
  description = "Label of the DynamoDB table stream"
  value       = aws_dynamodb_table.table.stream_label
}

output "stream_view_type" {
  description = "Stream view type of the DynamoDB table"
  value       = aws_dynamodb_table.table.stream_view_type
}

output "global_secondary_indexes" {
  description = "Global secondary indexes of the DynamoDB table"
  value = [
    for gsi in aws_dynamodb_table.table.global_secondary_index : {
      name               = gsi.name
      hash_key           = gsi.hash_key
      range_key          = gsi.range_key
      projection_type    = gsi.projection_type
      non_key_attributes = gsi.non_key_attributes
      read_capacity      = gsi.read_capacity
      write_capacity     = gsi.write_capacity
    }
  ]
}

output "local_secondary_indexes" {
  description = "Local secondary indexes of the DynamoDB table"
  value = [
    for lsi in aws_dynamodb_table.table.local_secondary_index : {
      name               = lsi.name
      range_key          = lsi.range_key
      projection_type    = lsi.projection_type
      non_key_attributes = lsi.non_key_attributes
    }
  ]
}

output "ttl_enabled" {
  description = "Whether TTL is enabled for the table"
  value       = var.ttl_enabled
}

output "ttl_attribute_name" {
  description = "TTL attribute name"
  value       = var.ttl_attribute_name
}

output "point_in_time_recovery_enabled" {
  description = "Whether point-in-time recovery is enabled"
  value       = aws_dynamodb_table.table.point_in_time_recovery[0].enabled
}

output "server_side_encryption" {
  description = "Server-side encryption configuration"
  value = length(aws_dynamodb_table.table.server_side_encryption) > 0 ? {
    enabled  = aws_dynamodb_table.table.server_side_encryption[0].enabled
    kms_key_id = aws_dynamodb_table.table.server_side_encryption[0].kms_key_id
  } : null
}

# Auto scaling outputs
output "read_autoscaling_target_arn" {
  description = "ARN of the read capacity auto scaling target"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? aws_appautoscaling_target.read_target[0].arn : null
}

output "write_autoscaling_target_arn" {
  description = "ARN of the write capacity auto scaling target"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? aws_appautoscaling_target.write_target[0].arn : null
}

output "read_autoscaling_policy_arn" {
  description = "ARN of the read capacity auto scaling policy"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? aws_appautoscaling_policy.read_policy[0].arn : null
}

output "write_autoscaling_policy_arn" {
  description = "ARN of the write capacity auto scaling policy"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? aws_appautoscaling_policy.write_policy[0].arn : null
}

# CloudWatch alarm outputs
output "read_throttled_alarm_arn" {
  description = "ARN of the read throttled requests CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.read_throttled_requests[0].arn : null
}

output "write_throttled_alarm_arn" {
  description = "ARN of the write throttled requests CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.write_throttled_requests[0].arn : null
}

# Additional metadata
output "table_created_datetime" {
  description = "Date and time when the table was created"
  value       = aws_dynamodb_table.table.id
}

output "deletion_protection_enabled" {
  description = "Whether deletion protection is enabled"
  value       = aws_dynamodb_table.table.deletion_protection_enabled
}

output "contributor_insights_status" {
  description = "Status of contributor insights"
  value       = var.enable_contributor_insights ? aws_dynamodb_contributor_insights.table_insights[0].id : null
}