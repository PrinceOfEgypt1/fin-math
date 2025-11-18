# Documentação de Acessibilidade - FinMath

## Visão Geral

O projeto FinMath segue rigorosamente o padrão **WCAG 2.2 Nível AA** para garantir que a aplicação seja acessível a todos os usuários, incluindo pessoas com deficiências.

## Conformidade WCAG 2.2 AA

### ✅ Implementado

#### 1.4.3 Contraste (Mínimo) - Nível AA

- **Status:** ✅ Conforme
- **Contraste:** ≥4.5:1 para texto normal
- **Contraste:** ≥3:1 para texto grande
- **Tokens utilizados:**
  - `text-DEFAULT` (≥4.5:1 com `surface`)
  - `text-secondary` (≥4.5:1 com `surface`)
  - Botões com contraste adequado

#### 2.4.1 Bypass Blocks - Nível A

- **Status:** ✅ Conforme
- **Implementação:** Componente `SkipLink`
- **Atalho:** Permite pular para conteúdo principal

#### 2.4.7 Foco Visível - Nível AA

- **Status:** ✅ Conforme
- **Implementação:**
  - Ring de 2px no foco
  - Offset de 2px
  - Cor `primary` (azul)

#### 2.5.5 Target Size (Minimum) - Nível AAA

- **Status:** ✅ Conforme (Excede AA)
- **Implementação:**
  - Touch target mínimo: 44x44px
  - Aplicado a todos os botões
  - Aplicado a todos os inputs

#### 3.3.2 Labels ou Instruções - Nível A

- **Status:** ✅ Conforme
- **Implementação:**
  - Todos os inputs têm labels associados
  - `helperText` para instruções adicionais
  - Mensagens de erro descritivas

#### 4.1.3 Status Messages - Nível AA

- **Status:** ✅ Conforme
- **Implementação:**
  - `role="alert"` para erros
  - `role="status"` para mensagens de sucesso

## Testes de Acessibilidade

### Testes Automatizados

#### axe-core

- **Ferramenta:** @axe-core/playwright
- **Cobertura:** Todas as páginas principais
- **Frequência:** A cada commit (CI/CD)
- **Tags testadas:**
  - wcag2a
  - wcag2aa
  - wcag21a
  - wcag21aa
  - wcag22aa

#### Playwright A11y Tests

- **Localização:** `tests/a11y/`
- **Testes:** 13 testes automatizados
- **Cobertura:**
  - Navegação por teclado
  - Contraste de cores
  - Labels de formulários
  - Landmarks ARIA
  - Hierarquia de headings
  - Leitores de tela

### Testes Manuais

#### Navegação por Teclado

- **Tab:** Navegar para frente
- **Shift+Tab:** Navegar para trás
- **Enter:** Ativar botão/link
- **Escape:** Fechar modal

#### Leitores de Tela

- **NVDA (Windows):** Testado
- **JAWS (Windows):** Testado
- **VoiceOver (macOS):** Testado

## Comandos

```bash
# Rodar testes de acessibilidade
pnpm test:a11y

# Gerar relatório A11y
pnpm test:a11y:report

# Ver relatório
cat docs/a11y/a11y-report.md
```

## Checklist de PR

Antes de abrir um PR, certifique-se:

- [ ] Testes de acessibilidade passam
- [ ] Contraste validado (≥4.5:1)
- [ ] Navegação por teclado funciona
- [ ] Labels em todos os inputs
- [ ] Foco visível em elementos interativos
- [ ] Touch targets ≥44x44px
- [ ] Relatório A11y sem violations

## Recursos

- [WCAG 2.2](https://www.w3.org/WAI/WCAG22/quickref/)
- [axe-core Rules](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md)
- [Playwright Accessibility](https://playwright.dev/docs/accessibility-testing)

## Contato

Para questões de acessibilidade, contate:

- **Responsável A11y:** [Nome]
- **Email:** [email@example.com]
