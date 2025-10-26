#!/bin/bash
# ============================================================================
# Script de Diagnóstico e Execução Completa de Testes - fin-math
# ============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_section() { echo -e "${CYAN}[SECTION]${NC} $1"; }

echo "============================================================================"
echo "  Diagnóstico e Execução Completa de Testes - fin-math"
echo "============================================================================"
echo ""

# Verificar diretório
if [ ! -f "package.json" ]; then
    log_error "Não está no diretório raiz do projeto!"
    log_error "Execute: cd ~/workspace/fin-math"
    exit 1
fi

log_success "Diretório correto confirmado"
echo ""

# PASSO 1: Analisar estrutura do projeto
log_section "PASSO 1: Analisando estrutura do projeto..."
echo ""

log_info "Pacotes encontrados no workspace:"
if [ -d "packages/engine" ]; then
    echo "  ✓ packages/engine (cálculos financeiros)"
fi
if [ -d "packages/api" ]; then
    echo "  ✓ packages/api (backend/API)"
fi
if [ -d "packages/ui" ]; then
    echo "  ✓ packages/ui (frontend/interface)"
fi
echo ""

# PASSO 2: Verificar scripts disponíveis
log_section "PASSO 2: Scripts de teste disponíveis..."
echo ""

log_info "Scripts no package.json raiz:"
cat package.json | grep -A 5 '"scripts"' | grep '"test' || echo "  (nenhum script de teste encontrado)"
echo ""

# PASSO 3: Verificar scripts em cada pacote
log_section "PASSO 3: Scripts de teste em cada pacote..."
echo ""

for pkg in packages/*/package.json; do
    if [ -f "$pkg" ]; then
        pkg_name=$(dirname "$pkg")
        log_info "Scripts em $pkg_name:"
        cat "$pkg" | grep -A 5 '"scripts"' | grep '"test' || echo "  (nenhum script de teste encontrado)"
        echo ""
    fi
done

# PASSO 4: Contar arquivos de teste
log_section "PASSO 4: Contando arquivos de teste..."
echo ""

total_test_files=0

if [ -d "packages/engine/test" ]; then
    engine_tests=$(find packages/engine/test -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | wc -l)
    log_info "packages/engine/test: $engine_tests arquivo(s) de teste"
    total_test_files=$((total_test_files + engine_tests))
fi

if [ -d "packages/api/test" ]; then
    api_tests=$(find packages/api/test -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | wc -l)
    log_info "packages/api/test: $api_tests arquivo(s) de teste"
    total_test_files=$((total_test_files + api_tests))
fi

if [ -d "packages/ui/test" ]; then
    ui_tests=$(find packages/ui/test -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" 2>/dev/null | wc -l)
    log_info "packages/ui/test: $ui_tests arquivo(s) de teste"
    total_test_files=$((total_test_files + ui_tests))
fi

echo ""
log_success "Total de arquivos de teste: $total_test_files"
echo ""

# PASSO 5: Mostrar comandos disponíveis
log_section "PASSO 5: Comandos para executar testes..."
echo ""

log_info "Comandos disponíveis para testar:"
echo ""
echo "  1. Testar TUDO (recomendado):"
echo "     ${GREEN}pnpm -r test${NC}"
echo "     ${GREEN}pnpm --recursive test${NC}"
echo ""
echo "  2. Testar pacote específico:"
echo "     ${GREEN}pnpm --filter @finmath/engine test${NC}"
echo "     ${GREEN}pnpm --filter @finmath/api test${NC}"
echo "     ${GREEN}pnpm --filter @finmath/ui test${NC}"
echo ""
echo "  3. Testar com coverage:"
echo "     ${GREEN}pnpm -r test:coverage${NC}"
echo ""
echo "  4. Testar em modo watch:"
echo "     ${GREEN}pnpm -r test:watch${NC}"
echo ""

# PASSO 6: Perguntar se quer executar todos os testes
log_section "PASSO 6: Executar testes agora?"
echo ""

read -p "Deseja executar TODOS os testes agora? (s/n): " executar
executar_lower=$(echo "$executar" | tr '[:upper:]' '[:lower:]')

if [[ "$executar_lower" != "s" && "$executar_lower" != "sim" && "$executar_lower" != "y" && "$executar_lower" != "yes" ]]; then
    log_warning "Execução de testes cancelada pelo usuário."
    echo ""
    log_info "Para executar manualmente depois, use:"
    echo "  ${GREEN}pnpm -r test${NC}"
    exit 0
fi

echo ""
echo "============================================================================"
echo "  Executando TODOS os testes..."
echo "============================================================================"
echo ""

# PASSO 7: Executar testes em cada pacote com detalhes
log_section "Executando testes em cada pacote..."
echo ""

total_pass=0
total_fail=0

# Testar engine
if [ -d "packages/engine" ]; then
    log_info "Testando packages/engine..."
    echo "--------------------------------------------------------------------------"
    cd packages/engine
    if pnpm test 2>&1 | tee /tmp/engine-test.log; then
        engine_results=$(cat /tmp/engine-test.log | tail -20)
        log_success "Testes do engine concluídos"
    else
        log_error "Testes do engine falharam"
    fi
    cd ../..
    echo ""
fi

# Testar API
if [ -d "packages/api" ]; then
    log_info "Testando packages/api..."
    echo "--------------------------------------------------------------------------"
    cd packages/api
    if pnpm test 2>&1 | tee /tmp/api-test.log; then
        api_results=$(cat /tmp/api-test.log | tail -20)
        log_success "Testes da API concluídos"
    else
        log_error "Testes da API falharam"
    fi
    cd ../..
    echo ""
fi

# Testar UI
if [ -d "packages/ui" ]; then
    log_info "Testando packages/ui..."
    echo "--------------------------------------------------------------------------"
    cd packages/ui
    if pnpm test 2>&1 | tee /tmp/ui-test.log; then
        ui_results=$(cat /tmp/ui-test.log | tail -20)
        log_success "Testes da UI concluídos"
    else
        log_error "Testes da UI falharam"
    fi
    cd ../..
    echo ""
fi

# PASSO 8: Executar teste recursivo completo
log_section "Executando comando recursivo global..."
echo "--------------------------------------------------------------------------"
echo ""

pnpm -r test

echo ""
echo "============================================================================"
echo "  ✅ Execução de testes concluída!"
echo "============================================================================"
echo ""

log_info "Para ver relatório detalhado de um pacote específico:"
echo "  ${GREEN}cat /tmp/engine-test.log${NC}"
echo "  ${GREEN}cat /tmp/api-test.log${NC}"
echo "  ${GREEN}cat /tmp/ui-test.log${NC}"
echo ""

log_info "Para executar novamente:"
echo "  ${GREEN}pnpm -r test${NC}                  # Todos os pacotes"
echo "  ${GREEN}pnpm --filter @finmath/engine test${NC}  # Só engine"
echo ""

log_success "Script concluído!"
