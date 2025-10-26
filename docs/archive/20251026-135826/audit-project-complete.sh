#!/bin/bash

# ==========================================
# AUDITORIA COMPLETA DO PROJETO FINMATH
# ==========================================

set -e

echo "🔍 AUDITORIA COMPLETA DO PROJETO FINMATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 1. ESTRUTURA DO PROJETO
# ==========================================

echo "📁 1. ESTRUTURA DO PROJETO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d ".git" ]; then
    echo "✅ Repositório Git encontrado"
    echo ""
    echo "🌐 URL do repositório remoto:"
    git remote -v || echo "Sem remote configurado"
    echo ""
else
    echo "⚠️  Não é um repositório Git"
fi

echo "📦 Estrutura de diretórios:"
tree -L 2 -I 'node_modules|dist|.next|.turbo' --dirsfirst

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 2. HISTÓRICO DE COMMITS
# ==========================================

echo "📜 2. HISTÓRICO DE COMMITS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d ".git" ]; then
    TOTAL_COMMITS=$(git rev-list --count HEAD)
    echo "📊 Total de commits: $TOTAL_COMMITS"
    echo ""
    
    echo "🔍 Últimos 20 commits:"
    git log --oneline --graph --decorate -20
    echo ""
    
    echo "📅 Primeiro commit:"
    git log --reverse --format="%h - %an - %ad - %s" --date=short | head -1
    echo ""
    
    echo "📅 Último commit:"
    git log --format="%h - %an - %ad - %s" --date=short -1
    echo ""
else
    echo "⚠️  Sem histórico Git disponível"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 3. DOCUMENTAÇÃO EXISTENTE
# ==========================================

echo "📚 3. DOCUMENTAÇÃO EXISTENTE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📄 Arquivos principais:"
ls -lh README.md CHANGELOG.md 2>/dev/null || echo "Arquivos principais não encontrados"
echo ""

echo "📁 Estrutura de docs/:"
if [ -d "docs" ]; then
    find docs -type f -name "*.md" | head -30
    echo ""
    echo "Total de arquivos .md: $(find docs -type f -name "*.md" | wc -l)"
else
    echo "⚠️  Diretório docs/ não encontrado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 4. HISTÓRIAS DE USUÁRIO
# ==========================================

echo "📋 4. HISTÓRIAS DE USUÁRIO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d "docs/historias-usuario" ]; then
    echo "📁 HUs encontradas:"
    ls -1 docs/historias-usuario/HU-*.md 2>/dev/null | while read file; do
        TITLE=$(grep "^# HU-" "$file" | head -1)
        STATUS=$(grep -A1 "Status:" "$file" | grep -E "(Implementado|Planejada|Andamento)" | head -1)
        echo "  • $(basename $file): $TITLE"
        echo "    Status: $STATUS"
    done
    echo ""
    echo "Total de HUs: $(ls -1 docs/historias-usuario/HU-*.md 2>/dev/null | wc -l)"
else
    echo "⚠️  Diretório historias-usuario não encontrado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 5. CÓDIGO IMPLEMENTADO
# ==========================================

echo "💻 5. CÓDIGO IMPLEMENTADO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔧 Engine (packages/engine/):"
if [ -d "packages/engine/src" ]; then
    echo "Estrutura:"
    tree packages/engine/src -L 2 -I 'node_modules|dist'
    echo ""
    echo "Módulos principais:"
    find packages/engine/src -type f -name "*.ts" | grep -E "(price|sac|cet|amortization)" | head -10
else
    echo "⚠️  Engine não encontrado"
fi

echo ""

echo "🎨 UI (packages/ui/):"
if [ -d "packages/ui/src" ]; then
    echo "Páginas/Simuladores:"
    find packages/ui/src/pages -type f -name "*.tsx" 2>/dev/null || echo "Sem páginas"
    echo ""
    echo "Componentes principais:"
    find packages/ui/src/components -type f -name "*.tsx" 2>/dev/null | head -10
else
    echo "⚠️  UI não encontrado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 6. SPRINTS E PLANEJAMENTO
# ==========================================

echo "🏃 6. SPRINTS E PLANEJAMENTO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d "docs/sprint-planning" ]; then
    echo "📁 Arquivos de sprint planning:"
    ls -1 docs/sprint-planning/*.md 2>/dev/null
    echo ""
elif [ -f "docs/SPRINTS_AND_HUS.md" ]; then
    echo "📄 Encontrado: docs/SPRINTS_AND_HUS.md"
    echo ""
    echo "Conteúdo relevante:"
    grep -E "(Sprint|HU-)" docs/SPRINTS_AND_HUS.md | head -30
else
    echo "⚠️  Sem documentação de sprints"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 7. PACKAGE.JSON - VERSÕES E DEPENDÊNCIAS
# ==========================================

echo "📦 7. VERSÕES E DEPENDÊNCIAS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "package.json" ]; then
    echo "📄 package.json (raiz):"
    cat package.json | jq '{name, version, workspaces}' 2>/dev/null || grep -E '(name|version)' package.json
fi

echo ""

if [ -f "packages/engine/package.json" ]; then
    echo "🔧 Engine version:"
    cat packages/engine/package.json | jq '{name, version}' 2>/dev/null || grep -E '(name|version)' packages/engine/package.json
fi

echo ""

if [ -f "packages/ui/package.json" ]; then
    echo "🎨 UI version:"
    cat packages/ui/package.json | jq '{name, version}' 2>/dev/null || grep -E '(name|version)' packages/ui/package.json
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 8. TESTES
# ==========================================

echo "🧪 8. TESTES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Engine tests:"
find packages/engine/test -type f -name "*.test.ts" 2>/dev/null | wc -l | xargs echo "Arquivos de teste:"

echo ""

echo "UI tests:"
find packages/ui/test -type f -name "*.test.tsx" -o -name "*.spec.ts" 2>/dev/null | wc -l | xargs echo "Arquivos de teste:"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 9. ANÁLISE DE SPRINTS (do docs/)
# ==========================================

echo "🔍 9. ANÁLISE DETALHADA DE SPRINTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "docs/SPRINTS_AND_HUS.md" ]; then
    echo "📊 Analisando docs/SPRINTS_AND_HUS.md..."
    echo ""
    
    # Extrair informações de sprints
    awk '/^##.*Sprint/ {print; getline; print; getline; print}' docs/SPRINTS_AND_HUS.md | head -50
else
    echo "⚠️  Arquivo SPRINTS_AND_HUS.md não encontrado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 10. RESUMO EXECUTIVO
# ==========================================

echo "📊 10. RESUMO EXECUTIVO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Pacotes encontrados:"
ls -d packages/* 2>/dev/null | wc -l | xargs echo "  •"

echo ""

echo "Linhas de código:"
echo "  • Engine (TypeScript):"
find packages/engine/src -name "*.ts" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print "    " $1 " linhas"}'
echo "  • UI (TypeScript/React):"
find packages/ui/src -name "*.tsx" -o -name "*.ts" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print "    " $1 " linhas"}'

echo ""

echo "Documentação:"
find docs -name "*.md" 2>/dev/null | wc -l | xargs echo "  • Arquivos markdown:"

echo ""

if [ -d ".git" ]; then
    echo "Git:"
    git rev-list --count HEAD | xargs echo "  • Commits:"
    git log --format=%an | sort -u | wc -l | xargs echo "  • Contribuidores:"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 11. VERIFICAR GITHUB
# ==========================================

echo "🌐 11. INFORMAÇÕES DO GITHUB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d ".git" ]; then
    REMOTE_URL=$(git config --get remote.origin.url)
    
    if [ ! -z "$REMOTE_URL" ]; then
        echo "✅ Repositório remoto configurado:"
        echo "   $REMOTE_URL"
        echo ""
        
        # Extrair owner e repo do GitHub
        if [[ $REMOTE_URL =~ github.com[:/]([^/]+)/([^/\.]+) ]]; then
            OWNER="${BASH_REMATCH[1]}"
            REPO="${BASH_REMATCH[2]}"
            
            echo "📦 Repositório GitHub:"
            echo "   Owner: $OWNER"
            echo "   Repo: $REPO"
            echo "   URL: https://github.com/$OWNER/$REPO"
            echo ""
            
            echo "💡 Para ver online:"
            echo "   • Código: https://github.com/$OWNER/$REPO"
            echo "   • Issues: https://github.com/$OWNER/$REPO/issues"
            echo "   • Projects: https://github.com/$OWNER/$REPO/projects"
            echo ""
        fi
        
        echo "📊 Status do Git:"
        echo "   Branch atual: $(git branch --show-current)"
        echo "   Último push: $(git log origin/$(git branch --show-current) --format="%ar" -1 2>/dev/null || echo 'Nunca')"
    else
        echo "⚠️  Sem remote configurado"
    fi
else
    echo "⚠️  Não é um repositório Git"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "✅ AUDITORIA COMPLETA FINALIZADA!"
echo ""
echo "📋 Próximos passos:"
echo "  1. Analisar o output acima"
echo "  2. Identificar gaps de documentação"
echo "  3. Definir status real das sprints"
echo ""

