#!/usr/bin/env bash
set -euo pipefail

# ==== Config ====
ROOT_NAME="finmath"
ORG="@finmath"
NODE_LTS="lts/*"
PNPM_VERSION="8.15.4"   # ajustável
YEAR=$(date +%Y)

# ==== Helpers ====
write_if_absent () {
  local path="$1"; shift
  if [ -e "$path" ]; then
    echo "skip  : $path (já existe)"
  else
    echo "write : $path"
    mkdir -p "$(dirname "$path")"
    cat > "$path" <<'EOF'
'"$@"'
EOF
  fi
}

echo "==> FinMath bootstrap em $(pwd)"

# ==== 0) Dependências de sistema (Ubuntu) ====
echo "==> Instalando pacotes do sistema (sudo será solicitado, WSL ok)"
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  ca-certificates curl git build-essential unzip

# ==== 1) Node LTS + pnpm ====
if ! command -v node >/dev/null 2>&1; then
  echo "==> Instalando nvm + Node LTS"
  export NVM_DIR="$HOME/.nvm"
  if [ ! -d "$NVM_DIR" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  nvm install "$NODE_LTS"
  nvm alias default "$NODE_LTS"
else
  echo "==> Node já instalado: $(node -v)"
fi

# Use corepack para pnpm
if ! command -v pnpm >/dev/null 2>&1; then
  echo "==> Ativando corepack e pnpm@$PNPM_VERSION"
  corepack enable
  corepack prepare "pnpm@${PNPM_VERSION}" --activate
else
  echo "==> pnpm já instalado: $(pnpm -v)"
fi

# ==== 2) Estrutura de pastas ====
echo "==> Criando estrutura de diretórios"
mkdir -p packages/engine/{src,test,types,golden/sprint1,golden/sprint2,golden/sprint3}
mkdir -p packages/api/{src/{routes,lib,middleware},test,openapi}
mkdir -p packages/ui/src/{components,screens}
mkdir -p packages/ui/public
mkdir -p docs/{vision-plan,backlog,boards,cet-sot,qa-playbook,design-system,api-contracts,adrs,glossary,profiles-diffs}
mkdir -p prototypes
mkdir -p tools/scripts
mkdir -p .husky

# ==== 3) Arquivos de config (root) ====
echo "==> Configurando monorepo pnpm + TS + lint"

# package.json (root)
cat > package.json <<EOF
{
  "name": "${ROOT_NAME}",
  "private": true,
  "version": "1.0.0",
  "packageManager": "pnpm@${PNPM_VERSION}",
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "build": "pnpm -r --filter ./packages... run build",
    "dev:api": "pnpm --filter ${ORG}/api run dev",
    "dev:ui": "pnpm --filter ${ORG}/ui run dev",
    "test": "pnpm -r --filter ./packages... test",
    "lint": "pnpm -r --filter ./packages... lint",
    "typecheck": "pnpm -r --filter ./packages... run typecheck",
    "prepare": "husky install"
  },
  "devDependencies": {
    "eslint": "^9.9.0",
    "eslint-config-standard-with-typescript": "^43.0.0",
    "eslint-plugin-import": "^2.29.1",
    "eslint-plugin-n": "^17.9.0",
    "eslint-plugin-promise": "^6.4.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.2.2",
    "prettier": "^3.3.3",
    "typescript": "^5.6.3"
  },
  "lint-staged": {
    "**/*.{ts,tsx,js,jsx,json,md,css}": [
      "prettier --write"
    ]
  }
}
EOF

# tsconfig base
cat > tsconfig.base.json <<'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
EOF

# .gitignore
cat > .gitignore <<'EOF'
node_modules
dist
coverage
*.log
.env
*.local
pnpm-lock.yaml
.vscode
.DS_Store
EOF

# .editorconfig
cat > .editorconfig <<'EOF'
root = true
[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true
EOF

# ==== 4) Pacote ENGINE ====
cat > packages/engine/package.json <<EOF
{
  "name": "${ORG}/engine",
  "version": "0.1.0",
  "type": "module",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc -p tsconfig.json",
    "typecheck": "tsc -p tsconfig.json --noEmit",
    "test": "vitest run",
    "lint": "eslint ."
  },
  "dependencies": {
    "decimal.js": "^10.4.3",
    "zod": "^3.23.8",
    "date-fns": "^4.1.0"
  },
  "devDependencies": {
    "@types/node": "^22.7.5",
    "fast-check": "^3.18.0",
    "vitest": "^1.6.0",
    "typescript": "^5.6.3"
  }
}
EOF

cat > packages/engine/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist"
  },
  "include": ["src/**/*", "types/**/*", "test/**/*"]
}
EOF

# Módulos do motor (stubs) + índice
cat > packages/engine/src/index.ts <<'EOF'
export * as interest from "./modules/interest";
export * as rate from "./modules/rate";
export * as series from "./modules/series";
export * as amortization from "./modules/amortization";
export * as irr from "./modules/irr";
export * as cet from "./modules/cet";
export * as daycount from "./modules/daycount";
export { round2 } from "./util/round";
EOF

mkdir -p packages/engine/src/modules packages/engine/src/util

cat > packages/engine/src/util/round.ts <<'EOF'
import Decimal from "decimal.js";
Decimal.set({ precision: 40, rounding: Decimal.ROUND_HALF_UP });
export const d = (v: number | string) => new Decimal(v);
export const round2 = (x: Decimal | number | string) =>
  new Decimal(x).toDecimalPlaces(2, Decimal.ROUND_HALF_UP);
EOF

cat > packages/engine/src/modules/interest.ts <<'EOF'
import { d, round2 } from "../util/round";
export function fv(pv: string | number, i: string | number, n: number){
  return round2(d(pv).mul(d(1).add(d(i)).pow(n)));
}
export function pv(fv: string | number, i: string | number, n: number){
  return round2(d(fv).div(d(1).add(d(i)).pow(n)));
}
EOF

cat > packages/engine/src/modules/rate.ts <<'EOF'
import { d } from "../util/round";
export const monthlyToAnnual = (im: string | number) => d(1).add(d(im)).pow(12).minus(1);
export const annualToMonthly = (ia: string | number) => d(1).add(d(ia)).pow(d(1).div(12)).minus(1);
EOF

cat > packages/engine/src/modules/series.ts <<'EOF'
import { d, round2 } from "../util/round";
export function pmt(pv: string|number, i: string|number, n: number, due = false){
  const I = d(i), PV = d(pv);
  if (I.isZero()) return round2(PV.div(n));
  const a = I.plus(1).pow(n).minus(1).div(I);
  let p = PV.div(a);
  if (due) p = p.div(I.plus(1));
  return round2(p);
}
EOF

cat > packages/engine/src/modules/amortization.ts <<'EOF'
import { d, round2 } from "../util/round";
import { pmt as pmtSeries } from "./series";

export function price(pv: string|number, i: string|number, n: number){
  const PMT = round2(pmtSeries(pv, i, n)).toNumber();
  let bal = d(pv);
  const rows: Array<{k:number,pmt:number,interest:number,amort:number,balance:number}> = [];
  for(let k=1;k<=n;k++){
    const interest = round2(bal.mul(i)).toNumber();
    let amort = round2(PMT - interest).toNumber();
    if (k===n) amort = round2(bal).toNumber();
    const newBal = round2(bal.minus(amort)).toNumber();
    rows.push({k,pmt:PMT,interest,amort,balance:newBal});
    bal = d(newBal);
  }
  const total = rows.reduce((s,r)=>s+r.pmt,0);
  const juros = total - d(pv).toNumber();
  return { pmt: PMT, rows, totalPaid: round2(total).toNumber(), totalInterest: round2(juros).toNumber() };
}

export function sac(pv: string|number, i: string|number, n: number){
  let bal = d(pv);
  const amortConst = round2(bal.div(n)).toNumber();
  const rows: Array<{k:number,pmt:number,interest:number,amort:number,balance:number}> = [];
  for(let k=1;k<=n;k++){
    const interest = round2(bal.mul(i)).toNumber();
    let amort = (k===n) ? round2(bal).toNumber() : amortConst;
    const pmt = round2(interest + amort).toNumber();
    const newBal = round2(bal.minus(amort)).toNumber();
    rows.push({k,pmt,interest,amort,balance:newBal});
    bal = d(newBal);
  }
  const total = rows.reduce((s,r)=>s+r.pmt,0);
  const juros = total - d(pv).toNumber();
  return { amortConst, rows, totalPaid: round2(total).toNumber(), totalInterest: round2(juros).toNumber() };
}
EOF

cat > packages/engine/src/modules/irr.ts <<'EOF'
import { d } from "../util/round";
export function npv(r: number|string, cfs: Array<string|number>){
  const R = d(r);
  return cfs.reduce((s, cf, t)=> s.plus(d(cf).div(d(1).add(R).pow(t))), d(0));
}
export function irrBisection(cfs: Array<string|number>, lo=0, hi=1){
  let fLo = npv(lo, cfs), fHi = npv(hi, cfs);
  let tries = 0;
  while(fLo.mul(fHi).gt(0) && hi < 10 && tries < 30){
    hi *= 1.5; fHi = npv(hi, cfs); tries++;
  }
  if (fLo.mul(fHi).gt(0)) return null;
  for(let k=0;k<120;k++){
    const mid = (lo+hi)/2, fMid = npv(mid, cfs);
    if (fMid.abs().lt(1e-12)) return mid;
    if (fLo.mul(fMid).lt(0)){ hi = mid; fHi = fMid; } else { lo = mid; fLo = fMid; }
  }
  return (lo+hi)/2;
}
EOF

cat > packages/engine/src/modules/cet.ts <<'EOF'
import { irrBisection } from "./irr";
export function cetBasic(pv: number|string, pmt: number|string, n: number, feesT0: Array<number|string> = [], baseAnnual = 12){
  const fees = feesT0.reduce((s,v)=> s + Number(v), 0);
  const cfs = [Number(pv) - fees, ...Array.from({length:n}, () => -Number(pmt))];
  const irr = irrBisection(cfs) ?? 0;
  const cetAnnual = Math.pow(1+irr, baseAnnual) - 1;
  return { irrMonthly: irr, cetAnnual, cashflows: cfs };
}
EOF

cat > packages/engine/src/modules/daycount.ts <<'EOF'
export type DayCount = "30360" | "ACT365";
export function prorataFactor(date0: Date, date1: Date, dc: DayCount){
  const ms = date1.getTime() - date0.getTime();
  const days = Math.max(0, Math.round(ms/86400000));
  return dc === "30360" ? Math.min(30, days)/30 : days/365;
}
EOF

# Vitest config (opcional via package.json)

# ==== 5) Pacote API (Fastify) ====
cat > packages/api/package.json <<EOF
{
  "name": "${ORG}/api",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc -p tsconfig.json",
    "typecheck": "tsc -p tsconfig.json --noEmit",
    "lint": "eslint ."
  },
  "dependencies": {
    "${ORG}/engine": "workspace:*",
    "fastify": "^4.28.1",
    "@fastify/cors": "^10.0.0",
    "pino": "^9.3.2",
    "zod": "^3.23.8"
  },
  "devDependencies": {
    "@types/node": "^22.7.5",
    "tsx": "^4.19.0",
    "typescript": "^5.6.3"
  }
}
EOF

cat > packages/api/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": { "outDir": "dist" },
  "include": ["src/**/*", "test/**/*"]
}
EOF

cat > packages/api/src/index.ts <<'EOF'
import Fastify from "fastify";
import cors from "@fastify/cors";
import { routes } from "./routes";
const app = Fastify({ logger: true });
await app.register(cors, { origin: true });
await app.register(routes, { prefix: "/v1/api" });
const port = Number(process.env.PORT || 3000);
app.listen({ port, host: "0.0.0.0" }).then(()=> {
  app.log.info(`FinMath API rodando em http://localhost:${port}/v1/api`);
});
EOF

cat > packages/api/src/routes/index.ts <<'EOF'
import { FastifyPluginAsync } from "fastify";
import * as engine from "@finmath/engine";
import { z } from "zod";

export const routes: FastifyPluginAsync = async (app) => {

  app.get("/health", async () => ({ ok: true, ts: Date.now(), motorVersion: "0.1.0" }));

  app.post("/price", async (req, reply) => {
    const schema = z.object({ pv: z.number(), rateMonthly: z.number(), n: z.number().int().positive() });
    const { pv, rateMonthly, n } = schema.parse(req.body);
    const out = engine.amortization.price(pv, rateMonthly, n);
    return { data: out, meta: { motorVersion: "0.1.0" } };
  });

  app.post("/sac", async (req, reply) => {
    const schema = z.object({ pv: z.number(), rateMonthly: z.number(), n: z.number().int().positive() });
    const { pv, rateMonthly, n } = schema.parse(req.body);
    const out = engine.amortization.sac(pv, rateMonthly, n);
    return { data: out, meta: { motorVersion: "0.1.0" } };
  });

  app.post("/npv-irr", async (req, reply) => {
    const schema = z.object({ cashflows: z.array(z.number()), baseAnnual: z.number().default(12) });
    const { cashflows, baseAnnual } = schema.parse(req.body);
    const irr = engine.irr.irrBisection(cashflows) ?? 0;
    const cetAnnual = Math.pow(1+irr, baseAnnual) - 1;
    return { data: { irrMonthly: irr, cetAnnual }, meta: { motorVersion: "0.1.0" } };
  });

  app.post("/cet/basic", async (req, reply) => {
    const schema = z.object({
      pv: z.number(), pmt: z.number(), n: z.number().int().positive(),
      feesT0: z.array(z.number()).optional()
    });
    const { pv, pmt, n, feesT0 } = schema.parse(req.body);
    const out = engine.cet.cetBasic(pv, pmt, n, feesT0 ?? []);
    return { data: out, meta: { motorVersion: "0.1.0" } };
  });

};
EOF

# ==== 6) Pacote UI (Vite + React + TS + Tailwind) ====
cat > packages/ui/package.json <<EOF
{
  "name": "${ORG}/ui",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint ."
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.47",
    "tailwindcss": "^3.4.12",
    "typescript": "^5.6.3",
    "vite": "^5.4.9"
  }
}
EOF

cat > packages/ui/index.html <<'EOF'
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>FinMath UI</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat > packages/ui/postcss.config.js <<'EOF'
export default { plugins: { tailwindcss: {}, autoprefixer: {} } }
EOF

cat > packages/ui/tailwind.config.js <<'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html","./src/**/*.{ts,tsx}"],
  theme: { extend: {} },
  plugins: [],
}
EOF

cat > packages/ui/src/main.tsx <<'EOF'
import React from "react";
import { createRoot } from "react-dom/client";
import "./styles.css";
import App from "./screens/App";
createRoot(document.getElementById("root")!).render(<App />);
EOF

cat > packages/ui/src/styles.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
:root{ color-scheme: dark; }
body{ @apply bg-slate-900 text-slate-100; }
EOF

cat > packages/ui/src/screens/App.tsx <<'EOF'
import React, { useState } from "react";

export default function App(){
  const [pv, setPv] = useState(10000);
  const [rate, setRate] = useState(0.025);
  const [n, setN] = useState(12);
  const [pmt, setPmt] = useState<number|undefined>();

  function calc(){
    const a = Math.pow(1+rate, n);
    const p = pv * (rate*a)/(a-1);
    setPmt(Math.round(p*100)/100);
  }

  return (
    <div className="max-w-3xl mx-auto p-6">
      <h1 className="text-xl font-semibold">FinMath — Simulador Price (stub)</h1>
      <div className="grid grid-cols-3 gap-3 mt-4">
        <label className="text-sm">PV (R$)
          <input className="w-full mt-1 px-2 py-1 bg-slate-800 rounded" type="number" value={pv} onChange={e=>setPv(Number(e.target.value))}/>
        </label>
        <label className="text-sm">i (% a.m.)
          <input className="w-full mt-1 px-2 py-1 bg-slate-800 rounded" type="number" step="0.0001" value={rate*100} onChange={e=>setRate(Number(e.target.value)/100)}/>
        </label>
        <label className="text-sm">n (meses)
          <input className="w-full mt-1 px-2 py-1 bg-slate-800 rounded" type="number" value={n} onChange={e=>setN(Number(e.target.value))}/>
        </label>
      </div>
      <button className="mt-4 px-3 py-2 rounded bg-cyan-500 text-slate-900 font-semibold" onClick={calc}>Calcular</button>
      <div className="mt-4">PMT: <b>{pmt?.toFixed(2) ?? "—"}</b></div>
    </div>
  );
}
EOF

cat > packages/ui/vite.config.ts <<'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
export default defineConfig({ plugins: [react()], server: { port: 5173, host: true } });
EOF

# ==== 7) OpenAPI placeholder (linká-lo ao seu arquivo SoT depois) ====
cat > packages/api/openapi/finmath-v1.yaml <<'EOF'
openapi: 3.1.0
info:
  title: FinMath API
  version: "1.0.0"
paths:
  /v1/api/price:
    post:
      summary: Simulador Price
      responses: { "200": { description: OK } }
  /v1/api/sac:
    post:
      summary: Simulador SAC
      responses: { "200": { description: OK } }
  /v1/api/npv-irr:
    post:
      summary: NPV/IRR (solver)
      responses: { "200": { description: OK } }
  /v1/api/cet/basic:
    post:
      summary: CET básico
      responses: { "200": { description: OK } }
EOF

# ==== 8) Git init + Husky (prettier em staged) ====
if [ ! -d .git ]; then
  echo "==> Inicializando git"
  git init
fi
pnpm install
npx --yes husky init > /dev/null
echo 'npx --yes lint-staged' > .husky/pre-commit
chmod +x .husky/pre-commit

echo "==> Tudo pronto!"
echo "Comandos úteis:"
echo "  pnpm dev:api   # inicia API (http://localhost:3000/v1/api/health)"
echo "  pnpm dev:ui    # inicia UI (http://localhost:5173)"
echo "  pnpm test      # roda testes de todos os pacotes"
echo "  pnpm build     # compila engine/api/ui"
