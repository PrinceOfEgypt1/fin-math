# Guia de Acessibilidade - FinMath

## 📋 Objetivo

Este guia estabelece padrões de acessibilidade (WCAG 2.1 Nível AA) para todos os componentes do FinMath, garantindo que pessoas com deficiências visuais, motoras ou cognitivas possam usar a plataforma sem barreiras.

## 🎯 Padrão Mínimo: WCAG 2.1 AA

Todos os componentes devem atender aos critérios de sucesso WCAG 2.1 Nível AA.

## ✅ Checklist de Acessibilidade

### Estrutura de Página

- [ ] Toda página possui uma região `<main>` única
- [ ] Existe um título `<h1>` descritivo em cada página
- [ ] Hierarquia de headings é lógica e sequencial (H1 → H2 → H3, sem pulos)
- [ ] Landmarks ARIA estão presentes (`main`, `nav`, `header`, `footer`)
- [ ] A linguagem da página está definida (`<html lang="pt-BR">`)

### Navegação por Teclado

- [ ] Todos os elementos interativos são focáveis via TAB
- [ ] Ordem de foco é lógica e sequencial
- [ ] Indicador de foco é visível (outline ou estilo customizado)
- [ ] Não há "armadilhas de foco" (focus trap indesejado)
- [ ] Atalhos de teclado estão documentados (se houver)
- [ ] É possível completar todas as ações apenas com teclado

### Componentes Interativos

- [ ] Botões possuem texto descritivo ou `aria-label`
- [ ] Links descrevem seu destino
- [ ] Ícones sozinhos têm texto alternativo
- [ ] Não usar `<div>` ou `<span>` com `onClick` sem `role` e `tabIndex`
- [ ] Elementos desabilitados têm `aria-disabled` ou `disabled`

### Formulários

- [ ] Todo campo tem um `<label>` associado via `htmlFor`/`id`
- [ ] Campos obrigatórios indicam `aria-required` ou `required`
- [ ] Mensagens de erro têm `aria-live` ou `role="alert"`
- [ ] Validação em tempo real não confunde leitores de tela
- [ ] Placeholder não substitui label

### Cores e Contraste

- [ ] Contraste mínimo de 4.5:1 para texto normal
- [ ] Contraste mínimo de 3:1 para texto grande (≥18pt ou ≥14pt bold)
- [ ] Informação não depende apenas de cor
- [ ] Indicadores de estado são multimodais (cor + ícone + texto)

### Conteúdo Dinâmico

- [ ] Mudanças importantes são anunciadas via `aria-live`
- [ ] Carregamento tem indicador acessível (`aria-busy`, spinner com texto)
- [ ] Modais/dialogs capturam foco e retornam ao fechar
- [ ] Mensagens de sucesso/erro são anunciadas

### Imagens e Mídia

- [ ] Imagens informativas têm `alt` descritivo
- [ ] Imagens decorativas têm `alt=""` ou `aria-hidden="true"`
- [ ] Gráficos têm resumo textual próximo
- [ ] Vídeos têm legendas (se aplicável)

## 🧩 Componentes Base Acessíveis

### Button

```tsx
<button
  type="button"
  aria-label="Descrição clara da ação"
  className="focus:outline-2 focus:outline-offset-2 focus:outline-blue-500"
>
  Texto do Botão
</button>
```

**Checklist:**

- ✅ Elemento `<button>` semântico (não `<div>`)
- ✅ `type` explícito (`button`, `submit`, `reset`)
- ✅ Texto visível ou `aria-label`
- ✅ Indicador de foco visível
- ✅ Estados hover/active/disabled acessíveis

### Input

```tsx
<div>
  <label htmlFor="valor-emprestimo" className="block mb-2">
    Valor do Empréstimo (R$)
  </label>
  <input
    id="valor-emprestimo"
    type="number"
    aria-required="true"
    aria-describedby="valor-hint"
    className="focus:ring-2 focus:ring-blue-500"
  />
  <span id="valor-hint" className="text-sm text-gray-600">
    Digite apenas números
  </span>
</div>
```

**Checklist:**

- ✅ `<label>` associado via `htmlFor`/`id`
- ✅ `aria-required` para campos obrigatórios
- ✅ `aria-describedby` para hints/erros
- ✅ Indicador de foco visível
- ✅ Placeholder não substitui label

### Link

```tsx
<a href="/comparador" className="focus:outline-2 focus:outline-blue-500">
  Compare sistemas de amortização
</a>
```

**Checklist:**

- ✅ Elemento `<a>` semântico (não `<div>`)
- ✅ Texto descritivo (evitar "clique aqui")
- ✅ `href` válido (não `#` ou `javascript:void(0)`)
- ✅ Links externos indicam isso (`aria-label` ou ícone)

## 🔍 Testes de Acessibilidade

### Ferramentas Automatizadas

```bash
# Rodar testes A11y automatizados
pnpm test:a11y

# Gerar relatório completo
pnpm test:a11y:report
```

### Ferramentas Manuais

1. **axe DevTools** (extensão Chrome/Firefox)
2. **WAVE** (extensão de navegador)
3. **Lighthouse** (auditoria do Chrome DevTools)

### Testes com Leitores de Tela

- **NVDA** (Windows, gratuito)
- **JAWS** (Windows, pago)
- **VoiceOver** (macOS/iOS, nativo)
- **TalkBack** (Android, nativo)

### Testes de Teclado

1. Desconecte o mouse
2. Navegue pelo site apenas com TAB/Shift+TAB
3. Ative elementos com Enter/Espaço
4. Verifique que todos os interativos são alcançáveis

## 🚨 Violações Comuns a Evitar

### ❌ Div-itis

```tsx
// ❌ ERRADO
<div onClick={handleClick}>Clique aqui</div>

// ✅ CORRETO
<button type="button" onClick={handleClick}>
  Clique aqui
</button>
```

### ❌ Label Ausente

```tsx
// ❌ ERRADO
<input type="text" placeholder="Nome" />

// ✅ CORRETO
<label htmlFor="nome">Nome</label>
<input id="nome" type="text" placeholder="Ex: João Silva" />
```

### ❌ Contraste Baixo

```tsx
// ❌ ERRADO (cinza claro em branco = contraste 2.1:1)
<p className="text-gray-300">Texto importante</p>

// ✅ CORRETO (cinza escuro em branco = contraste 7:1)
<p className="text-gray-800">Texto importante</p>
```

### ❌ Ícone Sem Texto

```tsx
// ❌ ERRADO
<button>
  <SearchIcon />
</button>

// ✅ CORRETO
<button aria-label="Buscar">
  <SearchIcon aria-hidden="true" />
</button>
```

## 📚 Recursos

### Documentação Oficial

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)

### Ferramentas

- [axe DevTools](https://www.deque.com/axe/devtools/)
- [WAVE Browser Extension](https://wave.webaim.org/extension/)
- [Color Contrast Checker](https://webaim.org/resources/contrastchecker/)

### Cursos e Tutoriais

- [Web Accessibility by Google (Udacity)](https://www.udacity.com/course/web-accessibility--ud891)
- [A11ycasts (YouTube)](https://www.youtube.com/playlist?list=PLNYkxOF6rcICWx0C9LVWWVqvHlYJyqw7g)

## 🎓 Manutenção

Este guia deve ser atualizado sempre que:

1. Novos componentes forem criados
2. Padrões WCAG evoluírem
3. Novas ferramentas de teste surgirem
4. Feedback de usuários com deficiência for recebido

---

**Última atualização:** Sprint 4
**Responsável:** Equipe FinMath
**Revisão:** A cada sprint
