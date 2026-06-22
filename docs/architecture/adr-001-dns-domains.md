# ADR-001: DNS e Domínios por Ambiente

## Status
**Aceito** (2026-06-22)

## Contexto
O projeto `testproject` precisa de múltiplos ambientes (dev, test, staging, production) e uma estratégia de rollback rápido em produção via blue/green. A tarefa TASK-008 vai implementar CloudFront para servir o frontend S3, e isso requer uma definição clara de domínios/subdomínios antes de implementar as distribuições CDN.

## Decisão
**1. Domínio principal**: Utilizar o domínio existente em Route53: `fpoiato.com`

**2. Estrutura de subdomínios por ambiente**:
| Ambiente      | Subdomínio                              | Propósito                              |
|---------------|-----------------------------------------|----------------------------------------|
| development   | `dev.testproject.fpoiato.com`          | Desenvolvimento diário/feature/validation |
| test          | `test.testproject.fpoiato.com`          | Validação funcional e QA             |
| staging       | `staging.testproject.fpoiato.com`       | Pré-produção, mirror de produção  |
| production    | `app.testproject.fpoiato.com`           | Produção ativa                       |

**3. Blue/Green em produção**: Alternância via DNS:
- `blue.testproject.fpoiato.com` → Ambiente Blue
- `green.testproject.fpoiato.com` → Ambiente Green
- `app.testproject.fpoiato.com` → CNAME(s) apontando para blue ou green com health checks

## Consequências

### Positivas
- Segregação clara entre ambientes
- Padrão consistente e fácil de lembrar
- Domínio existente reaproveitado (sem custo de novo registro)
- Blue/Green permite rollback rápido em produção
- Health checks no DNS Route53 para failover automático

### Negativas
- CNAMEs adicionais para blue/green (custo AWS gratuito, mas complexidade extra)
- Necessidade de certificados SSL/ACM para todos os subdomínios (*.testproject.fpoiato.com)
- Sincronização necessária entre domínio público (`app`), estáticos blue/green e subdomínios de ambientes não-prod

## Alternativas Consideradas

### Alternativa A: Um único subdomínio por ambiente, sem blue/green explícito
- `dev.testproject.com`, `test.testproject.com`, `staging.testproject.com`, `app.testproject.com`
- **Rejeição**: Não suporta blue/green adequadamente para rollback rápido

### Alternativa B: Separar domínio inteiro por ambiente
- `dev.testproject.com`, `test.testproject.com`, `staging.testproject.com`, `prod.testproject.com`
- **Rejeição**: Custo de 4+ domínios e certificados; hard to maintain

## Implementação

1. **Hosted Zone**: Existe hosted zone gerenciado para `fpoiato.com` no Route53 (ID a ser confirmado)
2. **certificados ACM**: Solicitar certificado wildcard `*.testproject.fpoiato.com` no US-East-1 (CloudFront)
3. **Route53 Records**:
   - `dev.testproject` → CloudFront Distribution Development
   - `test.testproject` → CloudFront Distribution Test
   - `staging.testproject` → CloudFront Distribution Staging
   - `app.testproject` → Alias para blue/green com health checks
   - `blue.testproject` → CloudFront Distribution Blue
   - `green.testproject` → CloudFront Distribution Green

## Referências
- TASK-008: Criar distribuições CloudFront
- TASK-019: Deploy Production (inclui DNS alternância)
- EPIC-002: AWS Foundation
