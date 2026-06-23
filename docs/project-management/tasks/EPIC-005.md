# EPIC-005 - Backend (Node Lambdas) da aplicacao de veiculos

Issue: [#46](https://github.com/fpoiato/testproject/issues/46)

## Tarefas
- [x] [TASK-025](./TASK-025.md) - Corrigir modelo de dados (id uuid + marca/modelo/versao/cor/ano)
- [x] [TASK-026](./TASK-026.md) - CRUD completo em `backend/`
- [x] [TASK-027](./TASK-027.md) - Testes unitarios das Lambdas

## Observacoes
Codigo movido de `cdk/lambda/*` para `backend/src/handlers/*`, com lib compartilhada.
A tabela DynamoDB e resolvida em runtime por `event.requestContext.stage` (modelo compartilhado).
