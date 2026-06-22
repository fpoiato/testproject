# TASK-017 - Deploy Test

## Objetivo
Configurar a etapa de deploy automático no CodePipeline para o stage `test` quando a branch `test` receber pushes via PR merge.

## Contexto
Parte do [EPIC-003 (CI/CD)](https://github.com/fpoiato/testproject/issues/22).

## Dependências
[#16 (TASK-016)](https://github.com/fpoiato/testproject/issues/16)

## Arquivos afetados
- [infra/stacks/pipeline_stack.*](https://github.com/fpoiato/testproject/tree/main/infra/stacks/pipeline_stack.)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Etapa de deploy configurada especificamente acoplada e escutada na branch `test`.

## Casos de Teste
- [TC-017](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-017.md): Validar critérios da TASK-017
