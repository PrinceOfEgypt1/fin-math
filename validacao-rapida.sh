#!/bin/bash
# ============================================
# SCRIPT: validacao-rapida.sh
# OBJETIVO: Validação rápida sem verbose
# USO: ./validacao-rapida.sh [motor|api|tudo]
# ============================================

set -e

ALVO=${1:-tudo}

echo "🚀 VALIDAÇÃO RÁPIDA: $ALVO"
echo ""

validar_motor() {
    echo "📦 Motor..."
    cd packages/engine
    pnpm typecheck > /dev/null 2>&1 && echo "  ✅ TypeCheck" || (echo "  ❌ TypeCheck"; exit 1)
    pnpm test > /dev/null 2>&1 && echo "  ✅ Testes" || (echo "  ❌ Testes"; exit 1)
    pnpm build > /dev/null 2>&1 && echo "  ✅ Build" || (echo "  ❌ Build"; exit 1)
    cd ../..
}

validar_api() {
    echo "🌐 API..."
    cd packages/api
    pnpm typecheck > /dev/null 2>&1 && echo "  ✅ TypeCheck" || (echo "  ❌ TypeCheck"; exit 1)
    pnpm test:integration > /dev/null 2>&1 && echo "  ✅ Testes" || (echo "  ❌ Testes"; exit 1)
    pnpm build > /dev/null 2>&1 && echo "  ✅ Build" || (echo "  ❌ Build"; exit 1)
    cd ../..
}

case $ALVO in
    motor)
        validar_motor
        ;;
    api)
        validar_api
        ;;
    tudo)
        validar_motor
        echo ""
        validar_api
        ;;
    *)
        echo "❌ Opção inválida: $ALVO"
        echo "Uso: ./validacao-rapida.sh [motor|api|tudo]"
        exit 1
        ;;
esac

echo ""
echo "✅ Validação completa!"

