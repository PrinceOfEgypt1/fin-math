#!/bin/bash

cd ~/workspace/fin-math

echo "╔═══════════════════════════════════════════════╗"
echo "║     DIAGNÓSTICO - SERVIDOR DEV                ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# 1. Verificar scripts
echo "📦 1. Scripts no package.json raiz:"
grep '"dev":' package.json || echo "   ❌ Script 'dev' não encontrado"
echo ""

# 2. Verificar packages
echo "📦 2. Scripts nos subpacotes:"
for pkg in packages/*/package.json; do
  if [ -f "$pkg" ]; then
    echo "   $(dirname $pkg):"
    grep '"dev":' "$pkg" || echo "      ❌ Sem script dev"
  fi
done
echo ""

# 3. Verificar Vite
echo "🔧 3. Configurações Vite:"
find . -name "vite.config.*" -type f | grep -v node_modules
echo ""

# 4. Verificar index.html
echo "📄 4. Arquivos index.html:"
find . -name "index.html" -type f | grep -v node_modules
echo ""

# 5. Tentar iniciar servidor
echo "🌐 5. Tentando iniciar servidor (10s)..."
timeout 10s pnpm dev 2>&1 | head -30
echo ""

# 6. Verificar fixtures
echo "📁 6. Fixtures de teste:"
ls -la tests/fixtures/ 2>/dev/null || echo "   ❌ Diretório fixtures não existe"
echo ""

echo "═══════════════════════════════════════════════"
