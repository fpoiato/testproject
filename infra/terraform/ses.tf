# ---------------------------------------------------------------------------
# Identidade de dominio no SES (SESv2) para envio de e-mails transacionais
# (codigo de verificacao do Cognito). Usa Easy DKIM + custom MAIL FROM para
# passar SPF/DKIM/DMARC e nao cair no spam (ao contrario do COGNITO_DEFAULT).
#
# Remetente: TestProject <no-reply@testproject.fpoiato.com>
# A verificacao do dominio e automatica assim que os CNAMEs DKIM propagarem
# (sem clique). Conferir com: aws sesv2 get-email-identity --email-identity testproject.fpoiato.com
# ---------------------------------------------------------------------------

locals {
  ses_sender_domain = local.base_domain # testproject.fpoiato.com
  ses_mail_from     = "mail.${local.base_domain}"
  ses_from_address  = "TestProject <no-reply@${local.base_domain}>"
}

resource "aws_sesv2_email_identity" "sender" {
  email_identity = local.ses_sender_domain

  # Easy DKIM gerenciado pela AWS (chave RSA 2048).
  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }

  tags = {
    Component = "SES"
  }
}

# Registros CNAME do Easy DKIM (3 tokens) na zona fpoiato.com.
resource "aws_route53_record" "ses_dkim" {
  count = 3

  zone_id         = data.aws_route53_zone.main.zone_id
  name            = "${aws_sesv2_email_identity.sender.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${local.ses_sender_domain}"
  type            = "CNAME"
  ttl             = 600
  records         = ["${aws_sesv2_email_identity.sender.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
  allow_overwrite = true
}

# Custom MAIL FROM (alinha SPF com o dominio do remetente -> DMARC-safe).
resource "aws_sesv2_email_identity_mail_from_attributes" "sender" {
  email_identity         = aws_sesv2_email_identity.sender.email_identity
  mail_from_domain       = local.ses_mail_from
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
}

# MX do MAIL FROM apontando para o endpoint de feedback do SES na regiao.
resource "aws_route53_record" "ses_mail_from_mx" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = local.ses_mail_from
  type            = "MX"
  ttl             = 600
  records         = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
  allow_overwrite = true
}

# SPF do MAIL FROM.
resource "aws_route53_record" "ses_mail_from_spf" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = local.ses_mail_from
  type            = "TXT"
  ttl             = 600
  records         = ["v=spf1 include:amazonses.com ~all"]
  allow_overwrite = true
}

# DMARC (p=none) para o subdominio do remetente — monitora sem bloquear.
resource "aws_route53_record" "ses_dmarc" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = "_dmarc.${local.ses_sender_domain}"
  type            = "TXT"
  ttl             = 600
  records         = ["v=DMARC1; p=none; rua=mailto:nandopoiato@gmail.com"]
  allow_overwrite = true
}

# Autoriza o servico Cognito a enviar e-mail por esta identidade (mesma conta).
# Politica de sending authorization na identidade SES.
resource "aws_ses_identity_policy" "cognito_send" {
  identity = aws_sesv2_email_identity.sender.arn
  name     = "AllowCognitoSend"
  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [{
      Sid       = "AllowCognitoIdpSend"
      Effect    = "Allow"
      Principal = { Service = "cognito-idp.amazonaws.com" }
      Action = [
        "ses:SendEmail",
        "ses:SendRawEmail",
      ]
      Resource = aws_sesv2_email_identity.sender.arn
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = local.account_id
        }
      }
    }]
  })
}
