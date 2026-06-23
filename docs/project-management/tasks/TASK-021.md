# TASK-021 - Stack Terraform unico multi-ambiente

## Objetivo
Reescrever `infra/terraform` como um unico stack que provisiona todos os
ambientes, usando `for_each` sobre o mapa de ambientes.

## Contexto
Parte do [EPIC-004](https://github.com/fpoiato/testproject/issues/45).

## Resultado
- `main.tf` com locals (environments, functions, aliases, frontend_sites).
- `dynamodb.tf` (4 tabelas) e `cognito.tf` (4 user pools + clients).
- CDK removido; tfvars com account falso removidos.
