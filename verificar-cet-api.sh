#!/bin/bash
echo "🔍 VERIFICANDO API DE CET"
echo "========================"
echo ""
echo "📂 Buscando CET em routes:"
ls -lah packages/api/src/routes/ | grep -i cet || echo "   ❌ Não encontrado"
echo ""
echo "📂 Buscando CET em controllers:"
ls -lah packages/api/src/controllers/ | grep -i cet || echo "   ❌ Não encontrado"
echo ""
echo "📂 Conteúdo de reports.routes.ts:"
cat packages/api/src/routes/reports.routes.ts
echo ""
echo "📂 Estrutura completa da API:"
find packages/api/src -name "*.ts" -type f | grep -E "(routes|controllers|schemas|services)" | sort
