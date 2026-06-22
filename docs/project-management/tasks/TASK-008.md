# TASK-008 - Criar distribuições CloudFront

## Objetivo
Declarar a CDN CloudFront no IaC para servir o conteúdo dos Buckets S3 do Frontend, utilizando OAC (Origin Access Control) para segurança.

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#7 (TASK-007)](https://github.com/fpoiato/testproject/issues/7)

## Arquivos afetados
- [infra/stacks/frontend_stack.*](https://github.com/fpoiato/testproject/tree/main/infra/stacks/frontend_stack.)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Distribuições CloudFront declaradas apontando para os respectivos buckets de cada stage.
- OAC (Origin Access Control) habilitado garantindo acesso privado aos buckets.

## Casos de Teste
- [TC-008](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-008.md): Validar critérios da TASK-008
