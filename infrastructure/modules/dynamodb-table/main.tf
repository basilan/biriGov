# DynamoDB Table Module
# Reusable module for AWS DynamoDB tables with configurable indexes and features

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# DynamoDB table
resource "aws_dynamodb_table" "table" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key

  # Provisioned throughput (only used when billing_mode = "PROVISIONED")
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Attributes definition
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Hash key attribute (always required)
  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  # Range key attribute (if specified)
  dynamic "attribute" {
    for_each = var.range_key != null ? [1] : []
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  # Global secondary indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name     = global_secondary_index.value.name
      hash_key = global_secondary_index.value.hash_key
      range_key = lookup(global_secondary_index.value, "range_key", null)
      
      projection_type   = lookup(global_secondary_index.value, "projection_type", "ALL")
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      
      read_capacity  = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", 5) : null
      write_capacity = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", 5) : null
    }
  }

  # Local secondary indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name      = local_secondary_index.value.name
      range_key = local_secondary_index.value.range_key
      
      projection_type   = lookup(local_secondary_index.value, "projection_type", "ALL")
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  # Time To Live configuration
  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      attribute_name = var.ttl_attribute_name
      enabled       = var.ttl_enabled
    }
  }

  # Server-side encryption
  dynamic "server_side_encryption" {
    for_each = var.encryption_enabled ? [1] : []
    content {
      enabled     = var.encryption_enabled
      kms_key_id  = var.kms_key_id
    }
  }

  # DynamoDB Streams
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # Deletion protection
  deletion_protection_enabled = var.deletion_protection_enabled

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to read/write capacity when using autoscaling
      read_capacity,
      write_capacity,
    ]
  }
}

# Auto scaling for read capacity (if enabled)
resource "aws_appautoscaling_target" "read_target" {
  count              = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.autoscaling_read_max_capacity
  min_capacity       = var.autoscaling_read_min_capacity
  resource_id        = "table/${aws_dynamodb_table.table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"

  tags = var.tags
}

resource "aws_appautoscaling_policy" "read_policy" {
  count              = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "${var.table_name}-read-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.autoscaling_read_target_value
  }
}

# Auto scaling for write capacity (if enabled)
resource "aws_appautoscaling_target" "write_target" {
  count              = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.autoscaling_write_max_capacity
  min_capacity       = var.autoscaling_write_min_capacity
  resource_id        = "table/${aws_dynamodb_table.table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"

  tags = var.tags
}

resource "aws_appautoscaling_policy" "write_policy" {
  count              = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "${var.table_name}-write-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.autoscaling_write_target_value
  }
}

# CloudWatch alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "read_throttled_requests" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.table_name}-read-throttled-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UserErrorsReadThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "DynamoDB read requests are being throttled"
  alarm_actions       = var.alarm_actions

  dimensions = {
    TableName = aws_dynamodb_table.table.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "write_throttled_requests" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.table_name}-write-throttled-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UserErrorsWriteThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "DynamoDB write requests are being throttled"
  alarm_actions       = var.alarm_actions

  dimensions = {
    TableName = aws_dynamodb_table.table.name
  }

  tags = var.tags
}

# Contributor insights (optional)
resource "aws_dynamodb_contributor_insights" "table_insights" {
  count      = var.enable_contributor_insights ? 1 : 0
  table_name = aws_dynamodb_table.table.name

  tags = var.tags
}

# DynamoDB table item for initialization (optional)
resource "aws_dynamodb_table_item" "init_items" {
  count      = length(var.initial_items)
  table_name = aws_dynamodb_table.table.name
  hash_key   = aws_dynamodb_table.table.hash_key
  range_key  = aws_dynamodb_table.table.range_key
  item       = var.initial_items[count.index]

  depends_on = [aws_dynamodb_table.table]
}