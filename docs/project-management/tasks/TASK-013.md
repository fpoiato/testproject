# TASK-013 - GitHub Actions

## Objetivo
Configurar workflows base do GitHub Actions para validação de Pull Requests contendo rotinas de lint e test (quando houver).

## Contexto
Parte do EPIC-003 (CI/CD).

## Dependências
#1 (TASK-001)

## Arquivos afetados
- .github/workflows/pr-validation.yml

## Estimativa de complexidade
S (Small)

## Critérios de aceite
- Workflow de validação de PRs criado.
- Execução automática bloqueando o merge em caso de falha de lint ou de teste.

## Casos de Teste
- [TC-013](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-013.md): Validar critérios da TASK-013
