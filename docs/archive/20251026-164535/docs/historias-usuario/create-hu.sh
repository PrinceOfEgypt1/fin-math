#!/bin/bash

# ==========================================
# Script de Criação Rápida de HU
# ==========================================

set -e

echo "🎯 Criar Nova História de Usuário"
echo ""

# Solicitar informações
read -p "📋 Número da HU (ex: 25): " HU_NUM
read -p "📝 Título (ex: Simulador CET Básico): " HU_TITLE
read -p "🎭 Sprint (ex: 6): " SPRINT_NUM

# Sanitizar título para nome de arquivo
FILE_TITLE=$(echo "$HU_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
FILENAME="HU-${HU_NUM}-${FILE_TITLE}.md"

# Copiar template
cp HU-template.md "$FILENAME"

# Substituir placeholders
sed -i "s/HU-XX/HU-${HU_NUM}/g" "$FILENAME"
sed -i "s/\[Título da História\]/${HU_TITLE}/g" "$FILENAME"
sed -i "s/\[Número da Sprint\]/${SPRINT_NUM}/g" "$FILENAME"
sed -i "s/YYYY-MM-DD/$(date +%Y-%m-%d)/g" "$FILENAME"

echo ""
echo "✅ HU criada: $FILENAME"
echo ""
echo "📋 Próximos passos:"
echo "  1. Editar: nano $FILENAME"
echo "  2. Preencher critérios de aceite"
echo "  3. Adicionar casos de teste"
echo "  4. Atualizar README.md"
echo ""
