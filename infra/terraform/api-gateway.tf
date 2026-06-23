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

# Note: the deployment and stage are intentionally NOT created here.
# An API Gateway deployment requires at least one method, and the methods
# (plus integrations and Cognito authorizer) are created by the CDK stack
# (cdk/sam-app-cdk). The CDK stack therefore also creates the deployment and
# the "${var.api_gateway_stage_name}" stage.

# Note: The following resources will be created in CDK (TASK-012):
# - aws_api_gateway_resource (paths: /veiculos, /veiculos/{placa})
# - aws_api_gateway_method (GET, POST, PUT, DELETE)
# - aws_api_gateway_integration (Lambda integrations)
# - aws_api_gateway_authorizer (Cognito JWT authorizer)
# - aws_lambda_permission (allow API Gateway to invoke Lambda)
