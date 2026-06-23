# ---------------------------------------------------------------------------
# Certificado ACM unico cobrindo todos os subdominios de frontend (us-east-1).
# ---------------------------------------------------------------------------
locals {
  all_cert_domains = [
    "dev.${local.base_domain}",
    "test.${local.base_domain}",
    "staging.${local.base_domain}",
    "app.${local.base_domain}",
    "app-blue.${local.base_domain}",
    "app-green.${local.base_domain}",
  ]

  # Registros de alias DNS: um por dominio (primary + extra) apontando para a
  # distribuicao do site correspondente. Chaves conhecidas no plan.
  frontend_alias_records = merge([
    for k, s in local.frontend_sites : {
      for d in concat([s.primary], s.extra) : d => { site = k }
    }
  ]...)
}

resource "aws_acm_certificate" "frontend" {
  domain_name               = local.all_cert_domains[0]
  subject_alternative_names = slice(local.all_cert_domains, 1, length(local.all_cert_domains))
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = toset(local.all_cert_domains)

  zone_id = data.aws_route53_zone.main.zone_id
  name    = one([for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.resource_record_name if dvo.domain_name == each.key])
  type    = one([for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.resource_record_type if dvo.domain_name == each.key])
  records = [one([for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.resource_record_value if dvo.domain_name == each.key])]
  ttl     = 60

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "frontend" {
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# ---------------------------------------------------------------------------
# Por site (dev/test/staging/production-blue/production-green): S3 + CloudFront.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "frontend" {
  for_each = local.frontend_sites
  bucket   = "testproject-frontend-${each.key}-${local.account_id}"
  tags     = { Site = each.key, Component = "Frontend" }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  for_each                = local.frontend_sites
  bucket                  = aws_s3_bucket.frontend[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  for_each = local.frontend_sites
  bucket   = aws_s3_bucket.frontend[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  for_each                          = local.frontend_sites
  name                              = "testproject-${each.key}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend" {
  for_each        = local.frontend_sites
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  comment         = "testproject ${each.key}"
  aliases         = concat([each.value.primary], each.value.extra)
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.frontend[each.key].bucket_regional_domain_name
    origin_id                = "s3-${each.key}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend[each.key].id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-${each.key}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # SPA: 403/404 -> index.html
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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.frontend.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = { Site = each.key, Component = "CloudFront" }
}

resource "aws_s3_bucket_policy" "frontend" {
  for_each = local.frontend_sites
  bucket   = aws_s3_bucket.frontend[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudFrontOAC"
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend[each.key].arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.frontend[each.key].arn
        }
      }
    }]
  })
}

# Registros DNS (alias A) para cada subdominio -> distribuicao.
resource "aws_route53_record" "frontend" {
  for_each = local.frontend_alias_records

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend[each.value.site].domain_name
    zone_id                = "Z2FDTNDATAQYW2" # zona fixa do CloudFront
    evaluate_target_health = false
  }
}
