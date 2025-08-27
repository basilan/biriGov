# Lambda Function Module Variables

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.function_name))
    error_message = "Function name must contain only alphanumeric characters, underscores, and hyphens (1-64 chars)."
  }
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Runtime environment for Lambda function"
  type        = string
  default     = "python3.11"
  
  validation {
    condition = contains([
      "python3.11", "python3.10", "python3.9", "python3.8",
      "nodejs18.x", "nodejs16.x", "nodejs14.x",
      "java17", "java11", "java8",
      "dotnet6", "dotnetcore3.1",
      "go1.x", "ruby2.7", "provided.al2"
    ], var.runtime)
    error_message = "Runtime must be a valid AWS Lambda runtime."
  }
}

variable "handler" {
  description = "Function entry point in your code"
  type        = string
  default     = "index.handler"
}

variable "source_path" {
  description = "Path to the Lambda function source code directory"
  type        = string
}

variable "timeout" {
  description = "Amount of time your Lambda function has to run in seconds"
  type        = number
  default     = 30
  
  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda function can use at runtime"
  type        = number
  default     = 512
  
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB."
  }
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "policy_statements" {
  description = "List of IAM policy statements for Lambda execution role"
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "vpc_config" {
  description = "VPC configuration for Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "dead_letter_target_arn" {
  description = "ARN of dead letter queue or topic for failed executions"
  type        = string
  default     = null
}

variable "tracing_mode" {
  description = "Tracing mode for Lambda function (Active or PassThrough)"
  type        = string
  default     = "PassThrough"
  
  validation {
    condition     = contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "Tracing mode must be Active or PassThrough."
  }
}

variable "reserved_concurrency" {
  description = "Reserved concurrency for Lambda function"
  type        = number
  default     = -1
  
  validation {
    condition     = var.reserved_concurrency >= -1 && var.reserved_concurrency <= 1000
    error_message = "Reserved concurrency must be between -1 (unreserved) and 1000."
  }
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

variable "enable_function_url" {
  description = "Whether to create a Lambda function URL"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Authorization type for Lambda function URL"
  type        = string
  default     = "AWS_IAM"
  
  validation {
    condition     = contains(["AWS_IAM", "NONE"], var.function_url_auth_type)
    error_message = "Function URL auth type must be AWS_IAM or NONE."
  }
}

variable "function_url_cors" {
  description = "CORS configuration for Lambda function URL"
  type = object({
    allow_credentials = bool
    allow_headers     = list(string)
    allow_methods     = list(string)
    allow_origins     = list(string)
    expose_headers    = list(string)
    max_age          = number
  })
  default = null
}

variable "alias_name" {
  description = "Name for Lambda function alias"
  type        = string
  default     = null
}

variable "alias_function_version" {
  description = "Function version for Lambda alias"
  type        = string
  default     = "$LATEST"
}

variable "layer_config" {
  description = "Configuration for Lambda layer"
  type = object({
    filename            = string
    layer_name          = string
    description         = string
    compatible_runtimes = list(string)
    source_code_hash    = string
  })
  default = null
}

variable "schedule_expression" {
  description = "EventBridge schedule expression for Lambda function"
  type        = string
  default     = null
}

variable "exclude_files" {
  description = "List of files to exclude from Lambda deployment package"
  type        = list(string)
  default = [
    "__pycache__",
    "*.pyc",
    ".pytest_cache",
    "tests",
    "test_*.py",
    "*.md",
    ".git",
    ".gitignore",
    "*.log"
  ]
}

variable "tags" {
  description = "Map of tags to assign to Lambda function and related resources"
  type        = map(string)
  default     = {}
}