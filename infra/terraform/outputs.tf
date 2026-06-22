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
