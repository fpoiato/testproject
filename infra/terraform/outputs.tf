# Terraform Outputs

# ========================================
# AWS Account Outputs
# ========================================

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

# ========================================
# S3 Bucket Outputs
# ========================================

output "s3_frontend_bucket_id" {
  description = "S3 Frontend Bucket ID"
  value       = aws_s3_bucket.frontend.id
}

output "s3_frontend_bucket_arn" {
  description = "S3 Frontend Bucket ARN"
  value       = aws_s3_bucket.frontend.arn
}

output "s3_frontend_bucket_name" {
  description = "S3 Frontend Bucket Name"
  value       = aws_s3_bucket.frontend.bucket
}

# ========================================
# CloudFront Distribution Outputs
# ========================================

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN"
  value       = aws_cloudfront_distribution.main.arn
}

output "cdn_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cdn_hosted_zone_id" {
  description = "CloudFront Distribution Hosted Zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

# ========================================
# DynamoDB Table Outputs
# ========================================

output "dynamodb_veiculos_table_name" {
  description = "DynamoDB Veiculos Table Name"
  value       = aws_dynamodb_table.veiculos.name
}

output "dynamodb_veiculos_table_arn" {
  description = "DynamoDB Veiculos Table ARN"
  value       = aws_dynamodb_table.veiculos.arn
}

# ========================================
# Cognito User Pool Outputs
# ========================================

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_endpoint" {
  description = "Cognito User Pool Endpoint"
  value       = aws_cognito_user_pool.main.endpoint
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

# ========================================
# Cognito Identity Pool Outputs
# ========================================

output "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = aws_cognito_identity_pool.main.id
}

output "cognito_identity_pool_arn" {
  description = "Cognito Identity Pool ARN"
  value       = aws_cognito_identity_pool.main.arn
}

# ========================================
# API Gateway Outputs (base infrastructure)
# ========================================

output "api_gateway_rest_api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_rest_api_name" {
  description = "API Gateway REST API Name"
  value       = aws_api_gateway_rest_api.main.name
}

output "api_gateway_execution_arn" {
  description = "API Gateway Execution ARN"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "api_gateway_stage_name" {
  description = "API Gateway Stage Name"
  value       = aws_api_gateway_stage.main.stage_name
}

output "api_gateway_deployment_id" {
  description = "API Gateway Deployment ID"
  value       = aws_api_gateway_deployment.main.id
}

# ========================================
# CodeBuild Project Outputs
# ========================================

output "codebuild_backend_project_id" {
  description = "CodeBuild Backend Project ID"
  value       = aws_codebuild_project.backend.id
}

output "codebuild_backend_project_arn" {
  description = "CodeBuild Backend Project ARN"
  value       = aws_codebuild_project.backend.arn
}

output "codebuild_backend_project_name" {
  description = "CodeBuild Backend Project Name"
  value       = aws_codebuild_project.backend.name
}

output "codebuild_frontend_project_id" {
  description = "CodeBuild Frontend Project ID"
  value       = aws_codebuild_project.frontend.id
}

output "codebuild_frontend_project_arn" {
  description = "CodeBuild Frontend Project ARN"
  value       = aws_codebuild_project.frontend.arn
}

output "codebuild_frontend_project_name" {
  description = "CodeBuild Frontend Project Name"
  value       = aws_codebuild_project.frontend.name
}

# ========================================
# CodeBuild Log Group Outputs
# ========================================

output "codebuild_backend_log_group_arn" {
  description = "CodeBuild Backend Log Group ARN"
  value       = aws_cloudwatch_log_group.codebuild_backend.arn
}

output "codebuild_backend_log_group_name" {
  description = "CodeBuild Backend Log Group Name"
  value       = aws_cloudwatch_log_group.codebuild_backend.name
}

output "codebuild_frontend_log_group_arn" {
  description = "CodeBuild Frontend Log Group ARN"
  value       = aws_cloudwatch_log_group.codebuild_frontend.arn
}

output "codebuild_frontend_log_group_name" {
  description = "CodeBuild Frontend Log Group Name"
  value       = aws_cloudwatch_log_group.codebuild_frontend.name
}
