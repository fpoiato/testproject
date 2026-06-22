output "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_bucket_arn" {
  description = "ARN of the S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}
