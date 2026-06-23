# TASK-029 - Auth Cognito (self sign-up + TOTP MFA)

## Objetivo
Permitir cadastro por email (auto-enroll), confirmacao por codigo e login com
MFA via app autenticador (TOTP).

## Contexto
Parte do [EPIC-006](https://github.com/fpoiato/testproject/issues/47).

## Arquivos afetados
- `frontend/src/app/core/auth.service.ts`, `auth.guard.ts`, `auth.interceptor.ts`
- `frontend/src/app/features/auth/*`

## Criterios de aceite
- Fluxos: cadastro -> confirmacao email -> login -> setup TOTP (QR) -> confirmacao.
- idToken anexado nas chamadas ao API Gateway via interceptor.
