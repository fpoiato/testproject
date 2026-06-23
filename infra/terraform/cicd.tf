locals {
  function_list = "GetVeiculos GetVeiculo CreateVeiculo UpdateVeiculo DeleteVeiculo"

  # Mapeia ambiente -> site de frontend (producao usa a cor ativa).
  env_frontend_site = {
    development = "development"
    test        = "test"
    staging     = "staging"
    production  = "production-${var.production_live_color}"
  }
}

# ----------------------------- Artefatos -----------------------------------
resource "aws_s3_bucket" "artifacts" {
  bucket        = "testproject-pipeline-artifacts-${local.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ----------------------------- IAM ----------------------------------------
resource "aws_iam_role" "codebuild" {
  name = "testproject-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "testproject-codebuild-policy"
  role = aws_iam_role.codebuild.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject", "s3:GetBucketLocation", "s3:ListBucket"]
        Resource = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"]
        Resource = concat(
          [for k, b in aws_s3_bucket.frontend : b.arn],
          [for k, b in aws_s3_bucket.frontend : "${b.arn}/*"],
        )
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:PublishVersion",
          "lambda:UpdateAlias",
          "lambda:GetFunction",
          "lambda:GetAlias",
        ]
        Resource = "arn:aws:lambda:${var.aws_region}:${local.account_id}:function:testproject-*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "codepipeline" {
  name = "testproject-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "testproject-codepipeline-policy"
  role = aws_iam_role.codepipeline.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject", "s3:GetBucketLocation", "s3:ListBucket"]
        Resource = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.pipeline_alerts.arn
      },
    ]
  })
}

# ----------------------------- CodeBuild ----------------------------------
resource "aws_codebuild_project" "backend" {
  for_each      = local.environments
  name          = "testproject-backend-${each.key}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 20

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = each.key
    }
    environment_variable {
      name  = "LAMBDA_ALIAS"
      value = each.value.lambda_alias
    }
    environment_variable {
      name  = "FUNCTIONS"
      value = local.function_list
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "infra/terraform/buildspecs/backend-buildspec.yml"
  }
}

resource "aws_codebuild_project" "frontend" {
  for_each      = local.environments
  name          = "testproject-frontend-${each.key}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 20

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = each.key
    }
    environment_variable {
      name  = "API_URL"
      value = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.aws_region}.amazonaws.com/${each.key}"
    }
    environment_variable {
      name  = "COGNITO_USER_POOL_ID"
      value = aws_cognito_user_pool.main[each.key].id
    }
    environment_variable {
      name  = "COGNITO_CLIENT_ID"
      value = aws_cognito_user_pool_client.spa[each.key].id
    }
    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "FRONTEND_BUCKET"
      value = aws_s3_bucket.frontend[local.env_frontend_site[each.key]].bucket
    }
    environment_variable {
      name  = "CF_DISTRIBUTION_ID"
      value = aws_cloudfront_distribution.frontend[local.env_frontend_site[each.key]].id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "infra/terraform/buildspecs/frontend-buildspec.yml"
  }
}

# ----------------------------- CodePipeline -------------------------------
resource "aws_codepipeline" "env" {
  for_each = local.environments
  name     = "testproject-${each.key}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["src"]
      configuration = {
        Owner                = var.github_owner
        Repo                 = var.github_repo
        Branch               = each.key
        OAuthToken           = var.github_oauth_token
        PollForSourceChanges = "true"
      }
    }
  }

  # Producao: aprovacao manual antes do deploy (blue/green controlado).
  dynamic "stage" {
    for_each = each.key == "production" ? [1] : []
    content {
      name = "Approve"
      action {
        name     = "ManualApproval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }

  stage {
    name = "Build-Deploy"
    action {
      name            = "Backend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["src"]
      run_order       = 1
      configuration   = { ProjectName = aws_codebuild_project.backend[each.key].name }
    }
    action {
      name            = "Frontend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["src"]
      run_order       = 1
      configuration   = { ProjectName = aws_codebuild_project.frontend[each.key].name }
    }
  }
}

# ----------------------------- Alertas ------------------------------------
resource "aws_sns_topic" "pipeline_alerts" {
  name = "testproject-pipeline-alerts"
}

resource "aws_sns_topic_subscription" "pipeline_alerts_email" {
  count     = var.pipeline_alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.pipeline_alerts.arn
  protocol  = "email"
  endpoint  = var.pipeline_alert_email
}

resource "aws_cloudwatch_metric_alarm" "pipeline_failure" {
  for_each            = local.environments
  alarm_name          = "testproject-pipeline-failure-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedPipelineExecutions"
  namespace           = "AWS/CodePipeline"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.pipeline_alerts.arn]
  dimensions          = { PipelineName = aws_codepipeline.env[each.key].name }
}
