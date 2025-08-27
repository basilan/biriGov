# API Gateway Module
# Reusable module for AWS API Gateway with Lambda integration, CORS, and deployment

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = var.endpoint_types
  }

  # Binary media types for file upload support
  binary_media_types = var.binary_media_types

  # Minimum compression size
  minimum_compression_size = var.minimum_compression_size

  # API key source
  api_key_source = var.api_key_source

  # Policy document
  policy = var.api_policy_json

  tags = var.tags
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
  
  description = "Deployment for ${var.api_name} at ${timestamp()}"

  # Create new deployment when API configuration changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.api.body,
      aws_api_gateway_method.proxy_method,
      aws_api_gateway_method.options_method,
      aws_api_gateway_integration.lambda_integration,
      aws_api_gateway_integration.options_integration,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.proxy_method,
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method.options_method,
    aws_api_gateway_integration.options_integration,
  ]
}

# API Gateway stage
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name

  # Access logging
  dynamic "access_log_settings" {
    for_each = var.access_log_destination_arn != null ? [1] : []
    content {
      destination_arn = var.access_log_destination_arn
      format         = var.access_log_format
    }
  }

  # X-Ray tracing
  xray_tracing_enabled = var.xray_tracing_enabled

  # Cache settings
  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_size

  # Client certificate
  client_certificate_id = var.client_certificate_id

  # Documentation version
  documentation_version = var.documentation_version

  # Variables for stage
  variables = var.stage_variables

  tags = var.tags
}

# API Gateway resource for proxy integration
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

# API Gateway method for proxy (ANY method)
resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = var.authorization_type

  # Authorization scopes (for JWT authorizers)
  authorization_scopes = var.authorization_scopes

  # Authorizer ID
  authorizer_id = var.authorizer_id

  # API key required
  api_key_required = var.api_key_required

  # Operation name
  operation_name = "ProxyMethod"

  # Request validator
  request_validator_id = var.request_validator_id

  # Request parameters
  request_parameters = var.request_parameters

  # Request models
  request_models = var.request_models
}

# API Gateway method for OPTIONS (CORS preflight)
resource "aws_api_gateway_method" "options_method" {
  count = var.cors_configuration != null ? 1 : 0
  
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Lambda integration for proxy method
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"

  # Timeout
  timeout_milliseconds = var.integration_timeout_milliseconds

  # Content handling
  content_handling = var.content_handling

  # Request templates
  request_templates = var.request_templates

  # Cache configuration
  cache_key_parameters = var.cache_key_parameters
  cache_namespace     = var.cache_namespace
}

# Mock integration for OPTIONS method (CORS)
resource "aws_api_gateway_integration" "options_integration" {
  count = var.cors_configuration != null ? 1 : 0
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_method[0].http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Method response for proxy method
resource "aws_api_gateway_method_response" "proxy_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = "200"

  # CORS headers
  response_parameters = var.cors_configuration != null ? {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  } : {}

  response_models = {
    "application/json" = "Empty"
  }
}

# Method response for OPTIONS method
resource "aws_api_gateway_method_response" "options_response" {
  count = var.cors_configuration != null ? 1 : 0
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_method[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration response for proxy method
resource "aws_api_gateway_integration_response" "proxy_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = aws_api_gateway_method_response.proxy_response.status_code

  # CORS headers
  response_parameters = var.cors_configuration != null ? {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  } : {}

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

# Integration response for OPTIONS method
resource "aws_api_gateway_integration_response" "options_integration_response" {
  count = var.cors_configuration != null ? 1 : 0
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_method[0].http_method
  status_code = aws_api_gateway_method_response.options_response[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = format("'%s'", join(",", var.cors_configuration.allow_headers))
    "method.response.header.Access-Control-Allow-Methods" = format("'%s'", join(",", var.cors_configuration.allow_methods))
    "method.response.header.Access-Control-Allow-Origin"  = format("'%s'", join(",", var.cors_configuration.allow_origins))
  }

  depends_on = [aws_api_gateway_integration.options_integration]
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# CloudWatch log group for API Gateway access logs
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  count             = var.access_log_destination_arn != null ? 1 : 0
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.log_retention_days
  
  tags = var.tags
}

# API Gateway authorizer (optional)
resource "aws_api_gateway_authorizer" "authorizer" {
  count = var.authorizer_configuration != null ? 1 : 0
  
  name                   = var.authorizer_configuration.name
  rest_api_id           = aws_api_gateway_rest_api.api.id
  type                  = var.authorizer_configuration.type
  authorizer_uri        = var.authorizer_configuration.authorizer_uri
  authorizer_credentials = var.authorizer_configuration.authorizer_credentials
  
  # For JWT authorizers
  identity_source                = var.authorizer_configuration.identity_source
  identity_validation_expression = var.authorizer_configuration.identity_validation_expression
  authorizer_result_ttl_in_seconds = var.authorizer_configuration.authorizer_result_ttl_in_seconds
}

# API Gateway API key (optional)
resource "aws_api_gateway_api_key" "api_key" {
  count = var.create_api_key ? 1 : 0
  
  name        = "${var.api_name}-api-key"
  description = "API key for ${var.api_name}"
  enabled     = true
  
  tags = var.tags
}

# API Gateway usage plan (optional)
resource "aws_api_gateway_usage_plan" "usage_plan" {
  count = var.usage_plan_configuration != null ? 1 : 0
  
  name         = var.usage_plan_configuration.name
  description  = var.usage_plan_configuration.description

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }

  dynamic "quota_settings" {
    for_each = lookup(var.usage_plan_configuration, "quota_settings", null) != null ? [var.usage_plan_configuration.quota_settings] : []
    content {
      limit  = quota_settings.value.limit
      offset = lookup(quota_settings.value, "offset", null)
      period = quota_settings.value.period
    }
  }

  dynamic "throttle_settings" {
    for_each = lookup(var.usage_plan_configuration, "throttle_settings", null) != null ? [var.usage_plan_configuration.throttle_settings] : []
    content {
      rate_limit  = throttle_settings.value.rate_limit
      burst_limit = throttle_settings.value.burst_limit
    }
  }
  
  tags = var.tags
}

# API Gateway usage plan key (optional)
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  count = var.create_api_key && var.usage_plan_configuration != null ? 1 : 0
  
  key_id        = aws_api_gateway_api_key.api_key[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan[0].id
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}