# TASK-011 - Criar API Gateway

**Status:** ✅ Concluído

## Objetivo
Declarar no Terraform a base do API Gateway REST com os stages dinâmicos (`development`, `test`, `staging`, `production-blue`, `production-green`).

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#6 (TASK-006)](https://github.com/fpoiato/testproject/issues/6) ✅
[#10 (TASK-010)](https://github.com/fpoiato/testproject/issues/10) ✅

## Arquivos afetados
- [infra/terraform/api-gateway.tf](https://github.com/fpoiato/testproject/tree/main/infra/terraform/api-gateway.tf)
- [infra/terraform/*.tfvars](https://github.com/fpoiato/testproject/tree/main/infra/terraform/) (configurar API Gateway)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- [x] API Gateway declarado no IaC (Terraform).
- [x] Stages de deploy configurados (development, test, staging, production-blue, production-green).
- [x] Integração com Cognito Authorizer definida como padrão para rotas seguras.
- [x] HTTPS enforced para todos os ambientes (endpoint type REGIONAL).
- [x] Mock integrations configuradas como placeholders (serão substituídas por Lambda integrations em TASK-012 via CDK).
- [x] Standard JSON request/response templates configurados.
- [x] CloudWatch logging disabled (não implementado por request).
- [x] X-Ray tracing disabled (não implementado por request).

## Configuração por Ambiente

| Environment         | Stage Name      | Endpoint Type |
|-------------|-------------------------|---------------|
| development  | development             | REGIONAL       |
| test         | test                    | REGIONAL       |
| staging      | staging                 | REGIONAL       |
| production-blue | production-blue     | REGIONAL       |
| production-green | production-green   | REGIONAL       |

## Casos de Teste
- [TC-011](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-011.md): Validar critérios da TASK-011

## Nota
Mock integrations são temporárias e substituídas por Lambda integrations em TASK-012 quando backend code for implementado via CDK Ars do ADR-002). Os endpoints mock retornam JSON responses para testar infraestrutura API Gateway. Não há CloudWatch logging ou X-Ray tracing configurados por design.

## Referências
- [ADR-002: Terraform + CDK Hybrid Architecture](../architecture/adr-002-terraform-cdk-hybrid.md) - Documentação da arquitetura híbrida
- TASK-012: Criar Lambdas Backend via CDK (será substituídas mock integrations)
- TASK-010: Configurar Cognito (dependência)
- EPIC-002: AWS Foundation
