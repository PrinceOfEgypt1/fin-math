#!/bin/bash
# ============================================
# SCRIPT: criar-arquivo-ts.sh
# OBJETIVO: Criar arquivos TypeScript com segurança
# USO: ./criar-arquivo-ts.sh caminho/para/arquivo.ts
# ============================================

set -e

# Validar argumentos
if [ $# -eq 0 ]; then
    echo "❌ Erro: Nenhum arquivo especificado"
    echo "Uso: ./criar-arquivo-ts.sh caminho/para/arquivo.ts"
    exit 1
fi

ARQUIVO=$1

# Verificar se arquivo já existe
if [ -f "$ARQUIVO" ]; then
    echo "⚠️  Arquivo já existe: $ARQUIVO"
    read -p "Deseja editar? (s/n): " RESPOSTA
    if [ "$RESPOSTA" != "s" ]; then
        echo "❌ Operação cancelada"
        exit 0
    fi
fi

# Criar diretórios se necessário
DIR=$(dirname "$ARQUIVO")
if [ ! -d "$DIR" ]; then
    echo "📁 Criando diretório: $DIR"
    mkdir -p "$DIR"
fi

# Abrir nano
echo "📝 Abrindo editor para: $ARQUIVO"
echo "   💡 Dica: Ctrl+O = Salvar | Ctrl+X = Sair"
echo ""
nano "$ARQUIVO"

# Verificar se foi criado
if [ ! -f "$ARQUIVO" ]; then
    echo "❌ Arquivo não foi salvo"
    exit 1
fi

# Verificar tamanho
LINHAS=$(wc -l < "$ARQUIVO")
TAMANHO=$(du -h "$ARQUIVO" | cut -f1)

echo ""
echo "✅ Arquivo criado com sucesso!"
echo "   📏 Linhas: $LINHAS"
echo "   💾 Tamanho: $TAMANHO"

# Verificar sintaxe TypeScript se tiver extensão .ts
if [[ "$ARQUIVO" == *.ts ]]; then
    echo ""
    echo "🔍 Verificando sintaxe TypeScript..."
    
    # Extrair diretório do package
    if [[ "$ARQUIVO" == packages/engine/* ]]; then
        cd packages/engine
        pnpm typecheck > /dev/null 2>&1
        RESULT=$?
        cd ../..
    elif [[ "$ARQUIVO" == packages/api/* ]]; then
        cd packages/api
        pnpm typecheck > /dev/null 2>&1
        RESULT=$?
        cd ../..
    else
        echo "   ⚠️  Não foi possível verificar (arquivo fora de packages/)"
        exit 0
    fi
    
    if [ $RESULT -eq 0 ]; then
        echo "   ✅ Sintaxe válida!"
    else
        echo "   ❌ Erros de TypeScript encontrados"
        echo "   Execute manualmente: cd packages/[engine|api] && pnpm typecheck"
        exit 1
    fi
fi

echo ""
echo "🎯 Próximos passos:"
echo "   1. Criar testes (se aplicável)"
echo "   2. Executar: pnpm test"
echo "   3. Commit: git add $ARQUIVO && git commit -m 'feat: ...'"

