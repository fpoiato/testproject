output "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_bucket_arn" {
  description = "ARN of the S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend.arn
}

# DynamoDB Outputs
output "dynamodb_veiculos_table_name" {
  description = "Name of the DynamoDB Veiculos table"
  value       = aws_dynamodb_table.veiculos.name
}

output "dynamodb_veiculos_table_arn" {
  description = "ARN of the DynamoDB Veiculos table"
  value       = aws_dynamodb_table.veiculos.arn
}

output "dynamodb_veiculos_stream_arn" {
  description = "ARN of the DynamoDB Veiculos table stream (if enabled)"
  value       = aws_dynamodb_table.veiculos.stream_arn
}

# Cognito Outputs
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
  description = "Cognito SPA Client ID"
  value       = aws_cognito_user_pool_client.spa.id
}

output "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = aws_cognito_identity_pool.main.id
}

# API Gateway Outputs (base infrastructure)
output "api_gateway_rest_api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_rest_api_name" {
  description = "API Gateway REST API Name"
  value       = aws_api_gateway_rest_api.main.name
}

output "api_gateway_root_resource_id" {
  description = "API Gateway root resource ID (needed by CDK to import the API)"
  value       = aws_api_gateway_rest_api.main.root_resource_id
}

output "api_gateway_execution_arn" {
  description = "API Gateway Execution ARN"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

# Note: the deployment/stage and invoke_url are created by the CDK stack
# (cdk/sam-app-cdk) after it adds the methods.

# ========================================
# CodePipeline Outputs
# ========================================

output "codepipeline_backend_id" {
  description = "CodePipeline Backend ID"
  value       = aws_codepipeline.backend.id
}

output "codepipeline_backend_arn" {
  description = "CodePipeline Backend ARN"
  value       = aws_codepipeline.backend.arn
}

output "codepipeline_backend_name" {
  description = "CodePipeline Backend Name"
  value       = aws_codepipeline.backend.name
}

output "codepipeline_frontend_id" {
  description = "CodePipeline Frontend ID"
  value       = aws_codepipeline.frontend.id
}

output "codepipeline_frontend_arn" {
  description = "CodePipeline Frontend ARN"
  value       = aws_codepipeline.frontend.arn
}

output "codepipeline_frontend_name" {
  description = "CodePipeline Frontend Name"
  value       = aws_codepipeline.frontend.name
}

output "codepipeline_artifacts_bucket_name" {
  description = "CodePipeline Artifacts S3 Bucket Name"
  value       = aws_s3_bucket.codepipeline_artifacts.bucket
}

output "codepipeline_artifacts_bucket_arn" {
  description = "CodePipeline Artifacts S3 Bucket ARN"
  value       = aws_s3_bucket.codepipeline_artifacts.arn
}

output "codepipeline_alerts_topic_arn" {
  description = "Pipeline Alerts SNS Topic ARN"
  value       = aws_sns_topic.pipeline_alerts.arn
}

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
