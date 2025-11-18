# Guia de Acessibilidade FinMath

## 📋 Visão Geral

Este guia estabelece os padrões de acessibilidade para o desenvolvimento de componentes no FinMath, seguindo as diretrizes **WCAG 2.1 Nível AA**.

## 🎯 Objetivo

Garantir que todas as pessoas, independente de suas capacidades, possam utilizar os simuladores e calculadoras do FinMath com:
- **Leitores de tela** (NVDA, JAWS, VoiceOver)
- **Navegação por teclado**
- **Contraste adequado**
- **Estrutura semântica clara**

## ✅ Checklist de Acessibilidade

### Estrutura Semântica

- [ ] Toda página possui uma região `<main>` única
- [ ] Título `<h1>` descritivo em cada página
- [ ] Hierarquia de headings correta (H1 > H2 > H3, sem pular níveis)
- [ ] Uso correto de landmarks HTML5 (`<header>`, `<nav>`, `<main>`, `<footer>`)
- [ ] Listas semânticas (`<ul>`, `<ol>`) para conteúdo relacionado

### Elementos Interativos

- [ ] Todos os botões usam `<button>` (não `<div>` com `onClick`)
- [ ] Links usam `<a>` com `href` válido
- [ ] Todos os elementos clicáveis são focáveis via TAB
- [ ] Indicador de foco visível (outline ou estilo customizado)
- [ ] Sem "prisão de foco" (focus trap não intencional)
- [ ] Ordem de tabulação lógica e intuitiva

### Formulários

- [ ] Todo `<input>` possui `<label>` associado via `htmlFor` ou envolvimento
- [ ] Labels descritivos e claros
- [ ] Mensagens de erro acessíveis (aria-describedby)
- [ ] Campos obrigatórios indicados visualmente E semanticamente
- [ ] Placeholders não substituem labels

### ARIA (Accessible Rich Internet Applications)

- [ ] Uso mínimo e correto de ARIA (HTML semântico é preferível)
- [ ] `aria-label` ou `aria-labelledby` em elementos sem texto visível
- [ ] `aria-describedby` para descrições adicionais
- [ ] `aria-live` para atualizações dinâmicas importantes
- [ ] `aria-invalid` e `aria-required` em formulários
- [ ] `role` apenas quando HTML semântico não for suficiente

### Contraste e Cores

- [ ] Texto normal: contraste mínimo 4.5:1
- [ ] Texto grande (18pt ou 14pt bold): contraste mínimo 3:1
- [ ] Elementos interativos: contraste mínimo 3:1 com fundo
- [ ] Informação não transmitida apenas por cor

### Conteúdo Multimídia

- [ ] Imagens decorativas: `alt=""` (vazio)
- [ ] Imagens informativas: `alt` descritivo e conciso
- [ ] Gráficos: texto alternativo ou resumo textual próximo
- [ ] Tabelas: `<caption>`, `<th>` com `scope`

## 🧩 Componentes Acessíveis Padrão

### Button

```tsx
// ✅ CORRETO
<button
  type="button"
  onClick={handleClick}
  aria-label="Calcular parcelas"
>
  Calcular
</button>

// ❌ INCORRETO
<div onClick={handleClick}>Calcular</div>
```

### Input com Label

```tsx
// ✅ CORRETO
<div>
  <label htmlFor="principal-amount">Valor Principal (R$)</label>
  <input
    id="principal-amount"
    type="number"
    value={amount}
    onChange={handleChange}
    aria-required="true"
    aria-describedby={error ? "amount-error" : undefined}
  />
  {error && (
    <span id="amount-error" role="alert">
      {error}
    </span>
  )}
</div>

// ❌ INCORRETO
<input placeholder="Valor Principal" />
```

### Link

```tsx
// ✅ CORRETO
<a href="/price" className="nav-link">
  Calculadora PRICE
</a>

// ❌ INCORRETO
<span onClick={() => navigate('/price')}>
  Calculadora PRICE
</span>
```

### Região Principal

```tsx
// ✅ CORRETO
<main id="main-content">
  <h1>Comparador PRICE vs SAC</h1>
  {/* conteúdo */}
</main>

// ❌ INCORRETO
<div className="content">
  <h2>Comparador PRICE vs SAC</h2>
  {/* h2 como título principal */}
</div>
```

## 🧪 Testando Acessibilidade

### Testes Automatizados

```bash
# Rodar testes de acessibilidade
pnpm test:a11y

# Gerar relatório detalhado
pnpm test:a11y:report
```

### Testes Manuais

#### Navegação por Teclado

1. Use apenas TAB/Shift+TAB para navegar
2. Verifique se todos os elementos interativos são alcançáveis
3. Confirme que a ordem de foco é lógica
4. Teste ações com Enter e Espaço

#### Leitor de Tela

- **Windows**: NVDA (gratuito)
- **Mac**: VoiceOver (nativo)
- **Linux**: Orca

#### Ferramentas de Desenvolvimento

- **axe DevTools** (extensão Chrome/Firefox)
- **Lighthouse** (Chrome DevTools)
- **WAVE** (extensão)

## 📚 Recursos

### Documentação WCAG

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)

### Ferramentas

- [axe-core](https://github.com/dequelabs/axe-core)
- [eslint-plugin-jsx-a11y](https://github.com/jsx-eslint/eslint-plugin-jsx-a11y)
- [Playwright axe integration](https://playwright.dev/docs/accessibility-testing)

### Leitores de Tela

- [NVDA (Windows)](https://www.nvaccess.org/)
- [JAWS (Windows)](https://www.freedomscientific.com/products/software/jaws/)
- VoiceOver (Mac - nativo)
- Orca (Linux)

## 🚨 Erros Comuns

### 1. Div Clicável

```tsx
// ❌ ERRADO
<div onClick={onClick}>Clique aqui</div>

// ✅ CORRETO
<button type="button" onClick={onClick}>
  Clique aqui
</button>
```

### 2. Label Ausente

```tsx
// ❌ ERRADO
<input placeholder="Digite seu nome" />

// ✅ CORRETO
<label htmlFor="name">Nome</label>
<input id="name" type="text" />
```

### 3. Informação Apenas Visual

```tsx
// ❌ ERRADO
<span style={{ color: 'red' }}>*</span>
<input />

// ✅ CORRETO
<label htmlFor="email">
  Email <span aria-label="obrigatório">*</span>
</label>
<input id="email" aria-required="true" />
```

### 4. Foco Invisível

```css
/* ❌ ERRADO */
*:focus {
  outline: none;
}

/* ✅ CORRETO */
*:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}
```

## 🎨 Padrões de Contraste

### Texto

- **Normal (< 18pt)**: 4.5:1
- **Grande (≥ 18pt ou ≥ 14pt bold)**: 3:1

### Componentes

- **Botões, inputs, borders**: 3:1
- **Estados (hover, focus)**: 3:1

### Ferramentas de Verificação

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Chrome DevTools (Lighthouse)

## 🔄 Fluxo de Desenvolvimento

1. **Desenvolver** com HTML semântico primeiro
2. **Adicionar** ARIA apenas quando necessário
3. **Testar** com teclado
4. **Validar** com axe-core (pnpm test:a11y)
5. **Verificar** com leitor de tela
6. **Revisar** com usuários reais (se possível)

## 📝 Notas Finais

- **HTML semântico** > ARIA
- **Simplicidade** > Complexidade
- **Testar cedo** e frequentemente
- **Não confiar apenas** em testes automatizados

---

**Versão**: 1.0
**Última atualização**: Sprint 4
**Padrão**: WCAG 2.1 AA
