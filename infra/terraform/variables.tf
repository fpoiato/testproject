# Terraform Variables

# Environment
variable "environment" {
  description = "Environment name (development, test, staging, production-blue, production-green)"
  type        = string
  validation {
    condition     = contains(["development", "test", "staging", "production-blue", "production-green"], var.environment)
    error_message = "Environment must be one of: development, test, staging, production-blue, production-green"
  }
}

# AWS Region
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# AWS Account ID
variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

# Project Name
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "testproject"
}

# GitHub OAuth token for CodeBuild source authentication
variable "github_oauth_token" {
  description = "GitHub OAuth token for CodeBuild source authentication"
  type        = string
  sensitive   = true
  default     = ""
}

# CodeBuild log retention days
variable "codebuild_log_retention_days" {
  description = "CloudWatch Logs retention days for CodeBuild projects"
  type        = number
  default     = 7
}

# ========================================
# S3 Variables
# ========================================

variable "s3_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "s3_lifecycle Days" {
  description = "Days before transitioning to Standard-IA"
  type        = number
  default     = 30
}

# ========================================
# CloudFront Variables
# ========================================

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100" # US, Canada, Europe
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100"
  }
}

# ========================================
# DynamoDB Variables
# ========================================

variable "veiculos_table_read_capacity" {
  description = "Veiculos table read capacity units"
  type        = number
  default     = 5
}

variable "veiculos_table_write_capacity" {
  description = "Veiculos table write capacity units"
  type        = number
  default     = 5
}

# ========================================
# Cognito Variables
# ========================================

variable "cognito_user_pool_name" {
  description = "Cognito User Pool name"
  type        = string
  default     = "testproject-users"
}

variable "cognito_identity_pool_name" {
  description = "Cognito Identity Pool name"
  type        = string
  default     = "testproject-identity"
}

variable "cognito_email_verification_type" {
  description = "Cognito email verification type"
  type        = string
  default     = "CODE"
  validation {
    condition     = contains(["CODE", "LINK", "NONE"], var.cognito_email_verification_type)
    error_message = "Email verification type must be one of: CODE, LINK, NONE"
  }
}

variable "cognito_required_mfa" {
  description = "Require MFA for Cognito Users (false for development, true for other environments)"
  type        = bool
  default     = false
}

# ========================================
# API Gateway Variables
# ========================================

variable "api_gateway_endpoint_type" {
  description = "API Gateway endpoint type (REGIONAL, EDGE, PRIVATE)"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.api_gateway_endpoint_type)
    error_message = "API Gateway endpoint type must be one of: REGIONAL, EDGE, PRIVATE"
  }
}

variable "api_gateway_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "api"
}

variable "api_gateway_binary_media_types" {
  description = "API Gateway binary media types"
  type        = list(string)
  default     = []
}

variable "api_gateway_minimum_compression_size" {
  description = "API Gateway minimum compression size (bytes)"
  type        = number
  default     = 0
}

# ========================================
# Frontend Variables
# ========================================

variable "frontend_distribution_enabled" {
  description = "Enable CloudFront distribution for frontend"
  type        = bool
  default     = true
}

variable "cdn_domain_name" {
  description = "CDN domain name (e.g., cdn.fpoiato.com)"
  type        = string
  default     = ""
}
