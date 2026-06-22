#!/bin/bash
echo "Verificando estrutura inicial de IaC (TASK-006)..."
ERROS=0

# Verifica inicialização do CDK
if [ ! -f "infra/cdk.json" ]; then
  echo "❌ Erro: Projeto CDK não inicializado em infra/cdk.json."
  ERROS=$((ERROS+1))
else
  echo "✅ Projeto CDK inicializado."
fi

if [ ! -f "infra/package.json" ]; then
  echo "❌ Erro: package.json do CDK não encontrado em infra/."
  ERROS=$((ERROS+1))
else
  echo "✅ package.json (CDK) existe."
fi

# Verifica o arquivo de configuração de ambientes que o cursor precisa criar
CONFIG_FILE="infra/lib/config.ts"
if [ ! -f "$CONFIG_FILE" ] && [ ! -f "infra/bin/infra.ts" ]; then
  echo "❌ Erro: Arquivo de configuração de ambientes não encontrado (esperado infra/lib/config.ts ou variáveis no infra.ts)."
  ERROS=$((ERROS+1))
else
  grep -qi "development" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'development' não mapeado."; ERROS=$((ERROS+1)); }
  grep -qi "test" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'test' não mapeado."; ERROS=$((ERROS+1)); }
  grep -qi "staging" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'staging' não mapeado."; ERROS=$((ERROS+1)); }
  grep -qi "production" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'production' não mapeado."; ERROS=$((ERROS+1)); }
  echo "✅ Ambientes (development, test, staging, production) configurados."
fi

if [ $ERROS -gt 0 ]; then
  echo "⚠️  Encontrados $ERROS erros na infraestrutura."
  exit 1
else
  echo "🎉 Sucesso! Projeto IaC validado."
  exit 0
fi
