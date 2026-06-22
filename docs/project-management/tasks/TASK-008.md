# TASK-008 - Criar distribuições CloudFront

**Status:** 🔄 In Progress

## Objetivo
Declarar a CDN CloudFront no IaC para servir o conteúdo dos Buckets S3 do Frontend, utilizando OAC (Origin Access Control) para segurança.

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Decisões de Domínio/DNS
Ver [ADR-001](../architecture/adr-001-dns-domains.md) para definição de domínios/subdomínios.

### Subdomínios por ambiente
| Ambiente      | Subdomínio                              |
|---------------|-----------------------------------------|
| development   | `dev.testproject.fpoiato.com`          |
| test          | `test.testproject.fpoiato.com`          |
| staging       | `staging.testproject.fpoiato.com`       |
| production    | `app.testproject.fpoiato.com`           |

### Blue/Green em produção
- `blue.testproject.fpoiato.com`
- `green.testproject.fpoiato.com`
- O CNAME `app.testproject.fpoiato.com` aponta para blue ou green via health checks (TASK-019)

## Dependências
[#7 (TASK-007)](https://github.com/fpoiato/testproject/issues/7)

## Arquivos afetados
- [infra/terraform/cloudfront.tf](https://github.com/fpoiato/testproject/tree/main/infra/terraform/cloudfront.tf)
- [infra/terraform/*.tfvars](https://github.com/fpoiato/testproject/tree/main/infra/terraform/) (adicionar domínios)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- Distribuições CloudFront declaradas apontando para os respectivos buckets de cada stage (dev, test, staging, production-blue, production-green).
- OAC (Origin Access Control) habilitado garantindo acesso privado aos buckets.
- Certificado ACM wildcard `*.testproject.fpoiato.com` configurado (quando disponível via ACM module).
- Domínios alternados configurados para cada distribuição.

## Casos de Teste
- [TC-008](https://github.com/fpoiato/testproject/blob/main/docs/test-cases/TC-008.md): Validar critérios da TASK-008
