# Healthcare AI Governance Agent - Terraform Variables
# Configuration variables for infrastructure deployment

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-west-2"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in format like 'us-west-2'."
  }
}

variable "cost_budget_limit" {
  description = "Maximum budget limit in USD for demo cost control"
  type        = string
  default     = "50"
  
  validation {
    condition     = can(tonumber(var.cost_budget_limit)) && tonumber(var.cost_budget_limit) > 0
    error_message = "Cost budget limit must be a positive number."
  }
}

variable "alert_email" {
  description = "Email address for budget and operational alerts"
  type        = string
  default     = "demo@example.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "Must be a valid email address."
  }
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "demo"
  
  validation {
    condition = contains(["demo", "dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: demo, dev, staging, prod."
  }
}

variable "lambda_memory_size" {
  description = "Memory allocation for Lambda function (MB)"
  type        = number
  default     = 1024
  
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 3008
    error_message = "Lambda memory size must be between 128 MB and 3008 MB."
  }
}

variable "lambda_timeout" {
  description = "Timeout for Lambda function execution (seconds)"
  type        = number
  default     = 300
  
  validation {
    condition     = var.lambda_timeout >= 3 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 3 and 900 seconds."
  }
}

variable "auto_cleanup_days" {
  description = "Number of days before automatic resource cleanup"
  type        = number
  default     = 1
  
  validation {
    condition     = var.auto_cleanup_days >= 1 && var.auto_cleanup_days <= 30
    error_message = "Auto cleanup days must be between 1 and 30."
  }
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning for audit trail"
  type        = bool
  default     = true
}

variable "enable_point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = true
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "demo"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.api_stage_name))
    error_message = "API stage name can only contain alphanumeric characters, underscores, and hyphens."
  }
}

# Local values for computed configurations
locals {
  # Resource naming prefix
  name_prefix = "healthcare-ai-governance"
  
  # Common resource tags
  common_tags = {
    Project         = local.name_prefix
    Environment     = var.environment
    ManagedBy       = "terraform"
    AutoCleanupDays = var.auto_cleanup_days
    CostCenter      = "demonstration"
    Owner           = "healthcare-ai-demo"
  }
  
  # Auto-cleanup configuration
  cleanup_timestamp = timeadd(timestamp(), "${var.auto_cleanup_days * 24}h")
}