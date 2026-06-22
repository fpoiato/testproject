# CloudFront Distribution for frontend S3 hosting
resource "aws_cloudfront_distribution" "frontend" {
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100" # US/Europe (cheapest, expand as needed)

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3-${var.environment}"

    # Use S3 Origin Access Control instead of Origin Access Identity
    s3_origin_config {
      origin_access_identity = "" # Must be empty when using OAC
    }

    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.environment}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400    # 24 hours
    max_ttl                = 31536000 # 1 year

    # Compress text-based assets
    compress = true

    # Use the ACM certificate for custom domain
    viewer_certificate {
      acm_certificate_arn      = var.acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  # Custom domain aliases
  aliases = [var.cloudfront_domain]

  # Default root object
  default_root_object = "index.html"

  # Custom error responses for SPA routing
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # Restrictions (optional - allow all by default)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Tags
  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "CloudFront"
  }
}

# S3 Origin Access Control (OAC) for private bucket access
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.environment}-frontend-oac"
  description                       = "OAC for ${var.environment} frontend S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Update S3 bucket policy to allow CloudFront OAC access
resource "aws_s3_bucket_policy" "frontend_cloudfront" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.frontend.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      },
    ]
  })
}

# Output CloudFront domain
output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}
