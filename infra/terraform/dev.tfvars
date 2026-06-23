environment       = "development"
aws_region        = "us-east-1"
aws_account_id    = "986873053420"
cloudfront_domain = "dev.testproject.fpoiato.com"
# acm_certificate_arn is no longer needed: the certificate is created and
# DNS-validated in acm.tf.

# DynamoDB
dynamodb_billing_mode   = "PAY_PER_REQUEST"
dynamodb_read_capacity  = 5
dynamodb_write_capacity = 5
dynamodb_enable_stream  = false

# Cognito
cognito_email_source_arn           = "arn:aws:ses:us-east-1:986873053420:identity/nandopoiato@gmail.com"
cognito_email_reply_to             = "nandopoiato@gmail.com"
cognito_mfa_required               = false # Optional in dev
cognito_password_policy_min_length = 8     # Shorter for dev
cognito_require_lowercase          = true
cognito_require_uppercase          = true
cognito_require_numbers            = true
cognito_require_symbols            = false
cognito_callback_urls              = ["http://localhost:4200"]
cognito_logout_urls                = ["http://localhost:4200"]
cognito_sms_external_user_id       = "testproject-dev"
# cognito_sms_caller_arn is no longer needed: the SMS role is created in
# cognito-sms.tf and referenced directly.

# API Gateway
api_gateway_stage_name    = "development"
api_gateway_endpoint_type = "REGIONAL"

# CodeBuild / CodePipeline
codebuild_log_retention_days = 7
pipeline_alert_email         = "nandopoiato@gmail.com"
