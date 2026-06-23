# TASK-038 - Producao com Manual Approval + blue/green

## Objetivo
O pipeline de producao tem um estagio de aprovacao manual antes do deploy.

## Contexto
Parte do [EPIC-007](https://github.com/fpoiato/testproject/issues/48).

## Resultado
- Estagio `Approve` (Manual) inserido no pipeline `testproject-production`.
- Deploy publica versao e move o alias `production-<cor ativa>`; o switch de cor
  e feito via Terraform (`production_live_color`).
