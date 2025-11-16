# 🚀 Guia de Configuração - FinMath no WSL/Ubuntu

> **Para**: moses@MOSES-SERVER
> **Ambiente**: WSL/Ubuntu
> **Diretório**: `~/workspace/fin-math`

## 📋 Pré-requisitos

### 1. Verificar Node.js e pnpm

```bash
# Verificar versões instaladas
node --version  # Necessário: v18+ (recomendado: v20+)
pnpm --version  # Necessário: 10.19.0

# Se não tiver Node.js, instalar via nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22

# Se não tiver pnpm, instalar:
npm install -g pnpm@10.19.0
```

### 2. Verificar Git

```bash
git --version  # Necessário: 2.0+

# Configurar se necessário:
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

## 🔧 Instalação do Projeto

### Passo 1: Clonar o repositório

```bash
# Navegar para o workspace
cd ~/workspace

# Clonar o repositório
git clone https://github.com/PrinceOfEgypt1/fin-math.git
cd fin-math

# Verificar branch (deve estar no branch principal ou claude/setup-project-repo-*)
git branch -a
git log --oneline -5
```

### Passo 2: Instalar dependências

```bash
# Instalar todas as dependências (demora ~1-2 minutos)
pnpm install

# Aguardar mensagem "Done in X.Xs"
```

**Saída esperada:**

```
Scope: all 4 workspace projects
Packages: +679
Done in 15-30s
```

### Passo 3: Build do projeto

```bash
# Compilar todos os pacotes
pnpm build
```

**Saída esperada:**

```
packages/engine build$ tsc
packages/engine build: Done
packages/api build$ tsc -p tsconfig.json
packages/api build: Done
packages/ui build$ tsc && vite build
packages/ui build: Done
```

### Passo 4: Executar testes

```bash
# Executar testes do engine
pnpm -F @finmath/engine test

# Ou todos os testes
pnpm test
```

**Saída esperada:**

```
✓ 118/118 testes passando
✓ 30/30 Golden Files validados
```

## 📂 Estrutura do Projeto

```
~/workspace/fin-math/
├── packages/
│   ├── engine/          # Motor de cálculo financeiro
│   │   ├── src/         # Código-fonte TypeScript
│   │   ├── test/        # Testes unitários
│   │   └── golden/      # Golden Files (validação)
│   ├── api/             # REST API (Fastify)
│   │   └── src/         # Controladores e rotas
│   └── ui/              # Interface React
├── .fenix/              # Sistema de governança
├── package.json         # Configuração do monorepo
└── pnpm-workspace.yaml  # Configuração de workspaces
```

## 🎯 Comandos Úteis

### Desenvolvimento

```bash
# Iniciar UI em modo desenvolvimento
pnpm dev
# Acesse: http://localhost:5173

# Iniciar API em modo desenvolvimento
pnpm dev:api
# Acesse: http://localhost:3000

# Iniciar demo HTML
pnpm dev:demo
# Acesse: http://localhost:8080
```

### Build e Testes

```bash
# Build de todos os pacotes
pnpm build

# Executar todos os testes
pnpm test

# Executar apenas Golden Files
pnpm test:golden

# Executar testes com cobertura
pnpm -F @finmath/engine test:coverage

# Executar testes E2E (Playwright)
pnpm test:e2e

# Type checking
pnpm typecheck

# Linting
pnpm lint
pnpm lint:fix
```

### Git

```bash
# Ver status
git status

# Ver commits recentes
git log --oneline -10

# Criar nova branch para desenvolvimento
git checkout -b feature/minha-feature

# Fazer commit
git add .
git commit -m "feat: minha nova feature"
```

## 🔍 Verificação da Instalação

Execute este script para verificar se tudo está funcionando:

```bash
#!/bin/bash
echo "🔍 Verificando instalação do FinMath..."
echo ""

echo "📌 Node.js: $(node --version)"
echo "📌 pnpm: $(pnpm --version)"
echo "📌 Git: $(git --version)"
echo ""

echo "📦 Verificando dependências..."
if [ -d "node_modules" ]; then
    echo "✅ node_modules encontrado"
else
    echo "❌ node_modules não encontrado - execute: pnpm install"
fi
echo ""

echo "🔨 Verificando build..."
if [ -d "packages/engine/dist" ]; then
    echo "✅ Engine compilado"
else
    echo "❌ Engine não compilado - execute: pnpm build"
fi
echo ""

echo "🧪 Executando smoke test..."
pnpm -F @finmath/engine test -- --run smoke
```

## ⚠️ Troubleshooting

### Erro: "Cannot find module '@finmath/engine'"

```bash
# Rebuild do engine
pnpm -F @finmath/engine build
```

### Erro: "ELIFECYCLE Command failed"

```bash
# Limpar cache e reinstalar
rm -rf node_modules pnpm-lock.yaml
pnpm install
pnpm build
```

### Erro de permissões

```bash
# Se encontrar erros de permissão
sudo chown -R $USER:$USER ~/workspace/fin-math
```

### Testes falhando

```bash
# Um teste pode falhar (fast-check)
# Isso é esperado - 118/119 passando é aceitável
# Para corrigir, instale fast-check:
pnpm -F @finmath/engine add -D fast-check
```

## 📚 Próximos Passos

1. ✅ Clone o repositório
2. ✅ Instale as dependências
3. ✅ Execute o build
4. ✅ Rode os testes
5. 🚀 Comece a desenvolver!

### Recursos

- **Documentação**: `README.md`
- **Changelog**: `CHANGELOG.md`
- **Arquitetura**: (se existir em docs/)
- **Issues**: https://github.com/PrinceOfEgypt1/fin-math/issues

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs de erro
2. Consulte a seção Troubleshooting acima
3. Abra uma issue no GitHub
4. Verifique o histórico de commits recentes

---

**Última atualização**: 2025-11-16
**Versão**: 0.4.0
**Status**: ✅ Ambiente validado e funcional
