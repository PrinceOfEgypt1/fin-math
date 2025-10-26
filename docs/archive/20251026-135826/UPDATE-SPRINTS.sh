#!/bin/bash

echo "📝 Atualizando documentação de Sprints..."

# Atualizar SPRINTS_AND_HUS.md
sed -i 's/### \*\*Sprint 4 - IRR + CET\*\* 📋 Planejada/### **Sprint 4A - Backend (IRR + CET)** ✅ Completa/' docs/SPRINTS_AND_HUS.md

# Adicionar Sprint 4B
cat >> docs/SPRINTS_AND_HUS.md << 'SPRINT4B'

### **Sprint 4B - Frontend (UI)** ✅ Completa (2025-10-19)

| HU  | Título | Status | Dependências | Issue |
|-----|--------|--------|--------------|-------|
| HU-09 | Simulador PRICE (UI) | ✅ Implementado | Sprint 2 | - |
| HU-10 | Simulador SAC (UI) | ✅ Implementado | Sprint 2 | - |
| HU-24 | Comparação PRICE vs SAC | ✅ Implementado | HU-09, HU-10 | - |

**Implementado:**
- Interface completa React + Vite
- Componentes: PriceSimulator, SacSimulator, ComparisonPage
- Design System: Tailwind + Framer Motion
- Navegação funcional

**Débitos Técnicos:**
- Issue #001: Testes unitários ComparisonPage
- Issue #002: Acessibilidade
SPRINT4B

echo "✅ Documentação atualizada!"
