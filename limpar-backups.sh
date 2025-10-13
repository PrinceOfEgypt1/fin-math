#!/bin/bash
# ============================================
# SCRIPT: limpar-backups.sh
# OBJETIVO: Remover backups físicos (REGRA #3)
# USO: ./limpar-backups.sh [--dry-run]
# ============================================

DRY_RUN=false

if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
    echo "🔍 MODO DRY-RUN (apenas visualizar, não remover)"
    echo ""
fi

echo "🧹 LIMPEZA DE BACKUPS FÍSICOS"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Buscar backups
BACKUPS=$(find packages \( -name "*bak*" -o -name "*backup*" -o -name "*.save" \) -type f 2>/dev/null)
BACKUP_DIRS=$(find packages \( -name "*bak*" -o -name "*backup*" \) -type d 2>/dev/null)

# Contar (corrigido)
if [ -z "$BACKUPS" ]; then
    COUNT_FILES=0
else
    COUNT_FILES=$(echo "$BACKUPS" | grep -c '^' 2>/dev/null || echo "0")
fi

if [ -z "$BACKUP_DIRS" ]; then
    COUNT_DIRS=0
else
    COUNT_DIRS=$(echo "$BACKUP_DIRS" | grep -c '^' 2>/dev/null || echo "0")
fi

TOTAL=$((COUNT_FILES + COUNT_DIRS))

if [ $TOTAL -eq 0 ]; then
    echo "✅ Nenhum backup encontrado!"
    echo "   Projeto limpo (REGRA #3 respeitada)"
    exit 0
fi

echo "⚠️  BACKUPS ENCONTRADOS:"
echo "   Arquivos: $COUNT_FILES"
echo "   Diretórios: $COUNT_DIRS"
echo ""

if [ $DRY_RUN = true ]; then
    echo "📋 Arquivos que seriam removidos:"
    [ -n "$BACKUPS" ] && echo "$BACKUPS" | sed 's/^/   - /'
    [ -n "$BACKUP_DIRS" ] && echo "$BACKUP_DIRS" | sed 's/^/   - /'
    echo ""
    echo "💡 Execute sem --dry-run para remover"
    exit 0
fi

# Remover
echo "🗑️  Removendo backups..."
[ -n "$BACKUPS" ] && echo "$BACKUPS" | xargs rm -f
[ -n "$BACKUP_DIRS" ] && echo "$BACKUP_DIRS" | xargs rm -rf

echo "✅ Limpeza concluída!"
echo "   Removidos: $TOTAL itens"
echo ""
echo "🎯 Próximo passo: git status (verificar que nada foi commitado)"
