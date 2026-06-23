# testproject

Monorepo para a aplicação serverless na AWS, organizado em três camadas principais: frontend, backend e infraestrutura.

## Visão geral

Este projeto adota uma arquitetura serverless com:

- **Frontend** — app Angular 19 hospedado via CloudFront e S3 (um por ambiente)
- **Backend** — handlers Node.js (Lambda) atrás de um único API Gateway REST com stages por ambiente
- **Infraestrutura** — recursos AWS provisionados via **Terraform** (state remoto em S3 + lock DynamoDB)

Modelo compartilhado: um API Gateway com stages `development`/`test`/`staging`/`production`, onde a stage variable `lambdaAlias` seleciona o alias da Lambda. DynamoDB e Cognito são por ambiente. Detalhes em [ADR-003](docs/architecture/adr-003-terraform-shared-model.md).

## Estrutura do repositório

```
testproject/
├── frontend/   # App Angular (veículos, auth MFA, export Excel)
├── backend/    # Handlers Lambda + Lambda Authorizer
├── infra/      # Terraform (infra/terraform)
└── docs/       # Documentação do projeto
```

## Setup / Instalação

Guia para configurar o ambiente de desenvolvimento local.

### Pré-requisitos

| Ferramenta | Versão mínima sugerida | Finalidade |
|------------|------------------------|------------|
| [Git](https://git-scm.com/) | 2.x | Controle de versão |
| [Node.js](https://nodejs.org/) | 20 LTS | Frontend, backend (Lambda) e infra (CDK) |
| [npm](https://www.npmjs.com/) | 10+ | Gerenciamento de dependências |
| [AWS CLI](https://docs.aws.amazon.com/cli/) | 2.x | Interação com recursos AWS |
| [AWS CDK CLI](https://docs.aws.amazon.com/cdk/) | 2.x | Deploy da infraestrutura (`infra/`) |

Configure também credenciais AWS válidas (`aws configure` ou variáveis de ambiente) para deploy e testes integrados.

### Passos iniciais

1. **Clone o repositório**

   ```bash
   git clone https://github.com/fpoiato/testproject.git
   cd testproject
   ```

2. **Verifique a estrutura base**

   ```bash
   tests/e2e/test_task_001_structure.sh
   ```

3. **Instale dependências** (quando os pacotes estiverem disponíveis em cada camada)

   ```bash
   # Frontend (Angular)
   cd frontend && npm install && cd ..

   # Backend (handlers Lambda)
   cd backend && npm install && cd ..

   # Infraestrutura (AWS CDK)
   cd infra && npm install && cd ..
   ```

4. **Configure variáveis de ambiente**

   Copie os arquivos `.env.example` de cada módulo (quando existirem) para `.env` e ajuste os valores conforme o ambiente local. Nunca commite arquivos `.env` — eles já estão listados no `.gitignore`.

5. **Valide a documentação inicial**

   ```bash
   tests/e2e/test_task_005_documentation.sh
   ```

### Próximos passos

Após a conclusão das tasks de infraestrutura (EPIC-002), será possível fazer deploy com CDK a partir de `infra/` e executar o frontend localmente apontando para o stage `development`.

## Documentação

Consulte a pasta [`docs/`](docs/) para detalhes sobre o projeto:

- [Arquitetura](docs/architecture/architecture.md) — stack Serverless (API Gateway, Lambda, DynamoDB, Cognito)
- [Tarefas e épicos](docs/project-management/tasks/) — backlog e planejamento
- [Casos de teste](docs/test-cases/) — critérios de validação automatizados e manuais
