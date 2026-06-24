# TASK-012 - Criar Lambdas base

> ⚠️ **DEPRECATED — documento histórico.** Descreve o modelo antigo (CDK híbrido + `*.tfvars` por ambiente), substituído pela consolidação em Terraform (stack único multi-ambiente). Mantido apenas como registro. Fonte da verdade atual: [`infra/terraform/README.md`](../../../infra/terraform/README.md) e [ADR-003](../../architecture/adr-003-terraform-shared-model.md).

## Objetivo
Declarar funções AWS Lambda em node.js (placeholders para o CRUD de Veículos) no IaC e vinculá-las ao API Gateway via aliases por stage.

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#11 (TASK-011)](https://github.com/fpoiato/testproject/issues/11)

## Arquivos afetados
- [infra/stacks/api_stack.*](https://github.com/fpoiato/testproject/tree/main/infra/stacks/api_stack.)
- [backend/src/handlers/](https://github.com/fpoiato/testproject/tree/main/backend/src/handlers)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Lambdas provisionadas com permissão de execução via API Gateway.
- Código skeleton backend incluído retornando 200 OK.

## Casos de Teste
- [TC-012](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-012.md): Validar critérios da TASK-012
