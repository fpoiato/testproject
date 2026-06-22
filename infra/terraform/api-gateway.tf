# API Gateway REST API - base infrastructure only

resource "aws_api_gateway_rest_api" "main" {
  name        = "testproject-${var.environment}"
  description = "TestProject Backend REST API - Base Infrastructure"

  # Endpoint configuration - REGIONAL (HTTPS only)
  endpoint_configuration {
    types = [var.api_gateway_endpoint_type]
  }

  # Binary media types (optional, expand as needed)
  binary_media_types = var.api_gateway_binary_media_types

  # Minimum compression size (in bytes)
  minimum_compression_size = var.api_gateway_minimum_compression_size

  # Note: CloudWatch logging and X-Ray tracing will be configured in CDK (TASK-012)

  # Tags
  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "API Gateway"
  }
}

# API Gateway Stage - deployment stage only
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.api_gateway_stage_name

  # CloudWatch logging disabled (will be configured in CDK if needed)
  # X-Ray tracing disabled (will be configured in CDK if needed)

  # Stage variables for environment-specific configuration
  variables = {
    Environment = var.environment
  }

  # Cache settings (disabled by default, can be enabled in CDK)
  cache_cluster_enabled = false

  # Method settings per API method (defaults, will be configured in CDK)
  method_settings {
    path        = "/*"
    method      = "*"
    http_method = "*"

    settings {
      caching_enabled = false

      # Logging and tracing (disabled here, will be configured in CDK)
      logging_level      = "OFF"
      data_trace_enabled = false

      # Throttling settings (defaults, will be configured in CDK)
      throttling_burst_limit = 1000
      throttling_rate_limit  = 500

      # Metrics (disabled by default, will be configured in CDK)
      metrics_enabled = false
    }
  }

  # Tags
  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "API Gateway Stage"
  }
}

# Note: Deployment trigger will be in CDK (TASK-012)
# This is a placeholder deployment for now
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redployment = sha1(jsonencode([
      aws_api_gateway_rest_api.main.id,
      aws_api_gateway_rest_api.main.name,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_rest_api.main,
    aws_api_gateway_stage.main,
  ]
}

# Note: The following resources will be created in CDK (TASK-012):
# - aws_api_gateway_resource (paths: /veiculos, /veiculos/{placa})
# - aws_api_gateway_method (GET, POST, PUT, DELETE)
# - aws_api_gateway_integration (Lambda integrations)
# - aws_api_gateway_authorizer (Cognito JWT authorizer)
# - aws_lambda_permission (allow API Gateway to invoke Lambda)
