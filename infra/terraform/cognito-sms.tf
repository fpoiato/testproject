# IAM role that Amazon Cognito assumes to publish SMS messages via SNS.
# Cognito requires the role's trust policy to scope sts:ExternalId to the
# user pool's external id (var.cognito_sms_external_user_id).

data "aws_iam_policy_document" "cognito_sms_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.cognito_sms_external_user_id]
    }
  }
}

resource "aws_iam_role" "cognito_sms" {
  name               = "testproject-cognito-sms-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.cognito_sms_assume.json

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "Cognito SMS"
  }
}

resource "aws_iam_role_policy" "cognito_sms" {
  name = "testproject-cognito-sms-${var.environment}"
  role = aws_iam_role.cognito_sms.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = "*"
      },
    ]
  })
}
