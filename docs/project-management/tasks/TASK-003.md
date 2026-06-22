# TASK-003 - Configurar proteção de branches

## Objetivo
Aplicar regras de branch protection no GitHub para as branches `development`, `test`, `staging` e `production`.

## Contexto
Parte do [EPIC-001 (Foundation)](https://github.com/fpoiato/testproject/issues/20).

## Dependências
[#2 (TASK-002)](https://github.com/fpoiato/testproject/issues/2)

## Arquivos afetados
- Configuração no GitHub (sem código no repo) ou script de automação via GitHub CLI.

## Estimativa de complexidade
S (Small)

## Critérios de aceite
- Pushes diretos bloqueados nas branches protegidas.
- PRs exigem review antes de merge.
- Status checks obrigatórios configurados (preparação para CI).

## Casos de Teste
- [TC-003](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-003.md): Validar critérios da TASK-003
