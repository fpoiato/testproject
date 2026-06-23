terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = local.project
      ManagedBy = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "main" {
  name         = "${local.zone_name}."
  private_zone = false
}

locals {
  project     = "testproject"
  zone_name   = "fpoiato.com"
  base_domain = "testproject.fpoiato.com"
  account_id  = data.aws_caller_identity.current.account_id

  # Ambientes logicos: cada um tem DynamoDB + Cognito + stage no API Gateway + frontend.
  # lambda_alias define qual alias da Lambda o stage do API Gateway invoca (stage variable).
  environments = {
    development = {
      subdomain    = "dev"
      mfa          = "OPTIONAL"
      password_min = 8
      lambda_alias = "development"
    }
    test = {
      subdomain    = "test"
      mfa          = "ON"
      password_min = 12
      lambda_alias = "test"
    }
    staging = {
      subdomain    = "staging"
      mfa          = "ON"
      password_min = 12
      lambda_alias = "staging"
    }
    production = {
      subdomain    = "app"
      mfa          = "ON"
      password_min = 12
      lambda_alias = "production-${var.production_live_color}"
    }
  }

  # Funcoes Lambda (pacote compartilhado; cada funcao aponta para um handler).
  functions = {
    GetVeiculos   = "handlers/getVeiculos.handler"
    GetVeiculo    = "handlers/getVeiculo.handler"
    CreateVeiculo = "handlers/createVeiculo.handler"
    UpdateVeiculo = "handlers/updateVeiculo.handler"
    DeleteVeiculo = "handlers/deleteVeiculo.handler"
  }

  # Aliases de deploy (slots). Producao tem blue e green.
  lambda_aliases = ["development", "test", "staging", "production-blue", "production-green"]

  # Produto funcao x alias (para aliases e permissions).
  function_alias_pairs = {
    for pair in setproduct(keys(local.functions), local.lambda_aliases) :
    "${pair[0]}__${pair[1]}" => { fn = pair[0], alias = pair[1] }
  }

  # Sites de frontend (bucket + cloudfront + cert + dns). Producao = blue/green.
  # O subdominio "app" e atribuido a cor ativa (var.production_live_color).
  frontend_sites = {
    development = {
      primary = "dev.${local.base_domain}"
      extra   = []
    }
    test = {
      primary = "test.${local.base_domain}"
      extra   = []
    }
    staging = {
      primary = "staging.${local.base_domain}"
      extra   = []
    }
    production-blue = {
      primary = "app-blue.${local.base_domain}"
      extra   = var.production_live_color == "blue" ? ["app.${local.base_domain}"] : []
    }
    production-green = {
      primary = "app-green.${local.base_domain}"
      extra   = var.production_live_color == "green" ? ["app.${local.base_domain}"] : []
    }
  }
}

# Pacote das Lambdas de aplicacao (apenas src/; o AWS SDK v3 ja existe no runtime nodejs20).
data "archive_file" "app_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../backend/src"
  output_path = "${path.module}/.build/app_lambda.zip"
}

# Pacote do Lambda Authorizer (inclui node_modules: aws-jwt-verify).
data "archive_file" "authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/../../backend/authorizer"
  output_path = "${path.module}/.build/authorizer.zip"
}
