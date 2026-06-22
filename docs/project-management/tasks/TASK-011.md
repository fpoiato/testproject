# TASK-011 - Criar API Gateway (Base Infrastructure).

**Status:** 🔄 In Progress

## Objetivo
Declarar no Terraform a base do API Gateway REST com os stages dinâmicos (`development`, `test`, `staging`, `production-blue`, `production-green`). *Nota: Resources, Methods, Integrations e Authorizer serão criados em TASK-012 via CDK.*

## Contexto
Parte do [EPIC-002 (AWS Foundation)](https://github.com/fpoiato/testproject/issues/21).

## Dependências
[#6 (TASK-006)](https://github.com/fpoiato/testproject/issues/6) ✅
[#10 (TASK-010)](https://github.com/fpoiato/testproject/issues/10) ✅ (para referência Cognito User Pool)

## Arquivos afetados
- [infra/terraform/api-gateway.tf](https://github.com/fpoiato/testproject/tree/main/infra/terraform/api-gateway.tf)
- [infra/terraform/outputs.tf](https://github.com/fpoiato/testproject/tree/main/infra/terraform/outputs.tf)
- [infra/terraform/variables.tf](https://github.com/fpoiato/testproject/tree/main/infra/terraform/variables.tf)

## Estimativa de complexidade
M (Medium)

## Critérios de aceite
- API Gateway REST API declarado no Terraform.
- Stages de deploy configurados (development, test, staging, production-blue, production-green).
- Endpoint type definido (REGIONAL - HTTPS enforced).
- Nota estabelecida explicando que Resources, Methods, Integrations e Authorizer serão criados em TASK-012 via CDK.

## Contexto do Near-Future (Terraform + CDK Hybrid)

**TERRAFORM TASK-011 (Aqui):**
- [ ] API Gateway REST API (base only)
- [ ] Stages
- [ ] Outputs: REST API ID, Nome, Execution ARN, Stage Name, Deployment ID
- [ ] Nota explicando que CDK (TASK-012) criará Resources, Methods, Integrations e Authorizer

**CDK TASK-012 (Próximo):**
- Recursos Resources (paths: /veiculos, /veiculos/{placa})
- Recursos Methods (GET, POST, PUT, DELETE)
- Recursos Integrations (Lambda functions)
- Recursos Authorizer (Cognito JWT)
- Recursos Lambda Functions (5 functions: get_veiculos, create_veiculo, get_veiculo, update_veiculo, delete_veiculo)

## Casos de Teste
- TC-011: Validar que API Gateway REST API criado com Stage especificado
- Validação futura (TASK-012): Resources/Methods/Integrations criados via CDK

## Referências
- [ADR-002: Terraform + CDK Hybrid Architecture](../architecture/adr-002-terraform-cdk-hybrid.md)
- TASK-010 (Cognito - referência)
- TASK-012 (CDK Lambda + API Gateway Resources/Methods/Integrations/Authorizer - Próximo)
- EPIC-002 (AWS Foundation)
