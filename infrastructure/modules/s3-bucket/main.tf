# S3 Bucket Module
# Reusable module for AWS S3 buckets with security, versioning, and lifecycle configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  
  tags = var.tags
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.kms_key_id != null ? var.bucket_key_enabled : null
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "pab" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# S3 bucket ACL
resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership]
  
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl
}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = lookup(rule.value, "filter", null) != null ? [rule.value.filter] : []
        content {
          prefix = lookup(filter.value, "prefix", null)
          
          dynamic "tag" {
            for_each = lookup(filter.value, "tags", {})
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration", null) != null ? rule.value.expiration : []
        content {
          days                         = lookup(expiration.value, "days", null)
          date                         = lookup(expiration.value, "date", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration", null) != null ? rule.value.noncurrent_version_expiration : []
        content {
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions", null)
        }
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])
        content {
          days          = lookup(transition.value, "days", null)
          date          = lookup(transition.value, "date", null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transitions", [])
        content {
          noncurrent_days           = lookup(noncurrent_version_transition.value, "noncurrent_days", null)
          newer_noncurrent_versions = lookup(noncurrent_version_transition.value, "newer_noncurrent_versions", null)
          storage_class            = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = lookup(rule.value, "abort_incomplete_multipart_upload", null) != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.versioning]
}

# S3 bucket CORS configuration
resource "aws_s3_bucket_cors_configuration" "cors" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      id              = lookup(cors_rule.value, "id", null)
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }
}

# S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "website" {
  count  = var.website_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = var.website_configuration.index_document
  }

  dynamic "error_document" {
    for_each = lookup(var.website_configuration, "error_document", null) != null ? [var.website_configuration.error_document] : []
    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = lookup(var.website_configuration, "redirect_all_requests_to", null) != null ? [var.website_configuration.redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = lookup(redirect_all_requests_to.value, "protocol", null)
    }
  }
}

# S3 bucket notification configuration
resource "aws_s3_bucket_notification" "notification" {
  count  = var.notification_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "lambda_function" {
    for_each = lookup(var.notification_configuration, "lambda_functions", [])
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events             = lambda_function.value.events
      filter_prefix      = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix      = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  dynamic "topic" {
    for_each = lookup(var.notification_configuration, "topics", [])
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = lookup(topic.value, "filter_prefix", null)
      filter_suffix = lookup(topic.value, "filter_suffix", null)
    }
  }

  dynamic "queue" {
    for_each = lookup(var.notification_configuration, "queues", [])
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
    }
  }

  depends_on = [
    aws_s3_bucket.bucket
  ]
}

# S3 bucket policy
resource "aws_s3_bucket_policy" "policy" {
  count  = var.bucket_policy_json != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  policy = var.bucket_policy_json

  depends_on = [aws_s3_bucket_public_access_block.pab]
}

# CloudFront Origin Access Control (OAC) for secure CloudFront access
resource "aws_cloudfront_origin_access_control" "oac" {
  count                             = var.create_cloudfront_oac ? 1 : 0
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy for CloudFront OAC
resource "aws_s3_bucket_policy" "cloudfront_oac_policy" {
  count  = var.create_cloudfront_oac ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.pab,
    aws_cloudfront_origin_access_control.oac
  ]
}

# S3 bucket logging
resource "aws_s3_bucket_logging" "logging" {
  count  = var.logging_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  target_bucket = var.logging_configuration.target_bucket
  target_prefix = lookup(var.logging_configuration, "target_prefix", null)

  dynamic "target_grant" {
    for_each = lookup(var.logging_configuration, "target_grants", [])
    content {
      grantee {
        id   = lookup(target_grant.value.grantee, "id", null)
        type = target_grant.value.grantee.type
        uri  = lookup(target_grant.value.grantee, "uri", null)
      }
      permission = target_grant.value.permission
    }
  }
}

# S3 bucket intelligent tiering configuration
resource "aws_s3_bucket_intelligent_tiering_configuration" "intelligent_tiering" {
  count  = var.intelligent_tiering_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  name   = var.intelligent_tiering_configuration.name
  status = var.intelligent_tiering_configuration.status

  dynamic "filter" {
    for_each = lookup(var.intelligent_tiering_configuration, "filter", null) != null ? [var.intelligent_tiering_configuration.filter] : []
    content {
      prefix = lookup(filter.value, "prefix", null)
      
      dynamic "tag" {
        for_each = lookup(filter.value, "tags", {})
        content {
          key   = tag.key
          value = tag.value
        }
      }
    }
  }

  dynamic "tiering" {
    for_each = lookup(var.intelligent_tiering_configuration, "tiering", [])
    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }
}