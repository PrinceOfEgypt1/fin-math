#!/bin/bash
set -e

# ============================================================================
# CORREÇÃO INTERATIVA DE ARQUIVO - API FINMATH
# ============================================================================
# Corrige um arquivo TypeScript específico com confirmação
# Uso: ./fix_single_file.sh <arquivo.ts>
# ============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FILE="$1"

if [ -z "$FILE" ]; then
    echo -e "${RED}❌ Uso: $0 <arquivo.ts>${NC}"
    echo "Exemplo: $0 src/controllers/price.controller.ts"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo -e "${RED}❌ Arquivo não encontrado: $FILE${NC}"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🔧 CORREÇÃO INTERATIVA DE ARQUIVO         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📄 Arquivo: $FILE${NC}"
echo ""

# Fazer backup
BACKUP="${FILE}.backup_$(date +%Y%m%d_%H%M%S)"
cp "$FILE" "$BACKUP"
echo -e "${GREEN}✅ Backup criado: $BACKUP${NC}"
echo ""

# ============================================================================
# Análise do arquivo
# ============================================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📊 Análise${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CATCH_NO_TYPE=$(grep -n "catch (error)" "$FILE" | wc -l)
CATCH_NO_TYPE_ALT=$(grep -n "catch(error)" "$FILE" | wc -l)
ERROR_MESSAGE=$(grep -n "error.message" "$FILE" | wc -l)
IMPORT_EXPRESS=$(grep -n "import express from 'express'" "$FILE" | wc -l)

echo "Catch blocks sem tipo: $((CATCH_NO_TYPE + CATCH_NO_TYPE_ALT))"
echo "Usos de error.message: $ERROR_MESSAGE"
echo "Imports sem tipos: $IMPORT_EXPRESS"
echo ""

# ============================================================================
# Correção 1: catch (error) → catch (error: unknown)
# ============================================================================
if [ $((CATCH_NO_TYPE + CATCH_NO_TYPE_ALT)) -gt 0 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}1️⃣  Correção: catch (error) → catch (error: unknown)${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo "Linhas afetadas:"
    grep -n "catch (error)" "$FILE" || true
    grep -n "catch(error)" "$FILE" || true
    echo ""
    
    read -p "Aplicar esta correção? (s/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        sed -i.tmp 's/catch (error)/catch (error: unknown)/g' "$FILE"
        sed -i.tmp 's/catch(error)/catch (error: unknown)/g' "$FILE"
        rm -f "${FILE}.tmp"
        echo -e "${GREEN}✅ Correção aplicada${NC}"
    else
        echo -e "${YELLOW}⏭️  Pulado${NC}"
    fi
    echo ""
fi

# ============================================================================
# Correção 2: Adicionar helper de error
# ============================================================================
if [ $ERROR_MESSAGE -gt 0 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}2️⃣  Adicionar import do error helper${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo "O arquivo usa error.message em $ERROR_MESSAGE lugar(es)."
    echo "Recomendado adicionar:"
    echo ""
    echo -e "${BLUE}import { getErrorMessage } from '@/utils/error-handler';${NC}"
    echo ""
    
    read -p "Adicionar import? (s/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        # Adicionar import após o último import
        LAST_IMPORT=$(grep -n "^import" "$FILE" | tail -1 | cut -d: -f1)
        if [ -n "$LAST_IMPORT" ]; then
            sed -i.tmp "${LAST_IMPORT}a\\
import { getErrorMessage } from '@/utils/error-handler';
" "$FILE"
            rm -f "${FILE}.tmp"
            echo -e "${GREEN}✅ Import adicionado${NC}"
        else
            echo -e "${RED}❌ Não foi possível encontrar linha de import${NC}"
        fi
    else
        echo -e "${YELLOW}⏭️  Pulado${NC}"
    fi
    echo ""
    
    echo -e "${YELLOW}⚠️  ATENÇÃO MANUAL NECESSÁRIA:${NC}"
    echo "Você ainda precisa substituir:"
    echo -e "${RED}  error.message${NC}"
    echo "Por:"
    echo -e "${GREEN}  getErrorMessage(error)${NC}"
    echo ""
fi

# ============================================================================
# Correção 3: Import de Express
# ============================================================================
if [ $IMPORT_EXPRESS -gt 0 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}3️⃣  Correção: Import de Express${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    grep -n "import express from 'express'" "$FILE"
    echo ""
    echo "Esta linha precisa ser corrigida manualmente para:"
    echo -e "${GREEN}import { Request, Response } from 'express';${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Correção automática muito arriscada - faça manualmente!${NC}"
    echo ""
fi

# ============================================================================
# Resultado
# ============================================================================
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              ✅ CONCLUÍDO                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Arquivo processado: $FILE${NC}"
echo -e "${GREEN}✅ Backup em: $BACKUP${NC}"
echo ""
echo -e "${YELLOW}📋 Próximos passos:${NC}"
echo "1. Revisar o arquivo editado"
echo "2. Fazer correções manuais necessárias"
echo "3. Testar: tsc --noEmit $FILE"
echo ""
echo "Para restaurar backup:"
echo "cp $BACKUP $FILE"
