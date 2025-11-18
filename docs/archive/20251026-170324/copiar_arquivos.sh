#!/bin/bash

# Define o diretório raiz do projeto
ROOT_DIR="$HOME/workspace/fin-math"
OUTPUT_FILE="$ROOT_DIR/CodigoCompletoFin-Math-$(date +'%d%m%y-%H%M%S').txt"

# Verifica se o diretório existe
if [ ! -d "$ROOT_DIR" ]; then
    echo "Erro: Diretório $ROOT_DIR não encontrado."
    exit 1
fi

# Limpa o arquivo de saída se já existir
> "$OUTPUT_FILE"

# Variáveis para controle
TOTAL_FILES=0
FILE_LIST=()

# Função para processar arquivos
process_file() {
    local file="$1"
    local relative_path="${file#$ROOT_DIR/}"
    echo "=== [$(date +'%d/%m/%Y %H:%M:%S')] $file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE" 2>/dev/null
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    ((TOTAL_FILES++))
    FILE_LIST+=("$relative_path")
}

# Função para percorrer diretórios recursivamente, ignorando pastas indesejadas
walk_dir() {
    local dir="$1"
    find "$dir" -type d \( -name ".git" -o -name "node_modules" \) -prune -o \
        -type f \( \
        -name "*.sh" -o \
        -name "*.md" -o \
        -name "*.ts" -o \
        -name "*.json" -o \
        -name "*.html" -o \
        -name "*.js" -o \
        -name "*.cjs" -o \
        -name "*.css" -o \
        -name "*.yaml" -o \
        -name "*.txt" -o \
        -name "*.pdf" -o \
        -name "*.csv" \) -print | while read -r file; do
            echo "Arquivo encontrado: $file"  # Debug: Mostra cada arquivo encontrado
            process_file "$file"
        done
}

# Inicia o processamento a partir da raiz do projeto
walk_dir "$ROOT_DIR"

# Exibe o resumo
echo "=== RESUMO DA EXECUÇÃO ==="
echo "Arquivo de saída: $OUTPUT_FILE"
echo "Total de arquivos copiados: $TOTAL_FILES"
echo ""
echo "Lista de arquivos copiados:"
for file in "${FILE_LIST[@]}"; do
    echo "- $file"
done
