#!/bin/bash

cd ~/workspace/fin-math

echo "╔═══════════════════════════════════════════════╗"
echo "║     INVESTIGAÇÃO COMPLETA - UI                ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# 1. Workspace
echo "📦 1. pnpm-workspace.yaml:"
cat pnpm-workspace.yaml
echo ""

# 2. Estrutura packages/
echo "📁 2. Estrutura de packages/:"
tree packages -L 2 2>/dev/null || ls -laR packages/
echo ""

# 3. Package.json nos pacotes
echo "📋 3. Procurando package.json:"
find packages -name "package.json" -exec echo "   {}" \; -exec head -3 {} \;
echo ""

# 4. Apps (se existir)
echo "📱 4. Verificando apps/:"
if [ -d apps ]; then
  ls -la apps/
  find apps -name "package.json" -exec echo "   {}" \; -exec head -3 {} \;
else
  echo "   ❌ Diretório apps/ não existe"
fi
echo ""

# 5. Arquivos React/Vite
echo "⚛️  5. Procurando arquivos React:"
find . -name "App.tsx" -o -name "App.jsx" -o -name "vite.config.*" | grep -v node_modules | grep -v dist | head -10
echo ""

# 6. HTMLs disponíveis
echo "📄 6. HTMLs disponíveis para servir:"
find . -name "index.html" -type f | grep -E "(dist|public)" | grep -v node_modules | grep -v coverage
echo ""

# 7. Testar npm ls
echo "📦 7. Pacotes instalados no workspace:"
pnpm ls --depth=0 2>&1 | head -20
echo ""

echo "═══════════════════════════════════════════════"
