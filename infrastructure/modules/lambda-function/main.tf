# Lambda Function Module
# Reusable module for AWS Lambda functions with IAM and deployment configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# Package Lambda function source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/lambda_function.zip"
  excludes    = var.exclude_files
}

# Lambda execution role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.function_name}-execution-role"

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

  tags = var.tags
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Custom IAM policy for additional permissions
resource "aws_iam_role_policy" "lambda_custom_policy" {
  count = length(var.policy_statements) > 0 ? 1 : 0
  name  = "${var.function_name}-custom-policy"
  role  = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.policy_statements
  })
}

# Lambda function
resource "aws_lambda_function" "function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = var.handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size
  description     = var.description

  # Environment variables
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # VPC configuration (optional)
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Dead letter queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  # Tracing configuration
  tracing_config {
    mode = var.tracing_mode
  }

  # Reserved concurrency
  reserved_concurrent_executions = var.reserved_concurrency

  tags = merge(var.tags, {
    LastUpdated = timestamp()
  })

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_custom_policy
  ]
}

# CloudWatch Log Group with retention
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  
  tags = var.tags
}

# Lambda function URL (optional)
resource "aws_lambda_function_url" "function_url" {
  count              = var.enable_function_url ? 1 : 0
  function_name      = aws_lambda_function.function.function_name
  authorization_type = var.function_url_auth_type

  dynamic "cors" {
    for_each = var.function_url_cors != null ? [var.function_url_cors] : []
    content {
      allow_credentials = cors.value.allow_credentials
      allow_headers    = cors.value.allow_headers
      allow_methods    = cors.value.allow_methods
      allow_origins    = cors.value.allow_origins
      expose_headers   = cors.value.expose_headers
      max_age         = cors.value.max_age
    }
  }
}

# Lambda alias (optional)
resource "aws_lambda_alias" "function_alias" {
  count            = var.alias_name != null ? 1 : 0
  name             = var.alias_name
  description      = "Alias for ${var.function_name}"
  function_name    = aws_lambda_function.function.function_name
  function_version = var.alias_function_version
}

# Lambda layer (optional)
resource "aws_lambda_layer_version" "layer" {
  count               = var.layer_config != null ? 1 : 0
  filename            = var.layer_config.filename
  layer_name          = var.layer_config.layer_name
  description         = var.layer_config.description
  compatible_runtimes = var.layer_config.compatible_runtimes
  source_code_hash    = var.layer_config.source_code_hash
}

# EventBridge rule for scheduled execution (optional)
resource "aws_cloudwatch_event_rule" "schedule" {
  count               = var.schedule_expression != null ? 1 : 0
  name                = "${var.function_name}-schedule"
  description         = "Schedule for ${var.function_name}"
  schedule_expression = var.schedule_expression
  
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = var.schedule_expression != null ? 1 : 0
  rule      = aws_cloudwatch_event_rule.schedule[0].name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.function.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.schedule_expression != null ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}