**Owner:** @PrinceOfEgypt1  
**Última revisão:** 2025-10-17

# Contributing to FinMath

## Workflow Git

### Início Sprint

```bash
git checkout -b sprint-X
```

### Durante Sprint

```bash
git commit -m "feat(HX): descrição"
# NÃO fazer push!
```

### Final Sprint

```bash
npm run test
git checkout main
git merge sprint-X --no-ff
git push origin main
```
