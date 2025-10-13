#!/usr/bin/env bash
set -Eeuo pipefail
REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
echo "Configurando TypeScript + deps da API…"
[ -f "$REPO/packages/api/tsconfig.json" ] || cat > "$REPO/packages/api/tsconfig.json" <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": { "outDir":"./dist","rootDir":"./src","module":"ESNext","moduleResolution":"bundler","target":"ES2022","lib":["ES2022"],"types":["node"],"esModuleInterop":true,"skipLibCheck":true,"strict":true,"resolveJsonModule":true,"declaration":true,"sourceMap":true },
  "include": ["src/**/*"], "exclude": ["node_modules","dist","test"]
}
EOF
pnpm -C "$REPO/packages/api" add -D typescript @types/node tsx vitest @vitest/ui pino-pretty
pnpm -C "$REPO/packages/api" add fastify @fastify/cors zod pino date-fns decimal.js
echo "OK"
