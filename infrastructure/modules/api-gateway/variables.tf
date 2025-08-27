# API Gateway Module Variables

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  
  validation {
    condition     = length(var.api_name) > 0 && length(var.api_name) <= 1024
    error_message = "API name must be between 1 and 1024 characters."
  }
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "endpoint_types" {
  description = "List of endpoint types for the API Gateway"
  type        = list(string)
  default     = ["REGIONAL"]
  
  validation {
    condition = alltrue([
      for endpoint_type in var.endpoint_types :
      contains(["EDGE", "REGIONAL", "PRIVATE"], endpoint_type)
    ])
    error_message = "Endpoint types must be EDGE, REGIONAL, or PRIVATE."
  }
}

variable "stage_name" {
  description = "Name of the deployment stage"
  type        = string
  default     = "prod"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.stage_name))
    error_message = "Stage name can only contain alphanumeric characters, underscores, and hyphens."
  }
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to integrate with"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to integrate with"
  type        = string
}

variable "authorization_type" {
  description = "Authorization type for API methods"
  type        = string
  default     = "NONE"
  
  validation {
    condition = contains([
      "NONE", "AWS_IAM", "CUSTOM", "COGNITO_USER_POOLS"
    ], var.authorization_type)
    error_message = "Authorization type must be NONE, AWS_IAM, CUSTOM, or COGNITO_USER_POOLS."
  }
}

variable "authorization_scopes" {
  description = "List of authorization scopes for the method"
  type        = list(string)
  default     = []
}

variable "authorizer_id" {
  description = "ID of the authorizer to use for the API"
  type        = string
  default     = null
}

variable "api_key_required" {
  description = "Whether an API key is required for the method"
  type        = bool
  default     = false
}

variable "cors_configuration" {
  description = "CORS configuration for the API"
  type = object({
    allow_credentials = optional(bool, false)
    allow_headers     = optional(list(string), ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key"])
    allow_methods     = optional(list(string), ["GET", "POST", "PUT", "DELETE", "OPTIONS"])
    allow_origins     = optional(list(string), ["*"])
    expose_headers    = optional(list(string), [])
    max_age          = optional(number, 86400)
  })
  default = null
}

variable "binary_media_types" {
  description = "List of binary media types supported by the API"
  type        = list(string)
  default     = []
}

variable "minimum_compression_size" {
  description = "Minimum response size to compress for the API"
  type        = number
  default     = -1
  
  validation {
    condition     = var.minimum_compression_size >= -1
    error_message = "Minimum compression size must be >= -1 (-1 disables compression)."
  }
}

variable "api_key_source" {
  description = "Source of the API key for requests"
  type        = string
  default     = "HEADER"
  
  validation {
    condition     = contains(["HEADER", "AUTHORIZER"], var.api_key_source)
    error_message = "API key source must be HEADER or AUTHORIZER."
  }
}

variable "api_policy_json" {
  description = "JSON string of the API policy"
  type        = string
  default     = null
}

variable "access_log_destination_arn" {
  description = "ARN of CloudWatch log group for access logging"
  type        = string
  default     = null
}

variable "access_log_format" {
  description = "Format for access logs"
  type        = string
  default     = "$requestId $extendedRequestId $ip $caller $user [$requestTime] \"$httpMethod $resourcePath $protocol\" $status $error.message $error.messageString $responseLength $requestTime $xrayTraceId $integrationError $integrationStatus $integrationLatency $integrationRequestId $functionResponseStatus $integrationErrorMessage"
}

variable "xray_tracing_enabled" {
  description = "Whether X-Ray tracing is enabled for the stage"
  type        = bool
  default     = false
}

variable "cache_cluster_enabled" {
  description = "Whether caching is enabled for the stage"
  type        = bool
  default     = false
}

variable "cache_cluster_size" {
  description = "Size of the cache cluster for the stage"
  type        = string
  default     = "0.5"
  
  validation {
    condition = contains([
      "0.5", "1.6", "6.1", "13.5", "28.4", "58.2", "118", "237"
    ], var.cache_cluster_size)
    error_message = "Cache cluster size must be a valid option."
  }
}

variable "client_certificate_id" {
  description = "ID of the client certificate for the stage"
  type        = string
  default     = null
}

variable "documentation_version" {
  description = "Version of the associated API documentation"
  type        = string
  default     = null
}

variable "stage_variables" {
  description = "Map of stage variables for the deployment stage"
  type        = map(string)
  default     = {}
}

variable "integration_timeout_milliseconds" {
  description = "Custom timeout for the integration in milliseconds"
  type        = number
  default     = 29000
  
  validation {
    condition     = var.integration_timeout_milliseconds >= 50 && var.integration_timeout_milliseconds <= 29000
    error_message = "Integration timeout must be between 50 and 29000 milliseconds."
  }
}

variable "content_handling" {
  description = "How to handle request/response content type conversions"
  type        = string
  default     = null
  
  validation {
    condition = var.content_handling == null || contains([
      "CONVERT_TO_BINARY", "CONVERT_TO_TEXT"
    ], var.content_handling)
    error_message = "Content handling must be CONVERT_TO_BINARY or CONVERT_TO_TEXT."
  }
}

variable "request_templates" {
  description = "Map of request templates for the integration"
  type        = map(string)
  default     = {}
}

variable "request_parameters" {
  description = "Map of request parameters for the method"
  type        = map(bool)
  default     = {}
}

variable "request_models" {
  description = "Map of request models for the method"
  type        = map(string)
  default     = {}
}

variable "request_validator_id" {
  description = "ID of the request validator"
  type        = string
  default     = null
}

variable "cache_key_parameters" {
  description = "List of cache key parameters for the integration"
  type        = list(string)
  default     = []
}

variable "cache_namespace" {
  description = "Integration cache namespace"
  type        = string
  default     = null
}

variable "authorizer_configuration" {
  description = "Configuration for API Gateway authorizer"
  type = object({
    name                           = string
    type                           = string
    authorizer_uri                 = optional(string)
    authorizer_credentials         = optional(string)
    identity_source               = optional(string)
    identity_validation_expression = optional(string)
    authorizer_result_ttl_in_seconds = optional(number, 300)
  })
  default = null
}

variable "create_api_key" {
  description = "Whether to create an API key"
  type        = bool
  default     = false
}

variable "usage_plan_configuration" {
  description = "Configuration for API Gateway usage plan"
  type = object({
    name        = string
    description = optional(string)
    quota_settings = optional(object({
      limit  = number
      offset = optional(number)
      period = string
    }))
    throttle_settings = optional(object({
      rate_limit  = number
      burst_limit = number
    }))
  })
  default = null
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "tags" {
  description = "Map of tags to assign to API Gateway and related resources"
  type        = map(string)
  default     = {}
}