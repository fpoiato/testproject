# Backend - Lambdas de Veiculos

Handlers Node.js (Node 20) para o CRUD de veiculos, usados no modelo compartilhado:
um unico conjunto de funcoes serve todos os ambientes, e a tabela DynamoDB e
resolvida em runtime pelo stage da requisicao (`event.requestContext.stage`):
`Veiculos-development`, `Veiculos-test`, `Veiculos-staging`, `Veiculos-production`.

## Modelo de dados

| Campo     | Tipo   | Obrigatorio |
|-----------|--------|-------------|
| id        | string (uuid) | gerado |
| marca     | string | sim |
| modelo    | string | sim |
| versao    | string | nao |
| cor       | string | sim |
| ano       | number | sim |
| createdAt | string ISO | gerado |
| updatedAt | string ISO | gerado |

## Endpoints (API Gateway REST, integracao AWS_PROXY)

- `GET /veiculos` -> `getVeiculos`
- `GET /veiculos/{id}` -> `getVeiculo`
- `POST /veiculos` -> `createVeiculo`
- `PUT /veiculos/{id}` -> `updateVeiculo`
- `DELETE /veiculos/{id}` -> `deleteVeiculo`

Cada funcao Lambda e publicada com versoes e possui aliases por ambiente
(`development`, `test`, `staging`, `production-blue`, `production-green`). O stage do
API Gateway seleciona o alias via stage variable `lambdaAlias`.

## Desenvolvimento

```bash
npm install
npm test
```

O empacotamento para deploy gera um unico zip com `src/` (todos os handlers
compartilham o mesmo pacote); cada funcao aponta para um handler diferente, ex.
`src/handlers/getVeiculos.handler`.
