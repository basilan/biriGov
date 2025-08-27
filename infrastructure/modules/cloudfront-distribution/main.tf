# CloudFront Distribution Module
# Reusable module for AWS CloudFront distributions with S3 origins and custom configurations

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "distribution" {
  # S3 origin configuration
  origin {
    domain_name              = var.s3_origin_domain_name
    origin_id                = var.origin_id
    origin_access_control_id = var.s3_origin_access_control_id

    # Custom origin configuration (if provided)
    dynamic "custom_origin_config" {
      for_each = var.custom_origin_config != null ? [var.custom_origin_config] : []
      content {
        http_port                = custom_origin_config.value.http_port
        https_port               = custom_origin_config.value.https_port
        origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
        origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
        origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", 5)
        origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", 30)
      }
    }

    # Custom headers
    dynamic "custom_header" {
      for_each = var.custom_headers
      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }

    # Origin shield
    dynamic "origin_shield" {
      for_each = var.origin_shield_region != null ? [1] : []
      content {
        enabled              = true
        origin_shield_region = var.origin_shield_region
      }
    }
  }

  # Additional origins (if provided)
  dynamic "origin" {
    for_each = var.additional_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = lookup(origin.value, "origin_path", "")

      dynamic "custom_origin_config" {
        for_each = lookup(origin.value, "custom_origin_config", null) != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", 5)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", 30)
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_headers", [])
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  enabled             = var.enabled
  is_ipv6_enabled     = var.ipv6_enabled
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment

  # Aliases (custom domain names)
  aliases = var.aliases

  # Default cache behavior
  default_cache_behavior {
    allowed_methods            = var.default_cache_behavior.allowed_methods
    cached_methods             = var.default_cache_behavior.cached_methods
    target_origin_id           = var.default_cache_behavior.target_origin_id
    compress                   = lookup(var.default_cache_behavior, "compress", true)
    viewer_protocol_policy     = var.default_cache_behavior.viewer_protocol_policy
    cache_policy_id            = lookup(var.default_cache_behavior, "cache_policy_id", null)
    origin_request_policy_id   = lookup(var.default_cache_behavior, "origin_request_policy_id", null)
    response_headers_policy_id = lookup(var.default_cache_behavior, "response_headers_policy_id", null)
    realtime_log_config_arn    = lookup(var.default_cache_behavior, "realtime_log_config_arn", null)
    
    # Legacy forwarded values (used when cache_policy_id is not set)
    dynamic "forwarded_values" {
      for_each = lookup(var.default_cache_behavior, "forwarded_values", null) != null && lookup(var.default_cache_behavior, "cache_policy_id", null) == null ? [var.default_cache_behavior.forwarded_values] : []
      content {
        query_string            = forwarded_values.value.query_string
        query_string_cache_keys = lookup(forwarded_values.value, "query_string_cache_keys", [])
        headers                 = lookup(forwarded_values.value, "headers", [])
        
        cookies {
          forward           = forwarded_values.value.cookies.forward
          whitelisted_names = lookup(forwarded_values.value.cookies, "whitelisted_names", [])
        }
      }
    }

    # TTL settings (legacy, used with forwarded_values)
    min_ttl     = lookup(var.default_cache_behavior, "min_ttl", null)
    default_ttl = lookup(var.default_cache_behavior, "default_ttl", null)
    max_ttl     = lookup(var.default_cache_behavior, "max_ttl", null)

    # Trusted signers/key groups
    trusted_signers   = lookup(var.default_cache_behavior, "trusted_signers", [])
    trusted_key_groups = lookup(var.default_cache_behavior, "trusted_key_groups", [])

    # Lambda function associations
    dynamic "lambda_function_association" {
      for_each = lookup(var.default_cache_behavior, "lambda_function_associations", [])
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lookup(lambda_function_association.value, "include_body", false)
      }
    }

    # CloudFront Functions
    dynamic "function_association" {
      for_each = lookup(var.default_cache_behavior, "function_associations", [])
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  # Additional cache behaviors
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern               = ordered_cache_behavior.value.path_pattern
      allowed_methods            = ordered_cache_behavior.value.allowed_methods
      cached_methods             = ordered_cache_behavior.value.cached_methods
      target_origin_id           = ordered_cache_behavior.value.target_origin_id
      compress                   = lookup(ordered_cache_behavior.value, "compress", true)
      viewer_protocol_policy     = ordered_cache_behavior.value.viewer_protocol_policy
      cache_policy_id            = lookup(ordered_cache_behavior.value, "cache_policy_id", null)
      origin_request_policy_id   = lookup(ordered_cache_behavior.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(ordered_cache_behavior.value, "response_headers_policy_id", null)
      realtime_log_config_arn    = lookup(ordered_cache_behavior.value, "realtime_log_config_arn", null)

      # Legacy forwarded values
      dynamic "forwarded_values" {
        for_each = lookup(ordered_cache_behavior.value, "forwarded_values", null) != null && lookup(ordered_cache_behavior.value, "cache_policy_id", null) == null ? [ordered_cache_behavior.value.forwarded_values] : []
        content {
          query_string            = forwarded_values.value.query_string
          query_string_cache_keys = lookup(forwarded_values.value, "query_string_cache_keys", [])
          headers                 = lookup(forwarded_values.value, "headers", [])
          
          cookies {
            forward           = forwarded_values.value.cookies.forward
            whitelisted_names = lookup(forwarded_values.value.cookies, "whitelisted_names", [])
          }
        }
      }

      # TTL settings
      min_ttl     = lookup(ordered_cache_behavior.value, "min_ttl", null)
      default_ttl = lookup(ordered_cache_behavior.value, "default_ttl", null)
      max_ttl     = lookup(ordered_cache_behavior.value, "max_ttl", null)

      # Trusted signers/key groups
      trusted_signers   = lookup(ordered_cache_behavior.value, "trusted_signers", [])
      trusted_key_groups = lookup(ordered_cache_behavior.value, "trusted_key_groups", [])

      # Lambda function associations
      dynamic "lambda_function_association" {
        for_each = lookup(ordered_cache_behavior.value, "lambda_function_associations", [])
        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lookup(lambda_function_association.value, "include_body", false)
        }
      }

      # CloudFront Functions
      dynamic "function_association" {
        for_each = lookup(ordered_cache_behavior.value, "function_associations", [])
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }
    }
  }

  # Geographic restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = lookup(var.geo_restriction, "locations", [])
    }
  }

  # SSL/TLS certificate
  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = var.acm_certificate_arn == null
    iam_certificate_id             = var.iam_certificate_id
    minimum_protocol_version       = var.minimum_protocol_version
    ssl_support_method             = var.acm_certificate_arn != null || var.iam_certificate_id != null ? var.ssl_support_method : null
  }

  # Custom error responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  # Logging configuration
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      include_cookies = lookup(logging_config.value, "include_cookies", false)
      bucket          = logging_config.value.bucket
      prefix          = lookup(logging_config.value, "prefix", "")
    }
  }

  # Web ACL ID
  web_acl_id = var.web_acl_id

  # HTTP version
  http_version = var.http_version

  tags = var.tags

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      # Ignore changes to ETag as it changes frequently
      etag,
    ]
  }
}

# CloudFront cache policy (optional)
resource "aws_cloudfront_cache_policy" "cache_policy" {
  count = var.create_cache_policy ? 1 : 0
  
  name    = var.cache_policy_name
  comment = var.cache_policy_comment
  
  default_ttl = var.cache_policy_default_ttl
  max_ttl     = var.cache_policy_max_ttl
  min_ttl     = var.cache_policy_min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = var.cache_policy_enable_brotli
    enable_accept_encoding_gzip   = var.cache_policy_enable_gzip

    cookies_config {
      cookie_behavior = var.cache_policy_cookies_behavior
      dynamic "cookies" {
        for_each = var.cache_policy_cookies_behavior == "whitelist" ? [1] : []
        content {
          items = var.cache_policy_cookies_items
        }
      }
    }

    headers_config {
      header_behavior = var.cache_policy_headers_behavior
      dynamic "headers" {
        for_each = var.cache_policy_headers_behavior == "whitelist" ? [1] : []
        content {
          items = var.cache_policy_headers_items
        }
      }
    }

    query_strings_config {
      query_string_behavior = var.cache_policy_query_strings_behavior
      dynamic "query_strings" {
        for_each = var.cache_policy_query_strings_behavior == "whitelist" ? [1] : []
        content {
          items = var.cache_policy_query_strings_items
        }
      }
    }
  }
}

# CloudFront origin request policy (optional)
resource "aws_cloudfront_origin_request_policy" "origin_request_policy" {
  count = var.create_origin_request_policy ? 1 : 0
  
  name    = var.origin_request_policy_name
  comment = var.origin_request_policy_comment

  cookies_config {
    cookie_behavior = var.origin_request_policy_cookies_behavior
    dynamic "cookies" {
      for_each = var.origin_request_policy_cookies_behavior == "whitelist" ? [1] : []
      content {
        items = var.origin_request_policy_cookies_items
      }
    }
  }

  headers_config {
    header_behavior = var.origin_request_policy_headers_behavior
    dynamic "headers" {
      for_each = var.origin_request_policy_headers_behavior == "whitelist" ? [1] : []
      content {
        items = var.origin_request_policy_headers_items
      }
    }
  }

  query_strings_config {
    query_string_behavior = var.origin_request_policy_query_strings_behavior
    dynamic "query_strings" {
      for_each = var.origin_request_policy_query_strings_behavior == "whitelist" ? [1] : []
      content {
        items = var.origin_request_policy_query_strings_items
      }
    }
  }
}

# CloudFront response headers policy (optional)
resource "aws_cloudfront_response_headers_policy" "response_headers_policy" {
  count = var.create_response_headers_policy ? 1 : 0
  
  name    = var.response_headers_policy_name
  comment = var.response_headers_policy_comment

  dynamic "cors_config" {
    for_each = var.response_headers_cors_config != null ? [var.response_headers_cors_config] : []
    content {
      access_control_allow_credentials = cors_config.value.access_control_allow_credentials
      access_control_max_age_sec       = cors_config.value.access_control_max_age_sec
      origin_override                  = cors_config.value.origin_override

      access_control_allow_headers {
        items = cors_config.value.access_control_allow_headers
      }

      access_control_allow_methods {
        items = cors_config.value.access_control_allow_methods
      }

      access_control_allow_origins {
        items = cors_config.value.access_control_allow_origins
      }

      dynamic "access_control_expose_headers" {
        for_each = length(lookup(cors_config.value, "access_control_expose_headers", [])) > 0 ? [1] : []
        content {
          items = cors_config.value.access_control_expose_headers
        }
      }
    }
  }

  dynamic "security_headers_config" {
    for_each = var.response_headers_security_config != null ? [var.response_headers_security_config] : []
    content {
      dynamic "content_type_options" {
        for_each = lookup(security_headers_config.value, "content_type_options", null) != null ? [security_headers_config.value.content_type_options] : []
        content {
          override = content_type_options.value.override
        }
      }

      dynamic "frame_options" {
        for_each = lookup(security_headers_config.value, "frame_options", null) != null ? [security_headers_config.value.frame_options] : []
        content {
          frame_option = frame_options.value.frame_option
          override     = frame_options.value.override
        }
      }

      dynamic "referrer_policy" {
        for_each = lookup(security_headers_config.value, "referrer_policy", null) != null ? [security_headers_config.value.referrer_policy] : []
        content {
          referrer_policy = referrer_policy.value.referrer_policy
          override        = referrer_policy.value.override
        }
      }

      dynamic "strict_transport_security" {
        for_each = lookup(security_headers_config.value, "strict_transport_security", null) != null ? [security_headers_config.value.strict_transport_security] : []
        content {
          access_control_max_age_sec = strict_transport_security.value.access_control_max_age_sec
          include_subdomains         = lookup(strict_transport_security.value, "include_subdomains", false)
          override                   = strict_transport_security.value.override
          preload                    = lookup(strict_transport_security.value, "preload", false)
        }
      }
    }
  }

  dynamic "custom_headers_config" {
    for_each = length(var.response_headers_custom_headers) > 0 ? [1] : []
    content {
      dynamic "items" {
        for_each = var.response_headers_custom_headers
        content {
          header   = items.value.header
          value    = items.value.value
          override = items.value.override
        }
      }
    }
  }
}