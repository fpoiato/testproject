# TASK-035 - Pipelines por ambiente (trigger por push)

## Objetivo
Um CodePipeline por ambiente cujo source e a branch homonima; push/merge na
branch dispara o pipeline -> CodeBuild -> deploy.

## Contexto
Parte do [EPIC-007](https://github.com/fpoiato/testproject/issues/48).

## Resultado
- `aws_codepipeline.env` (`for_each` ambientes), source GitHub v1 com
  `PollForSourceChanges = true` na branch do ambiente.
