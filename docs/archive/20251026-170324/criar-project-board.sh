#!/bin/bash
# criar-project-board.sh

set -e

echo "📋 CRIANDO PROJECT BOARD VIA GITHUB CLI"
echo "======================================="

# 1. Criar projeto
echo "Criando projeto..."
PROJECT_URL=$(gh project create \
  --owner PrinceOfEgypt1 \
  --title "FinMath - Development Board" \
  --format json | jq -r '.url')

echo "✅ Projeto criado: $PROJECT_URL"

# 2. Extrair número do projeto da URL
PROJECT_NUM=$(echo $PROJECT_URL | grep -oP 'projects/\K[0-9]+')

echo "📊 Número do projeto: $PROJECT_NUM"

# 3. Atualizar docs/PROJECT-BOARD.md
sed -i "s/\[NÚMERO\]/$PROJECT_NUM/g" docs/PROJECT-BOARD.md

# 4. Criar labels no repositório
echo ""
echo "🏷️  Criando labels..."

# Sprints
gh label create "sprint-1" --color "0366d6" --description "Sprint 1" --repo PrinceOfEgypt1/fin-math || true
gh label create "sprint-2" --color "0366d6" --description "Sprint 2" --repo PrinceOfEgypt1/fin-math || true
gh label create "sprint-3" --color "0366d6" --description "Sprint 3" --repo PrinceOfEgypt1/fin-math || true
gh label create "sprint-4" --color "0366d6" --description "Sprint 4" --repo PrinceOfEgypt1/fin-math || true

# Módulos
gh label create "engine" --color "28a745" --description "Motor de cálculos" --repo PrinceOfEgypt1/fin-math || true
gh label create "api" --color "fbca04" --description "API REST" --repo PrinceOfEgypt1/fin-math || true
gh label create "ui" --color "7057ff" --description "Interface" --repo PrinceOfEgypt1/fin-math || true
gh label create "docs" --color "d4c5f9" --description "Documentação" --repo PrinceOfEgypt1/fin-math || true

# Prioridades
gh label create "priority-high" --color "d73a4a" --description "Alta prioridade" --repo PrinceOfEgypt1/fin-math || true
gh label create "priority-medium" --color "fbca04" --description "Média prioridade" --repo PrinceOfEgypt1/fin-math || true
gh label create "priority-low" --color "0e8a16" --description "Baixa prioridade" --repo PrinceOfEgypt1/fin-math || true

echo "✅ Labels criados!"

# 5. Commit da atualização
echo ""
echo "📝 Commitando atualização do docs/PROJECT-BOARD.md..."
git add docs/PROJECT-BOARD.md
git commit -m "docs: Atualiza link do Project Board (projeto $PROJECT_NUM)"
git push origin main

echo ""
echo "========================================="
echo "✅ PROJECT BOARD CRIADO COM SUCESSO!"
echo "========================================="
echo ""
echo "🔗 URL: $PROJECT_URL"
echo "📊 Número: $PROJECT_NUM"
echo ""
echo "Próximo passo: Adicionar colunas via UI ou CLI"
