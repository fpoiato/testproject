# TASK-041 - Forgot Password (recuperacao de senha via email)

Issue: [#81](https://github.com/fpoiato/testproject/issues/81)

## Objetivo
Permitir que usuarios recuperem a senha informando o email cadastrado, recebam um
codigo de verificacao e definam uma nova senha, sem suporte manual.

## Contexto
Parte do [EPIC-006](https://github.com/fpoiato/testproject/issues/47).

O Cognito User Pool ja possui `account_recovery_setting` com `verified_email`
(`infra/terraform/cognito.tf`). O frontend (TASK-029) cobre cadastro, confirmacao
e login com MFA, mas ainda nao expoe o fluxo de esqueci minha senha.

## Arquivos afetados
- `frontend/src/app/core/auth.service.ts`
- `frontend/src/app/features/auth/auth.component.ts`
- `frontend/src/app/features/auth/auth.component.html`
- `frontend/src/app/features/auth/auth.component.scss` (se necessario)
- Testes unitarios do auth service / componente (se existirem ou forem criados)

## Criterios de aceite
- [ ] Link "Esqueci minha senha" visivel na tela de login.
- [ ] Fluxo: informar email -> receber codigo por email -> informar codigo + nova senha -> confirmacao de sucesso.
- [ ] Metodos `resetPassword` e `confirmResetPassword` (aws-amplify/auth v6) encapsulados no `AuthService`.
- [ ] Validacao de senha alinhada a politica do Cognito (minimo 8 chars em development; requisitos de complexidade nos demais ambientes).
- [ ] Mensagens de erro amigaveis (email invalido, codigo incorreto, senha fraca) sem expor se o email existe (Cognito `prevent_user_existence_errors`).
- [ ] Apos redefinir a senha, usuario pode voltar ao login e autenticar normalmente (incluindo MFA TOTP).
- [ ] Verificar se o User Pool Client precisa de ajuste em `cognito.tf`; se sim, incluir no escopo da task.

## Testes
- Manual: solicitar reset em development, confirmar recebimento do email (SES) e concluir troca de senha.
- Manual: login com nova senha + MFA apos reset.
- Opcional: teste unitario dos novos metodos do `AuthService` com mocks do Amplify.
