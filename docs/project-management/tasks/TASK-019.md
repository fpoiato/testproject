# TASK-019 - Deploy Production

## Objetivo
Configurar a etapa de deploy para `production` a partir da branch `production`, exigindo obrigatoriamente um portão de aprovação manual (Manual Approval) no Pipeline.

## Contexto
Parte do EPIC-003 (CI/CD).

## Dependências
#18 (TASK-018)

## Arquivos afetados
- infra/stacks/pipeline_stack.*

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Ação de deploy para ambiente produtivo acoplada na branch `production`.
- Passo explícito de `Manual Approval` inserido no fluxo da pipeline antes de executar as alterações finais AWS.

## Casos de Teste
- [TC-019](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-019.md): Validar critérios da TASK-019
