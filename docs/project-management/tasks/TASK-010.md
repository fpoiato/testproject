# TASK-010 - Criar Cognito

## Objetivo
Configurar no IaC o Amazon Cognito User Pool para gerenciar o auto cadastro, confirmação por e-mail e exigência de MFA via aplicativo autenticador.

## Contexto
Parte do EPIC-002 (AWS Foundation).

## Dependências
#6 (TASK-006)

## Arquivos afetados
- infra/stacks/auth_stack.*

## Estimativa de complexidade
L (Large)

## Critérios de aceite
- User Pool e Identity Pool criados via IaC.
- Configuração de auto cadastro validado por e-mail habilitada.
- Políticas de MFA exigindo TOTP (Authenticator App) implementadas obrigatoriamente.

## Casos de Teste
- [TC-010](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-010.md): Validar critérios da TASK-010
