# CloudFront Distribution Module Outputs

# Distribution basic information
output "id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.id
}

output "arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.arn
}

output "distribution_id" {
  description = "ID of the CloudFront distribution (alias for id)"
  value       = aws_cloudfront_distribution.distribution.id
}

output "domain_name" {
  description = "Domain name corresponding to the distribution"
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "hosted_zone_id" {
  description = "CloudFront Route 53 zone ID for aliasing"
  value       = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "status" {
  description = "Current status of the distribution"
  value       = aws_cloudfront_distribution.distribution.status
}

output "last_modified_time" {
  description = "Date and time the distribution was last modified"
  value       = aws_cloudfront_distribution.distribution.last_modified_time
}

output "in_progress_validation_batches" {
  description = "Number of invalidation batches currently in progress"
  value       = aws_cloudfront_distribution.distribution.in_progress_validation_batches
}

output "etag" {
  description = "Current version of the distribution's information"
  value       = aws_cloudfront_distribution.distribution.etag
}

# Distribution configuration
output "enabled" {
  description = "Whether the distribution is enabled"
  value       = aws_cloudfront_distribution.distribution.enabled
}

output "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  value       = aws_cloudfront_distribution.distribution.is_ipv6_enabled
}

output "comment" {
  description = "Comment for the distribution"
  value       = aws_cloudfront_distribution.distribution.comment
}

output "default_root_object" {
  description = "Default root object for the distribution"
  value       = aws_cloudfront_distribution.distribution.default_root_object
}

output "price_class" {
  description = "Price class for the distribution"
  value       = aws_cloudfront_distribution.distribution.price_class
}

output "http_version" {
  description = "Maximum HTTP version supported by the distribution"
  value       = aws_cloudfront_distribution.distribution.http_version
}

# Aliases and SSL/TLS configuration
output "aliases" {
  description = "List of aliases (CNAMEs) for the distribution"
  value       = aws_cloudfront_distribution.distribution.aliases
}

output "viewer_certificate" {
  description = "SSL/TLS certificate configuration"
  value = {
    acm_certificate_arn            = aws_cloudfront_distribution.distribution.viewer_certificate[0].acm_certificate_arn
    cloudfront_default_certificate = aws_cloudfront_distribution.distribution.viewer_certificate[0].cloudfront_default_certificate
    iam_certificate_id             = aws_cloudfront_distribution.distribution.viewer_certificate[0].iam_certificate_id
    minimum_protocol_version       = aws_cloudfront_distribution.distribution.viewer_certificate[0].minimum_protocol_version
    ssl_support_method             = aws_cloudfront_distribution.distribution.viewer_certificate[0].ssl_support_method
  }
}

# Origin information
output "origins" {
  description = "List of origins for the distribution"
  value = [
    for origin in aws_cloudfront_distribution.distribution.origin : {
      domain_name = origin.domain_name
      origin_id   = origin.origin_id
      origin_path = origin.origin_path
    }
  ]
}

# Cache behavior information
output "default_cache_behavior" {
  description = "Default cache behavior configuration"
  value = {
    target_origin_id       = aws_cloudfront_distribution.distribution.default_cache_behavior[0].target_origin_id
    viewer_protocol_policy = aws_cloudfront_distribution.distribution.default_cache_behavior[0].viewer_protocol_policy
    allowed_methods        = aws_cloudfront_distribution.distribution.default_cache_behavior[0].allowed_methods
    cached_methods         = aws_cloudfront_distribution.distribution.default_cache_behavior[0].cached_methods
    compress               = aws_cloudfront_distribution.distribution.default_cache_behavior[0].compress
    cache_policy_id        = aws_cloudfront_distribution.distribution.default_cache_behavior[0].cache_policy_id
  }
}

output "ordered_cache_behaviors" {
  description = "List of ordered cache behaviors"
  value = [
    for behavior in aws_cloudfront_distribution.distribution.ordered_cache_behavior : {
      path_pattern           = behavior.path_pattern
      target_origin_id       = behavior.target_origin_id
      viewer_protocol_policy = behavior.viewer_protocol_policy
      allowed_methods        = behavior.allowed_methods
      cached_methods         = behavior.cached_methods
    }
  ]
}

# Geographic restrictions
output "geo_restriction" {
  description = "Geographic restriction configuration"
  value = {
    restriction_type = aws_cloudfront_distribution.distribution.restrictions[0].geo_restriction[0].restriction_type
    locations        = aws_cloudfront_distribution.distribution.restrictions[0].geo_restriction[0].locations
  }
}

# Custom error responses
output "custom_error_responses" {
  description = "List of custom error response configurations"
  value = [
    for error_response in aws_cloudfront_distribution.distribution.custom_error_response : {
      error_code            = error_response.error_code
      response_code         = error_response.response_code
      response_page_path    = error_response.response_page_path
      error_caching_min_ttl = error_response.error_caching_min_ttl
    }
  ]
}

# Logging configuration
output "logging_config" {
  description = "Logging configuration for the distribution"
  value = length(aws_cloudfront_distribution.distribution.logging_config) > 0 ? {
    include_cookies = aws_cloudfront_distribution.distribution.logging_config[0].include_cookies
    bucket          = aws_cloudfront_distribution.distribution.logging_config[0].bucket
    prefix          = aws_cloudfront_distribution.distribution.logging_config[0].prefix
  } : null
}

# Web ACL
output "web_acl_id" {
  description = "AWS WAF web ACL ID associated with the distribution"
  value       = aws_cloudfront_distribution.distribution.web_acl_id
}

# Policy outputs
output "cache_policy_id" {
  description = "ID of the created cache policy"
  value       = var.create_cache_policy ? aws_cloudfront_cache_policy.cache_policy[0].id : null
}

output "cache_policy_etag" {
  description = "ETag of the created cache policy"
  value       = var.create_cache_policy ? aws_cloudfront_cache_policy.cache_policy[0].etag : null
}

output "origin_request_policy_id" {
  description = "ID of the created origin request policy"
  value       = var.create_origin_request_policy ? aws_cloudfront_origin_request_policy.origin_request_policy[0].id : null
}

output "origin_request_policy_etag" {
  description = "ETag of the created origin request policy"
  value       = var.create_origin_request_policy ? aws_cloudfront_origin_request_policy.origin_request_policy[0].etag : null
}

output "response_headers_policy_id" {
  description = "ID of the created response headers policy"
  value       = var.create_response_headers_policy ? aws_cloudfront_response_headers_policy.response_headers_policy[0].id : null
}

output "response_headers_policy_etag" {
  description = "ETag of the created response headers policy"
  value       = var.create_response_headers_policy ? aws_cloudfront_response_headers_policy.response_headers_policy[0].etag : null
}

# URLs for easy access
output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.distribution.domain_name}"
}

output "distribution_url" {
  description = "CloudFront distribution URL (alias for cloudfront_url)"
  value       = "https://${aws_cloudfront_distribution.distribution.domain_name}"
}

# Trusted signers and key groups
output "trusted_signers" {
  description = "List of trusted signers for the default cache behavior"
  value       = aws_cloudfront_distribution.distribution.default_cache_behavior[0].trusted_signers
}

output "trusted_key_groups" {
  description = "List of trusted key groups for the default cache behavior"
  value       = aws_cloudfront_distribution.distribution.default_cache_behavior[0].trusted_key_groups
}

# Tags
output "tags_all" {
  description = "Map of all tags assigned to the distribution"
  value       = aws_cloudfront_distribution.distribution.tags_all
}

# Additional metadata
output "caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the distribution configuration"
  value       = aws_cloudfront_distribution.distribution.caller_reference
}

output "retain_on_delete" {
  description = "Whether the distribution is retained when destroyed"
  value       = var.retain_on_delete
}

output "wait_for_deployment" {
  description = "Whether Terraform waits for deployment to complete"
  value       = var.wait_for_deployment
}