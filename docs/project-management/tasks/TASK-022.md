# TASK-022 - API Gateway unico + Lambdas versionadas com aliases

## Objetivo
Um API Gateway REST com stages por ambiente; a integracao usa a stage variable
`lambdaAlias` para invocar o alias correto. Lambdas publicadas (versoes) com
aliases development/test/staging/production-blue/production-green.

## Contexto
Parte do [EPIC-004](https://github.com/fpoiato/testproject/issues/45).

## Resultado
- `apigateway.tf`: recursos `/veiculos` e `/veiculos/{id}`, metodos, integracao
  `AWS_PROXY` com `${stageVariables.lambdaAlias}`, OPTIONS (CORS) e 4 stages.
- `lambda.tf`: 5 funcoes + aliases + `lambda_permission` por alias.
