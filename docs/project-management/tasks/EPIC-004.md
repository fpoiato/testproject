# EPIC-004 - Infra: modelo compartilhado (stages+aliases) + multi-ambiente

Issue: [#45](https://github.com/fpoiato/testproject/issues/45)

## Tarefas
- [x] [TASK-020](./TASK-020.md) - Backend remoto Terraform (S3 + DynamoDB lock) + cleanup do stack antigo
- [x] [TASK-021](./TASK-021.md) - Reescrever Terraform para stack unico multi-ambiente
- [x] [TASK-022](./TASK-022.md) - API Gateway unico com stages + Lambdas versionadas com aliases
- [x] [TASK-023](./TASK-023.md) - Lambda Authorizer customizado (stage -> Cognito pool)
- [x] [TASK-024](./TASK-024.md) - Producao blue/green

## Resultado
- IaC consolidado em Terraform (CDK removido).
- 1 API Gateway com stages development/test/staging/production; stage variable
  `lambdaAlias` seleciona o alias da Lambda por ambiente.
- 5 Lambdas versionadas com aliases development/test/staging/production-blue/green.
- DynamoDB e Cognito por ambiente; frontends por ambiente (CloudFront+S3+ACM+Route53).
