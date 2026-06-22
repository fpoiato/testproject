# API Gateway REST API for backend endpoints

resource "aws_api_gateway_rest_api" "main" {
  name        = "testproject-${var.environment}"
  description = var.api_gateway_description

  # Endpoint configuration - REGIONAL (HTTPS only)
  endpoint_configuration {
    types = [var.api_gateway_endpoint_type]
  }

  # Binary media types
  binary_media_types = var.api_gateway_binary_media_types

  # Minimum compression size (in bytes)
  minimum_compression_size = var.api_gateway_minimum_compression_size

  # Disable CloudWatch logging (per user request)
  # enable_access_logs = false

  # Disable X-Ray tracing (per user request)

  # Tags
  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "API Gateway"
  }
}

# Root resource
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = ""
}

# Resource paths for Veiculos entity
# /veiculos
resource "aws_api_gateway_resource" "veiculos" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "veiculos"
}

# /veiculos/{placa}
resource "aws_api_gateway_resource" "veiculos_placa" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.veiculos.id
  path_part   = "{placa}"
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name        = "testproject-cognito-${var.environment}"
  rest_api_id = aws_api_gateway_rest_api.main.id
  type        = "COGNITO_USER_POOLS"

  provider_arns = [
    "arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_id}:userpool/${aws_cognito_user_pool.main.id}",
  ]
}

# Methods and Integrations for /veiculos - Mock integrations for now
# GET /veiculos
resource "aws_api_gateway_method" "veiculos_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.veiculos.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "veiculos_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.veiculos.id
  http_method = aws_api_gateway_method.veiculos_get.http_method

  type                    = "MOCK"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  response_templates = {
    "application/json" = jsonencode({
      message = "GET /veiculos - Mock integration"
    })
  }
}

# POST /veiculos
resource "aws_api_gateway_method" "veiculos_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.veiculos.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "veiculos_post" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.veiculos.id
  http_method = aws_api_gateway_method.veiculos_post.http_method

  type                    = "MOCK"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 201
    })
  }

  response_templates = {
    "application/json" = jsonencode({
      message = "POST /veiculos - Mock integration"
    })
  }
}

# GET /veiculos/{placa}
resource "aws_api_gateway_method" "veiculos_placa_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.veiculos_placa.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "veiculos_placa_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.veiculos_placa.id
  http_method = aws_api_gateway_method.veiculos_placa_get.http_method

  type                    = "MOCK"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  response_templates = {
    "application/json" = jsonencode({
      message = "GET /veiculos/{placa} - Mock integration"
      placa   = "$input.params('placa')"
    })
  }
}

# PUT /veiculos/{placa}
resource "aws_api_gateway_method" "veiculos_placa_put" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.veiculos_placa.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "veiculos_placa_put" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.veiculos_placa.id
  http_method = aws_api_gateway_method.veiculos_placa_put.http_method

  type                    = "MOCK"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  response_templates = {
    "application/json" = jsonencode({
      message = "PUT /veiculos/{placa} - Mock integration"
      placa   = "$input.params('placa')"
    })
  }
}

# DELETE /veiculos/{placa}
resource "aws_api_gateway_method" "veiculos_placa_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.veiculos_placa.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "veiculos_placa_delete" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.veiculos_placa.id
  http_method = aws_api_gateway_method.veiculos_placa_delete.http_method

  type                    = "MOCK"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 204
    })
  }

  response_templates = {
    "application/json" = jsonencode({
      message = "DELETE /veiculos/{placa} - Mock integration"
      placa   = "$input.params('placa')"
    })
  }
}

# Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redployment = sha1(jsonencode([
      aws_api_gateway_resource.root.id,
      aws_api_gateway_resource.veiculos.id,
      aws_api_gateway_resource.veiculos_placa.id,
      aws_api_gateway_method.veiculos_get.id,
      aws_api_gateway_method.veiculos_post.id,
      aws_api_gateway_method.veiculos_placa_get.id,
      aws_api_gateway_method.veiculos_placa_put.id,
      aws_api_gateway_method.veiculos_placa_delete.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.veiculos_get,
    aws_api_gateway_method.veiculos_post,
    aws_api_gateway_method.veiculos_placa_get,
    aws_api_gateway_method.veiculos_placa_put,
    aws_api_gateway_method.veiculos_placa_delete,
  ]
}

# Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.api_gateway_stage_name

  # HTTPS only (endpoint type = REGIONAL ensures this)
  xray_tracing_enabled = false

  # CloudWatch logging disabled (per user request)
  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.api_gw.arn
  #   format           = "$requestId"
  # }

  # Stage variables for environment-specific configuration
  variables = {
    Environment = var.environment
  }

  # Cache settings (disabled by default)
  cache_cluster_enabled = false

  # Method settings per API method
  method_settings {
    path        = "/*"
    method      = "*"
    http_method = "*"

    settings {
      # Caching settings
      caching_enabled = false

      # Logging settings (CloudWatch disabled per request)
      logging_level      = "OFF"
      data_trace_enabled = false

      # Throttling settings (disabled by default)
      throttling_burst_limit = 1000
      throttling_rate_limit  = 500

      # Metrics (disabled per request)
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
