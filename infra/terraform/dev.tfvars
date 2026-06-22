environment         = "development"
aws_region          = "us-east-1"
aws_account_id      = "123456789012"
cloudfront_domain   = "dev.testproject.fpoiato.com"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# DynamoDB
dynamodb_billing_mode   = "PAY_PER_REQUEST"
dynamodb_read_capacity  = 5
dynamodb_write_capacity = 5
dynamodb_enable_stream  = false

# Cognito
cognito_email_source_arn           = "arn:aws:ses:us-east-1:123456789012:identity/dev@fpoiato.com"
cognito_email_reply_to             = "noreply-dev@fpoiato.com"
cognito_mfa_required               = false # Optional in dev
cognito_password_policy_min_length = 8     # Shorter for dev
cognito_require_lowercase          = true
cognito_require_uppercase          = true
cognito_require_numbers            = true
cognito_require_symbols            = false
cognito_callback_urls              = ["http://localhost:4200"]
cognito_logout_urls                = ["http://localhost:4200"]
cognito_sms_external_user_id       = "testproject-dev"
cognito_sms_caller_arn             = "arn:aws:iam::123456789012:role/testproject-dev-sms"

# API Gateway
api_gateway_stage_name    = "development"
api_gateway_endpoint_type = "REGIONAL"
