# 🚨 Troubleshooting Guide - FinMath Project

**Última atualização:** 2025-10-13  
**Mantenedor:** Moses  
**Objetivo:** Resolver problemas comuns rapidamente

---

## 📋 **Índice**

1. [Problemas de Arquivos](#problemas-de-arquivos)
2. [TypeScript & Monorepo](#typescript--monorepo)
3. [Fastify & API](#fastify--api)
4. [Testes & Validação](#testes--validação)
5. [Git & Commits](#git--commits)

---

## 🔧 **Problemas de Arquivos**

### ❌ Problema 1: Arquivos truncados ao usar heredoc

**Sintoma:**

```bash
cat > arquivo.ts << 'EOF'
# ... código ...
EOF

# Arquivo fica incompleto ou cortado
Causa: heredoc não lida bem com arquivos TypeScript grandes ou complexos.
Solução:
bash# ✅ SEMPRE use nano para arquivos TypeScript
nano arquivo.ts

# OU para substituições pontuais
sed -i 's/antigo/novo/' arquivo.ts
Regra de ouro: Se arquivo tem >50 linhas ou >1KB → use nano

❌ Problema 2: Backups físicos aparecendo
Sintoma:
bashpackages/api.backup/
packages/engine/src/file.ts.bak
Causa: Criação inadvertida de backups durante edição.
Solução:
bash# Limpeza diária (REGRA CRÍTICA #3)
find packages -name "*bak*" -o -name "*backup*" -o -name "*.save" -type f -delete

# Verificar antes de commit
git status | grep -E "(bak|backup|save)"
Prevenção: NUNCA criar backups físicos. Use Git:
bash# ✅ CORRETO: Backup via Git
git add .
git commit -m "WIP: salvando progresso"

# ❌ ERRADO: Backup físico
cp file.ts file.ts.bak

🔷 TypeScript & Monorepo
❌ Problema 3: tsconfig rootDir em monorepo
Sintoma:
error TS6059: File 'packages/engine/src/index.ts' is not under 'rootDir'
Causa: rootDir impede imports entre packages do monorepo.
Solução:
json// packages/api/tsconfig.json
{
  "compilerOptions": {
    "outDir": "./dist",
    // ❌ REMOVER: "rootDir": "./src",
    "paths": {
      "@finmath/engine": ["../engine/src/index.ts"]
    }
  }
}
Explicação: Em monorepos, imports cruzam boundaries de diretórios.

❌ Problema 4: Exports com isolatedModules
Sintoma:
error TS1205: Re-exporting a type when 'isolatedModules' is enabled requires using 'export type'
Causa: TypeScript precisa distinguir tipos de valores com isolatedModules: true.
Solução:
typescript// ❌ ERRADO
export { DayCountConvention, daysBetween } from './conventions';

// ✅ CORRETO
export { daysBetween, yearFraction } from './conventions';
export type { DayCountConvention } from './conventions';
Regra: Separe export type de export regular.

🌐 Fastify & API
❌ Problema 5: Fastify + Pino incompatibilidade de tipos
Sintoma:
error TS2769: Property 'msgPrefix' is missing in type 'Logger'
Causa: Logger customizado do Pino não é compatível com tipos do Fastify.
Solução:
typescript// ❌ ERRADO
import { createChildLogger } from './infrastructure/logger';
const fastify = Fastify({
  logger: createChildLogger({ context: 'server' })
});

// ✅ CORRETO
const fastify = Fastify({
  logger: true  // Use logger built-in do Fastify
});
Alternativa: Se precisar de logger customizado, use as any:
typescriptfastify.setErrorHandler(errorHandler as any);

❌ Problema 6: Error handling retorna 500 em vez de 400
Sintoma:
javascript// Teste espera 400, mas recebe 500
expect(response.statusCode).toBe(400); // ❌ Falha
Causa: Error handler não trata erros de validação do Fastify.
Solução:
typescriptexport function errorHandler(
  error: Error & { validation?: any },
  request: FastifyRequest,
  reply: FastifyReply,
) {
  // ✅ Tratar erros de schema do Fastify PRIMEIRO
  if (error.validation) {
    return reply.status(400).send({
      error: {
        code: 'VALIDATION_ERROR',
        message: error.message
      }
    });
  }

  // Depois tratar Zod, AppError, etc.
  if (error instanceof ZodError) { /* ... */ }
}
Ordem importa: Fastify validation → Zod → AppError → Generic

🧪 Testes & Validação
❌ Problema 7: Testes falhando por import incorreto
Sintoma:
TypeError: createServer is not a function
Causa: Import não corresponde ao export do módulo.
Solução:
typescript// Verificar o que é exportado
// src/server.ts
export { buildServer };  // ← Nome correto

// test/integration/test.ts
// ❌ ERRADO
import { createServer } from '../../src/server';

// ✅ CORRETO
import { buildServer } from '../../src/server';
Dica: Sempre verificar exports antes de importar:
bashgrep "export" src/server.ts

❌ Problema 8: Golden Files falhando por tolerância
Sintoma:
Expected: 946.56
Received: 946.57
Difference: 0.01 > tolerance (0.01)
Causa: Arredondamento de ponto flutuante.
Solução:
json// Golden File
{
  "tolerance": {
    "interest": 0.01  // ✅ Aumentar se necessário
  }
}
Investigação:
typescript// Verificar resultado real
console.log(result.interest.toNumber()); // 946.567891234
// Ajustar round2() ou tolerância

🔄 Git & Commits
❌ Problema 9: Lint/Prettier bloqueando commit
Sintoma:
✖ Running tasks for staged files...
✖ Lint failed
Causa: Husky executa lint-staged antes do commit.
Solução imediata:
bash# Opção 1: Corrigir erros
pnpm lint --fix

# Opção 2: Skip hooks (EVITAR)
git commit --no-verify -m "mensagem"
Solução permanente: Sempre rodar lint antes de commit:
bash# Workflow correto
pnpm typecheck
pnpm lint
pnpm test
git add .
git commit -m "mensagem"

❌ Problema 10: Merge conflicts ao sincronizar
Sintoma:
git pull origin main
CONFLICT (content): Merge conflict in package.json
Causa: Mudanças concorrentes no mesmo arquivo.
Solução:
bash# 1. Abortar merge
git merge --abort

# 2. Criar backup local
git branch backup-$(date +%Y%m%d)

# 3. Forçar sincronização (CUIDADO!)
git fetch origin
git reset --hard origin/main

# 4. Reaplicar mudanças manualmente se necessário
Prevenção: Sincronizar no INÍCIO de cada sprint (REGRA #1).

📊 Checklist de Debugging
Quando algo der errado, siga esta ordem:
markdown### 1. Identificar o erro
- [ ] Ler mensagem de erro COMPLETA
- [ ] Copiar stack trace
- [ ] Identificar arquivo e linha

### 2. Verificar causas comuns
- [ ] Arquivo foi criado com heredoc? → usar nano
- [ ] Import está correto? → verificar exports
- [ ] Tipos estão corretos? → typecheck
- [ ] Error handler trata o erro? → verificar logs

### 3. Isolar o problema
- [ ] Testar arquivo isolado: `pnpm typecheck arquivo.ts`
- [ ] Testar build: `pnpm build`
- [ ] Testar testes: `pnpm test arquivo.test.ts`

### 4. Aplicar solução
- [ ] Consultar este guia
- [ ] Aplicar correção
- [ ] Validar: `pnpm typecheck && pnpm test`

### 5. Documentar
- [ ] Adicionar ao troubleshooting se for novo
- [ ] Atualizar checklist se for recorrente

🎓 Lições Aprendidas
✅ O que SEMPRE fazer:

✅ Usar nano para arquivos TypeScript
✅ Limpar backups físicos diariamente
✅ Testar typecheck após cada arquivo criado
✅ Consultar este guia antes de debugar
✅ Commits locais frequentes

❌ O que NUNCA fazer:

❌ Usar heredoc para TypeScript grande
❌ Criar backups físicos (.bak, .backup)
❌ Commit sem validação (typecheck + test)
❌ Pular leitura de erros completos
❌ Fazer push durante a sprint


🆘 Última linha de defesa
Se NADA funcionar:
bash# 1. Backup completo via Git
git add .
git commit -m "WIP: antes de reset"

# 2. Ver estado do último commit bom
git log --oneline -5

# 3. Reset para commit bom
git reset --hard <commit-hash>

# 4. Reaplicar mudanças manualmente
# (Use diff do backup)

📞 Contato

Mantenedor: Moses (mpmoses@gmail.com)
Última revisão: 2025-10-13
Versão do guia: 1.0


🎯 Objetivo: Resolver 80% dos problemas em <5min consultando este guia.
```
