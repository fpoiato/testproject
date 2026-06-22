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
