# ADR-003 - Consolidacao em Terraform e modelo compartilhado (stages + aliases)

## Status
Aceito (supersede o ADR-002 - hibrido Terraform+CDK).

## Contexto
A arquitetura hibrida (Terraform para base + CDK via CodeBuild para Lambdas/API)
gerava retrabalho, duplicacao e divergencia entre documentacao e realidade.
Alem disso, apenas o ambiente `development` estava provisionado.

## Decisao
1. Consolidar toda a IaC em **Terraform** (CDK removido).
2. Adotar o **modelo compartilhado** descrito no requisito original:
   - 1 API Gateway REST com stages `development`/`test`/`staging`/`production`.
   - Stage variable `lambdaAlias` seleciona o alias da Lambda por ambiente.
   - 5 Lambdas versionadas com aliases por slot de deploy
     (`development`, `test`, `staging`, `production-blue`, `production-green`).
   - O codigo da Lambda resolve a tabela DynamoDB por `requestContext.stage`.
3. **DynamoDB e Cognito por ambiente** (isolamento de dados e usuarios).
4. **Lambda Authorizer customizado** mapeando stage -> user pool (isolamento de
   auth com um unico API Gateway).
5. **Frontend por ambiente** (S3 + CloudFront + ACM + Route53); producao blue/green.
6. **State remoto** (S3 + DynamoDB lock).

## Consequencias
- Operacao mais simples e coerente; um unico `terraform apply` provisiona tudo.
- Deploy por ambiente via CodePipeline (push na branch) que publica versao da
  Lambda + move o alias do ambiente e builda/publica o frontend.
- Trade-off: o modelo compartilhado acopla os ambientes em um unico API Gateway;
  o isolamento de auth e garantido pelo authorizer por stage.
