#!/bin/bash
# Validar que todos os documentos foram criados

echo "🔍 Validando documentação da Sprint 2..."
echo ""

DOCS=(
  "README.md"
  "ARQUITETURA.md"
  "EXEMPLOS_API.md"
  "RESUMO_EXECUTIVO.md"
)

ALL_OK=true

for doc in "${DOCS[@]}"; do
  if [ -f "$doc" ]; then
    SIZE=$(wc -l < "$doc")
    echo "✅ $doc ($SIZE linhas)"
  else
    echo "❌ $doc - NÃO ENCONTRADO"
    ALL_OK=false
  fi
done

echo ""

if [ "$ALL_OK" = true ]; then
  echo "🎉 Todos os documentos criados com sucesso!"
  exit 0
else
  echo "❌ Alguns documentos estão faltando"
  exit 1
fi
