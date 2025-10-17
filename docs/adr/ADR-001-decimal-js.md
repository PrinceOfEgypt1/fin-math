# ADR-001: Decimal.js

**Status:** ✅ Accepted  
**Data:** 2025-10-11

## Decisão

Usar Decimal.js para precisão monetária.

## Motivo

Float64 tem erros binários (0.1 + 0.2 ≠ 0.3).

## Impacto

- Engine usa Decimal em tudo
- API converte nas bordas
