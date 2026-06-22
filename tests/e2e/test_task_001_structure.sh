#!/bin/bash
echo "Verificando estrutura da TASK-001..."
ERROS=0

for pasta in frontend backend infra; do
  if [ ! -d "$pasta" ]; then
    echo "❌ Erro: Pasta '$pasta' não encontrada."
    ERROS=$((ERROS+1))
  else
    echo "✅ Pasta '$pasta' existe."
  fi
done

if [ ! -f ".gitignore" ]; then
  echo "❌ Erro: Arquivo .gitignore não encontrado."
  ERROS=$((ERROS+1))
else
  grep -q "node_modules" .gitignore || { echo "❌ Erro: .gitignore não ignora node_modules."; ERROS=$((ERROS+1)); }
  echo "✅ .gitignore configurado."
fi

if [ ! -f ".editorconfig" ]; then
  echo "❌ Erro: Arquivo .editorconfig não encontrado."
  ERROS=$((ERROS+1))
else
  grep -q "utf-8" .editorconfig || { echo "❌ Erro: .editorconfig sem charset utf-8."; ERROS=$((ERROS+1)); }
  echo "✅ .editorconfig configurado."
fi

if [ ! -f "README.md" ]; then
  echo "❌ Erro: Arquivo README.md não encontrado."
  ERROS=$((ERROS+1))
else
  echo "✅ README.md raiz existe."
fi

if [ $ERROS -gt 0 ]; then
  echo "⚠️  Foram encontrados $ERROS erros na estrutura."
  exit 1
else
  echo "🎉 Sucesso! Estrutura inicial validada."
  exit 0
fi
