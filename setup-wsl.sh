#!/usr/bin/env bash
# setup-wsl.sh - Script de configuração automática para FinMath no WSL/Ubuntu
# Autor: Claude/PrinceOfEgypt1
# Data: 2025-11-16

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Banner
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  🧮 FinMath - Setup WSL/Ubuntu            ║"
echo "║  Motor de Cálculos Financeiros            ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Verificar sistema operacional
log_info "Verificando sistema operacional..."
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    log_success "Sistema: $PRETTY_NAME"
else
    log_warn "Não foi possível detectar o sistema operacional"
fi
echo ""

# Verificar Node.js
log_info "Verificando Node.js..."
if check_command node; then
    NODE_VERSION=$(node --version)
    log_success "Node.js instalado: $NODE_VERSION"

    # Verificar se é v18+
    NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v\([0-9]*\).*/\1/')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        log_warn "Node.js $NODE_VERSION é antigo. Recomendado: v20+"
        echo "   Instale via: nvm install 22 && nvm use 22"
    fi
else
    log_error "Node.js não encontrado!"
    log_info "Para instalar Node.js via nvm:"
    echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    echo "   source ~/.bashrc"
    echo "   nvm install 22"
    echo "   nvm use 22"
    exit 1
fi
echo ""

# Verificar pnpm
log_info "Verificando pnpm..."
if check_command pnpm; then
    PNPM_VERSION=$(pnpm --version)
    log_success "pnpm instalado: $PNPM_VERSION"

    # Verificar versão exata
    if [[ "$PNPM_VERSION" != "10.19.0" ]]; then
        log_warn "pnpm $PNPM_VERSION difere da recomendada: 10.19.0"
        read -p "Deseja instalar pnpm@10.19.0? (s/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            npm install -g pnpm@10.19.0
            log_success "pnpm@10.19.0 instalado"
        fi
    fi
else
    log_warn "pnpm não encontrado. Instalando pnpm@10.19.0..."
    npm install -g pnpm@10.19.0
    log_success "pnpm@10.19.0 instalado"
fi
echo ""

# Verificar Git
log_info "Verificando Git..."
if check_command git; then
    GIT_VERSION=$(git --version)
    log_success "Git instalado: $GIT_VERSION"
else
    log_error "Git não encontrado!"
    log_info "Para instalar: sudo apt-get update && sudo apt-get install git"
    exit 1
fi
echo ""

# Verificar Python (opcional, para scripts auxiliares)
log_info "Verificando Python (opcional)..."
if check_command python3; then
    PYTHON_VERSION=$(python3 --version)
    log_success "Python instalado: $PYTHON_VERSION"
else
    log_warn "Python3 não encontrado (opcional para scripts auxiliares)"
fi
echo ""

# Verificar se já está no repositório
if [[ -f "package.json" ]] && grep -q "finmath" package.json 2>/dev/null; then
    log_info "Repositório já clonado. Pulando clone..."
    SKIP_CLONE=true
else
    SKIP_CLONE=false
fi

# Clonar repositório (se necessário)
if [[ "$SKIP_CLONE" == "false" ]]; then
    log_info "Clonando repositório do GitHub..."

    # Verificar se o diretório atual está vazio
    if [ "$(ls -A .)" ]; then
        log_error "Diretório não está vazio!"
        log_info "Execute este script em um diretório vazio ou dentro do repositório já clonado"
        exit 1
    fi

    git clone https://github.com/PrinceOfEgypt1/fin-math.git .
    log_success "Repositório clonado"
    echo ""
fi

# Verificar branch
log_info "Branch atual: $(git branch --show-current)"
LATEST_COMMIT=$(git log --oneline -1)
log_info "Último commit: $LATEST_COMMIT"
echo ""

# Instalar dependências
log_info "Instalando dependências..."
echo "   Isso pode demorar 1-2 minutos..."
pnpm install
log_success "Dependências instaladas"
echo ""

# Build do projeto
log_info "Compilando projeto..."
pnpm build
log_success "Build concluído"
echo ""

# Executar testes
log_info "Executando testes..."
if pnpm -F @finmath/engine test 2>&1 | tee /tmp/finmath-test.log; then
    log_success "Testes executados com sucesso"
else
    # Contar testes que passaram
    PASSED=$(grep -oP '\d+(?= passed)' /tmp/finmath-test.log | head -1 || echo "?")
    log_warn "Alguns testes podem ter falha (esperado: 118+ passando)"
    log_info "Testes passando: $PASSED"
fi
echo ""

# Sumário final
echo "╔════════════════════════════════════════════╗"
echo "║  ✅ Configuração Concluída!               ║"
echo "╚════════════════════════════════════════════╝"
echo ""
log_success "Ambiente configurado com sucesso!"
echo ""
echo "📚 Próximos passos:"
echo ""
echo "   1. Desenvolvimento:"
echo "      $ pnpm dev              # UI dev server"
echo "      $ pnpm dev:api          # API dev server"
echo ""
echo "   2. Testes:"
echo "      $ pnpm test             # Todos os testes"
echo "      $ pnpm test:golden      # Golden Files"
echo ""
echo "   3. Build:"
echo "      $ pnpm build            # Compilar todos os pacotes"
echo ""
echo "   4. Documentação:"
echo "      $ cat README.md         # Guia principal"
echo "      $ cat SETUP_WSL.md      # Guia de setup"
echo ""
echo "🔗 Links úteis:"
echo "   GitHub: https://github.com/PrinceOfEgypt1/fin-math"
echo "   Issues: https://github.com/PrinceOfEgypt1/fin-math/issues"
echo ""
echo "🎉 Bom desenvolvimento!"
echo ""
