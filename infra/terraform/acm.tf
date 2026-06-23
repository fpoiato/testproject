# ACM certificate + DNS validation for the CloudFront custom domain.
# The certificate must live in us-east-1 to be used by CloudFront.

data "aws_route53_zone" "main" {
  name         = "fpoiato.com"
  private_zone = false
}

resource "aws_acm_certificate" "frontend" {
  domain_name       = var.cloudfront_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "ACM"
  }
}

# DNS validation records in the fpoiato.com hosted zone
resource "aws_route53_record" "frontend_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.main.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "frontend" {
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = [for r in aws_route53_record.frontend_cert_validation : r.fqdn]
}

# Alias record pointing the custom domain at the CloudFront distribution
resource "aws_route53_record" "frontend_alias_a" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.cloudfront_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend_alias_aaaa" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.cloudfront_domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}
