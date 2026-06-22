# TASK-016 - Deploy Development

## Objetivo
Configurar a etapa do Pipeline para deploy automático no stage `development` a partir de pushes/merges na branch `development`.

## Contexto
Parte do [EPIC-003 (CI/CD)](https://github.com/fpoiato/testproject/issues/22).

## Dependências
[#15 (TASK-015)](https://github.com/fpoiato/testproject/issues/15)

## Arquivos afetados
- [infra/stacks/pipeline_stack.*](https://github.com/fpoiato/testproject/tree/main/infra/stacks/pipeline_stack.)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Deploy em `development` sendo triggado automaticamente por mudanças rastreadas na branch `development`.

## Casos de Teste
- [TC-016](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-016.md): Validar critérios da TASK-016
