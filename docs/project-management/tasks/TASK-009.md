# TASK-009 - Criar DynamoDB

## Objetivo
Declarar no IaC a tabela DynamoDB principal para a entidade `Veiculos`, com configuração atrelada ao ambiente.

## Contexto
Parte do EPIC-002 (AWS Foundation).

## Dependências
#6 (TASK-006)

## Arquivos afetados
- infra/stacks/database_stack.*

## Estimativa de complexidade
S (Small)

## Critérios de aceite
- Tabela DynamoDB `Veiculos` declarada com Partition Key definida de forma padronizada.
- Nomes de tabela prefixados com o nome do ambiente de deploy.

## Casos de Teste
- [TC-009](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-009.md): Validar critérios da TASK-009
