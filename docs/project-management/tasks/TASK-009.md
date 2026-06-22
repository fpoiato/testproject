# TASK-009 - Criar DynamoDB

## Objetivo
Declarar no IaC a tabela DynamoDB principal para a entidade `Veiculos`, com configuração atrelada ao ambiente.

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#6 (TASK-006)](https://github.com/fpoiato/testproject/issues/6)

## Arquivos afetados
- [infra/stacks/database_stack.*](https://github.com/fpoiato/testproject/tree/main/infra/stacks/database_stack.)

## Estimativa de complexidade
S (Small)

## Critérios de aceite
- Tabela DynamoDB `Veiculos` declarada com Partition Key definida de forma padronizada.
- Nomes de tabela prefixados com o nome do ambiente de deploy.

## Casos de Teste
- [TC-009](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-009.md): Validar critérios da TASK-009
