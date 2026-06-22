# AWS CodeBuild Projects - Backend and Frontend

# Backend CodeBuild Project for Lambda Functions
resource "aws_codebuild_project" "backend" {
  name         = "testproject-backend-${var.environment}"
  description  = "TestProject Backend Build - Lambda Functions (CDK)"
  service_role = aws_iam_role.codebuild_backend.arn

  build_timeout = "30" # 30 minutes

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-aarch64-standard:5.0"
    type         = "ARM_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "CDK_DEFAULT_ACCOUNT"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "CDK_DEPLOY_REGION"
      value = var.aws_region
    }

    privileged_mode = false
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/fpoiato/testproject.git"
    git_clone_depth = 1

    auth {
      type     = "OAUTH"
      resource = var.github_oauth_token
    }

    buildspec = file("${path.module}/buildspecs/backend-buildspec.yml")
  }

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "CodeBuild Backend"
  }
}

# Frontend CodeBuild Project
resource "aws_codebuild_project" "frontend" {
  name         = "testproject-frontend-${var.environment}"
  description  = "TestProject Frontend Build - React/Vue/Static Site"
  service_role = aws_iam_role.codebuild_frontend.arn

  build_timeout = "15" # 15 minutes

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-aarch64-standard:5.0"
    type         = "ARM_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    privileged_mode = false
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/fpoiato/testproject.git"
    git_clone_depth = 1

    auth {
      type     = "OAUTH"
      resource = var.github_oauth_token
    }

    buildspec = file("${path.module}/buildspecs/frontend-buildspec.yml")
  }

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "CodeBuild Frontend"
  }
}

# IAM Role for Backend CodeBuild
resource "aws_iam_role" "codebuild_backend" {
  name = "testproject-codebuild-backend-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "CodeBuild Backend IAM Role"
  }
}

# IAM Role for Frontend CodeBuild
resource "aws_iam_role" "codebuild_frontend" {
  name = "testproject-codebuild-frontend-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project     = "testproject"
    Environment = var.environment
    Component   = "CodeBuild Frontend IAM Role"
  }
}

# IAM Policy for Backend CodeBuild (CDK deployment permissions)
resource "aws_iam_role_policy" "codebuild_backend_policy" {
  name = "testproject-codebuild-backend-policy-${var.environment}"
  role = aws_iam_role.codebuild_backend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          "${aws_cloudwatch_log_group.codebuild_backend.arn}",
          "${aws_cloudwatch_log_group.codebuild_backend.arn}:*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "arn:aws:s3:::testproject-cdk-assets-${var.aws_account_id}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:*",
          "apigateway:*",
          "iam:PassRole",
          "cloudformation:*",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*",
        ]
        Resource = [
          aws_dynamodb_table.veiculos.arn,
          "${aws_dynamodb_table.veiculos.arn}/*",
        ]
      },
    ]
  })
}

# IAM Policy for Frontend CodeBuild (S3 upload permissions)
resource "aws_iam_role_policy" "codebuild_frontend_policy" {
  name = "testproject-codebuild-frontend-policy-${var.environment}"
  role = aws_iam_role.codebuild_frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          "${aws_cloudwatch_log_group.codebuild_frontend.arn}",
          "${aws_cloudwatch_log_group.codebuild_frontend.arn}:*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.frontend.arn,
          "${aws_s3_bucket.frontend.arn}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
        ]
        Resource = aws_cloudfront_distribution.main.arn
      },
    ]
  })
}

# CloudWatch Log Groups for CodeBuild
resource "aws_cloudwatch_log_group" "codebuild_backend" {
  name              = "/aws/codebuild/testproject-backend-${var.environment}"
  retention_in_days = var.codebuild_log_retention_days
}

resource "aws_cloudwatch_log_group" "codebuild_frontend" {
  name              = "/aws/codebuild/testproject-frontend-${var.environment}"
  retention_in_days = var.codebuild_log_retention_days
}
