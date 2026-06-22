#!/bin/bash
echo "Verificando estrutura inicial de IaC com Blue/Green (TASK-006)..."
ERROS=0

if [ ! -f "infra/cdk.json" ] || [ ! -f "infra/package.json" ]; then
  echo "❌ Erro: Projeto CDK não inicializado."
  ERROS=$((ERROS+1))
fi

CONFIG_FILE="infra/lib/config.ts"
if [ ! -f "$CONFIG_FILE" ] && [ ! -f "infra/bin/infra.ts" ]; then
  echo "❌ Erro: Arquivo de configuração não encontrado."
  ERROS=$((ERROS+1))
else
  grep -qi "development" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'development' não mapeado."; ERROS=$((ERROS+1)); }
  grep -qi "test" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'test' não mapeado."; ERROS=$((ERROS+1)); }
  grep -qi "staging" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'staging' não mapeado."; ERROS=$((ERROS+1)); }
  grep -qi "production-blue" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'production-blue' não mapeado."; ERROS=$((ERROS+1)); }
  grep -qi "production-green" "infra/lib/config.ts" "infra/bin/infra.ts" 2>/dev/null || { echo "❌ Erro: Ambiente 'production-green' não mapeado."; ERROS=$((ERROS+1)); }
  echo "✅ Ambientes (development, test, staging, production-blue, production-green) configurados."
fi

if [ $ERROS -gt 0 ]; then
  echo "⚠️  Encontrados $ERROS erros na infraestrutura."
  exit 1
else
  echo "🎉 Sucesso! Projeto IaC validado."
  exit 0
fi
