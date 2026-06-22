# TASK-016 - Deploy Development

## Objetivo
Configurar a etapa do Pipeline para deploy automático no stage `development` a partir de pushes/merges na branch `development`.

## Contexto
Parte do EPIC-003 (CI/CD).

## Dependências
#15 (TASK-015)

## Arquivos afetados
- infra/stacks/pipeline_stack.*

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Deploy em `development` sendo triggado automaticamente por mudanças rastreadas na branch `development`.

## Casos de Teste
- [TC-016](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-016.md): Validar critérios da TASK-016
