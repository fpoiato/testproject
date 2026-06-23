# IAM role compartilhada pelas Lambdas de aplicacao.
resource "aws_iam_role" "lambda_exec" {
  name = "testproject-lambda-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamo" {
  name = "testproject-lambda-dynamo"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan",
        "dynamodb:Query",
      ]
      Resource = [
        "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/Veiculos-*",
        "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/Veiculos-*/index/*",
      ]
    }]
  })
}

# 5 funcoes Lambda (pacote compartilhado, publicadas/versionadas).
resource "aws_lambda_function" "fn" {
  for_each = local.functions

  function_name    = "testproject-${each.key}"
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "nodejs20.x"
  handler          = each.value
  filename         = data.archive_file.app_lambda.output_path
  source_code_hash = data.archive_file.app_lambda.output_base64sha256
  timeout          = 15
  memory_size      = 256
  publish          = true

  environment {
    variables = {
      CORS_ALLOWED_ORIGINS = "*"
    }
  }

  tags = { Component = "Lambda" }
}

# Aliases por slot de deploy (development/test/staging/production-blue/green).
# function_version e movido pelo pipeline; o Terraform ignora mudancas posteriores.
resource "aws_lambda_alias" "alias" {
  for_each = local.function_alias_pairs

  name             = each.value.alias
  function_name    = aws_lambda_function.fn[each.value.fn].function_name
  function_version = aws_lambda_function.fn[each.value.fn].version

  lifecycle {
    ignore_changes = [function_version, routing_config]
  }
}

# Permissao para o API Gateway invocar cada alias.
resource "aws_lambda_permission" "apigw" {
  for_each = local.function_alias_pairs

  statement_id  = "AllowAPIGW-${each.value.fn}-${each.value.alias}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn[each.value.fn].function_name
  qualifier     = aws_lambda_alias.alias[each.key].name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}
