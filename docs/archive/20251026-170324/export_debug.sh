#!/usr/bin/env bash
set -euo pipefail

# Vai pra raiz do repo, se possível
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

OUT="_debug_api_core.tgz"
TMP="$(mktemp)"

# Lista alvo (inclui só os que existirem)
files=(
  packages/engine/src/index.ts
  packages/engine/dist/index.d.ts
  packages/engine/package.json
  packages/api/package.json
  packages/api/tsconfig.json
  packages/api/src/server.ts
  packages/api/src/controllers/irr.controller.ts
  packages/api/src/controllers/comparador.controller.ts
  packages/api/src/controllers/perfis.controller.ts
  packages/api/src/controllers/xlsx-export.controller.ts
  packages/api/src/services/comparador.service.ts
  packages/api/src/routes/irr.routes.ts
  packages/api/src/routes/perfis.routes.ts
  packages/api/src/routes/comparador.routes.ts
  packages/api/test/integration/irr.test.ts
  packages/api/test/integration/infrastructure.test.ts
  packages/api/openapi.yaml
  packages/api/openapi.json
  packages/api/src/swagger.ts
  package.json
  00_validacao_completa.sh
)

# Filtra os que existem e guarda numa lista \0-separada (evita problemas com espaços)
> "$TMP"
for f in "${files[@]}"; do
  if [ -e "$f" ]; then
    printf '%s\0' "$f" >> "$TMP"
  fi
done

if [ ! -s "$TMP" ]; then
  echo "Nenhum dos arquivos alvo foi encontrado. Confira os caminhos." >&2
  exit 1
fi

# Cria o TGZ em UMA passada
tar --null -czf "$OUT" --files-from="$TMP"

rm -f "$TMP"

echo "✅ Gerado: $OUT"
ls -lh -- "$OUT"
