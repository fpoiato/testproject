# TASK-009 - Criar DynamoDB

> ⚠️ **DEPRECATED — documento histórico.** Descreve o modelo antigo (CDK híbrido + `*.tfvars` por ambiente), substituído pela consolidação em Terraform (stack único multi-ambiente). Mantido apenas como registro. Fonte da verdade atual: [`infra/terraform/README.md`](../../../infra/terraform/README.md) e [ADR-003](../../architecture/adr-003-terraform-shared-model.md).

**Status:** 🔄 In Progress

## Objetivo
Declarar no Terraform a tabela DynamoDB principal para a entidade `Veiculos`, com configuração atrelada ao ambiente.

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#6 (TASK-006)](https://github.com/fpoiato/testproject/issues/6) ✅

## Arquivos afetados
- [infra/terraform/dynamodb.tf](https://github.com/fpoiato/testproject/tree/main/infra/terraform/dynamodb.tf)
- [infra/terraform/*.tfvars](https://github.com/fpoiato/testproject/tree/main/infra/terraform/) (adicionar configuração DynamoDB)

## Estimativa de complexidade
S (Small)

## Esquema DynamoDB

### Tabela: Veiculos

| Atributo    | Tipo  | Descrição                |
|------------|-------|--------------------------|
| placa      | S     | Partition Key (primary)  |
| marca      | S     | Marca do veículo         |
| modelo     | S     | Modelo do veículo        |
| ano        | N     | Ano de fabricação        |
| cor        | S     | Cor do veículo           |

**Nota:** Não há Sort Key (Single-table design).

## Critérios de aceite
- Tabela DynamoDB `Veiculos` declarada com Partition Key `placa` (String).
- Nomes de tabela prefixados com o nome do ambiente (ex: `Veiculos-dev`, `Veiculos-test`, etc.).
- Atributos esperados definidos: `marca`, `modelo`, `ano`, `cor`.
- Configuração de billing (on-demand ou provisionada) definida.
- Tags de ambiente aplicadas (Environment=..., Project=testproject, etc.).
- Provisioned throughput ou on-demand mode configurado em cada ambiente (dev/test on-demand, staging/prod provisionadas).

## Casos de Teste
- [TC-009](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-009.md): Validar critérios da TASK-009
