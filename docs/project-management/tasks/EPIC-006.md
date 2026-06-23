# EPIC-006 - Frontend Angular

Issue: [#47](https://github.com/fpoiato/testproject/issues/47)

## Tarefas
- [x] [TASK-028](./TASK-028.md) - Bootstrap Angular + config por ambiente
- [x] [TASK-029](./TASK-029.md) - Auth Cognito (self sign-up + TOTP MFA)
- [x] [TASK-030](./TASK-030.md) - Tabela com filtro/busca/sorting
- [x] [TASK-031](./TASK-031.md) - Formulario CRUD
- [x] [TASK-032](./TASK-032.md) - Export Excel
- [ ] [TASK-041](./TASK-041.md) - Forgot Password (recuperacao de senha via email)

## Stack
Angular 19 (standalone), aws-amplify v6 (Cognito), xlsx (export). Config por
ambiente carregada em runtime de `public/config.json`, gerado no build por
`scripts/generate-config.js` a partir das variaveis do CodeBuild.
