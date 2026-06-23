# IAM role do Lambda Authorizer.
resource "aws_iam_role" "authorizer_exec" {
  name = "testproject-authorizer-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "authorizer_basic" {
  role       = aws_iam_role.authorizer_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Funcao do authorizer: mapeia stage -> user pool via STAGE_POOL_MAP.
resource "aws_lambda_function" "authorizer" {
  function_name    = "testproject-authorizer"
  role             = aws_iam_role.authorizer_exec.arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.authorizer.output_path
  source_code_hash = data.archive_file.authorizer.output_base64sha256
  timeout          = 10
  memory_size      = 256

  environment {
    variables = {
      STAGE_POOL_MAP = jsonencode({
        for env, _ in local.environments : env => {
          userPoolId = aws_cognito_user_pool.main[env].id
          clientId   = aws_cognito_user_pool_client.spa[env].id
        }
      })
    }
  }

  tags = { Component = "Authorizer" }
}

# Permite o API Gateway invocar o authorizer.
resource "aws_lambda_permission" "authorizer_invoke" {
  statement_id  = "AllowAPIGWInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/authorizers/*"
}

# Authorizer TOKEN no API Gateway (compartilhado por todos os stages).
resource "aws_api_gateway_authorizer" "cognito" {
  name                             = "testproject-jwt-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.main.id
  type                             = "TOKEN"
  identity_source                  = "method.request.header.Authorization"
  authorizer_uri                   = aws_lambda_function.authorizer.invoke_arn
  authorizer_result_ttl_in_seconds = 300
}
