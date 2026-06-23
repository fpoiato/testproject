# TASK-037 - Frontend buildspec (build por ambiente + sync + invalidation)

## Objetivo
Buildar o Angular com a config do ambiente (env vars do CodeBuild), publicar no
bucket S3 do ambiente e invalidar o CloudFront.

## Contexto
Parte do [EPIC-007](https://github.com/fpoiato/testproject/issues/48).

## Resultado
- `buildspecs/frontend-buildspec.yml` (npm ci, npm run build, s3 sync, invalidation).
- Env vars: ENVIRONMENT, API_URL, COGNITO_*, FRONTEND_BUCKET, CF_DISTRIBUTION_ID.
