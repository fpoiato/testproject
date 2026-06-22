# TASK-007 - Criar buckets frontend

## Objetivo
Declarar os S3 Buckets no IaC para a hospedagem do SPA Angular, provendo um bucket isolado por ambiente.

## Contexto
Parte do EPIC-002 (AWS Foundation).

## Dependências
#6 (TASK-006)

## Arquivos afetados
- infra/stacks/frontend_stack.* (ou equivalente IaC)

## Estimativa de complexidade
S (Small)

## Critérios de aceite
- Buckets S3 declarados no IaC.
- Políticas de acesso restrito (preparando para integração OAC/CloudFront) configuradas de forma segura.

## Casos de Teste
- [TC-007](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-007.md): Validar critérios da TASK-007
