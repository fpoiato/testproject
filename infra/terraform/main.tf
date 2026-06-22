# Terraform Main Configuration

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "testproject-terraform-state-dev"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "testproject-terraform-locks"
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "testproject"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data Source to get current AWS Account ID
data "aws_caller_identity" "current" {}

# Data Source to get current AWS Region
data "aws_region" "current" {}
