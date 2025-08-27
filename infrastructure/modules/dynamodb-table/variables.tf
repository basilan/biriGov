# DynamoDB Table Module Variables

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{3,255}$", var.table_name))
    error_message = "Table name must be between 3 and 255 characters and contain only letters, numbers, underscores, periods, and hyphens."
  }
}

variable "billing_mode" {
  description = "Billing mode for the DynamoDB table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
  
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "Attribute name of the hash (partition) key"
  type        = string
}

variable "hash_key_type" {
  description = "Attribute type of the hash key (S, N, or B)"
  type        = string
  default     = "S"
  
  validation {
    condition     = contains(["S", "N", "B"], var.hash_key_type)
    error_message = "Hash key type must be S (String), N (Number), or B (Binary)."
  }
}

variable "range_key" {
  description = "Attribute name of the range (sort) key"
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "Attribute type of the range key (S, N, or B)"
  type        = string
  default     = "S"
  
  validation {
    condition     = contains(["S", "N", "B"], var.range_key_type)
    error_message = "Range key type must be S (String), N (Number), or B (Binary)."
  }
}

variable "attributes" {
  description = "List of additional attributes for the table"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "read_capacity" {
  description = "Read capacity units for the table (only used with PROVISIONED billing mode)"
  type        = number
  default     = 5
  
  validation {
    condition     = var.read_capacity >= 1
    error_message = "Read capacity must be at least 1."
  }
}

variable "write_capacity" {
  description = "Write capacity units for the table (only used with PROVISIONED billing mode)"
  type        = number
  default     = 5
  
  validation {
    condition     = var.write_capacity >= 1
    error_message = "Write capacity must be at least 1."
  }
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes for the table"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number, 5)
    write_capacity     = optional(number, 5)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes for the table"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "ttl_enabled" {
  description = "Whether Time to Live (TTL) is enabled"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the table attribute for TTL"
  type        = string
  default     = "expires_at"
}

variable "encryption_enabled" {
  description = "Whether server-side encryption is enabled"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for server-side encryption (uses AWS managed key if not specified)"
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Whether DynamoDB Streams is enabled"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When streams are enabled, specifies the information written to stream"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
  
  validation {
    condition = contains([
      "KEYS_ONLY",
      "NEW_IMAGE",
      "OLD_IMAGE", 
      "NEW_AND_OLD_IMAGES"
    ], var.stream_view_type)
    error_message = "Stream view type must be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}

variable "point_in_time_recovery_enabled" {
  description = "Whether point-in-time recovery is enabled"
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "Whether deletion protection is enabled"
  type        = bool
  default     = false
}

variable "enable_autoscaling" {
  description = "Whether to enable auto scaling for the table"
  type        = bool
  default     = false
}

variable "autoscaling_read_min_capacity" {
  description = "Minimum read capacity for auto scaling"
  type        = number
  default     = 5
}

variable "autoscaling_read_max_capacity" {
  description = "Maximum read capacity for auto scaling"
  type        = number
  default     = 100
}

variable "autoscaling_read_target_value" {
  description = "Target utilization percentage for read capacity auto scaling"
  type        = number
  default     = 70.0
  
  validation {
    condition     = var.autoscaling_read_target_value >= 10 && var.autoscaling_read_target_value <= 90
    error_message = "Read target value must be between 10 and 90."
  }
}

variable "autoscaling_write_min_capacity" {
  description = "Minimum write capacity for auto scaling"
  type        = number
  default     = 5
}

variable "autoscaling_write_max_capacity" {
  description = "Maximum write capacity for auto scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_target_value" {
  description = "Target utilization percentage for write capacity auto scaling"
  type        = number
  default     = 70.0
  
  validation {
    condition     = var.autoscaling_write_target_value >= 10 && var.autoscaling_write_target_value <= 90
    error_message = "Write target value must be between 10 and 90."
  }
}

variable "enable_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms for the table"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "List of actions to execute when alarms transition to ALARM state"
  type        = list(string)
  default     = []
}

variable "enable_contributor_insights" {
  description = "Whether to enable contributor insights for the table"
  type        = bool
  default     = false
}

variable "initial_items" {
  description = "List of initial items to create in the table"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Map of tags to assign to DynamoDB table and related resources"
  type        = map(string)
  default     = {}
}