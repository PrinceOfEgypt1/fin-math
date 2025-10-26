#!/bin/bash
set -e

# ============================================================================
# INSTALAÇÃO DE DEPENDÊNCIAS - API FINMATH
# ============================================================================
# Instala @types/express e @types/node
# Uso: ./install_dependencies.sh [caminho-do-projeto]
# ============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ROOT="${1:-.}"

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     📦 INSTALAÇÃO DE DEPENDÊNCIAS            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

cd "$PROJECT_ROOT"
echo -e "${GREEN}✅ Diretório: $(pwd)${NC}"
echo ""

# Detectar gerenciador de pacotes
if [ -f "pnpm-lock.yaml" ]; then
    PKG="pnpm"
elif [ -f "yarn.lock" ]; then
    PKG="yarn"
else
    PKG="npm"
fi

echo -e "${BLUE}📦 Gerenciador: $PKG${NC}"
echo ""

# Instalar dependências críticas
echo -e "${YELLOW}Instalando @types/express...${NC}"
$PKG add -D @types/express@^4.17.21

echo -e "${YELLOW}Instalando @types/node...${NC}"
$PKG add -D @types/node@^20.10.0

# Verificar se cors está instalado
if grep -q '"cors"' package.json; then
    echo -e "${YELLOW}Instalando @types/cors...${NC}"
    $PKG add -D @types/cors@^2.8.17
fi

echo ""
echo -e "${GREEN}✅ Dependências instaladas com sucesso!${NC}"
echo ""

# Verificar instalação
echo -e "${BLUE}Verificando instalação...${NC}"
$PKG list @types/express 2>/dev/null | grep "@types/express" || echo "❌ @types/express não encontrado"
$PKG list @types/node 2>/dev/null | grep "@types/node" || echo "❌ @types/node não encontrado"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Instalação concluída!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
