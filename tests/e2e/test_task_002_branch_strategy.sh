#!/bin/bash
echo "Verificando documento de branch-strategy (TASK-002)..."
ERROS=0

FILE="docs/guides/branch-strategy.md"

if [ ! -f "$FILE" ]; then
  echo "❌ Erro: Arquivo '$FILE' não encontrado."
  exit 1
else
  echo "✅ Arquivo '$FILE' existe."
fi

# Verifica regras de nomenclatura de branches
for term in "feature/" "bugfix/" "hotfix/"; do
  if ! grep -qi "$term" "$FILE"; then
    echo "❌ Erro: O termo '$term' não foi documentado."
    ERROS=$((ERROS+1))
  else
    echo "✅ Termo '$term' encontrado."
  fi
done

# Verifica documentação dos ambientes e fluxo de merge
for env in "development" "test" "staging" "production"; do
  if ! grep -qi "$env" "$FILE"; then
    echo "❌ Erro: O ambiente '$env' não foi documentado no fluxo de merge."
    ERROS=$((ERROS+1))
  else
    echo "✅ Ambiente '$env' encontrado."
  fi
done

if [ $ERROS -gt 0 ]; then
  echo "⚠️  Foram encontrados $ERROS erros no documento."
  exit 1
else
  echo "🎉 Sucesso! Branch strategy validada."
  exit 0
fi
