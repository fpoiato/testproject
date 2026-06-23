# TASK-025 - Corrigir modelo de dados de veiculo

## Objetivo
Alinhar o modelo de dados ao requisito: `marca`, `modelo`, `versao`, `cor`, `ano`,
com chave primaria `id` (uuid) gerada no backend. Remover o campo `placa`.

## Contexto
Parte do [EPIC-005](https://github.com/fpoiato/testproject/issues/46).

## Arquivos afetados
- `backend/src/lib/veiculo.js` (validacao e normalizacao)
- `backend/src/lib/dynamo.js` (resolucao de tabela por stage)
- `backend/src/lib/http.js` (CORS)

## Criterios de aceite
- PK `id` (uuid); campos marca/modelo/versao/cor/ano.
- Validacao de campos obrigatorios e do intervalo de `ano`.
- Respostas com headers CORS.
