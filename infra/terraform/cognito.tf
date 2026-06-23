# Ambientes que enviam e-mail via SES (DEVELOPER) com dominio proprio + DKIM,
# em vez do COGNITO_DEFAULT (que estava caindo/sumindo na entrega ao Gmail).
# staging/production seguem em COGNITO_DEFAULT por ora (menor blast radius).
locals {
  cognito_ses_envs = toset(["development", "staging", "test", "production-blue", "production-green"])
}

# Um Cognito User Pool por ambiente. Self sign-up por email + TOTP MFA.
resource "aws_cognito_user_pool" "main" {
  for_each = local.environments

  name = "testproject-${each.key}"

  # Self sign-up habilitado (auto-enroll por email).
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # dev/test: SES (DEVELOPER) com remetente no dominio testproject.fpoiato.com.
  # demais: COGNITO_DEFAULT.
  email_configuration {
    email_sending_account = contains(local.cognito_ses_envs, each.key) ? "DEVELOPER" : "COGNITO_DEFAULT"
    from_email_address    = contains(local.cognito_ses_envs, each.key) ? local.ses_from_address : null
    source_arn            = contains(local.cognito_ses_envs, each.key) ? aws_sesv2_email_identity.sender.arn : null
  }

  password_policy {
    minimum_length                   = each.value.password_min
    require_lowercase                = true
    require_numbers                  = true
    require_uppercase                = true
    require_symbols                  = each.key == "development" ? false : true
    temporary_password_validity_days = 7
  }

  # MFA via TOTP (app autenticador).
  mfa_configuration = each.value.mfa
  software_token_mfa_configuration {
    enabled = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "TestProject - codigo de verificacao"
    email_message        = "Seu codigo de verificacao e {####}"
  }

  tags = {
    Environment = each.key
    Component   = "Cognito"
  }
}

resource "aws_cognito_user_pool_client" "spa" {
  for_each = local.environments

  name         = "testproject-spa-${each.key}"
  user_pool_id = aws_cognito_user_pool.main[each.key].id

  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  supported_identity_providers = ["COGNITO"]

  callback_urls = compact([
    "https://${each.value.subdomain}.${local.base_domain}",
    each.key == "development" ? "http://localhost:4200" : "",
  ])
  logout_urls = compact([
    "https://${each.value.subdomain}.${local.base_domain}",
    each.key == "development" ? "http://localhost:4200" : "",
  ])

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}
