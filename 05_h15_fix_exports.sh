#!/bin/bash

################################################################################
# SCRIPT: 05_h15_fix_exports.sh
# DESCRIÇÃO: Diagnosticar e corrigir problema de exports no brent.ts
# AUTOR: FinMath Team
# DATA: 2025-10-18
# VERSÃO: 1.0.0
################################################################################

set -e

echo "🔍 =========================================="
echo "🔍 DIAGNÓSTICO: Verificando brent.ts"
echo "🔍 =========================================="
echo ""

cd ~/workspace/fin-math

# ============================================================================
# VERIFICAR SE ARQUIVO EXISTE
# ============================================================================
echo "📂 Verificando se arquivo existe..."

if [ -f "packages/engine/src/irr/brent.ts" ]; then
    echo "✅ Arquivo packages/engine/src/irr/brent.ts existe"
    echo ""
    echo "📊 Tamanho do arquivo:"
    ls -lh packages/engine/src/irr/brent.ts
    echo ""
else
    echo "❌ Arquivo packages/engine/src/irr/brent.ts NÃO EXISTE!"
    exit 1
fi

# ============================================================================
# VERIFICAR EXPORTS
# ============================================================================
echo "🔍 Verificando exports no arquivo..."
echo ""
grep -n "^export" packages/engine/src/irr/brent.ts || echo "⚠️  Nenhum export encontrado!"
echo ""

# ============================================================================
# CRIAR TESTE SIMPLES DE IMPORT
# ============================================================================
echo "📝 Criando teste simples de import..."

cat > /tmp/test_import_brent.mjs << 'EOFTEST'
import { solveIRR, convertToAnnual } from './packages/engine/src/irr/brent.ts';

console.log('✅ Import bem-sucedido!');
console.log('solveIRR:', typeof solveIRR);
console.log('convertToAnnual:', typeof convertToAnnual);
EOFTEST

echo "✅ Teste de import criado"
echo ""

# ============================================================================
# MOSTRAR PRIMEIRAS LINHAS DO ARQUIVO
# ============================================================================
echo "📄 Primeiras 50 linhas de brent.ts:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -n 50 packages/engine/src/irr/brent.ts
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# VERIFICAR ESTRUTURA DO PROJETO
# ============================================================================
echo "📁 Estrutura do diretório irr/:"
ls -la packages/engine/src/irr/
echo ""

# ============================================================================
# ANÁLISE
# ============================================================================
echo "🔍 =========================================="
echo "🔍 ANÁLISE COMPLETA"
echo "🔍 =========================================="
echo ""
echo "Por favor, verifique a saída acima e me informe:"
echo ""
echo "1. O arquivo brent.ts está completo?"
echo "2. As funções 'export function solveIRR' e 'export function convertToAnnual' aparecem?"
echo "3. O tamanho do arquivo está correto (deveria ter ~200+ linhas)?"
echo ""
echo "Se o arquivo estiver incompleto ou vazio, vou recriá-lo do zero."
