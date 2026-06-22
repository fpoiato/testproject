# TASK-006 - Criar estrutura de ambientes

## Objetivo
Inicializar o projeto IaC configurando os pilares para os 4 ambientes (dev, test, stg, prod) na mesma conta AWS.

## Contexto
Parte do EPIC-002 (AWS Foundation).

## Dependências
#1 (TASK-001)

## Arquivos afetados
- infra/*

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Projeto IaC base inicializado na pasta `infra/`.
- Configuração definindo a segregação de recursos por stage/ambiente estruturada através de arquivos ou variáveis.

## Casos de Teste
- [TC-006](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-006.md): Validar critérios da TASK-006
