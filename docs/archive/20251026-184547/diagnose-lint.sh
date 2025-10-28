#!/bin/bash

echo "🔍 DIAGNÓSTICO - Problema de Lint"
echo "=================================="
echo ""

# 1. Ver o erro completo
echo "1️⃣ Erro de Lint Completo:"
echo "---"
cat /tmp/finmath_test_10.log
echo ""
echo "=================================="
echo ""

# 2. Verificar se eslint.config.js existe
echo "2️⃣ Verificando configuração ESLint:"
if [ -f "packages/engine/eslint.config.js" ]; then
    echo "✅ packages/engine/eslint.config.js existe"
elif [ -f "eslint.config.js" ]; then
    echo "✅ eslint.config.js (raiz) existe"
else
    echo "❌ Nenhum arquivo de configuração ESLint encontrado"
fi
echo ""

# 3. Verificar package.json do engine
echo "3️⃣ Script de lint no package.json:"
cat packages/engine/package.json | grep -A 2 '"lint"'
echo ""

# 4. Verificar versão do ESLint
echo "4️⃣ Versão do ESLint instalada:"
cd packages/engine && pnpm list eslint
echo ""

# 5. Tentar rodar lint manualmente
echo "5️⃣ Tentando rodar lint manualmente:"
cd packages/engine
pnpm lint 2>&1 | head -20
echo ""

# 6. Verificar arquivos TypeScript
echo "6️⃣ Arquivos TypeScript no engine:"
find packages/engine/src -name "*.ts" | head -10
echo ""

echo "=================================="
echo "✅ Diagnóstico concluído"
