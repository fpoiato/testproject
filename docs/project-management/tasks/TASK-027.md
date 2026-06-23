# TASK-027 - Testes unitarios das Lambdas

## Objetivo
Cobrir os handlers e a validacao com testes unitarios usando `aws-sdk-client-mock`.

## Contexto
Parte do [EPIC-005](https://github.com/fpoiato/testproject/issues/46).

## Arquivos afetados
- `backend/test/veiculos.test.js`
- `backend/jest.config.js`

## Criterios de aceite
- `npm test` verde cobrindo validacao + os 5 handlers (sucesso e erros 400/404).
