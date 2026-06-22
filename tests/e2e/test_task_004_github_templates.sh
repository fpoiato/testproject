#!/bin/bash
echo "Verificando templates do GitHub (TASK-004)..."
ERROS=0

# Template de PR
if [ ! -f ".github/PULL_REQUEST_TEMPLATE.md" ]; then
  echo "❌ Erro: Arquivo PULL_REQUEST_TEMPLATE.md não encontrado."
  ERROS=$((ERROS+1))
else
  grep -q "Closes #" .github/PULL_REQUEST_TEMPLATE.md || { echo "❌ Erro: PR Template não possui keyword 'Closes #'."; ERROS=$((ERROS+1)); }
  echo "✅ PR Template existe e validado."
fi

# Template de Feature Issue
if [ ! -f ".github/ISSUE_TEMPLATE/feature.md" ]; then
  echo "❌ Erro: Template feature.md não encontrado."
  ERROS=$((ERROS+1))
else
  echo "✅ Template de Feature Issue existe."
fi

# Template de Bug Issue
if [ ! -f ".github/ISSUE_TEMPLATE/bug.md" ]; then
  echo "❌ Erro: Template bug.md não encontrado."
  ERROS=$((ERROS+1))
else
  echo "✅ Template de Bug Issue existe."
fi

if [ $ERROS -gt 0 ]; then
  echo "⚠️  Foram encontrados $ERROS erros na checagem dos templates."
  exit 1
else
  echo "🎉 Sucesso! Templates do GitHub validados."
  exit 0
fi
