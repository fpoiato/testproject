# Development Environment Deployment

This documents the automatic deployment pipeline for the `development` environment.

## Deployment Trigger

The deployment to `development` is automatically triggered by:
- Git push to the `development` branch
- Merge of PR to `development` branch

## Pipeline Flow

```
GitHub (development branch)
   ↓ (push/merge)
CodePipeline Backend (testproject-backend-development)
   ↓
CodeBuild Backend (testproject-backend-development)
   ↓
CDK Deploy Lambda + API Gateway
   ↓
Development Environment Updated
```

## Deployment Configuration

**CodePipeline Branch Trigger:**
- Backend pipeline: Triggers on `development` branch
- Frontend pipeline: Triggers on `development` branch
- On push/merge event

**CodeBuild Projects:**
- Backend project: `testproject-backend-development`
- Frontend project: `testproject-frontend-development`
- Both use ARM architecture for cost efficiency
- 7-day log retention

**Environment Variables:**
- `ENVIRONMENT: development`
- `AWS_REGION: us-east-1`
- Pipeline alert email configured in `dev.tfvars`

## Deployment Status

Check deployment status:
1. CodePipeline console: `testproject-backend-development`
2. CodeBuild console: Build logs
3. CloudWatch Logs: `/aws/codebuild/testproject-backend-development`

## Rollback

To rollback a deployment:
1. Push a fixed commit to `development`
2. Pipeline automatically triggers
3. Manual rollback via CodeBuild: Select previous build

## Monitoring

- CloudWatch Alarms: Failures trigger email alerts
- Pipeline failures: SNS topic notifications
- Build logs: Available in CodeBuild console for 7 days
