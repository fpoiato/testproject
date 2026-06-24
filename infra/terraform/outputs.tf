output "api_id" {
  description = "ID do API Gateway REST (compartilhado)"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_invoke_urls" {
  description = "Invoke URL por ambiente (stage)"
  value = {
    for env, _ in local.environments :
    env => "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.aws_region}.amazonaws.com/${env}"
  }
}

output "frontend_urls" {
  description = "URLs publicas do frontend por ambiente"
  value = {
    for env, cfg in local.environments :
    env => "https://${cfg.subdomain}.${local.base_domain}"
  }
}

output "cognito_user_pool_ids" {
  value = { for env, _ in local.environments : env => aws_cognito_user_pool.main[env].id }
}

output "cognito_client_ids" {
  value = { for env, _ in local.environments : env => aws_cognito_user_pool_client.spa[env].id }
}

output "cloudfront_distribution_ids" {
  value = { for k, d in aws_cloudfront_distribution.frontend : k => d.id }
}

output "frontend_buckets" {
  value = { for k, b in aws_s3_bucket.frontend : k => b.bucket }
}

output "production_live_color" {
  value = var.production_live_color
}

output "ses_sender_identity" {
  description = "Identidade de dominio SES usada como remetente do Cognito (dev/test)"
  value       = aws_sesv2_email_identity.sender.email_identity
}

output "ses_sender_arn" {
  value = aws_sesv2_email_identity.sender.arn
}

output "ses_from_address" {
  value = local.ses_from_address
}

output "github_connection_arn" {
  description = "ARN da conexao AWS CodeConnections com o GitHub (autorize no console se PENDING)"
  value       = aws_codestarconnections_connection.github.arn
}

output "github_connection_status" {
  description = "Status da conexao GitHub (AVAILABLE apos autorizacao no console AWS)"
  value       = aws_codestarconnections_connection.github.connection_status
}

output "codepipeline_names" {
  description = "Nomes dos pipelines por ambiente"
  value       = { for env, p in aws_codepipeline.env : env => p.name }
}
