resource "aws_api_gateway_rest_api" "main" {
  name        = "testproject"
  description = "TestProject API (modelo compartilhado: stages + stage variables -> aliases de Lambda)"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "veiculos" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "veiculos"
}

resource "aws_api_gateway_resource" "veiculo_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.veiculos.id
  path_part   = "{id}"
}

locals {
  api_resource_ids = {
    veiculos   = aws_api_gateway_resource.veiculos.id
    veiculo_id = aws_api_gateway_resource.veiculo_id.id
  }

  api_methods = {
    list   = { resource = "veiculos", http = "GET", fn = "GetVeiculos" }
    create = { resource = "veiculos", http = "POST", fn = "CreateVeiculo" }
    get    = { resource = "veiculo_id", http = "GET", fn = "GetVeiculo" }
    update = { resource = "veiculo_id", http = "PUT", fn = "UpdateVeiculo" }
    delete = { resource = "veiculo_id", http = "DELETE", fn = "DeleteVeiculo" }
  }
}

resource "aws_api_gateway_method" "m" {
  for_each = local.api_methods

  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = local.api_resource_ids[each.value.resource]
  http_method   = each.value.http
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

# Integracao AWS_PROXY usando stage variable lambdaAlias para escolher o alias.
resource "aws_api_gateway_integration" "i" {
  for_each = local.api_methods

  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = local.api_resource_ids[each.value.resource]
  http_method             = aws_api_gateway_method.m[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.fn[each.value.fn].arn}:$${stageVariables.lambdaAlias}/invocations"
}

# CORS: metodo OPTIONS (MOCK) por recurso.
resource "aws_api_gateway_method" "options" {
  for_each = local.api_resource_ids

  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = each.value
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  for_each = local.api_resource_ids

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = each.value
  http_method = aws_api_gateway_method.options[each.key].http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  for_each = local.api_resource_ids

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = each.value
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  for_each = local.api_resource_ids

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = each.value
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = aws_api_gateway_method_response.options[each.key].status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.options]
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeploy = sha1(jsonencode([
      local.api_methods,
      local.api_resource_ids,
      [for k, m in aws_api_gateway_integration.i : m.uri],
      aws_api_gateway_authorizer.cognito.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.i,
    aws_api_gateway_integration.options,
    aws_api_gateway_integration_response.options,
  ]
}

# Um stage por ambiente; stage variable lambdaAlias seleciona o alias da Lambda.
resource "aws_api_gateway_stage" "env" {
  for_each = local.environments

  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.main.id
  stage_name    = each.key

  variables = {
    lambdaAlias = each.value.lambda_alias
  }

  tags = {
    Environment = each.key
    Component   = "API Gateway Stage"
  }
}
