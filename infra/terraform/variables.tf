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
