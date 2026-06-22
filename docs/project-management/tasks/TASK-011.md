# TASK-011 - Criar API Gateway

**Status:** 🔄 In Progress

## Objetivo
Declarar no Terraform a base do API Gateway REST com os stages dinâmicos (`development`, `test`, `staging`, `production-blue`, `production-green`).

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#6 (TASK-006)](https://github.com/fpoiato/testproject/issues/6) ✅
[#10 (TASK-010)](https://github.com/fpoiato/testproject/issues/10) ✅

## Arquivos afetados
- [infra/terraform/api-gateway.tf](https://github.com/fpoiato/testproject/tree/main/infra/terraform/api-gateway.tf)
- [infra/terraform/*.tfvars](https://github.com/fpoiato/testproject/tree/main/infra/terraform/) (adicionar configuração API Gateway)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- API Gateway declarado via Terraform.
- Stages de deploy configurados no IaC (development, test, staging, production-blue, production-green).
- Integração com Cognito Authorizer definida como padrão para as rotas seguras.
- HTTPS enforced para todos os ambientes (endpoint type REGIONAL).
- Mock integrations configuradas (serão substituídas por Lambda integrations em TASK-012).
- Standard JSON request/response templates configurados.
- CloudWatch logging disabled (per user request).
- X-Ray tracing disabled (per user request).

## Configuração por Ambiente

| Environment | Stage Name            | Endpoint Type |
|-------------|-----------------------|---------------|
| development | development            | REGIONAL       |
| test        | test                   | REGIONAL       |
| staging     | staging                | REGIONAL       |
| production-blue | production-blue    | REGIONAL       |
| production-green | production-green  | REGIONAL       |

## Casos de Teste
- [TC-011](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-011.md): Validar critérios da TASK-011
