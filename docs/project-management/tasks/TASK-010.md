# TASK-010 - Criar Cognito

> ⚠️ **DEPRECATED — documento histórico.** Descreve o modelo antigo (CDK híbrido + `*.tfvars` por ambiente), substituído pela consolidação em Terraform (stack único multi-ambiente). Mantido apenas como registro. Fonte da verdade atual: [`infra/terraform/README.md`](../../../infra/terraform/README.md) e [ADR-003](../../architecture/adr-003-terraform-shared-model.md).

**Status:** 🔄 In Progress

## Objetivo
Configurar no Terraform o Amazon Cognito User Pool para gerenciar o auto cadastro, confirmação por e-mail e exigência de MFA via aplicativo autenticador.

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#6 (TASK-006)](https://github.com/fpoiato/testproject/issues/6) ✅

## Arquivos afetados
- [infra/terraform/cognito.tf](https://github.com/fpoiato/testproject/tree/main/infra/terraform/cognito.tf)
- [infra/terraform/*.tfvars](https://github.com/fpoiato/testproject/tree/main/infra/terraform/) (adicionar configuração Cognito)

## Estimativa de complexidade
L (Large)

## Critérios de aceite
- User Pool e Identity Pool criados via Terraform.
- Configuração de auto cadastro validado por e-mail habilitada.
- Políticas de MFA exigindo TOTP (Authenticator App) implementadas obrigatoriamente.
- SPA client sem secret (PKCE flow).
- Password policy: mínimo 12 caracteres, números e símbolos obrigatórios.
- IAM roles para usuários autenticados criados.

## Configuração por Ambiente

| Environment | Password Policy | MFA Required | Callback URLs |
|-------------|----------------|--------------|--------------|
| development | min 8 chars, no symbols | Optional (false) | localhost:4200 |
| test | min 12 chars, all | Required (true) | test.testproject.fpoiato.com |
| staging | min 12 chars, all | Required (true) | staging.testproject.fpoiato.com |
| production-blue | min 12 chars, all | Required (true) | app.testproject.fpoiato.com + blue.testproject.fpoiato.com |
| production-green | min 12 chars, all | Required (true) | app.testproject.fpoiato.com + green.testproject.fpoiato.com |

## Casos de Teste
- [TC-010](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-010.md): Validar critérios da TASK-010
