# ✅ Checklist para Implementar Novas ONDAs

**Versão:** 1.0  
**Data:** 2025-10-13  
**Baseado em:** Lições da ONDA 0 e ONDA 1

---

## 🚦 ANTES DE COMEÇAR

### Preparação do Ambiente

- [ ] Limpar backups físicos: `./limpar-backups.sh`
- [ ] Confirmar branch: `git status`
- [ ] Verificar último commit: `git log -1 --oneline`

---

## 🏗️ DURANTE IMPLEMENTAÇÃO

### Criação de Arquivos

- [ ] Usar `nano` para arquivos >50 linhas (NUNCA heredoc)
- [ ] Testar `typecheck` após cada arquivo

### Estrutura

- [ ] Motor: `packages/engine/src/modulo/`
- [ ] API: `packages/api/src/routes/modulo.routes.ts`
- [ ] Testes unitários: `test/unit/modulo/`
- [ ] Golden Files: `test/golden/ondaX/`
- [ ] Testes integração: `test/integration/modulo.test.ts`

### Commits

- [ ] Commit local a cada história: `git commit -m "feat(HXX): ..."`

---

## 🔍 ANTES DE VALIDAR

### Verificações

- [ ] Imports corretos?
- [ ] Error handler completo?
- [ ] Types com `export type`?
- [ ] Testes unitários passando?
- [ ] Golden Files passando?

---

## ✅ VALIDAÇÃO

### Rápida

```bash
./validacao-rapida.sh tudo
```
