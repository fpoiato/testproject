# TASK-001 - Criar estrutura do repositório

## Objetivo
Estabelecer a estrutura inicial de diretórios e arquivos de configuração base do repositório `testproject`, preparando o ambiente para o desenvolvimento do Frontend, Backend e Infraestrutura.

## Contexto
Parte do EPIC-001 (Foundation). Este é o primeiro passo para garantir que todas as camadas do projeto tenham seus respectivos espaços e configurações iniciais padronizadas antes do início da escrita de código funcional.

## Dependências
Nenhuma. Esta é a primeira tarefa do projeto.

## Arquivos afetados
- `/` (raiz)
- `frontend/`
- `backend/`
- `infra/`
- `.gitignore`
- `.editorconfig`
- `README.md` (raiz)

## Estimativa de complexidade
XS (Extra Small)

## Critérios de aceite
- Pastas base (`frontend/`, `backend/`, `infra/`) criadas na raiz do repositório.
- Arquivo `.gitignore` global configurado (ignorando `node_modules`, pastas de build, `.env`, etc).
- Arquivo `.editorconfig` configurado para padronização de formatação (tamanho de tabulação, charset, etc).
- `README.md` principal na raiz criado com uma visão geral do projeto e links para as documentações na pasta `docs/`.

## Casos de Teste
- [TC-001](https://github.com/fpoiato/testproject/blob/main/docs/007-testing/test-cases/TC-001.md): Validar Estrutura Inicial do Repositório
