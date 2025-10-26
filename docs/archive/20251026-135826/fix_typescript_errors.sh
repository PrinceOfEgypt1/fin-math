#!/bin/bash
set -e

# ============================================================================
# SCRIPT DE CORREÇÃO DE ERROS TYPESCRIPT - API FINMATH
# ============================================================================
# Aplica todas as 16 correções de tipo 'unknown' automaticamente
# Uso: ./fix_typescript_errors.sh [caminho-do-projeto]
# ============================================================================

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuração
PROJECT_ROOT="${1:-./packages/api}"
BACKUP_DIR=".backup_$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔧 CORREÇÃO DE ERROS TYPESCRIPT - FINMATH    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# FASE 1: VALIDAÇÃO
# ============================================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}FASE 1: Validação${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ! -d "$PROJECT_ROOT" ]; then
    echo -e "${RED}❌ Erro: Diretório $PROJECT_ROOT não encontrado${NC}"
    echo "Uso: $0 [caminho-do-projeto]"
    echo "Exemplo: $0 ~/workspace/fin-math/packages/api"
    exit 1
fi

cd "$PROJECT_ROOT"
echo -e "${GREEN}✅ Diretório encontrado: $(pwd)${NC}"

# Verificar se é um projeto Node.js
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Erro: package.json não encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ package.json encontrado${NC}"

# ============================================================================
# FASE 2: BACKUP
# ============================================================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}FASE 2: Backup${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

mkdir -p "$BACKUP_DIR"
echo -e "${BLUE}📦 Criando backup em: $BACKUP_DIR${NC}"

# Fazer backup dos arquivos que serão modificados
if [ -d "src" ]; then
    cp -r src "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Backup de src/ criado${NC}"
fi

if [ -f "package.json" ]; then
    cp package.json "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Backup de package.json criado${NC}"
fi

# ============================================================================
# FASE 3: INSTALAR DEPENDÊNCIAS
# ============================================================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}FASE 3: Instalando Dependências${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Detectar gerenciador de pacotes
if [ -f "pnpm-lock.yaml" ]; then
    PKG_MANAGER="pnpm"
elif [ -f "yarn.lock" ]; then
    PKG_MANAGER="yarn"
else
    PKG_MANAGER="npm"
fi

echo -e "${BLUE}📦 Usando: $PKG_MANAGER${NC}"

# Instalar @types/express
echo -e "${BLUE}Installing @types/express...${NC}"
$PKG_MANAGER add -D @types/express@^4.17.21
echo -e "${GREEN}✅ @types/express instalado${NC}"

# Instalar @types/node
echo -e "${BLUE}Installing @types/node...${NC}"
$PKG_MANAGER add -D @types/node@^20.10.0
echo -e "${GREEN}✅ @types/node instalado${NC}"

# Instalar @types/cors se necessário
if grep -q "cors" package.json; then
    echo -e "${BLUE}Installing @types/cors...${NC}"
    $PKG_MANAGER add -D @types/cors@^2.8.17
    echo -e "${GREEN}✅ @types/cors instalado${NC}"
fi

# ============================================================================
# FASE 4: APLICAR CORREÇÕES TYPESCRIPT
# ============================================================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}FASE 4: Aplicando Correções TypeScript${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CORRECTIONS=0

# Função para aplicar correção em um arquivo
apply_corrections() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        return
    fi
    
    echo -e "${BLUE}🔧 Processando: $file${NC}"
    
    # Correção 1: catch (error) → catch (error: unknown)
    if grep -q "catch (error)" "$file" 2>/dev/null; then
        sed -i.bak 's/catch (error)/catch (error: unknown)/g' "$file"
        echo "  ✓ Adicionado tipo 'unknown' em catch blocks"
        ((CORRECTIONS++))
    fi
    
    # Correção 2: catch(error) → catch (error: unknown) (sem espaço)
    if grep -q "catch(error)" "$file" 2>/dev/null; then
        sed -i.bak 's/catch(error)/catch (error: unknown)/g' "$file"
        echo "  ✓ Adicionado tipo 'unknown' em catch blocks (sem espaço)"
        ((CORRECTIONS++))
    fi
    
    # Correção 3: Imports de Express sem tipos
    if grep -q "import express from 'express'" "$file" 2>/dev/null; then
        # Não fazer substituição automática - muito arriscado
        echo "  ⚠️  ATENÇÃO: Encontrado import sem tipos. Revisar manualmente:"
        echo "     import express from 'express'  → import { Request, Response } from 'express'"
    fi
    
    # Remover arquivo de backup .bak
    rm -f "${file}.bak"
}

# Processar todos os arquivos TypeScript
if [ -d "src" ]; then
    echo -e "${BLUE}Processando arquivos em src/...${NC}"
    
    # Controllers
    for file in src/controllers/*.ts; do
        apply_corrections "$file"
    done
    
    # Services
    for file in src/services/*.ts; do
        apply_corrections "$file"
    done
    
    # Routes
    for file in src/routes/*.ts; do
        apply_corrections "$file"
    done
    
    # Server
    if [ -f "src/server.ts" ]; then
        apply_corrections "src/server.ts"
    fi
    
    # Qualquer outro .ts
    find src -name "*.ts" -type f | while read -r file; do
        apply_corrections "$file"
    done
fi

echo -e "${GREEN}✅ $CORRECTIONS correções aplicadas${NC}"

# ============================================================================
# FASE 5: CRIAR HELPER PARA TYPE GUARDS
# ============================================================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}FASE 5: Criando Utilitários${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Criar diretório de utils se não existir
mkdir -p src/utils

# Criar arquivo de error handling utilities
cat > src/utils/error-handler.ts << 'EOF'
/**
 * Utilitários para tratamento de erros com type safety
 */

/**
 * Extrai mensagem de erro com type guard
 */
export function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  
  if (typeof error === 'string') {
    return error;
  }
  
  return 'Erro desconhecido';
}

/**
 * Verifica se é um erro com código
 */
export function hasErrorCode(error: unknown): error is { code: string } {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    typeof (error as { code: unknown }).code === 'string'
  );
}

/**
 * Formata resposta de erro padronizada
 */
export function formatErrorResponse(error: unknown, defaultCode = 'INTERNAL_ERROR') {
  const message = getErrorMessage(error);
  const code = hasErrorCode(error) ? error.code : defaultCode;
  
  return {
    error: {
      code,
      message
    }
  };
}
EOF

echo -e "${GREEN}✅ Criado: src/utils/error-handler.ts${NC}"

# ============================================================================
# FASE 6: VALIDAÇÃO
# ============================================================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}FASE 6: Validação${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Type check
echo -e "${BLUE}Executando type check...${NC}"
if $PKG_MANAGER run typecheck 2>&1 | tee /tmp/typecheck.log; then
    echo -e "${GREEN}✅ Type check passou!${NC}"
else
    echo -e "${YELLOW}⚠️  Type check com erros. Verifique:${NC}"
    grep "error TS" /tmp/typecheck.log | head -10
fi

# Contar erros restantes
ERROR_COUNT=$(grep -c "error TS" /tmp/typecheck.log 2>/dev/null || echo "0")
echo ""
echo -e "${BLUE}📊 Erros TypeScript restantes: $ERROR_COUNT${NC}"

# ============================================================================
# FASE 7: INSTRUÇÕES FINAIS
# ============================================================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}FASE 7: Próximos Passos${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
echo -e "${GREEN}✅ Correções automáticas aplicadas: $CORRECTIONS${NC}"
echo ""
echo -e "${BLUE}📋 AÇÕES MANUAIS NECESSÁRIAS:${NC}"
echo ""
echo "1️⃣  Revisar imports de Express nos arquivos:"
echo "    ❌ REMOVER: import express from 'express'"
echo "    ✅ ADICIONAR: import { Request, Response, NextFunction } from 'express'"
echo ""
echo "2️⃣  Em cada catch block, substituir:"
echo "    ❌ res.json({ error: error.message })"
echo "    ✅ res.json({ error: { code: 'ERROR_CODE', message: getErrorMessage(error) } })"
echo ""
echo "3️⃣  Importar o helper criado:"
echo "    import { getErrorMessage, formatErrorResponse } from '@/utils/error-handler'"
echo ""
echo "4️⃣  Testar a compilação:"
echo "    $PKG_MANAGER run typecheck"
echo "    $PKG_MANAGER run build"
echo ""
echo -e "${BLUE}📦 Backup criado em: $BACKUP_DIR${NC}"
echo -e "${BLUE}Para restaurar: cp -r $BACKUP_DIR/src/* src/${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Script concluído!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
