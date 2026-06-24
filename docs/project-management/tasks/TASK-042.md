# TASK-042 - Internacionalizacao (i18n) pt/en/es no frontend Angular

Issue: [#94](https://github.com/fpoiato/testproject/issues/94)

## Objetivo
Implementar i18n no frontend com portugues (padrao), ingles e espanhol.

## Contexto
Parte do [EPIC-008](https://github.com/fpoiato/testproject/issues/93).

Consolida o escopo da TASK-050 (#95), fechada como duplicata.

## Arquivos afetados
- `frontend/public/i18n/{pt,en,es}.json`
- `frontend/src/app/core/i18n.service.ts`
- `frontend/src/app/core/translate.pipe.ts`
- `frontend/src/app/shared/language-selector.component.ts`
- `frontend/src/app/app.component.*`
- `frontend/src/app/features/auth/*`
- `frontend/src/app/features/veiculos/*`
- `frontend/src/app/core/auth.service.ts` (mensagens traduzidas)

## Criterios de aceite
- [ ] Seletor de idioma visivel (navbar e tela de login)
- [ ] Telas auth e veiculos traduzidas em pt, en, es
- [ ] Mensagens de erro Cognito/validacao traduzidas
- [ ] Preferencia persistida em localStorage
- [ ] Build e testes passando

## Testes
- Manual: alternar idioma em login e listagem de veiculos
- `npm run build` e `npm test` no diretorio `frontend/`
