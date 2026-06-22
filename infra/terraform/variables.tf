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

# DynamoDB Variables
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode: PAY_PER_REQUEST or PROVISIONED"
  type        = string
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamodb_billing_mode)
    error_message = "Billing mode must be either PAY_PER_REQUEST or PROVISIONED"
  }
}

variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_enable_stream" {
  description = "Enable DynamoDB stream for future AWS Lambda triggers"
  type        = bool
  default     = false
}

# Cognito Variables
variable "cognito_email_source_arn" {
  description = "SES email source ARN (required in production)"
  type        = string
  default     = "arn:aws:ses:us-east-1:123456789012:identity/testproject@fpoiato.com"
}

variable "cognito_email_reply_to" {
  description = "Email reply-to address for Cognito"
  type        = string
  default     = "noreply@fpoiato.com"
}

variable "cognito_mfa_required" {
  description = "Require MFA for all users"
  type        = bool
  default     = true
}

variable "cognito_password_policy_min_length" {
  description = "Minimum password length"
  type        = number
  default     = 12
}

variable "cognito_require_lowercase" {
  description = "Require lowercase letters in password"
  type        = bool
  default     = true
}

variable "cognito_require_uppercase" {
  description = "Require uppercase letters in password"
  type        = bool
  default     = true
}

variable "cognito_require_numbers" {
  description = "Require numbers in password"
  type        = bool
  default     = true
}

variable "cognito_require_symbols" {
  description = "Require symbols in password"
  type        = bool
  default     = true
}

variable "cognito_callback_urls" {
  description = "Allowed callback URLs for OAuth flows"
  type        = list(string)
  default     = ["http://localhost:4200"]
}

variable "cognito_logout_urls" {
  description = "Allowed logout URLs"
  type        = list(string)
  default     = ["http://localhost:4200"]
}

variable "cognito_sms_external_user_id" {
  description = "External user ID for SMS configuration"
  type        = string
  default     = "testproject"
}

variable "cognito_sms_caller_arn" {
  description = "SNS caller ARN for SMS messages"
  type        = string
  default     = "arn:aws:iam::123456789012:role/testproject-sms-role"
}

# API Gateway Variables
variable "api_gateway_description" {
  description = "Description for API Gateway REST API"
  type        = string
  default     = "TestProject Backend API"
}

variable "api_gateway_stage_name" {
  description = "API Gateway stage name (should match environment)"
  type        = string
}

variable "api_gateway_endpoint_type" {
  description = "API Gateway endpoint type: REGIONAL, PRIVATE, or EDGE"
  type        = string
  validation {
    condition     = contains(["REGIONAL", "PRIVATE", "EDGE"], var.api_gateway_endpoint_type)
    error_message = "Endpoint type must be REGIONAL, PRIVATE, or EDGE"
  }
  default = "REGIONAL"
}

variable "api_gateway_binary_media_types" {
  description = "Binary media types supported by API Gateway"
  type        = list(string)
  default     = []
}

variable "api_gateway_minimum_compression_size" {
  description = "Minimum response size to compress (in bytes)"
  type        = number
  default     = 1024 # 1KB default compression threshold
  validation {
    condition     = can(var.api_gateway_minimum_compression_size >= 0 && var.api_gateway_minimum_compression_size <= 10485760)
    error_message = "Minimum compression size must be between 0 and 10485760"
  }
}
