# TASK-026 - CRUD completo das Lambdas em backend/

## Objetivo
Implementar os 5 handlers do CRUD de veiculos lendo a tabela do ambiente via
`event.requestContext.stage`.

## Contexto
Parte do [EPIC-005](https://github.com/fpoiato/testproject/issues/46).

## Arquivos afetados
- `backend/src/handlers/getVeiculos.js`
- `backend/src/handlers/getVeiculo.js`
- `backend/src/handlers/createVeiculo.js`
- `backend/src/handlers/updateVeiculo.js`
- `backend/src/handlers/deleteVeiculo.js`

## Criterios de aceite
- GET lista/obtem, POST cria (uuid), PUT atualiza (ALL_NEW), DELETE remove.
- 404 quando o recurso nao existe (ConditionExpression).
- Empacotamento unico: cada funcao aponta para `src/handlers/<nome>.handler`.
