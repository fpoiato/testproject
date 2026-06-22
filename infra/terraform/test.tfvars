environment         = "test"
aws_region          = "us-east-1"
aws_account_id      = "123456789012"
cloudfront_domain   = "test.testproject.fpoiato.com"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# DynamoDB
dynamodb_billing_mode   = "PAY_PER_REQUEST"
dynamodb_read_capacity  = 5
dynamodb_write_capacity = 5
dynamodb_enable_stream  = false

# Cognito
cognito_email_source_arn           = "arn:aws:ses:us-east-1:123456789012:identity/test@fpoiato.com"
cognito_email_reply_to             = "noreply@fpoiato.com"
cognito_mfa_required               = true
cognito_password_policy_min_length = 12
cognito_require_lowercase          = true
cognito_require_uppercase          = true
cognito_require_numbers            = true
cognito_require_symbols            = true
cognito_callback_urls              = ["https://test.testproject.fpoiato.com"]
cognito_logout_urls                = ["https://test.testproject.fpoiato.com"]
cognito_sms_external_user_id       = "testproject"
cognito_sms_caller_arn             = "arn:aws:iam::123456789012:role/testproject-sms-role"
