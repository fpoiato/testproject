# TASK-011 - Criar API Gateway

## Objetivo
Declarar no IaC a base do API Gateway REST com os stages dinâmicos (`development`, `test`, `staging`, `production`).

## Contexto
Parte do EPIC-002 (AWS Foundation).

## Dependências
#6 (TASK-006), #10 (TASK-010)

## Arquivos afetados
- infra/stacks/api_stack.*

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- API Gateway declarado.
- Stages de deploy configurados no IaC.
- Integração com Cognito Authorizer definida como padrão para as rotas seguras.

## Casos de Teste
- [TC-011](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-011.md): Validar critérios da TASK-011
