#!/bin/bash
echo "Verificando documentação inicial (TASK-005)..."
ERROS=0

FILE_ARCH="docs/architecture/architecture.md"
FILE_README="README.md"

if [ ! -f "$FILE_ARCH" ]; then
  echo "❌ Erro: Arquivo '$FILE_ARCH' não encontrado."
  ERROS=$((ERROS+1))
else
  grep -qi "Serverless" "$FILE_ARCH" || { echo "❌ Erro: Faltou mencionar Serverless."; ERROS=$((ERROS+1)); }
  grep -qi "API Gateway" "$FILE_ARCH" || { echo "❌ Erro: Faltou mencionar API Gateway."; ERROS=$((ERROS+1)); }
  grep -qi "Lambda" "$FILE_ARCH" || { echo "❌ Erro: Faltou mencionar Lambda."; ERROS=$((ERROS+1)); }
  grep -qi "DynamoDB" "$FILE_ARCH" || { echo "❌ Erro: Faltou mencionar DynamoDB."; ERROS=$((ERROS+1)); }
  grep -qi "Cognito" "$FILE_ARCH" || { echo "❌ Erro: Faltou mencionar Cognito."; ERROS=$((ERROS+1)); }
  echo "✅ architecture.md existe e contém a stack Serverless."
fi

if [ ! -f "$FILE_README" ]; then
  echo "❌ Erro: Arquivo '$FILE_README' não encontrado."
  ERROS=$((ERROS+1))
else
  grep -qi "setup" "$FILE_README" || grep -qi "instala" "$FILE_README" || { echo "❌ Erro: Faltou guia de setup no README."; ERROS=$((ERROS+1)); }
  echo "✅ README.md validado."
fi

if [ $ERROS -gt 0 ]; then
  echo "⚠️  Encontrados $ERROS erros."
  exit 1
else
  echo "🎉 Sucesso! Documentação inicial validada."
  exit 0
fi
