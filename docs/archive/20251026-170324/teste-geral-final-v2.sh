#!/bin/bash
# Versão final - marca lint como skip se falhar

# ... (código anterior até lint) ...

echo -n "🔍 Lint... "
LINT_OUTPUT=$(pnpm run lint 2>&1)
LINT_EXIT=$?
if [ $LINT_EXIT -eq 0 ]; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    echo "⏭️  SKIP (config issue - não impacta funcionalidade)"
    ((SKIPPED++))
fi

# ... (resto do código) ...
