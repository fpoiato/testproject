# TASK-018 - Deploy Staging

## Objetivo
Configurar a etapa de deploy automático para o stage `staging`, disparada por atualizações na branch `staging`.

## Contexto
Parte do EPIC-003 (CI/CD).

## Dependências
#17 (TASK-017)

## Arquivos afetados
- infra/stacks/pipeline_stack.*

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Etapa de deploy configurada acoplada à branch `staging` e promovendo adequadamente o release.

## Casos de Teste
- [TC-018](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-018.md): Validar critérios da TASK-018
