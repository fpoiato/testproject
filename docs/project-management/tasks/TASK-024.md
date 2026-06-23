# TASK-024 - Producao blue/green

## Objetivo
Producao com duas cores (blue/green) tanto no backend (aliases
`production-blue`/`production-green`) quanto no frontend (duas distribuicoes
CloudFront). O subdominio `app.testproject.fpoiato.com` aponta para a cor ativa.

## Contexto
Parte do [EPIC-004](https://github.com/fpoiato/testproject/issues/45).

## Resultado
- `var.production_live_color` (blue|green) controla o switch.
- Stage `production` usa `lambdaAlias = production-<cor>`; registro DNS `app.`
  e o alias incluido na distribuicao da cor ativa.
- O switch e uma operacao Terraform controlada (mudar a variavel + apply).
