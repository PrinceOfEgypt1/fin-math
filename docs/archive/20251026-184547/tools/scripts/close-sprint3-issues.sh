#!/bin/bash
# close-sprint3-issues.sh
# Script para fechar issues da Sprint 3 usando GitHub CLI

REPO="PrinceOfEgypt1/fin-math"

echo "🚀 FECHANDO ISSUES DA SPRINT 3"
echo "Repositório: $REPO"
echo ""

# Comentário padrão para H13
COMMENT_H13=$(cat <<'COMMENT'
✅ **ISSUE RESOLVIDA - Sprint 3 Completa**

### Implementado:
- ✅ `POST /api/reports/price.csv` - Exportação CSV Price
- ✅ `POST /api/reports/sac.csv` - Exportação CSV SAC  
- ✅ `POST /api/reports/price.pdf` - Exportação PDF Price (pdfkit)
- ✅ `POST /api/reports/sac.pdf` - Exportação PDF SAC (pdfkit)

### Commits:
- `30cb764` - feat(H13): Implementa exportações CSV
- `40a7b59` - feat(H13): Completa exportações PDF
- `a1bb7cf` - fix(H13): Correção TypeScript

### Validação:
- ✅ CSV funcional (523 bytes, formato correto)
- ✅ PDF funcional (2.1-2.2KB por arquivo)
- ✅ Formato consistente entre Price e SAC
- ✅ Testes: 54/54 passando

### Arquivos Gerados:
- `packages/api/src/routes/reports.routes.ts` (155+ linhas)
- Função `toCSV()` para CSV
- Função `generatePDF()` para PDF

### Links:
- [CHANGELOG v0.3.0](https://github.com/PrinceOfEgypt1/fin-math/blob/main/CHANGELOG.md#030---2025-10-17)
- [README](https://github.com/PrinceOfEgypt1/fin-math#readme)
- [Commits da Sprint 3](https://github.com/PrinceOfEgypt1/fin-math/commits/main)

**Data de conclusão**: 2025-10-17
COMMENT
)

# Fechar Issue #13 (H13: Exportações)
echo "📋 Fechando Issue #13 - H13: Exportações CSV/PDF..."
gh issue comment 13 --repo "$REPO" --body "$COMMENT_H13"
gh issue close 13 --repo "$REPO" --reason completed
echo "✅ Issue #13 fechada!"

echo ""
echo "✅ TODAS AS ISSUES DA SPRINT 3 FORAM ATUALIZADAS!"
