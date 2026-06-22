# TASK-006 - Criar estrutura de ambientes

## Objetivo
Inicializar o projeto IaC configurando os pilares para os 4 ambientes (dev, test, stg, prod) na mesma conta AWS.

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#1 (TASK-001)](https://github.com/fpoiato/testproject/issues/1)

## Arquivos afetados
- [infra/](https://github.com/fpoiato/testproject/tree/main/infra)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Projeto IaC base inicializado na pasta `infra/`.
- Configuração definindo a segregação de recursos por stage/ambiente estruturada através de arquivos ou variáveis.

## Casos de Teste
- [TC-006](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-006.md): Validar critérios da TASK-006
