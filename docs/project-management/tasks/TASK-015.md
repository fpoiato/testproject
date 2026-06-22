# TASK-015 - CodePipeline

## Objetivo
Provisionar o AWS CodePipeline via IaC para orquestrar as entregas contínuas extraindo fontes do GitHub e encaminhando para CodeBuild.

## Contexto
Parte do EPIC-003 (CI/CD).

## Dependências
#14 (TASK-014)

## Arquivos afetados
- infra/stacks/pipeline_stack.*

## Estimativa de complexidade
L (Large)

## Critérios de aceite
- Estrutura do CodePipeline criada.
- Conexão nativa com o GitHub Actions/Webhooks ou AWS CodeStar configurada para puxar o código base.

## Casos de Teste
- [TC-015](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-015.md): Validar critérios da TASK-015
