#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [ $# -lt 1 ]; then
  echo "Uso: $0 <caminho_backup_dir>"
  exit 1
fi

BACKUP_DIR="$1"
MANIFEST="${BACKUP_DIR}/manifest.txt"
if [ ! -f "$MANIFEST" ]; then
  echo "Manifesto não encontrado: $MANIFEST"
  exit 1
fi

cd "$ROOT"
echo "↩️  Restaurando de: $BACKUP_DIR"
while IFS= read -r rel; do
  if [ -f "$BACKUP_DIR/$rel" ]; then
    mkdir -p "$(dirname "$rel")"
    cp -f "$BACKUP_DIR/$rel" "$rel"
    echo "✔️  Restaurado: $rel"
  else
    echo "⚠️  Ausente no backup: $rel"
  fi
done < "$MANIFEST"

echo "✅ Rollback concluído."
