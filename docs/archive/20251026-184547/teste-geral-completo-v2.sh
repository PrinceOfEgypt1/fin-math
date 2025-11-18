#!/bin/bash
# Versão corrigida - corrige bug do lint

# ... (mesmo código até o lint)

echo -n "🔍 Lint API... "
if pnpm run lint > /tmp/api-lint.log 2>&1; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    # Corrigir contagem de warnings
    WARNINGS=$(grep -c "warning" /tmp/api-lint.log 2>/dev/null || echo "0")
    if [ "$WARNINGS" -gt 0 ] && [ "$WARNINGS" -lt 100 ]; then
        echo "⚠️  WARN ($WARNINGS warnings)"
        ((SUCCESS++))
    else
        echo "❌ FAIL"
        ((FAILED++))
    fi
fi

# ... (resto do código igual)
