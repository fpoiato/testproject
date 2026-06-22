# testproject

Monorepo para a aplicação serverless na AWS, organizado em três camadas principais: frontend, backend e infraestrutura.

## Visão geral

Este projeto adota uma arquitetura serverless com:

- **Frontend** — interface web hospedada via CloudFront e S3
- **Backend** — APIs REST implementadas com AWS Lambda e API Gateway
- **Infraestrutura** — recursos AWS provisionados via AWS CDK (TypeScript)

Os serviços centrais incluem Amazon Cognito (autenticação), DynamoDB (persistência) e demais componentes definidos na documentação de arquitetura.

## Estrutura do repositório

```
testproject/
├── frontend/   # Aplicação web
├── backend/    # Handlers Lambda e lógica de API
├── infra/      # Stacks AWS CDK
└── docs/       # Documentação do projeto
```

## Documentação

Consulte a pasta [`docs/`](docs/) para detalhes sobre o projeto:

- [Tarefas e épicos](docs/project-management/tasks/) — backlog e planejamento
- [Casos de teste](docs/test-cases/) — critérios de validação automatizados e manuais
