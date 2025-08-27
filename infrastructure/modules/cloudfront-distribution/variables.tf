# CloudFront Distribution Module Variables

# Basic distribution configuration
variable "origin_id" {
  description = "Unique identifier for the origin"
  type        = string
}

variable "s3_origin_domain_name" {
  description = "Domain name of the S3 bucket origin"
  type        = string
}

variable "s3_origin_access_control_id" {
  description = "Origin Access Control ID for S3 origin"
  type        = string
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the distribution"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "Default root object for the distribution"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class for the distribution"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition = contains([
      "PriceClass_All", "PriceClass_200", "PriceClass_100"
    ], var.price_class)
    error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "retain_on_delete" {
  description = "Retain the distribution when destroyed"
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "Wait for deployment to complete"
  type        = bool
  default     = true
}

variable "aliases" {
  description = "List of custom domain names (aliases) for the distribution"
  type        = list(string)
  default     = []
}

# Default cache behavior
variable "default_cache_behavior" {
  description = "Default cache behavior for the distribution"
  type = object({
    allowed_methods            = list(string)
    cached_methods             = list(string)
    target_origin_id           = string
    compress                   = optional(bool, true)
    viewer_protocol_policy     = string
    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)
    realtime_log_config_arn    = optional(string)
    min_ttl                    = optional(number)
    default_ttl                = optional(number)
    max_ttl                    = optional(number)
    trusted_signers            = optional(list(string), [])
    trusted_key_groups         = optional(list(string), [])
    
    forwarded_values = optional(object({
      query_string            = bool
      query_string_cache_keys = optional(list(string), [])
      headers                 = optional(list(string), [])
      cookies = object({
        forward           = string
        whitelisted_names = optional(list(string), [])
      })
    }))
    
    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
    
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
  })
}

# Additional cache behaviors
variable "ordered_cache_behaviors" {
  description = "List of ordered cache behaviors"
  type = list(object({
    path_pattern               = string
    allowed_methods            = list(string)
    cached_methods             = list(string)
    target_origin_id           = string
    compress                   = optional(bool, true)
    viewer_protocol_policy     = string
    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)
    realtime_log_config_arn    = optional(string)
    min_ttl                    = optional(number)
    default_ttl                = optional(number)
    max_ttl                    = optional(number)
    trusted_signers            = optional(list(string), [])
    trusted_key_groups         = optional(list(string), [])
    
    forwarded_values = optional(object({
      query_string            = bool
      query_string_cache_keys = optional(list(string), [])
      headers                 = optional(list(string), [])
      cookies = object({
        forward           = string
        whitelisted_names = optional(list(string), [])
      })
    }))
    
    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
    
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
  }))
  default = []
}

# Additional origins
variable "additional_origins" {
  description = "List of additional origins for the distribution"
  type = list(object({
    domain_name = string
    origin_id   = string
    origin_path = optional(string, "")
    
    custom_origin_config = optional(object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
    }))
    
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = []
}

# Custom origin configuration (for main origin if not S3)
variable "custom_origin_config" {
  description = "Custom origin configuration for non-S3 origins"
  type = object({
    http_port                = number
    https_port               = number
    origin_protocol_policy   = string
    origin_ssl_protocols     = list(string)
    origin_keepalive_timeout = optional(number, 5)
    origin_read_timeout      = optional(number, 30)
  })
  default = null
}

# Custom headers for main origin
variable "custom_headers" {
  description = "List of custom headers to forward to the origin"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Origin Shield
variable "origin_shield_region" {
  description = "AWS region for Origin Shield"
  type        = string
  default     = null
}

# Geographic restrictions
variable "geo_restriction" {
  description = "Geographic restriction configuration"
  type = object({
    restriction_type = string
    locations        = optional(list(string), [])
  })
  default = {
    restriction_type = "none"
  }
  
  validation {
    condition = contains([
      "none", "whitelist", "blacklist"
    ], var.geo_restriction.restriction_type)
    error_message = "Restriction type must be none, whitelist, or blacklist."
  }
}

# SSL/TLS certificate configuration
variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
  default     = null
}

variable "iam_certificate_id" {
  description = "IAM certificate ID"
  type        = string
  default     = null
}

variable "minimum_protocol_version" {
  description = "Minimum SSL/TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
  
  validation {
    condition = contains([
      "SSLv3", "TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021"
    ], var.minimum_protocol_version)
    error_message = "Minimum protocol version must be a valid SSL/TLS version."
  }
}

variable "ssl_support_method" {
  description = "SSL support method for custom SSL certificates"
  type        = string
  default     = "sni-only"
  
  validation {
    condition = contains([
      "sni-only", "vip"
    ], var.ssl_support_method)
    error_message = "SSL support method must be sni-only or vip."
  }
}

# Custom error responses
variable "custom_error_responses" {
  description = "List of custom error response configurations"
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

# Logging configuration
variable "logging_config" {
  description = "Logging configuration for the distribution"
  type = object({
    include_cookies = optional(bool, false)
    bucket          = string
    prefix          = optional(string, "")
  })
  default = null
}

# Web ACL
variable "web_acl_id" {
  description = "AWS WAF web ACL ID"
  type        = string
  default     = null
}

# HTTP version
variable "http_version" {
  description = "Maximum HTTP version to support"
  type        = string
  default     = "http2"
  
  validation {
    condition = contains([
      "http1.1", "http2", "http2and3", "http3"
    ], var.http_version)
    error_message = "HTTP version must be http1.1, http2, http2and3, or http3."
  }
}

# Cache Policy Configuration
variable "create_cache_policy" {
  description = "Whether to create a cache policy"
  type        = bool
  default     = false
}

variable "cache_policy_name" {
  description = "Name for the cache policy"
  type        = string
  default     = null
}

variable "cache_policy_comment" {
  description = "Comment for the cache policy"
  type        = string
  default     = null
}

variable "cache_policy_default_ttl" {
  description = "Default TTL for cache policy (seconds)"
  type        = number
  default     = 86400
}

variable "cache_policy_max_ttl" {
  description = "Maximum TTL for cache policy (seconds)"
  type        = number
  default     = 31536000
}

variable "cache_policy_min_ttl" {
  description = "Minimum TTL for cache policy (seconds)"
  type        = number
  default     = 0
}

variable "cache_policy_enable_brotli" {
  description = "Enable Brotli compression in cache policy"
  type        = bool
  default     = true
}

variable "cache_policy_enable_gzip" {
  description = "Enable Gzip compression in cache policy"
  type        = bool
  default     = true
}

variable "cache_policy_cookies_behavior" {
  description = "Cookies behavior for cache policy"
  type        = string
  default     = "none"
  
  validation {
    condition = contains([
      "none", "whitelist", "allExcept", "all"
    ], var.cache_policy_cookies_behavior)
    error_message = "Cookies behavior must be none, whitelist, allExcept, or all."
  }
}

variable "cache_policy_cookies_items" {
  description = "List of cookie names for cache policy whitelist"
  type        = list(string)
  default     = []
}

variable "cache_policy_headers_behavior" {
  description = "Headers behavior for cache policy"
  type        = string
  default     = "none"
  
  validation {
    condition = contains([
      "none", "whitelist"
    ], var.cache_policy_headers_behavior)
    error_message = "Headers behavior must be none or whitelist."
  }
}

variable "cache_policy_headers_items" {
  description = "List of header names for cache policy whitelist"
  type        = list(string)
  default     = []
}

variable "cache_policy_query_strings_behavior" {
  description = "Query strings behavior for cache policy"
  type        = string
  default     = "none"
  
  validation {
    condition = contains([
      "none", "whitelist", "allExcept", "all"
    ], var.cache_policy_query_strings_behavior)
    error_message = "Query strings behavior must be none, whitelist, allExcept, or all."
  }
}

variable "cache_policy_query_strings_items" {
  description = "List of query string names for cache policy whitelist"
  type        = list(string)
  default     = []
}

# Origin Request Policy Configuration
variable "create_origin_request_policy" {
  description = "Whether to create an origin request policy"
  type        = bool
  default     = false
}

variable "origin_request_policy_name" {
  description = "Name for the origin request policy"
  type        = string
  default     = null
}

variable "origin_request_policy_comment" {
  description = "Comment for the origin request policy"
  type        = string
  default     = null
}

variable "origin_request_policy_cookies_behavior" {
  description = "Cookies behavior for origin request policy"
  type        = string
  default     = "none"
  
  validation {
    condition = contains([
      "none", "whitelist", "all"
    ], var.origin_request_policy_cookies_behavior)
    error_message = "Cookies behavior must be none, whitelist, or all."
  }
}

variable "origin_request_policy_cookies_items" {
  description = "List of cookie names for origin request policy whitelist"
  type        = list(string)
  default     = []
}

variable "origin_request_policy_headers_behavior" {
  description = "Headers behavior for origin request policy"
  type        = string
  default     = "none"
  
  validation {
    condition = contains([
      "none", "whitelist", "allViewer", "allViewerAndWhitelistCloudFront"
    ], var.origin_request_policy_headers_behavior)
    error_message = "Headers behavior must be none, whitelist, allViewer, or allViewerAndWhitelistCloudFront."
  }
}

variable "origin_request_policy_headers_items" {
  description = "List of header names for origin request policy whitelist"
  type        = list(string)
  default     = []
}

variable "origin_request_policy_query_strings_behavior" {
  description = "Query strings behavior for origin request policy"
  type        = string
  default     = "none"
  
  validation {
    condition = contains([
      "none", "whitelist", "all"
    ], var.origin_request_policy_query_strings_behavior)
    error_message = "Query strings behavior must be none, whitelist, or all."
  }
}

variable "origin_request_policy_query_strings_items" {
  description = "List of query string names for origin request policy whitelist"
  type        = list(string)
  default     = []
}

# Response Headers Policy Configuration
variable "create_response_headers_policy" {
  description = "Whether to create a response headers policy"
  type        = bool
  default     = false
}

variable "response_headers_policy_name" {
  description = "Name for the response headers policy"
  type        = string
  default     = null
}

variable "response_headers_policy_comment" {
  description = "Comment for the response headers policy"
  type        = string
  default     = null
}

variable "response_headers_cors_config" {
  description = "CORS configuration for response headers policy"
  type = object({
    access_control_allow_credentials = bool
    access_control_max_age_sec       = number
    origin_override                  = bool
    access_control_allow_headers     = list(string)
    access_control_allow_methods     = list(string)
    access_control_allow_origins     = list(string)
    access_control_expose_headers    = optional(list(string), [])
  })
  default = null
}

variable "response_headers_security_config" {
  description = "Security headers configuration for response headers policy"
  type = object({
    content_type_options = optional(object({
      override = bool
    }))
    frame_options = optional(object({
      frame_option = string
      override     = bool
    }))
    referrer_policy = optional(object({
      referrer_policy = string
      override        = bool
    }))
    strict_transport_security = optional(object({
      access_control_max_age_sec = number
      include_subdomains         = optional(bool, false)
      override                   = bool
      preload                    = optional(bool, false)
    }))
  })
  default = null
}

variable "response_headers_custom_headers" {
  description = "List of custom headers for response headers policy"
  type = list(object({
    header   = string
    value    = string
    override = bool
  }))
  default = []
}

variable "tags" {
  description = "Map of tags to assign to CloudFront distribution and related resources"
  type        = map(string)
  default     = {}
}