# EPIC-007 - CI/CD por ambiente

Issue: [#48](https://github.com/fpoiato/testproject/issues/48)

## Tarefas
- [x] [TASK-034](./TASK-034.md) - Branches test/staging/production + branch protection
- [x] [TASK-035](./TASK-035.md) - Pipelines por ambiente (trigger por push)
- [x] [TASK-036](./TASK-036.md) - Backend buildspec (publish version + shift alias)
- [x] [TASK-037](./TASK-037.md) - Frontend buildspec (build por ambiente + sync + invalidation)
- [x] [TASK-038](./TASK-038.md) - Producao com Manual Approval + blue/green

## Resultado
- 1 CodePipeline por ambiente com source na branch correspondente (GitHub v1, poll).
- Build-Deploy com CodeBuild backend + frontend; producao com aprovacao manual.
- `cicd.tf` + `buildspecs/`.
