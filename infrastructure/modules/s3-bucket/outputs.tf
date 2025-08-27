# S3 Bucket Module Outputs

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for the S3 bucket"
  value       = aws_s3_bucket.bucket.hosted_zone_id
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.bucket.region
}

output "website_endpoint" {
  description = "Website endpoint of the S3 bucket (if website hosting is enabled)"
  value       = var.website_configuration != null ? aws_s3_bucket_website_configuration.website[0].website_endpoint : null
}

output "website_domain" {
  description = "Website domain of the S3 bucket (if website hosting is enabled)"
  value       = var.website_configuration != null ? aws_s3_bucket_website_configuration.website[0].website_domain : null
}

output "versioning_enabled" {
  description = "Whether versioning is enabled for the bucket"
  value       = var.versioning_enabled
}

output "encryption_configuration" {
  description = "Server-side encryption configuration of the bucket"
  value = {
    sse_algorithm     = aws_s3_bucket_server_side_encryption_configuration.encryption.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm
    kms_master_key_id = aws_s3_bucket_server_side_encryption_configuration.encryption.rule[0].apply_server_side_encryption_by_default[0].kms_master_key_id
    bucket_key_enabled = aws_s3_bucket_server_side_encryption_configuration.encryption.rule[0].bucket_key_enabled
  }
}

output "public_access_block_configuration" {
  description = "Public access block configuration of the bucket"
  value = {
    block_public_acls       = aws_s3_bucket_public_access_block.pab.block_public_acls
    block_public_policy     = aws_s3_bucket_public_access_block.pab.block_public_policy
    ignore_public_acls      = aws_s3_bucket_public_access_block.pab.ignore_public_acls
    restrict_public_buckets = aws_s3_bucket_public_access_block.pab.restrict_public_buckets
  }
}

output "lifecycle_configuration" {
  description = "Lifecycle configuration rules of the bucket"
  value = length(var.lifecycle_rules) > 0 ? [
    for rule in aws_s3_bucket_lifecycle_configuration.lifecycle[0].rule : {
      id     = rule.id
      status = rule.status
    }
  ] : null
}

output "cors_rules" {
  description = "CORS rules of the bucket"
  value = length(var.cors_rules) > 0 ? [
    for rule in aws_s3_bucket_cors_configuration.cors[0].cors_rule : {
      id              = rule.id
      allowed_methods = rule.allowed_methods
      allowed_origins = rule.allowed_origins
      allowed_headers = rule.allowed_headers
      expose_headers  = rule.expose_headers
      max_age_seconds = rule.max_age_seconds
    }
  ] : null
}

# CloudFront Origin Access Control outputs
output "origin_access_control_id" {
  description = "ID of the CloudFront Origin Access Control (if created)"
  value       = var.create_cloudfront_oac ? aws_cloudfront_origin_access_control.oac[0].id : null
}

output "origin_access_control_etag" {
  description = "ETag of the CloudFront Origin Access Control (if created)"
  value       = var.create_cloudfront_oac ? aws_cloudfront_origin_access_control.oac[0].etag : null
}

# Additional outputs for integration
output "bucket_policy" {
  description = "Bucket policy JSON (if configured)"
  value       = var.bucket_policy_json
  sensitive   = true
}

output "notification_configuration" {
  description = "Notification configuration of the bucket"
  value = var.notification_configuration != null ? {
    lambda_functions = lookup(var.notification_configuration, "lambda_functions", [])
    topics          = lookup(var.notification_configuration, "topics", [])
    queues          = lookup(var.notification_configuration, "queues", [])
  } : null
}

output "logging_configuration" {
  description = "Access logging configuration of the bucket"
  value = var.logging_configuration != null ? {
    target_bucket = var.logging_configuration.target_bucket
    target_prefix = lookup(var.logging_configuration, "target_prefix", null)
  } : null
}

output "intelligent_tiering_configuration" {
  description = "Intelligent tiering configuration of the bucket"
  value = var.intelligent_tiering_configuration != null ? {
    name   = var.intelligent_tiering_configuration.name
    status = var.intelligent_tiering_configuration.status
  } : null
}

# Metadata outputs
output "bucket_tags" {
  description = "Tags assigned to the bucket"
  value       = aws_s3_bucket.bucket.tags
}

output "force_destroy" {
  description = "Whether force destroy is enabled for the bucket"
  value       = var.force_destroy
}

output "acl" {
  description = "ACL applied to the bucket"
  value       = var.acl
}

output "object_ownership" {
  description = "Object ownership configuration of the bucket"
  value       = aws_s3_bucket_ownership_controls.ownership.rule[0].object_ownership
}