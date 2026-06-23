# ADR-002: Terraform + CDK Hybrid Architecture

> ⚠️ **DEPRECATED — documento histórico.** Este ADR descreve o modelo híbrido CDK + Terraform, que foi abandonado. Mantido apenas como registro. Fonte da verdade atual: [ADR-003](adr-003-terraform-shared-model.md) e [`infra/terraform/README.md`](../../infra/terraform/README.md).

## Status
**Superseded by [ADR-003](adr-003-terraform-shared-model.md)** (originalmente Aceito em 2026-06-22)

## Contexto
O projeto `testproject` requer um arquitetura que:
1. Mantenha infraestrutura estável (Cognito Pools, DynamoDB, S3, CloudFront)
2. Evite problemas com stacks CloudFormation presos que requerem deleção/recriação
3. Perita deploy rápido de código Lambda sem reconstruir infraestrutura core
4. Use ferramentas gratuitas e open-source (Serverless Framework agora é pago)

Tarefas completadas até o momento (TASK-007 até TASK-011) foram implementadas via Terraform, mas TASK-012 (Lambda Functions) requer uma decisão sobre ferramenta de deploy.

## Decisão
Adotar arquitetura **Hybrid Terraform + CDK**:

**Terraform (Infrastructure As Code):**
- Gerencia recursos infraestrutura core: Cognito API, DynamoDB, S3 buckets, CloudFront distributions
- Gerencia API Gateway components: REST API, Resources, Methods, Stages, Authorizer
- Cria IAM Roles para Lambda execution (no Terraform, referenciadas pelo CDK)

**CDK (Application Code):**
- Gerencia Lambda Function code deployment
- Configura API Gateway Integrations (mock → Lambda)
- Gerencia Lambda Environment Variables
- Replace mock integrations do TASK-011 com Lambda integrations reais

### Arquitetura por Camada

```
APLICAÇÃO (CDK - sam-app-cdk)
  ├─ Criar Lambda Functions (get_veiculos, create_veiculo, get_veiculo, update_veiculo, delete_veiculo)
  ├─ Configurar Lambda Runtime (Node.js / Python)
  ├─ Configurar Lambda Environment Variables
  ├─ Importar API Gateway Resources (via data sources ou environment variables)
  ├─ Configurar API Gateway Integrations
  └─ Deploy de código Lambda (.zip files)

INFRAESTRURA (Terraform - infra/terraform)
  ├─ Cognito User Pool & Identity Pool
  ├─ DynamoDB Table (Veiculos)
  ├─ S3 Buckets (Frontend)
  ├─ CloudFront Distributions (CDN)
  ├─ API Gateway REST API, Resources, Methods, Stages
  ├─ API Gateway Authorizer (Cognito JWT)
  └─ IAM Roles para Lambda Execution
```

## Justificativa

### Pros (Terraform + CDK)

**Infrastructure Stability:**
- ☑️ Recursos core em Terraform nunca precisam ser recriados
- ☑️ Terraform state management garante consistência
- ☑️ Nenhum risco de stacks CloudFormation presos para recursos core

**Deployment Speed:**
- ☑️ Changes em código Lambda (CDK) são rápidos, independentes de Terraform
- ☑️ `cdk deploy` para código apenas (hot-swap Lambda code)
- ☑️ `terraform apply` apenas quando infra mudar

**Claridade de Separation of Concerns:**
- ☑️ Infra mudanças via Terraform (requer PR approval)
- ☑️ Código mudanças via CDK (pode ser automatizado em CI/CD)
- ☑️ Equipe entende o que cada ferramenta gerencia

**Cost:**
- ☑️ Terraform: free & open-source (Apache 2.0)
- ☑️ CDK: free & open-source (Apache 2.0)
- ☑️ Nenhum custo de licensing

### Cons Consideradas e Mitigadas

**Ferramenta Fragmentation:**
- ☑️arefação aceita dado benefits: infra stability + deployment speed
- ☑️ Ambas ferramentas são populares, com comunidade ativa

**Orchestration Complexity:**
- ☑️ Terraform outputs exported como environment variables para CDK
- ☑️ API Gateway resources imported via CDK data sources (ou CloudFormation exports)

**Learning Curve:**
- ☑️ Ambas ferramentas são amplas conhecidas na indústria
- ☑️ Terraform já está estabelecido no projeto (TASK-007 até TASK-011)

## Alternativas Consideradas

### Alternativa A: Zero Terraform (Tudo via CDK)
- **Rejeição:** CloudFormation stacks podem presar, necessitando deleção/recriação
- **Custo Alto:** risking Cognito Pools e outros recursos core

### Alternativa B: CDK para Tudo (com overlaps)
- **Rejeição:** CDK bootsraps CloudFormation stacks, mesmos riscos
- **Custo Alto:** CloudFormation stack management still present

### Alternativa C: Zero Terraform + Serverless Framework
- **Rejeição:** Serverless Framework agora é pago, não mais free com updates
- **Custo Alto:** Licensing cost & não mais free maintainers

## Implementação

### Single-Account Implementation (Current Setup)

**Terraform Outputs Export:**
```hcl
# outputs.tf
output "api_gateway_rest_api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "api_gateway_execution_arn" {
  value = aws_api_gateway_rest_api.main.execution_arn
}

output "api_gateway_resources" {
  value = {
    veiculos       = aws_api_gateway_resource.veiculos.id
    veiculos_placa = aws_api_gateway_resource.veiculos_placa.id
  }
}

output "dynamodb_veiculos_table_name" {
  value = aws_dynamodb_table.veiculos.name
}
```

**CDK Consumption Pattern:**
```typescript
// In CDK stack (sam-app-cdk)
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';

// Import API Gateway via environment variable
const apiId = process.env.API_GATEWAY_ID!;
const restApi = apigateway.RestApi.fromRestApiAttributes(this, 'ImportedApi', {
  restApiId: apiId
});

// Import DynamoDB Table via environment variable
const tableName = process.env.DYNAMODB_TABLE_NAME!;

// Create Lambda function
const getVeiculosFn = new lambda.Function(this, 'GetVeiculos', {
  runtime: lambda.Runtime.NODEJS_20_X,
  handler: 'index.handler',
  code: lambda.Code.fromAsset(path.join(__dirname, '../lambda/get-veiculos')),
  environment: {
    DYNAMODB_TABLE: tableName
  }
});

// Create API Gateway integration
const getVeiculosIntegration = new apigateway.LambdaIntegration(getVeiculosFn);
const veiculosResource = restApi.root.getResource('veiculos');
veiculosResource.addMethod('GET', getVeiculosIntegration, {
  authorizationType: apigateway.AuthorizationType.COGNITO
});
```

**Note on Terraform Code Upload:**
O CDK (via built-in bundling ou local bundling) é responsável pelo upcar o código Lambda; Terraform não vai gerenciar o código Lambda (.zip) diretamente.

### Directory Structure
```
testproject/
├── infra/
│   └── terraform/           ← Terraform Core Infra
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── s3.tf
│       ├── cloudfront.tf
│       ├── dynamodb.tf
│       ├── cognito.tf
│       ├── api-gateway.tf
│       └── local.tfvars/*.tfvars
├── cdk/
│   ├── sam-app-cdk/         ← CDK Application Stack
│   │   ├── bin/
│   │   │   └── sam-app.ts
│   │   ├── lib/
│   │   │   └── sam-app-stack.ts
│   │   └── cdk.json
│   └── lambda/              ← Lambda Function Code
│       ├── get-veiculos/
│       ├── create-veiculo/
│       ├── get-veiculo/
│       ├── update-veiculo/
│       └── delete-veiculo/
```

### Deployment Sequence

**Initial Setup:**
1. `terraform apply` (Terraform - cria infra core)
2. Exportar Terraform outputs (manual ou via script)
3. Configurar environment variables para CDK
4. `cdk deploy` (CDK - cria Lambda functions + API Gateway integrations)

**Subsequent Deployments (Code Changes Only):**
1. Modificar código Lambda
2. `cdk deploy`deploy apenas o código
3. Não necessita re-executar terraform

**Subsequent Deployments (Infra Changes Only):**
1. Modificar infra Terraform
2. `terraform plan / apply`
3. CDK components automaticamente re-importam resources atualizados via environment variables

### IAM Roles Policy

**Terraform Roles Preferences:**
- Criar IAM Role para Lambda execution (no Terraform)
- Adicionar permissões DynamoDB (Tabela Veiculos)
- Adicionar permissões básicas Cognito (opcional)

**CDK Role Override:**
Por padrão, CDK cria uma IAM Role por função Lambda; você pode substituir isso usando a função `Role` e trazendo a IAM Role criada pelo Terraform: `import Role.fromRoleArn(this, 'ExistingRole', roleArn)`.

**Restrição:**
Terraform não va managed_entry_point aos Permission Statements do Role que o CDK contém, porque o CDK deve ter o Role atribuído à função a partir de um CloudFormation exports (use outputs + CloudFormation exports) e você precisa try/catch com data sources, mas a política de importação via `sam-app` não é trivial. Por segurança e gerenciabilid

ade, é mais simples e mais seguro permitir que o CDK crie a IAM Role associada à função Lambda e controlar suas permissões específicas dentro do CDK (incluindo o consumo da `DYNAMODB_TABLE` via environment variable); ao mesmo tempo, o CloudFormation stack não é eliminado para os recursos Terraform, que continuam imutáveis.

## Consequências

### Positivas
- Infraestrutura core imutável, gerenciada via Terraform
- Deploy de código Lambda rápido e independente via CDK
- Flexibilidade para futuros multi-account setups (CDK podem faz cross-account)
- Ferramentas completamente gratuitas e open-source

### Negativas
- Operações sincronização de produção: CLI invés de CLI only (mas muito simples)
- Necessário exportar/ter em mente Terraform outputs na sequência de deploy
- IAM Role split: Terraform cria algumas roles (infra), CDK cria Lambda execution roles

## Referências
- EPIC-002: AWS Foundation
- TASK-007 até TASK-011: Implemented via Terraform
- TASK-012: Criar Functions Lambda via CDK
- ADR-001: DNS e Domínios por Ambiente
