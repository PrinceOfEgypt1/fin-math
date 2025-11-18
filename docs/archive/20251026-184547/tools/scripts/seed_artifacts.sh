#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   bash tools/scripts/seed_artifacts.sh <GF_ZIP> <CET_ZIP>
# Exemplo:
#   bash tools/scripts/seed_artifacts.sh "/mnt/c/Users/MOSES/Downloads/finmath_gf_starter_pack_v1.zip" "/mnt/c/Users/MOSES/Downloads/finmath_cet_cenarios_gabaritados_v1.zip"

# Executar a partir da raiz do repositório.
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GF_ZIP="${1:-}"
CET_ZIP="${2:-}"

GF_DEST="$ROOT_DIR/packages/engine/golden/starter"
CET_DEST="$ROOT_DIR/docs/cet-sot/evidences/v1"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Falta dependência: $1"; exit 1; }; }

echo "==> Verificando dependências…"
need unzip

if [[ -z "$GF_ZIP" || -z "$CET_ZIP" ]]; then
  echo "Uso: bash tools/scripts/seed_artifacts.sh <GF_ZIP> <CET_ZIP>"
  exit 1
fi

if [[ ! -f "$GF_ZIP" ]]; then echo "Arquivo não encontrado: $GF_ZIP"; exit 1; fi
if [[ ! -f "$CET_ZIP" ]]; then echo "Arquivo não encontrado: $CET_ZIP"; exit 1; fi

mkdir -p "$GF_DEST" "$CET_DEST"

echo "==> Extraindo Golden Files → $GF_DEST"
tmp_gf="$(mktemp -d)"
unzip -q "$GF_ZIP" -d "$tmp_gf"
mapfile -t gf_list < <(find "$tmp_gf" -type f -name '*.json')
if ((${#gf_list[@]}==0)); then
  echo "Nenhum .json encontrado no pacote de Golden Files"; exit 1
fi
cp -f "${gf_list[@]}" "$GF_DEST"/
echo "   • ${#gf_list[@]} arquivos copiados"

echo "==> Extraindo Cenários CET → $CET_DEST"
tmp_cet="$(mktemp -d)"
unzip -q "$CET_ZIP" -d "$tmp_cet"
for d in "$tmp_cet"/*; do
  [[ -d "$d" ]] || continue
  base="$(basename "$d")"
  mkdir -p "$CET_DEST/$base"
  cp -f "$d"/* "$CET_DEST/$base"/ || true
done

echo "==> Concluído."
echo "Golden Files em: $GF_DEST"
echo "Cenários CET em: $CET_DEST"
