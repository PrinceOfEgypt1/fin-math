#!/bin/bash
# verificar-pre-requisitos.sh
# Verifica TODOS os pré-requisitos antes de iniciar implementação

set -e

echo "🔍 VERIFICAÇÃO DE PRÉ-REQUISITOS - H21 + H22"
echo "=============================================="
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Contadores
PASSED=0
FAILED=0
WARNINGS=0

pass() {
    echo -e "${GREEN}✅${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}❌${NC} $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠️${NC}  $1"
    ((WARNINGS++))
}

# ========================================
# 1. SISTEMA OPERACIONAL
# ========================================
echo -e "${BLUE}📋 1. Sistema Operacional${NC}"
echo ""

OS=$(uname -s)
case "$OS" in
    Linux*)     pass "Sistema: Linux" ;;
    Darwin*)    pass "Sistema: macOS" ;;
    MINGW*)     warn "Sistema: Windows (GitBash)" ;;
    *)          fail "Sistema: Desconhecido ($OS)" ;;
esac
echo ""

# ========================================
# 2. NODE.JS
# ========================================
echo -e "${BLUE}📋 2. Node.js${NC}"
echo ""

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        pass "Node.js: v$(node --version | cut -d'v' -f2) (>= 18 ✓)"
    else
        fail "Node.js: v$(node --version | cut -d'v' -f2) (< 18 ✗)"
        echo "   Atualizar para Node.js 18+: https://nodejs.org"
    fi
else
    fail "Node.js: Não instalado"
    echo "   Instalar: https://nodejs.org"
fi
echo ""

# ========================================
# 3. PNPM
# ========================================
echo -e "${BLUE}📋 3. pnpm${NC}"
echo ""

if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm --version)
    pass "pnpm: v$PNPM_VERSION"
else
    fail "pnpm: Não instalado"
    echo "   Instalar: npm install -g pnpm"
fi
echo ""

# ========================================
# 4. GIT
# ========================================
echo -e "${BLUE}📋 4. Git${NC}"
echo ""

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    pass "Git: v$GIT_VERSION"
    
    # Verificar configuração básica
    if git config user.name > /dev/null && git config user.email > /dev/null; then
        pass "Git config: Nome e email configurados"
    else
        warn "Git config: Falta configurar nome/email"
        echo "   git config --global user.name \"Seu Nome\""
        echo "   git config --global user.email \"email@example.com\""
    fi
else
    fail "Git: Não instalado"
    echo "   Instalar: https://git-scm.com"
fi
echo ""

# ========================================
# 5. ESTRUTURA DO PROJETO
# ========================================
echo -e "${BLUE}📋 5. Estrutura do Projeto${NC}"
echo ""

if [ -d "packages" ]; then
    pass "Diretório: packages/"
else
    fail "Diretório: packages/ não encontrado"
    echo "   Execute na raiz do projeto finmath"
fi

if [ -d "packages/engine" ]; then
    pass "Diretório: packages/engine/"
else
    fail "Diretório: packages/engine/ não encontrado"
fi

if [ -d "packages/api" ]; then
    pass "Diretório: packages/api/"
else
    fail "Diretório: packages/api/ não encontrado"
fi

if [ -f "package.json" ]; then
    pass "Arquivo: package.json (raiz)"
else
    fail "Arquivo: package.json não encontrado na raiz"
fi

if [ -f "pnpm-workspace.yaml" ]; then
    pass "Arquivo: pnpm-workspace.yaml"
else
    warn "Arquivo: pnpm-workspace.yaml não encontrado"
fi
echo ""

# ========================================
# 6. DEPENDÊNCIAS INSTALADAS
# ========================================
echo -e "${BLUE}📋 6. Dependências${NC}"
echo ""

if [ -d "node_modules" ]; then
    pass "node_modules/ instalado"
else
    fail "node_modules/ não encontrado"
    echo "   Execute: pnpm install"
fi

if [ -d "packages/engine/node_modules" ]; then
    pass "Dependências engine instaladas"
else
    warn "Dependências engine não instaladas"
fi

if [ -d "packages/api/node_modules" ]; then
    pass "Dependências API instaladas"
else
    warn "Dependências API não instaladas"
fi
echo ""

# ========================================
# 7. BRANCH CORRETA
# ========================================
echo -e "${BLUE}📋 7. Git Branch${NC}"
echo ""

if git rev-parse --git-dir > /dev/null 2>&1; then
    CURRENT_BRANCH=$(git branch --show-current)
    
    if [ "$CURRENT_BRANCH" == "sprint-2" ]; then
        pass "Branch: sprint-2 ✓"
    elif [ "$CURRENT_BRANCH" == "main" ] || [ "$CURRENT_BRANCH" == "master" ]; then
        warn "Branch: $CURRENT_BRANCH (deveria ser sprint-2)"
        echo "   Criar branch: git checkout -b sprint-2"
    else
        warn "Branch: $CURRENT_BRANCH (esperado: sprint-2)"
    fi
    
    # Verificar status
    UNCOMMITTED=$(git status --porcelain | wc -l)
    if [ "$UNCOMMITTED" -eq 0 ]; then
        pass "Working tree: limpo"
    else
        warn "Working tree: $UNCOMMITTED arquivo(s) modificado(s)"
    fi
else
    fail "Não é um repositório Git"
fi
echo ""

# ========================================
# 8. FERRAMENTAS OPCIONAIS
# ========================================
echo -e "${BLUE}📋 8. Ferramentas Opcionais${NC}"
echo ""

if command -v curl &> /dev/null; then
    pass "curl: Instalado (para testes)"
else
    warn "curl: Não instalado (recomendado para testes)"
fi

if command -v jq &> /dev/null; then
    pass "jq: Instalado (para parsing JSON)"
else
    warn "jq: Não instalado (recomendado para testes)"
    echo "   Instalar: apt-get install jq (Linux) ou brew install jq (macOS)"
fi
echo ""

# ========================================
# 9. ESPAÇO EM DISCO
# ========================================
echo -e "${BLUE}📋 9. Espaço em Disco${NC}"
echo ""

if command -v df &> /dev/null; then
    AVAILABLE_MB=$(df . | tail -1 | awk '{print int($4/1024)}')
    if [ "$AVAILABLE_MB" -gt 500 ]; then
        pass "Espaço livre: ${AVAILABLE_MB}MB (>500MB ✓)"
    elif [ "$AVAILABLE_MB" -gt 100 ]; then
        warn "Espaço livre: ${AVAILABLE_MB}MB (baixo)"
    else
        fail "Espaço livre: ${AVAILABLE_MB}MB (insuficiente)"
    fi
else
    warn "Não foi possível verificar espaço em disco"
fi
echo ""

# ========================================
# 10. PORTAS DISPONÍVEIS
# ========================================
echo -e "${BLUE}📋 10. Portas Disponíveis${NC}"
echo ""

check_port() {
    local PORT=$1
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

if check_port 3001; then
    pass "Porta 3001: Disponível (API)"
else
    warn "Porta 3001: Em uso (pode causar conflito)"
    echo "   Parar processo: lsof -ti:3001 | xargs kill -9"
fi
echo ""

# ========================================
# 11. ARQUIVOS CONFLITANTES
# ========================================
echo -e "${BLUE}📋 11. Arquivos Conflitantes${NC}"
echo ""

BAK_COUNT=$(find packages -name "*.bak" -o -name "*.backup" -o -name "*.save" 2>/dev/null | wc -l)
if [ "$BAK_COUNT" -eq 0 ]; then
    pass "Backups físicos: Nenhum encontrado"
else
    warn "Backups físicos: $BAK_COUNT arquivo(s)"
    echo "   Remover: find . \\( -name '*.bak' -o -name '*.backup' \\) -delete"
fi
echo ""

# ========================================
# 12. TYPESCRIPT
# ========================================
echo -e "${BLUE}📋 12. TypeScript${NC}"
echo ""

if [ -f "packages/api/tsconfig.json" ]; then
    pass "TypeScript config: packages/api/tsconfig.json"
else
    fail "TypeScript config: Não encontrado"
fi

if command -v tsc &> /dev/null; then
    TSC_VERSION=$(tsc --version | awk '{print $2}')
    pass "TypeScript compiler: v$TSC_VERSION"
else
    warn "TypeScript compiler: Não encontrado globalmente (OK se local)"
fi
echo ""

# ========================================
# RESUMO FINAL
# ========================================
echo "=============================================="
echo -e "${BLUE}📊 RESUMO DA VERIFICAÇÃO${NC}"
echo "=============================================="
echo ""
echo -e "${GREEN}Passou: $PASSED${NC}"
echo -e "${YELLOW}Avisos: $WARNINGS${NC}"
echo -e "${RED}Falhou: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}🎉 TODOS OS PRÉ-REQUISITOS ATENDIDOS!${NC}"
        echo ""
        echo "✅ Pronto para implementar H21 + H22"
        echo ""
        echo "Próximos passos:"
        echo "  1. chmod +x implementar-h21-h22.sh"
        echo "  2. ./implementar-h21-h22.sh"
        echo ""
        exit 0
    else
        echo -e "${YELLOW}⚠️  PRÉ-REQUISITOS ATENDIDOS COM AVISOS${NC}"
        echo ""
        echo "Você pode prosseguir, mas recomenda-se resolver os avisos:"
        for i in $(seq 1 $WARNINGS); do
            echo "  - Revisar avisos acima"
        done
        echo ""
        read -p "Deseja prosseguir mesmo assim? (s/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            echo "Prosseguindo..."
            exit 0
        else
            echo "Abortado. Resolva os avisos e execute novamente."
            exit 1
        fi
    fi
else
    echo -e "${RED}❌ PRÉ-REQUISITOS NÃO ATENDIDOS${NC}"
    echo ""
    echo "Corrija os problemas acima antes de prosseguir:"
    echo ""
    
    if ! command -v node &> /dev/null; then
        echo "  1. Instalar Node.js 18+: https://nodejs.org"
    fi
    
    if ! command -v pnpm &> /dev/null; then
        echo "  2. Instalar pnpm: npm install -g pnpm"
    fi
    
    if [ ! -d "packages" ]; then
        echo "  3. Navegar para raiz do projeto: cd ~/workspace/fin-math"
    fi
    
    if [ ! -d "node_modules" ]; then
        echo "  4. Instalar dependências: pnpm install"
    fi
    
    echo ""
    echo "Após corrigir, execute novamente:"
    echo "  ./verificar-pre-requisitos.sh"
    echo ""
    exit 1
fi
