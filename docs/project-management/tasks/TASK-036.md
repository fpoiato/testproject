# TASK-036 - Backend buildspec (publish version + shift alias)

## Objetivo
No deploy do backend, empacotar `src/`, publicar nova versao de cada Lambda e
mover o alias do ambiente para a nova versao.

## Contexto
Parte do [EPIC-007](https://github.com/fpoiato/testproject/issues/48).

## Resultado
- `buildspecs/backend-buildspec.yml` usando `FUNCTIONS` e `LAMBDA_ALIAS`.
