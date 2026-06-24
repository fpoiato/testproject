# Infraestrutura Terraform (stack unico multi-ambiente)

Este diretorio contem **toda** a infraestrutura do projeto em um unico stack Terraform.
Um unico `terraform apply` provisiona os quatro ambientes ao mesmo tempo
(`development`, `test`, `staging`, `production`) usando `for_each` sobre
`local.environments` (ver `main.tf`).

> Nao existe mais um `*.tfvars` por ambiente. O modelo antigo (um apply por
> ambiente com `-var-file`) foi substituido por este stack compartilhado.

## Ambientes

| Ambiente     | Subdominio | URL                                  | MFA      | Lambda alias                         |
|--------------|------------|--------------------------------------|----------|--------------------------------------|
| development  | `dev`      | https://dev.testproject.fpoiato.com  | OPTIONAL | `development`                        |
| test         | `test`     | https://test.testproject.fpoiato.com | ON       | `test`                               |
| staging      | `staging`  | https://staging.testproject.fpoiato.com | ON    | `staging`                            |
| production   | `app`      | https://app.testproject.fpoiato.com  | ON       | `production-blue` / `production-green` |

A producao usa **blue/green**: o subdominio `app` aponta para a cor ativa,
controlada pela variavel `production_live_color` (`blue` por padrao). Existem
ainda os subdominios `app-blue` e `app-green` para validar cada cor antes do switch.

## O que o stack provisiona

- **API Gateway** unico (`apigateway.tf`) com um stage por ambiente. Cada stage
  define a stage variable `lambdaAlias`, que roteia para o alias correto da Lambda.
- **Lambdas de aplicacao** (`lambda.tf`) versionadas, com aliases por slot
  (`development`, `test`, `staging`, `production-blue`, `production-green`).
- **Lambda Authorizer** (`authorizer.tf`) que mapeia o stage do request para o
  Cognito User Pool correto.
- **DynamoDB** (`dynamodb.tf`): uma tabela `Veiculos-<ambiente>` por ambiente.
- **Cognito** (`cognito.tf`): um User Pool por ambiente, com self sign-up por
  email e TOTP MFA.
- **SES** (`ses.tf`): identidade de dominio (`testproject.fpoiato.com`) com Easy
  DKIM + custom MAIL FROM, usada como remetente dos e-mails do Cognito.
- **Frontend** (`frontend.tf`): S3 + CloudFront + certificado ACM + registros
  Route53 por ambiente, incluindo blue/green em producao.
- **CI/CD** (`cicd.tf`): CodePipeline + CodeBuild por ambiente, com aprovacao
  manual na producao. Source via **AWS CodeConnections** (GitHub App) com
  webhooks (`DetectChanges`), substituindo o GitHub v1 (OAuth/PAT + polling).

## Estado remoto

O state fica em S3 com lock em DynamoDB (`backend.tf`):

- Bucket: `testproject-tfstate-986873053420`
- Key: `infra/terraform.tfstate`
- Lock: tabela DynamoDB `testproject-tflock`

## Variaveis

Todas as variaveis (`variables.tf`) tem `default`.

| Variavel                       | Default       | Descricao                                            |
|--------------------------------|---------------|------------------------------------------------------|
| `aws_region`                   | `us-east-1`   | Regiao AWS (CloudFront exige ACM em us-east-1).       |
| `production_live_color`        | `blue`        | Cor ativa do blue/green de producao.                 |
| `github_owner`                 | `fpoiato`     | Owner do repositorio.                                 |
| `github_repo`                  | `testproject` | Nome do repositorio.                                  |
| `pipeline_alert_email`         | `nandopoiato@gmail.com` | Email de alerta de falha de pipeline.      |
| `codebuild_log_retention_days` | `7`           | Retencao (dias) dos logs de CodeBuild.               |

### Conexao GitHub (CodeConnections)

O pipeline usa `aws_codestarconnections_connection` (`testproject-github`).
Apos o primeiro `terraform apply`, autorize a conexao no console AWS:

1. **Developer Tools** → **Settings** → **Connections**
2. Selecione `testproject-github` (status **Pending**)
3. **Update pending connection** → autorize o app GitHub da AWS

Quando o status for **Available**, merges na branch disparam o pipeline via webhook
(sem polling nem PAT no Terraform).

## Uso

Defina o profile AWS antes dos comandos:

```bash
export AWS_PROFILE=nandopoiato
cd infra/terraform
```

### Inicializar

```bash
terraform init
```

### Plan / Apply (todos os ambientes de uma vez)

```bash
terraform plan
terraform apply
```

### Switch blue/green de producao

Promova a cor green (faz o subdominio `app` apontar para o slot green):

```bash
terraform apply -var="production_live_color=green"
```

## Outputs

`outputs.tf` expoe, entre outros: `api_id`, `api_invoke_urls`, `frontend_urls`,
`cognito_user_pool_ids`, `cognito_client_ids`, `cloudfront_distribution_ids`,
`frontend_buckets`, `production_live_color` e a identidade SES do remetente.

## Deploy de aplicacao x infraestrutura

- **Infraestrutura** (este diretorio): aplicada manualmente com `terraform apply`.
- **Aplicacao** (frontend Angular + Lambdas): deployada pelos pipelines de CI/CD
  ao fazer push/merge nas branches `development`, `test`, `staging`, `production`.
  Os pipelines **nao** executam Terraform.

Veja os ADRs em `../../docs/architecture/` para o detalhamento das decisoes
(incluindo `adr-003-terraform-shared-model.md`).
