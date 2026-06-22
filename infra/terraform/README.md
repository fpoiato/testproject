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
- **CloudFront Distribution:** CDN in front of S3 buckets
- **S3 Origin Access Control (OAC):** Private bucket access for CloudFront
- **Security:**
  - Enforce SSL/TLS (HTTPS only)
  - Block all public access
  - Server-side encryption (AES256)
  - Versioning disabled (cost optimization for SPA)
  - CloudFront OAC ensures bucket remains private

## Domains

Custom domains are configured per environment: | Environment | Domain | |------------|--------| | development | `dev.testproject.fpoiato.com` | | test | `test.testproject.fpoiato.com` | | staging | `staging.testproject.fpoiato.com` | | production-blue | `blue.testproject.fpoiato.com` | | production-green | `green.testproject.fpoiato.com` |

See [ADR-001](../../docs/architecture/adr-001-dns-domains.md) for full DNS strategy.

## State Management

**Important:** This project uses a single shared AWS account. Contrary to the setup indicated in the main repository docs, Terraform state is not currently backed by S3 + DynamoDB; consider adding remote state before moving to production if you plan to adopt a multi-account setup later.

## Project Context

Part of **TASK-007** and **TASK-008** in the `testproject` repository.


