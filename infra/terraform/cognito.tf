# Amazon Cognito User Pool for Authentication

resource "aws_cognito_user_pool" "main" {
  name = "testproject-${var.environment}"

  # Admin create user only (no sign-up via API initially)
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  # Alias attributes (email as username)
  alias_attributes = ["email", "preferred_username"]

  # Auto-verified attributes
  auto_verified_attributes = ["email"]

  # Email configuration (DEVELOPER mode so Cognito sends via the verified
  # SES identity in var.cognito_email_source_arn)
  email_configuration {
    email_sending_account  = "DEVELOPER"
    source_arn             = var.cognito_email_source_arn
    reply_to_email_address = var.cognito_email_reply_to
  }

  # Password policy
  password_policy {
    minimum_length                   = var.cognito_password_policy_min_length
    require_lowercase                = var.cognito_require_lowercase
    require_numbers                  = var.cognito_require_numbers
    require_symbols                  = var.cognito_require_symbols
    require_uppercase                = var.cognito_require_uppercase
    temporary_password_validity_days = 7
  }

  # MFA Configuration
  mfa_configuration = var.cognito_mfa_required ? "ON" : "OPTIONAL"
  software_token_mfa_configuration {
    enabled = var.cognito_mfa_required
  }

  # Account recovery settings
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Verification settings
  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
    email_subject        = "Verify your email address"
    email_message        = "Thanks for signing up! Your verification code is {####}"
  }

  # SMS verification (enabled but MFA uses TOTP)
  sms_configuration {
    external_id    = var.cognito_sms_external_user_id
    sns_caller_arn = aws_iam_role.cognito_sms.arn
  }

  # Device tracking
  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = false
  }

  # Tags
  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "Cognito"
  }
}

# SPA Application Client (no secret, uses PKCE)
resource "aws_cognito_user_pool_client" "spa" {
  user_pool_id = aws_cognito_user_pool.main.id

  name                          = "testproject-spa-${var.environment}"
  generate_secret               = false # PKCE for public clients
  prevent_user_existence_errors = "ENABLED"

  # Allowed OAuth flows
  allowed_oauth_flows  = ["implicit", "code"] # PKCE uses code flow
  allowed_oauth_scopes = ["email", "openid", "profile"]

  # Callback URLs (example, customize per environment)
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  # Explicit auth flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  # Token configuration
  access_token_validity  = 1  # 1 hour
  id_token_validity      = 1  # 1 hour
  refresh_token_validity = 30 # 30 days

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # Read attributes
  read_attributes = [
    "email",
    "email_verified",
    "phone_number",
    "phone_number_verified",
    "preferred_username",
    "profile",
  ]

  # Write attributes
  write_attributes = [
    "email",
    "phone_number",
    "preferred_username",
  ]

  supported_identity_providers = ["COGNITO"]

  # Analytics configuration (optional in the future)
  # analytics_configuration {
  #   application_id  = var.cognito_analytics_app_id
  #   external_id     = var.cognito_analytics_external_id
  #   role_arn        = var.cognito_analytics_role_arn
  #   user_data_shared = false
  # }
}

# Cognito Identity Pool (Federated Identities)
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "testproject-${var.environment}"
  allow_unauthenticated_identities = false # Require authentication

  # Cognito User Pool as identity provider
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.spa.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = true
  }

  # Tags
  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "Cognito"
  }
}

# IAM Role for authenticated users
data "aws_iam_policy_document" "authenticated" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"

      values = [aws_cognito_identity_pool.main.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"

      values = ["authenticated"]
    }
  }
}

resource "aws_iam_role" "authenticated" {
  name               = "testproject-cognito-authenticated-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.authenticated.json

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "Cognito"
  }
}

# IAM Role policy for authenticated users (minimal permissions - update as needed)
resource "aws_iam_role_policy" "authenticated" {
  name = "testproject-cognito-authenticated-${var.environment}"
  role = aws_iam_role.authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
        ]
        Resource = "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/Veiculos-${var.environment}"
      },
    ]
  })
}

# Attach role to identity pool
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    authenticated = aws_iam_role.authenticated.arn
  }
}
