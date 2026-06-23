# TASK-028 - Bootstrap Angular + config por ambiente

## Objetivo
Criar o app Angular em `frontend/` e injetar a configuracao por ambiente no build.

## Contexto
Parte do [EPIC-006](https://github.com/fpoiato/testproject/issues/47).

## Arquivos afetados
- `frontend/` (scaffold Angular 19)
- `frontend/scripts/generate-config.js`, `frontend/public/config.json`
- `frontend/src/app/core/app-config.ts`, `app-init.ts`

## Criterios de aceite
- `npm run build` gera `config.json` a partir de `ENVIRONMENT`/saidas do Terraform.
- Amplify configurado em runtime com os valores do ambiente.
