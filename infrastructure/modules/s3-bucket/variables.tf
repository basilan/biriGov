# S3 Bucket Module Variables

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  
  validation {
    condition = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters, start and end with lowercase letter or number, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Whether to enable S3 bucket versioning"
  type        = bool
  default     = false
}

variable "acl" {
  description = "Canned ACL to apply to the bucket"
  type        = string
  default     = "private"
  
  validation {
    condition = contains([
      "private", "public-read", "public-read-write", "authenticated-read",
      "aws-exec-read", "bucket-owner-read", "bucket-owner-full-control"
    ], var.acl)
    error_message = "ACL must be a valid canned ACL."
  }
}

variable "object_ownership" {
  description = "Object ownership setting for the bucket"
  type        = string
  default     = "BucketOwnerPreferred"
  
  validation {
    condition = contains([
      "BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"
    ], var.object_ownership)
    error_message = "Object ownership must be BucketOwnerPreferred, ObjectWriter, or BucketOwnerEnforced."
  }
}

variable "block_public_acls" {
  description = "Whether to block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether to block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether to ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether to restrict public bucket policies"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for server-side encryption (uses AWS managed key if not specified)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether to use S3 bucket key for KMS encryption cost reduction"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    id     = string
    status = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    expiration = optional(list(object({
      days                         = optional(number)
      date                         = optional(string)
      expired_object_delete_marker = optional(bool)
    })))
    noncurrent_version_expiration = optional(list(object({
      noncurrent_days           = optional(number)
      newer_noncurrent_versions = optional(number)
    })))
    transitions = optional(list(object({
      days          = optional(number)
      date          = optional(string)
      storage_class = string
    })))
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days           = optional(number)
      newer_noncurrent_versions = optional(number)
      storage_class            = string
    })))
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
  }))
  default = []
}

variable "cors_rules" {
  description = "List of CORS rules for the bucket"
  type = list(object({
    id              = optional(string)
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "website_configuration" {
  description = "Website configuration for the bucket"
  type = object({
    index_document = string
    error_document = optional(string)
    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string)
    }))
  })
  default = null
}

variable "notification_configuration" {
  description = "Notification configuration for the bucket"
  type = object({
    lambda_functions = optional(list(object({
      lambda_function_arn = string
      events             = list(string)
      filter_prefix      = optional(string)
      filter_suffix      = optional(string)
    })))
    topics = optional(list(object({
      topic_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })))
    queues = optional(list(object({
      queue_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })))
  })
  default = null
}

variable "bucket_policy_json" {
  description = "JSON string of the bucket policy"
  type        = string
  default     = null
}

variable "create_cloudfront_oac" {
  description = "Whether to create CloudFront Origin Access Control"
  type        = bool
  default     = false
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution for OAC policy"
  type        = string
  default     = null
}

variable "logging_configuration" {
  description = "Logging configuration for the bucket"
  type = object({
    target_bucket = string
    target_prefix = optional(string)
    target_grants = optional(list(object({
      grantee = object({
        id   = optional(string)
        type = string
        uri  = optional(string)
      })
      permission = string
    })))
  })
  default = null
}

variable "intelligent_tiering_configuration" {
  description = "Intelligent tiering configuration for the bucket"
  type = object({
    name   = string
    status = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    tiering = list(object({
      access_tier = string
      days        = number
    }))
  })
  default = null
}

variable "tags" {
  description = "Map of tags to assign to S3 bucket and related resources"
  type        = map(string)
  default     = {}
}