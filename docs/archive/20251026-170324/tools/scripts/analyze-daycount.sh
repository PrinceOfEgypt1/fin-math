#!/bin/bash
# tools/scripts/analyze-daycount.sh
# Script para analisar o estado atual do módulo daycount

echo "🔍 ANÁLISE DO MÓDULO DAYCOUNT - SPRINT 3"
echo "========================================"
echo ""

# 1. Verificar se o arquivo daycount.ts existe
echo "📄 1. Verificando arquivos daycount..."
if [ -f "packages/engine/src/modules/daycount.ts" ]; then
    echo "✅ daycount.ts encontrado"
    echo "   Linhas de código:"
    wc -l packages/engine/src/modules/daycount.ts
else
    echo "❌ daycount.ts NÃO encontrado"
fi
echo ""

# 2. Verificar testes
echo "🧪 2. Verificando arquivos de teste..."
if [ -f "packages/engine/test/unit/daycount.test.ts" ]; then
    echo "✅ daycount.test.ts encontrado"
    echo "   Linhas de código:"
    wc -l packages/engine/test/unit/daycount.test.ts
else
    echo "❌ daycount.test.ts NÃO encontrado"
fi
echo ""

# 3. Procurar por .skip() nos testes
echo "⏭️  3. Procurando testes com .skip()..."
if [ -f "packages/engine/test/unit/daycount.test.ts" ]; then
    SKIP_COUNT=$(grep -c "\.skip(" packages/engine/test/unit/daycount.test.ts || echo "0")
    echo "   Testes com .skip(): $SKIP_COUNT"
    
    if [ "$SKIP_COUNT" -gt 0 ]; then
        echo ""
        echo "   Localizações dos .skip():"
        grep -n "\.skip(" packages/engine/test/unit/daycount.test.ts
    fi
else
    echo "   ⚠️  Arquivo de teste não encontrado"
fi
echo ""

# 4. Verificar estrutura de diretórios
echo "📁 4. Estrutura de diretórios..."
echo "   Árvore do módulo engine:"
tree -L 3 -I 'node_modules|dist' packages/engine/ || ls -R packages/engine/
echo ""

# 5. Verificar Golden Files existentes
echo "🏆 5. Golden Files para daycount..."
if [ -d "packages/engine/golden" ]; then
    echo "   Golden Files encontrados:"
    find packages/engine/golden -name "*DAYCOUNT*" -o -name "*daycount*" || echo "   Nenhum Golden File de daycount encontrado"
else
    echo "   ⚠️  Diretório golden/ não encontrado"
fi
echo ""

# 6. Verificar imports do daycount
echo "🔗 6. Arquivos que importam daycount..."
grep -r "from.*daycount" packages/engine/src/ 2>/dev/null || echo "   Nenhum import encontrado"
echo ""

echo "✅ ANÁLISE CONCLUÍDA!"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "   1. Copie TODA a saída acima"
echo "   2. Cole no chat com Claude"
echo "   3. Claude vai criar o código baseado no que existe"
