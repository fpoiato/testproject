# AWS CodePipeline - Continuous Delivery Orchestration

# S3 Bucket for CodePipeline Artifacts
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "testproject-codepipeline-artifacts-${var.environment}"
}

resource "aws_s3_bucket_versioning" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CodePipeline - Backend Deployment
resource "aws_codepipeline" "backend" {
  name     = "testproject-backend-${var.environment}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
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
      output_artifacts = ["source_output"]

      configuration = {
        Owner                = "fpoiato"
        Repo                 = "testproject"
        Branch               = "development"
        OAuthToken           = var.github_oauth_token
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.backend.name
      }
    }
  }

  # Note: no separate Deploy stage - the Build stage (CodeBuild) runs
  # `cdk deploy`, so CDK handles deployment directly.

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "CodePipeline Backend"
  }
}

# CodePipeline - Frontend Deployment
resource "aws_codepipeline" "frontend" {
  name     = "testproject-frontend-${var.environment}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
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
      output_artifacts = ["source_output"]

      configuration = {
        Owner                = "fpoiato"
        Repo                 = "testproject"
        Branch               = "development"
        OAuthToken           = var.github_oauth_token
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.frontend.name
      }
    }
  }

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "CodePipeline Frontend"
  }
}

# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline" {
  name = "testproject-codepipeline-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "CodePipeline IAM Role"
  }
}

# IAM Policy for CodePipeline
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "testproject-codepipeline-policy-${var.environment}"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
        ]
        Resource = [
          aws_codebuild_project.backend.arn,
          aws_codebuild_project.frontend.arn,
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:*",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = [
          aws_iam_role.codebuild_backend.arn,
          aws_iam_role.codebuild_frontend.arn,
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          "arn:aws:logs:*:*:*",
        ]
      },
    ]
  })
}

# Note: CodeStarConnections resources removed - the pipeline uses the
# GitHub v1 OAuth source action (var.github_oauth_token) with polling.

# CloudWatch Alarms for CodePipeline failures
resource "aws_cloudwatch_metric_alarm" "backend_pipeline_failure" {
  alarm_name          = "testproject-backend-pipeline-failure-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedExecutions"
  namespace           = "AWS/CodePipeline"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors backend CodePipeline failures"
  alarm_actions       = [aws_sns_topic.pipeline_alerts.arn]
  ok_actions          = [aws_sns_topic.pipeline_alerts.arn]

  dimensions = {
    PipelineName = aws_codepipeline.backend.name
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_pipeline_failure" {
  alarm_name          = "testproject-frontend-pipeline-failure-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedExecutions"
  namespace           = "AWS/CodePipeline"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors frontend CodePipeline failures"
  alarm_actions       = [aws_sns_topic.pipeline_alerts.arn]
  ok_actions          = [aws_sns_topic.pipeline_alerts.arn]

  dimensions = {
    PipelineName = aws_codepipeline.frontend.name
  }
}

# SNS Topic for Pipeline Alerts
resource "aws_sns_topic" "pipeline_alerts" {
  name = "testproject-pipeline-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "pipeline_alerts_email" {
  topic_arn = aws_sns_topic.pipeline_alerts.arn
  protocol  = "email"
  endpoint  = var.pipeline_alert_email
}
