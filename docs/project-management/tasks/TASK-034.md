# TASK-034 - Branches test/staging/production + branch protection

## Objetivo
Criar as branches de ambiente e proteger contra push direto (somente via PR).

## Contexto
Parte do [EPIC-007](https://github.com/fpoiato/testproject/issues/48).

## Resultado
- Branches `test`, `staging`, `production` criadas a partir de `development`.
- Branch protection exigindo PR (sem push direto) nas branches de ambiente.
