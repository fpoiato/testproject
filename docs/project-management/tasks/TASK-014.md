# TASK-014 - CodeBuild

## Objetivo
Provisionar Projetos no AWS CodeBuild via IaC para realizar as rotinas de build e testes do Backend e Frontend nas contas AWS.

## Contexto
Parte do [EPIC-003 (CI/CD)](https://github.com/fpoiato/testproject/issues/22).

## Dependências
[#6 (TASK-006)](https://github.com/fpoiato/testproject/issues/6)

## Arquivos afetados
- [infra/stacks/pipeline_stack.*](https://github.com/fpoiato/testproject/tree/main/infra/stacks/pipeline_stack.)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Projetos do CodeBuild para backend e frontend declarados no IaC.
- Permissões de IAM granulares (roles) atreladas aos CodeBuilds configuradas.

## Casos de Teste
- [TC-014](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-014.md): Validar critérios da TASK-014
