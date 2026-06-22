# TASK-013 - GitHub Actions

## Objetivo
Configurar workflows base do GitHub Actions para validação de Pull Requests contendo rotinas de lint e test (quando houver).

## Contexto
Parte do [EPIC-003 (CI/CD)](https://github.com/fpoiato/testproject/issues/22).

## Dependências
[#1 (TASK-001)](https://github.com/fpoiato/testproject/issues/1)

## Arquivos afetados
- [.github/workflows/pr-validation.yml](https://github.com/fpoiato/testproject/blob/main/.github/workflows/pr-validation.yml)

## Estimativa de complexidade
S (Small)

## Critérios de aceite
- Workflow de validação de PRs criado.
- Execução automática bloqueando o merge em caso de falha de lint ou de teste.

## Casos de Teste
- [TC-013](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-013.md): Validar critérios da TASK-013
