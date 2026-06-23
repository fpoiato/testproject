# TASK-023 - Lambda Authorizer customizado (stage -> Cognito pool)

## Objetivo
Como o API Gateway e unico mas cada ambiente tem seu user pool, um authorizer
TOKEN customizado deriva o stage do `methodArn` e valida o JWT contra o user
pool correspondente (isolamento por ambiente).

## Contexto
Parte do [EPIC-004](https://github.com/fpoiato/testproject/issues/45).

## Resultado
- `backend/authorizer/` (aws-jwt-verify) com mapa STAGE_POOL_MAP.
- `authorizer.tf`: funcao, permissao e `aws_api_gateway_authorizer` TOKEN.
