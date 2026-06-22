variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (development, test, staging, production-blue, production-green)"
  type        = string
  validation {
    condition     = contains(["development", "test", "staging", "production-blue", "production-green"], var.environment)
    error_message = "Environment must be one of: development, test, staging, production-blue, production-green"
  }
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "cloudfront_domain" {
  description = "CloudFront custom domain (e.g., dev.testproject.fpoiato.com)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9.-]*$", var.cloudfront_domain))
    error_message = "Domain must contain only lowercase letters, numbers, dots, and hyphens"
  }
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the custom domain (must be in us-east-1 for CloudFront)"
  type        = string
}
