#!/bin/bash
set -e

echo "📦 Bootstrapping CDK for testproject..."

# Get Terraform outputs from development branch
cd infra/terraform
terraform refresh -var-file=dev.tfvars

# Create .env file for CDK
cd ../../
cat > .env << EOF
# Terraform Outputs (from development environment)
API_GATEWAY_ID=$(terraform output -raw api_gateway_rest_api_id)
API_GATEWAY_EXECUTION_ARN=$(terraform output -raw api_gateway_execution_arn)
DYNAMODB_TABLE_NAME=$(terraform output -raw dynamodb_veiculos_table_name)
COGNITO_USER_POOL_ID=$(terraform output -raw cognito_user_pool_id)
COGNITO_USER_POOL_ARN=$(terraform output -raw cognito_user_pool_arn)
COGNITO_USER_POOL_ENDPOINT=$(terraform output -raw cognito_user_pool_endpoint)
COGNITO_IDENTITY_POOL_ID=$(terraform output -raw cognito_identity_pool_id)

# Environment configuration
AWS_REGION=$(terraform output -raw aws_region)
AWS_ACCOUNT_ID=$(terraform output -raw aws_account_id)
ENVIRONMENT=development
EOF

echo "✅ .env file created with Terraform outputs"
echo "📊 Environment variables set:"
echo "   - API_GATEWAY_ID: $API_GATEWAY_ID"
echo "   - DYNAMODB_TABLE_NAME: $DYNAMODB_TABLE_NAME"
echo "   - COGNITO_USER_POOL_ID: $COGNITO_USER_POOL_ID"

cd cdk/sam-app-cdk

# Bootstrap CDK
echo "🚀 Bootstrapping CDK..."
npm run build
npx cdk bootstrap
