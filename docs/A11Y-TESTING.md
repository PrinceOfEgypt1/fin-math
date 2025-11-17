# Testes de Acessibilidade - FinMath

## 🎯 Objetivo

Garantir que todas as interfaces do FinMath atendam aos padrões WCAG 2.1 Nível AA através de testes automatizados e manuais.

## 🔧 Configuração

Os testes de acessibilidade usam:

- **Playwright** para automação de browser
- **@axe-core/playwright** para análise de acessibilidade
- **WCAG 2.1 AA** como padrão mínimo

## 🚀 Executando Testes

### Localmente

1. **Iniciar servidor de desenvolvimento:**

```bash
# Terminal 1: Iniciar UI em modo dev
pnpm -F @finmath/ui dev
```

2. **Rodar testes A11y (em outro terminal):**

```bash
# Rodar testes A11y automatizados
pnpm test:a11y

# Gerar relatório completo (JSON + Markdown)
pnpm test:a11y:report
```

3. **Visualizar relatórios:**

Os relatórios são salvos em `docs/a11y/`:

- `a11y-report.json` - Relatório completo em JSON
- `a11y-report.md` - Relatório formatado em Markdown

```bash
# Ver relatório Markdown
cat docs/a11y/a11y-report.md

# Ver relatório JSON
cat docs/a11y/a11y-report.json | jq
```

### Na Pipeline CI

Os testes A11y rodam automaticamente na pipeline CI (GitHub Actions) em:

- Todo push para branches `main` e `sprint-*`
- Todo Pull Request para `main`

**Como funciona:**

1. A pipeline executa o job `a11y-tests`
2. Roda testes automatizados com Playwright + axe-core
3. Gera relatório completo
4. Faz upload do relatório como artifact
5. **FALHA** se houver violations de severidade **critical** ou **serious**

**Baixar relatórios da CI:**

1. Acesse a aba "Actions" no GitHub
2. Clique no workflow executado
3. Baixe o artifact `a11y-report`

## 📊 Interpretando Resultados

### Níveis de Severidade

O axe-core classifica violations em 4 níveis:

| Severidade   | Descrição                                   | Impacto na CI |
| ------------ | ------------------------------------------- | ------------- |
| **Critical** | Viola completamente WCAG, impossibilita uso | ❌ FALHA      |
| **Serious**  | Viola WCAG de forma significativa           | ❌ FALHA      |
| **Moderate** | Dificulta acessibilidade                    | ⚠️ AVISO      |
| **Minor**    | Pequenos problemas                          | ⚠️ AVISO      |

### Exemplo de Relatório

```markdown
## Resumo Geral

| Página         | Passes | Violations | Incomplete |
| -------------- | ------ | ---------- | ---------- |
| ✅ /           | 45     | 0          | 2          |
| ❌ /comparador | 38     | 3          | 1          |

## Detalhes das Violations

### /comparador

#### ❌ label-content-name-mismatch

**Impacto:** serious
**Descrição:** Elements must have their visible text as part of their accessible name
**Tags:** wcag2a, wcag21a, wcag131

**Elementos afetados:** 1
**Exemplos:**

- `<button aria-label="Calcular">Comparar</button>`
```

### Como Corrigir Violations

1. **Consulte a documentação do erro:**

   Cada violation tem um ID único. Busque no [axe-core rules](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md).

2. **Use o Playwright Inspector para debug:**

```bash
pnpm test:a11y:debug
```

3. **Corrija no código:**

```tsx
// ❌ ANTES (violation: label-content-name-mismatch)
<button aria-label="Calcular">Comparar</button>

// ✅ DEPOIS
<button aria-label="Comparar sistemas de amortização">
  Comparar
</button>
```

4. **Rode novamente:**

```bash
pnpm test:a11y
```

## 🧪 Testes Manuais

Além dos testes automatizados, realize testes manuais:

### 1. Navegação por Teclado

- [ ] Desconecte o mouse
- [ ] Navegue pelo site apenas com TAB/Shift+TAB
- [ ] Ative elementos com Enter/Espaço
- [ ] Verifique que todos os interativos são alcançáveis
- [ ] Indicador de foco é sempre visível

### 2. Leitores de Tela

Teste com pelo menos um leitor de tela:

- **NVDA** (Windows, gratuito): [nvaccess.org](https://www.nvaccess.org/)
- **JAWS** (Windows, pago)
- **VoiceOver** (macOS/iOS, nativo): `Cmd+F5`
- **TalkBack** (Android, nativo)

**Checklist:**

- [ ] Headings são anunciados corretamente
- [ ] Formulários têm labels claros
- [ ] Mudanças dinâmicas são anunciadas
- [ ] Navegação entre landmarks funciona

### 3. Ferramentas de Browser

- **axe DevTools** (Chrome/Firefox): Extensão gratuita
- **WAVE** (Chrome/Firefox): Extensão gratuita
- **Lighthouse** (Chrome DevTools): Nativo no Chrome

## 📝 Adicionando Novos Testes

Para adicionar testes A11y de novas páginas:

1. **Adicione a rota no gerador de relatórios:**

Edite `tests/utils/generate-a11y-report.ts`:

```typescript
const urls = [
  { path: "/", name: "Home" },
  { path: "/comparador", name: "Comparador PRICE vs SAC" },
  { path: "/calculadora", name: "Calculadora" },
  { path: "/nova-pagina", name: "Nova Página" }, // ← Adicione aqui
];
```

2. **Crie teste específico (opcional):**

Crie `tests/a11y/nova-pagina.spec.ts`:

```typescript
import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test.describe("Nova Página - A11y", () => {
  test("should not have accessibility violations", async ({ page }) => {
    await page.goto("/nova-pagina");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });
});
```

3. **Rode os testes:**

```bash
pnpm test:a11y
```

## 🔄 Integração Contínua

### Workflow na CI

```yaml
- name: Run accessibility tests
  run: pnpm test:a11y

- name: Generate A11y Report
  if: always()
  run: pnpm test:a11y:report

- name: Upload A11y Report
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: a11y-report
    path: docs/a11y/
```

### Política de Merge

- ✅ **Permitido:** Violations de nível `moderate` ou `minor`
- ❌ **Bloqueado:** Violations de nível `critical` ou `serious`

## 📚 Recursos

### Documentação Oficial

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [axe-core Rules](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md)
- [Playwright Accessibility Testing](https://playwright.dev/docs/accessibility-testing)

### Guias Internos

- [Guia de Acessibilidade](./A11Y-GUIDE.md) - Padrões e componentes acessíveis

### Ferramentas

- [axe DevTools](https://www.deque.com/axe/devtools/)
- [WAVE Browser Extension](https://wave.webaim.org/extension/)
- [Color Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [NVDA Screen Reader](https://www.nvaccess.org/)

## ❓ FAQ

### Os testes estão falhando com "Timeout waiting for page"

Certifique-se de que o servidor dev está rodando:

```bash
# Terminal 1
pnpm -F @finmath/ui dev

# Terminal 2 (aguarde servidor iniciar)
pnpm test:a11y
```

### Como ignorar uma violation conhecida temporariamente?

Use `.disableRules()` no teste:

```typescript
const results = await new AxeBuilder({ page })
  .disableRules(["color-contrast"]) // Apenas temporário!
  .analyze();
```

**Importante:** Documente o motivo e crie issue para corrigir.

### Os testes passam localmente mas falham na CI

Verifique:

1. Versões de dependências (pnpm-lock.yaml sincronizado)
2. Variáveis de ambiente
3. Timeouts (CI pode ser mais lento)

## 🎓 Manutenção

Este documento deve ser atualizado:

- Quando novos testes A11y forem adicionados
- Quando ferramentas mudarem
- Quando padrões WCAG evoluírem

---

**Última atualização:** Sprint 4
**Responsável:** Equipe FinMath
