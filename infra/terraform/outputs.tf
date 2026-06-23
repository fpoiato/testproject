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
