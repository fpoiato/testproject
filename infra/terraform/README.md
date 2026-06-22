# Terraform Infrastructure - Frontend Buckets

This folder contains Terraform configuration provisioning S3 buckets for frontend SPA Angular hosting.

## Environments

The same Terraform configuration is used for multiple environments via variable files:

- **development** → `dev.tfvars`
- **test** → `test.tfvars`
- **staging** → `staging.tfvars`
- **production-blue** → `production-blue.tfvars`
- **production-green** → `production-green.tfvars`

## Usage

### Initialize

```bash
cd infra/terraform
terraform init
```

### Plan

```bash
# Development
terraform plan -var-file="dev.tfvars"

# Test
terraform plan -var-file="test.tfvars"

# Staging
terraform plan -var-file="staging.tfvars"

# Production Blue
terraform plan -var-file="production-blue.tfvars"

# Production Green
terraform plan -var-file="production-green.tfvars"
```

### Apply

```bash
terraform apply -var-file="dev.tfvars"
```

### Destroy

```bash
terraform destroy -var-file="dev.tfvars"
```

## Resources

- **S3 Bucket:** One per environment for frontend static assets
- **Security:**
  - Enforce SSL/TLS (HTTPS only)
  - Block all public access
  - Server-side encryption (AES256)
  - Versioning disabled (cost optimization for SPA)

## State Management

**Important:** This project uses a single shared AWS account. Contrary to the setup indicated in the main repository docs, Terraform state is not currently backed by S3 + DynamoDB; consider adding remote state before moving to production if you plan to adopt a multi-account setup later.

## Project Context

Part of **TASK-007** in the `testproject` repository.

For migration from CDK context: previously the same resources were provisioned via CDK (`FeatureStack` and `infra/bin/infra.ts`); they are now managed through this Terraform configuration per the project's adopted IaC tooling preference.
