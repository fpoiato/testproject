# Development Environment Deployment

This documents the automatic deployment pipeline for the `development` environment.

## Deployment Trigger

The deployment to `development` is automatically triggered by:
- Git push to the `development` branch
- Merge of PR to `development` branch

The source action uses **AWS CodeConnections** (GitHub App) with webhooks
(`DetectChanges`). After a merge, the pipeline should start within seconds.
You can also start it manually:

```bash
aws codepipeline start-pipeline-execution --name testproject-development
```

## Pipeline Flow

```
GitHub (development branch)
   |  (push/merge → webhook via CodeConnections)
CodePipeline (testproject-development)
   |-- Source            -> artifact "src"
   `-- Build-Deploy (parallel)
        |-- Backend  (CodeBuild: testproject-backend-development)
        |     publishes a new Lambda version and shifts the
        |     "development" alias to it
        `-- Frontend (CodeBuild: testproject-frontend-development)
              builds the Angular app with the env config,
              s3 sync to the bucket, CloudFront invalidation
```

> There is **no CDK** in the deploy. The backend buildspec
> (`infra/terraform/buildspecs/backend-buildspec.yml`) updates the Lambda code,
> publishes a version and moves the alias. The frontend buildspec
> (`infra/terraform/buildspecs/frontend-buildspec.yml`) builds and ships the SPA.
> Infrastructure itself is provisioned separately via `terraform apply`.

## Deployment Configuration

**CodePipeline:** `testproject-development` (one pipeline per environment,
source = `development` branch via CodeConnections `testproject-github`).

**CodeBuild Projects:**
- Backend: `testproject-backend-development`
- Frontend: `testproject-frontend-development`
- Image: `aws/codebuild/amazonlinux2-x86_64-standard:5.0`, `BUILD_GENERAL1_SMALL`

**Key environment variables (injected by Terraform, see `infra/terraform/cicd.tf`):**
- Backend: `ENVIRONMENT`, `LAMBDA_ALIAS=development`, `FUNCTIONS`, `AWS_DEFAULT_REGION`
- Frontend: `ENVIRONMENT`, `API_URL`, `COGNITO_USER_POOL_ID`, `COGNITO_CLIENT_ID`,
  `AWS_REGION`, `FRONTEND_BUCKET`, `CF_DISTRIBUTION_ID`

The pipeline alert email is the `pipeline_alert_email` Terraform variable
(default `nandopoiato@gmail.com`), not a `*.tfvars` file.

## Deployment Status

Check deployment status:
1. CodePipeline console: `testproject-development`
2. CodeBuild console: build logs of `testproject-backend-development` / `testproject-frontend-development`
3. CloudWatch Logs: `/aws/codebuild/testproject-backend-development`

## Promoting to other environments

`development` is the first stage. Promote by merging into the next branch
(`test` -> `staging` -> `production`); each merge triggers the matching
`testproject-<env>` pipeline. The `production` pipeline has a **Manual Approval**
stage before Build-Deploy.

## Rollback

To rollback a deployment:
1. Push a fixed commit to `development` (pipeline re-runs), or
2. Re-point the Lambda `development` alias to a previous version, or
3. Re-run a previous successful pipeline execution from the console.

## Monitoring

- CloudWatch Alarm `testproject-pipeline-failure-development` on failed executions
- SNS topic `testproject-pipeline-alerts` (email subscription) for notifications
- Build logs available in the CodeBuild console
