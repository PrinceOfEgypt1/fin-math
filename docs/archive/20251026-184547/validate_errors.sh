#!/bin/bash
set -e

# ============================================================================
# VALIDAÇÃO DE ERROS TYPESCRIPT - API FINMATH
# ============================================================================
# Verifica quantos erros TypeScript existem sem modificar nada
# Uso: ./validate_errors.sh [caminho-do-projeto]
# ============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="${1:-.}"

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🔍 VALIDAÇÃO DE ERROS TYPESCRIPT           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

cd "$PROJECT_ROOT"

# Verificar se tem package.json
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json não encontrado${NC}"
    exit 1
fi

# Detectar gerenciador de pacotes
if [ -f "pnpm-lock.yaml" ]; then
    PKG="pnpm"
elif [ -f "yarn.lock" ]; then
    PKG="yarn"
else
    PKG="npm"
fi

echo -e "${BLUE}📂 Projeto: $(pwd)${NC}"
echo -e "${BLUE}📦 Gerenciador: $PKG${NC}"
echo ""

# ============================================================================
# 1. Verificar Dependências Críticas
# ============================================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}1️⃣  Dependências Críticas${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_package() {
    if $PKG list "$1" 2>/dev/null | grep -q "$1"; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 NÃO INSTALADO${NC}"
        return 1
    fi
}

MISSING_DEPS=0
check_package "@types/express" || ((MISSING_DEPS++))
check_package "@types/node" || ((MISSING_DEPS++))
check_package "express" || ((MISSING_DEPS++))
check_package "typescript" || ((MISSING_DEPS++))

echo ""

# ============================================================================
# 2. Type Check
# ============================================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}2️⃣  Type Check${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if $PKG run typecheck 2>&1 | tee /tmp/typecheck_validation.log >/dev/null; then
    echo -e "${GREEN}✅ Type check passou - 0 erros!${NC}"
    TS_ERRORS=0
else
    TS_ERRORS=$(grep -c "error TS" /tmp/typecheck_validation.log 2>/dev/null || echo "0")
    echo -e "${RED}❌ Type check falhou - $TS_ERRORS erros${NC}"
    echo ""
    echo -e "${YELLOW}Primeiros 10 erros:${NC}"
    grep "error TS" /tmp/typecheck_validation.log | head -10
fi

echo ""

# ============================================================================
# 3. Análise de Código
# ============================================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}3️⃣  Análise de Código${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -d "src" ]; then
    # Contar catch blocks sem tipo
    CATCH_WITHOUT_TYPE=$(grep -r "catch (error)" src --include="*.ts" 2>/dev/null | wc -l || echo "0")
    CATCH_WITHOUT_TYPE_ALT=$(grep -r "catch(error)" src --include="*.ts" 2>/dev/null | wc -l || echo "0")
    TOTAL_CATCH_NO_TYPE=$((CATCH_WITHOUT_TYPE + CATCH_WITHOUT_TYPE_ALT))
    
    # Contar catch blocks com tipo
    CATCH_WITH_TYPE=$(grep -r "catch (error: unknown)" src --include="*.ts" 2>/dev/null | wc -l || echo "0")
    
    # Contar imports sem tipos
    IMPORTS_NO_TYPES=$(grep -r "import express from 'express'" src --include="*.ts" 2>/dev/null | wc -l || echo "0")
    
    # Contar imports com tipos
    IMPORTS_WITH_TYPES=$(grep -r "import.*Request.*Response.*from 'express'" src --include="*.ts" 2>/dev/null | wc -l || echo "0")
    
    echo "Catch blocks sem tipo explícito: $TOTAL_CATCH_NO_TYPE"
    echo "Catch blocks com tipo (unknown): $CATCH_WITH_TYPE"
    echo "Imports Express sem tipos: $IMPORTS_NO_TYPES"
    echo "Imports Express com tipos: $IMPORTS_WITH_TYPES"
else
    echo -e "${RED}❌ Diretório src/ não encontrado${NC}"
fi

echo ""

# ============================================================================
# 4. Build Test
# ============================================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}4️⃣  Build Test${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if $PKG run build 2>&1 | tee /tmp/build_validation.log >/dev/null; then
    echo -e "${GREEN}✅ Build passou!${NC}"
    BUILD_FAILED=0
else
    echo -e "${RED}❌ Build falhou${NC}"
    BUILD_FAILED=1
fi

echo ""

# ============================================================================
# RESUMO FINAL
# ============================================================================
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              📊 RESUMO FINAL                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

TOTAL_ISSUES=$((MISSING_DEPS + TS_ERRORS + TOTAL_CATCH_NO_TYPE + IMPORTS_NO_TYPES + BUILD_FAILED))

echo "┌─────────────────────────────────────────────────┐"
printf "│ %-35s │ %6s │\n" "Métrica" "Valor"
echo "├─────────────────────────────────────────────────┤"
printf "│ %-35s │ %6d │\n" "Dependências ausentes" "$MISSING_DEPS"
printf "│ %-35s │ %6d │\n" "Erros TypeScript" "$TS_ERRORS"
printf "│ %-35s │ %6d │\n" "Catch blocks sem tipo" "$TOTAL_CATCH_NO_TYPE"
printf "│ %-35s │ %6d │\n" "Imports Express sem tipos" "$IMPORTS_NO_TYPES"
printf "│ %-35s │ %6d │\n" "Build falhou?" "$BUILD_FAILED"
echo "├─────────────────────────────────────────────────┤"
printf "│ %-35s │ %6d │\n" "TOTAL DE PROBLEMAS" "$TOTAL_ISSUES"
echo "└─────────────────────────────────────────────────┘"

echo ""

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   🎉 PERFEITO! ZERO PROBLEMAS! 🎉            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${YELLOW}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   ⚠️  $TOTAL_ISSUES PROBLEMA(S) ENCONTRADO(S)            ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📋 PRÓXIMOS PASSOS:${NC}"
    echo ""
    if [ $MISSING_DEPS -gt 0 ]; then
        echo "1. Instalar dependências:"
        echo "   ./install_dependencies.sh"
        echo ""
    fi
    if [ $TS_ERRORS -gt 0 ] || [ $TOTAL_CATCH_NO_TYPE -gt 0 ] || [ $IMPORTS_NO_TYPES -gt 0 ]; then
        echo "2. Aplicar correções:"
        echo "   ./fix_typescript_errors.sh"
        echo ""
    fi
    echo "3. Validar novamente:"
    echo "   ./validate_errors.sh"
    exit 1
fi
