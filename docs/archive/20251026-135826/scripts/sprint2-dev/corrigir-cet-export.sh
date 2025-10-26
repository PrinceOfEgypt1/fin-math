#!/bin/bash
set -euo pipefail

echo "🔧 CORRIGINDO EXPORT DE CET"
echo "==========================="
echo ""

echo "1️⃣ Verificando exports atuais..."
echo ""

echo "📄 packages/engine/src/modules/cet.ts:"
cat packages/engine/src/modules/cet.ts
echo ""

echo "📄 packages/engine/src/index.ts:"
cat packages/engine/src/index.ts
echo ""

echo "2️⃣ Analisando problema..."
echo ""

# Verificar se cetBasic existe no cet.ts
if grep -q "export function cetBasic" packages/engine/src/modules/cet.ts; then
  echo "   ✅ cetBasic está exportada em cet.ts"
  EXPORT_EXISTS=1
elif grep -q "function cetBasic" packages/engine/src/modules/cet.ts; then
  echo "   ⚠️  cetBasic existe mas NÃO está exportada em cet.ts"
  EXPORT_EXISTS=0
else
  echo "   ❌ cetBasic NÃO existe em cet.ts"
  echo ""
  echo "   Função encontrada no cet.ts:"
  grep "export function" packages/engine/src/modules/cet.ts || echo "   Nenhuma função exportada encontrada"
  EXPORT_EXISTS=-1
fi

echo ""
echo "3️⃣ Aplicando correção..."
echo ""

if [ $EXPORT_EXISTS -eq 1 ]; then
  # cetBasic já está exportada, verificar re-export no index.ts
  if grep -q "cetBasic" packages/engine/src/index.ts; then
    echo "   ✅ cetBasic já está no index.ts"
  else
    echo "   ⚠️  Adicionando cetBasic ao index.ts"
    
    # Adicionar export de cetBasic
    if grep -q 'export.*from.*modules/cet' packages/engine/src/index.ts; then
      # Já tem export de cet, adicionar cetBasic
      sed -i 's/export {.*} from.*modules\/cet/export { cetBasic } from ".\/modules\/cet";/' packages/engine/src/index.ts
    else
      # Adicionar nova linha de export
      echo 'export { cetBasic } from "./modules/cet";' >> packages/engine/src/index.ts
    fi
    
    echo "   ✅ Export adicionado ao index.ts"
  fi
elif [ $EXPORT_EXISTS -eq 0 ]; then
  echo "   ⚠️  Corrigindo export em cet.ts"
  
  # Adicionar export à função
  sed -i 's/^function cetBasic/export function cetBasic/' packages/engine/src/modules/cet.ts
  
  echo "   ✅ Export adicionado em cet.ts"
  
  # Adicionar re-export no index.ts
  if ! grep -q "cetBasic" packages/engine/src/index.ts; then
    echo 'export { cetBasic } from "./modules/cet";' >> packages/engine/src/index.ts
    echo "   ✅ Re-export adicionado em index.ts"
  fi
fi

echo ""
echo "4️⃣ Verificando resultado..."
echo ""

echo "📄 packages/engine/src/index.ts (últimas 10 linhas):"
tail -10 packages/engine/src/index.ts
echo ""

echo "5️⃣ Rebuilding engine..."
echo ""
cd packages/engine
pnpm build
cd ../..

echo ""
echo "6️⃣ Rebuilding API..."
echo ""
cd packages/api
pnpm build
cd ../..

echo ""
echo "==========================="
echo "✅ CORREÇÃO APLICADA!"
echo "==========================="
