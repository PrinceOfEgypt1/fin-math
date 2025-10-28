#!/bin/bash
################################################################################
# SPRINT 4 - ACESSIBILIDADE & E2E
# História: H24 - Acessibilidade WCAG AA & E2E Tests
# Autor: FinMath Team
# Data: 2025-10-27
# Versão: 1.0.0
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "════════════════════════════════════════════════════════════════════════════"
echo "🚀 INICIANDO SPRINT 4 - ACESSIBILIDADE & E2E"
echo "════════════════════════════════════════════════════════════════════════════"

# ============================================================================
# REGRA #1: GITHUB COMO FONTE DA VERDADE
# Sincronização obrigatória no início da sprint
# ============================================================================
echo ""
echo -e "${BLUE}🔄 FASE 1: Sincronizando com GitHub...${NC}"

# Verificar se estamos em um repositório Git
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Erro: Não está em um repositório Git${NC}"
    echo "Execute este script na raiz do projeto FinMath"
    exit 1
fi

# Fetch e pull
echo "Fetching do origin..."
git fetch origin || {
    echo -e "${YELLOW}⚠️  Aviso: Falha ao fazer fetch (pode ser repositório local)${NC}"
}

echo "Pulling da branch main..."
git pull origin main --rebase || {
    echo -e "${YELLOW}⚠️  Aviso: Falha ao fazer pull (pode ser repositório local)${NC}"
}

# Criar branch da sprint 4
SPRINT_BRANCH="sprint-4"
echo ""
echo -e "${BLUE}📝 Criando branch: ${SPRINT_BRANCH}${NC}"

if git show-ref --verify --quiet "refs/heads/${SPRINT_BRANCH}"; then
    echo -e "${YELLOW}⚠️  Branch ${SPRINT_BRANCH} já existe. Usando a existente.${NC}"
    git checkout "${SPRINT_BRANCH}"
else
    git checkout -b "${SPRINT_BRANCH}"
    echo -e "${GREEN}✅ Branch ${SPRINT_BRANCH} criada com sucesso${NC}"
fi

# ============================================================================
# REGRA #3: BACKUP EXCLUSIVO VIA GIT (LOCAL)
# Limpar backups físicos proibidos
# ============================================================================
echo ""
echo -e "${BLUE}🧹 FASE 2: Limpando backups físicos (OBRIGATÓRIO)...${NC}"

# Buscar e deletar arquivos .bak, .backup, .save
BACKUP_FILES=$(find . -type f \( -name "*bak*" -o -name "*backup*" -o -name "*.save" \) 2>/dev/null | wc -l)

if [ "$BACKUP_FILES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Encontrados ${BACKUP_FILES} arquivos de backup físico${NC}"
    find . -type f \( -name "*bak*" -o -name "*backup*" -o -name "*.save" \) -delete
    echo -e "${GREEN}✅ Arquivos de backup removidos${NC}"
else
    echo -e "${GREEN}✅ Nenhum arquivo de backup físico encontrado${NC}"
fi

# ============================================================================
# FASE 3: Verificar ambiente e dependências
# ============================================================================
echo ""
echo -e "${BLUE}🔍 FASE 3: Verificando ambiente...${NC}"

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js não encontrado. Instale antes de continuar.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"

# Verificar pnpm
if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}❌ pnpm não encontrado. Instale antes de continuar.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ pnpm: $(pnpm --version)${NC}"

# Verificar TypeScript
if ! command -v tsc &> /dev/null; then
    echo -e "${YELLOW}⚠️  TypeScript não encontrado globalmente, mas pode estar em node_modules${NC}"
fi

# ============================================================================
# FASE 4: Instalar dependências da Sprint 4
# ============================================================================
echo ""
echo -e "${BLUE}📦 FASE 4: Instalando dependências da Sprint 4...${NC}"

# Dependências para E2E (Playwright)
echo "Instalando Playwright e dependências de teste..."
pnpm add -D @playwright/test@latest

# Dependências para Acessibilidade (axe-core)
echo "Instalando axe-core para auditoria A11y..."
pnpm add -D axe-core @axe-core/playwright axe-playwright

# Dependências adicionais para testes
echo "Instalando dependências de testes adicionais..."
pnpm add -D @testing-library/react @testing-library/jest-dom @testing-library/user-event
pnpm add -D vitest @vitest/ui jsdom
pnpm add -D eslint-plugin-jsx-a11y

# Instalar browsers do Playwright
echo "Instalando browsers do Playwright..."
npx playwright install chromium firefox webkit

echo -e "${GREEN}✅ Dependências instaladas com sucesso${NC}"

# ============================================================================
# FASE 5: Criar estrutura de diretórios
# ============================================================================
echo ""
echo -e "${BLUE}📁 FASE 5: Criando estrutura de diretórios...${NC}"

# Criar diretórios de teste
mkdir -p tests/e2e
mkdir -p tests/a11y
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/fixtures
mkdir -p tests/utils
mkdir -p docs/a11y
mkdir -p .github/workflows

echo -e "${GREEN}✅ Estrutura de diretórios criada${NC}"

# ============================================================================
# FASE 6: Verificar estrutura atual do projeto
# ============================================================================
echo ""
echo -e "${BLUE}📊 FASE 6: Analisando estrutura atual...${NC}"

echo "Componentes encontrados:"
find . -name "*.tsx" -not -path "./node_modules/*" -not -path "./.git/*" | head -10

echo ""
echo "Arquivos de configuração:"
ls -la *.json *.config.* 2>/dev/null || echo "Nenhum arquivo de configuração na raiz"

# ============================================================================
# RESUMO DO SETUP
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ SETUP DA SPRINT 4 CONCLUÍDO COM SUCESSO!${NC}"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo ""
echo "1. Execute: ./sprint4_part1_a11y.sh"
echo "   → Implementa melhorias de acessibilidade (Design System A11y, tokens, etc)"
echo ""
echo "2. Execute: ./sprint4_part2_e2e.sh"
echo "   → Configura Playwright e cria testes E2E"
echo ""
echo "3. Execute: ./sprint4_part3_integration.sh"
echo "   → Integra testes no CI/CD e gera relatórios"
echo ""
echo "4. Execute: ./sprint4_finalizacao.sh"
echo "   → Validação anti-regressão e finalização da sprint"
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}💡 LEMBRETE DAS REGRAS CRÍTICAS:${NC}"
echo "   ✓ Commits locais frequentes (git add . && git commit)"
echo "   ✓ Nenhum arquivo .bak ou .backup"
echo "   ✓ Documentação durante implementação"
echo "   ✓ Push final apenas ao término da sprint com validação completa"
echo ""
echo "📚 Documentação de referência:"
echo "   → Guia de Excelência de UI/UX (v1.0)"
echo "   → Plano de Execução UI/UX (v1.0)"
echo "   → Regras Críticas FinMath (v2.0)"
echo "   → Catálogo 24 HUs"
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
