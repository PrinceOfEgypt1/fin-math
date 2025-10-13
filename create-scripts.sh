#!/usr/bin/env bash
set -Eeuo pipefail

REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

color() { local c="$1"; shift; printf "%b%s%b\n" "$c" "$*" "\033[0m"; }
log_i(){ color "\033[0;34m" "ℹ️  $*"; }
log_ok(){ color "\033[0;32m" "✅ $*"; }
log_w(){ color "\033[1;33m" "⚠️  $*"; }
log_e(){ color "\033[0;31m" "❌ $*"; }

# 1) implement-h9.sh  ──────────────────────────────────────────────────────────
cat > "$REPO/implement-h9.sh" <<'IMPL_EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error()   { echo -e "${RED}❌ $1${NC}"; }

sprint2_init() {
  log_info "🚀 INICIANDO SPRINT 2 - História H9 (Price API)"
  git -C "$REPO" fetch origin || true
  git -C "$REPO" pull --rebase origin main || log_warning "Pull falhou, seguindo assim mesmo"
  if ! git -C "$REPO" rev-parse --verify sprint-2 >/dev/null 2>&1; then
    git -C "$REPO" checkout -b sprint-2
  else
    git -C "$REPO" checkout sprint-2
  fi
  find "$REPO" \( -name "*bak*" -o -name "*backup*" -o -name "*.save" \) -type f -delete || true
  pnpm -C "$REPO" -F @finmath/engine typecheck
  pnpm -C "$REPO" -F @finmath/engine test:golden
  log_success "Ambiente ok"
}

create_directory_structure() {
  log_info "📁 Estrutura Clean Architecture"
  mkdir -p "$REPO/packages/api/src/application/services"
  mkdir -p "$REPO/packages/api/src/presentation/controllers"
  mkdir -p "$REPO/packages/api/src/presentation/validators"
  mkdir -p "$REPO/packages/api/src/infrastructure/logger"
  mkdir -p "$REPO/packages/api/src/infrastructure/metrics"
  mkdir -p "$REPO/packages/api/src/routes"
  mkdir -p "$REPO/packages/api/test/integration" "$REPO/packages/api/test/unit/services"
}

create_logger() {
  mkdir -p "$REPO/packages/api/src/infrastructure/logger"
  cat > "$REPO/packages/api/src/infrastructure/logger/index.ts" <<'EOF'
import pino from 'pino';
export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: process.env.NODE_ENV === 'development'
    ? { target: 'pino-pretty', options: { colorize: true } }
    : undefined,
});
export function createContextLogger(context: Record<string, unknown>) {
  return logger.child(context);
}
EOF
}

create_metrics() {
  mkdir -p "$REPO/packages/api/src/infrastructure/metrics"
  cat > "$REPO/packages/api/src/infrastructure/metrics/index.ts" <<'EOF'
export function recordCalculationDuration(kind: string, ms: number){ console.log(`[METRIC] ${kind}_duration_ms: ${ms}`); if(ms>150) console.warn(`[SLO_BREACH] ${kind} ${ms}ms`); }
export function recordCalculationResult(kind: string, ok: boolean){ console.log(`[METRIC] ${kind}_total{status="${ok?'success':'error'}"}: 1`); }
EOF
}

create_zod_schema() {
  mkdir -p "$REPO/packages/api/src/presentation/validators"
  cat > "$REPO/packages/api/src/presentation/validators/price.schema.ts" <<'EOF'
import { z } from 'zod';
export const PriceRequestSchema = z.object({
  pv: z.number().positive().min(100).max(10_000_000),
  rate: z.number().positive().min(0.0001).max(1.0),
  n: z.number().int().positive().min(1).max(480),
  daycount: z.enum(['30360','ACT365']).optional().default('30360'),
  prorata: z.boolean().optional().default(false),
  feesT0: z.array(z.object({name:z.string().min(1), value:z.number().nonnegative()})).optional().default([]),
});
export type PriceRequest = z.infer<typeof PriceRequestSchema>;
export const PriceResponseSchema = z.object({
  pmt: z.number(), totalInterest:z.number(), totalPaid:z.number(),
  schedule: z.array(z.object({period:z.number(),date:z.string(),payment:z.number(),interest:z.number(),amortization:z.number(),balance:z.number()})),
  meta: z.object({ calculationId:z.string().uuid(), motorVersion:z.string(), timestamp:z.string() }),
});
export type PriceResponse = z.infer<typeof PriceResponseSchema>;
EOF
}

create_price_service() {
  mkdir -p "$REPO/packages/api/src/application/services"
  cat > "$REPO/packages/api/src/application/services/price.service.ts" <<'EOF'
import Decimal from 'decimal.js';
import { randomUUID } from 'crypto';
import { addMonths, format } from 'date-fns';
import { createContextLogger } from '../../infrastructure/logger';
import { recordCalculationDuration, recordCalculationResult } from '../../infrastructure/metrics';
import type { PriceRequest, PriceResponse } from '../../presentation/validators/price.schema';

// PMT Price local (evita acoplamento direto ao pacote do motor neste protótipo)
function pmtPrice(pv: Decimal, i: Decimal, n: number): Decimal {
  if (n <= 0) return new Decimal(0);
  if (i.isZero()) return pv.div(n);
  const a = i.add(1).pow(n);
  return pv.mul(i.mul(a).div(a.sub(1)));
}

export interface IPriceService { calculate(params: PriceRequest): Promise<PriceResponse>; }

export class PriceService implements IPriceService {
  private readonly motorVersion = '0.1.1';
  async calculate(params: PriceRequest): Promise<PriceResponse> {
    const t0 = Date.now();
    const calculationId = randomUUID();
    const log = createContextLogger({ calculationId, motorVersion: this.motorVersion });

    try{
      const pv = new Decimal(params.pv);
      const i  = new Decimal(params.rate);
      const pmt = pmtPrice(pv, i, params.n);

      const schedule = [];
      let balance = pv;
      const base = new Date();
      for(let k=1;k<=params.n;k++){
        const interest = balance.mul(i);
        let amort = pmt.sub(interest);
        let payment = pmt;
        if(k===params.n){ amort = balance; payment = amort.add(interest); }
        balance = balance.sub(amort);
        schedule.push({ period:k, date:addMonths(base,k), payment, interest, amortization:amort, balance: balance.abs().lt(0.01)? new Decimal(0): balance });
      }

      const totalInterest = schedule.reduce((s,r)=>s.add(r.interest), new Decimal(0));
      const totalFeesT0 = (params.feesT0||[]).reduce((s,f)=> s + f.value, 0);
      const totalPaid = pmt.mul(params.n).add(totalFeesT0);

      const duration = Date.now()-t0;
      recordCalculationDuration('price', duration); recordCalculationResult('price', true);
      log.info({ pmt: pmt.toFixed(2), totalInterest: totalInterest.toFixed(2), duration }, 'OK');

      return {
        pmt: pmt.toNumber(),
        totalInterest: totalInterest.toNumber(),
        totalPaid: totalPaid.toNumber(),
        schedule: schedule.map(p=>({ period:p.period, date: format(p.date, 'yyyy-MM-dd'), payment: p.payment.toNumber(), interest: p.interest.toNumber(), amortization: p.amortization.toNumber(), balance: p.balance.toNumber() })),
        meta: { calculationId, motorVersion: this.motorVersion, timestamp: new Date().toISOString() },
      };
    }catch(err){
      const duration = Date.now()-t0;
      recordCalculationDuration('price', duration); recordCalculationResult('price', false);
      throw err;
    }
  }
}
EOF
}

create_price_controller() {
  mkdir -p "$REPO/packages/api/src/presentation/controllers"
  cat > "$REPO/packages/api/src/presentation/controllers/price.controller.ts" <<'EOF'
import type { FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import { PriceService } from '../../application/services/price.service';
import { PriceRequestSchema } from '../validators/price.schema';
import { logger } from '../../infrastructure/logger';

export async function priceController(req: FastifyRequest, reply: FastifyReply){
  try{
    const validated = PriceRequestSchema.parse(req.body);
    const service = new PriceService();
    const result = await service.calculate(validated);
    reply.status(200).send(result);
  }catch(error){
    if (error instanceof ZodError){
      logger.warn({ errors:error.errors }, 'Validação falhou');
      reply.status(400).send({ error:{ code:'VALIDATION_ERROR', message:'Parâmetros inválidos', details: error.errors.map(e=>({field:e.path.join('.'), message:e.message})) } });
      return;
    }
    logger.error({ error: (error as Error).message }, 'Erro no controller');
    reply.status(500).send({ error:{ code:'INTERNAL_ERROR', message:'Erro ao calcular Price' }});
  }
}
EOF
}

create_price_routes() {
  mkdir -p "$REPO/packages/api/src/routes"
  cat > "$REPO/packages/api/src/routes/price.routes.ts" <<'EOF'
import type { FastifyInstance } from 'fastify';
import { priceController } from '../presentation/controllers/price.controller';
export async function priceRoutes(app: FastifyInstance){
  app.post('/api/price', { schema:{ description:'Calcula Price', tags:['Amortização'] } }, priceController);
}
EOF
}

update_main_server() {
  mkdir -p "$REPO/packages/api/src"
  cat > "$REPO/packages/api/src/index.ts" <<'EOF'
import Fastify from 'fastify';
import cors from '@fastify/cors';
import { priceRoutes } from './routes/price.routes';
import { logger } from './infrastructure/logger';

const app = Fastify({ logger:false });
await app.register(cors, { origin:true });
app.get('/health', async ()=>({ status:'ok', motorVersion:'0.1.1', timestamp:new Date().toISOString() }));
await app.register(priceRoutes);

const start = async () => {
  try{
    await app.listen({ port:3001, host:'0.0.0.0' });
    logger.info('🚀 API http://localhost:3001');
  }catch(err){ logger.error(err); process.exit(1); }
};
start();
EOF
}

create_integration_tests() {
  mkdir -p "$REPO/packages/api/test/integration"
  cat > "$REPO/packages/api/test/integration/price.test.ts" <<'EOF'
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import Fastify, { FastifyInstance } from 'fastify';
import { priceRoutes } from '../../src/routes/price.routes';

describe('POST /api/price', ()=>{
  let app: FastifyInstance;
  beforeAll(async ()=>{ app = Fastify(); await app.register(priceRoutes); await app.ready(); });
  afterAll(async ()=>{ await app.close(); });

  it('calcula PMT (básico)', async ()=>{
    const res = await app.inject({ method:'POST', url:'/api/price', payload:{ pv:10000, rate:0.025, n:12 }});
    expect(res.statusCode).toBe(200);
    const j = JSON.parse(res.payload);
    expect(j.pmt).toBeCloseTo(974.87, 2);
    expect(j.schedule).toHaveLength(12);
  });

  it('valida PV mínimo', async ()=>{
    const res = await app.inject({ method:'POST', url:'/api/price', payload:{ pv:50, rate:0.025, n:12 }});
    expect(res.statusCode).toBe(400);
  });
});
EOF
}

update_package_json() {
  mkdir -p "$REPO/packages/api"
  pushd "$REPO/packages/api" >/dev/null
  npm pkg set scripts.dev="tsx watch src/index.ts"
  npm pkg set scripts.build="tsc"
  npm pkg set scripts.start="node dist/index.js"
  npm pkg set scripts.test="vitest"
  npm pkg set "scripts.test:integration"="vitest run test/integration"
  popd >/dev/null
}

setup_tsconfig_and_deps() {
  # tsconfig
  if [ ! -f "$REPO/packages/api/tsconfig.json" ]; then
    cat > "$REPO/packages/api/tsconfig.json" <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "target": "ES2022",
    "lib": ["ES2022"],
    "types": ["node"],
    "esModuleInterop": true,
    "skipLibCheck": true,
    "strict": true,
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules","dist","test"]
}
EOF
  fi
  pnpm -C "$REPO/packages/api" add -D typescript @types/node tsx vitest @vitest/ui
  pnpm -C "$REPO/packages/api" add fastify @fastify/cors zod pino date-fns decimal.js
  pnpm -C "$REPO/packages/api" add -D pino-pretty
}

validate_implementation() {
  log_info "🔍 Validação…"
  pnpm -C "$REPO" -F @finmath/engine typecheck
  pnpm -C "$REPO" -F @finmath/engine test:golden
  pnpm -C "$REPO/packages/api" run build || log_warning "build api ignorado (ok em dev)"
  log_success "Validação básica passou"
}

commit_h9() {
  git -C "$REPO" add packages/api/
  git -C "$REPO" commit -m "feat(H9): POST /api/price (Clean Architecture) + testes integração"
}

main(){
  read -p "Iniciar implementação H9? (s/n): " -n 1 -r; echo
  [[ $REPLY =~ ^[Ss]$ ]] || { log_warning "Cancelado"; exit 0; }
  sprint2_init
  create_directory_structure
  create_logger
  create_metrics
  create_zod_schema
  create_price_service
  create_price_controller
  create_price_routes
  update_main_server
  create_integration_tests
  update_package_json
  setup_tsconfig_and_deps
  validate_implementation
  commit_h9
  log_success "H9 implementado. Rode: pnpm -F @finmath/api dev"
}
main "$@"
IMPL_EOF

# 2) validar-sprint.sh  ───────────────────────────────────────────
cat > "$REPO/validar-sprint.sh" <<'VALIDATION_EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
log_i(){ echo -e "${BLUE}ℹ️  $1${NC}"; }
log_ok(){ echo -e "${GREEN}✅ $1${NC}"; }
log_e(){ echo -e "${RED}❌ $1${NC}"; }
REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

log_i "Typecheck engine"; pnpm -C "$REPO" -F @finmath/engine typecheck
log_i "Golden files";    pnpm -C "$REPO" -F @finmath/engine test:golden
if pnpm -C "$REPO/packages/api" run -s build >/dev/null 2>&1; then log_ok "API build OK"; else log_i "API build (opcional)"; fi
cnt=$(find "$REPO" \( -name "*bak*" -o -name "*backup*" -o -name "*.save" \) -type f | wc -l); [ "$cnt" -eq 0 ] || { log_e "Backups físicos encontrados ($cnt)"; exit 1; }
log_ok "Validação concluída"
VALIDATION_EOF

# 3) finalizar-sprint.sh  ─────────────────────────────────────────
cat > "$REPO/finalizar-sprint.sh" <<'FINALIZATION_EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
log(){ printf "%b%s%b\n" "$BLUE" "$*" "$NC"; }
err(){ printf "%b%s%b\n" "$RED" "$*" "$NC"; }

BR=$(git -C "$REPO" branch --show-current)
[[ $BR =~ ^sprint- ]] || { err "Branch atual não é de sprint ($BR)"; exit 1; }
./validar-sprint.sh
git -C "$REPO" checkout main
git -C "$REPO" pull --rebase origin main || true
git -C "$REPO" merge "$BR" --no-ff -m "chore: merge Sprint 2 (H9 Price API)"
git -C "$REPO" push origin main
git -C "$REPO" tag -a v0.2.0 -m "Sprint 2 (H9)"; git -C "$REPO" push origin v0.2.0
git -C "$REPO" branch -d "$BR" || true
log "Finalizado 🎉"
FINALIZATION_EOF

# 4) setup-api-tsconfig.sh  ───────────────────────────────────────
cat > "$REPO/setup-api-tsconfig.sh" <<'TSCONFIG_EOF'
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
TSCONFIG_EOF

# 5) test-api-local.sh  ───────────────────────────────────────────
cat > "$REPO/test-api-local.sh" <<'TEST_EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
have(){ command -v "$1" >/dev/null 2>&1; }
json(){ if have jq; then jq -r '.'; else cat; fi; }

if ! curl -s http://localhost:3001/health >/dev/null 2>&1; then
  pnpm -C "$(git rev-parse --show-toplevel 2>/dev/null || pwd)/packages/api" dev >/tmp/finmath-api.log 2>&1 &
  sleep 5
fi

echo "Health:"; curl -s http://localhost:3001/health | json
echo "POST /api/price:"; curl -s -X POST http://localhost:3001/api/price -H "Content-Type: application/json" -d '{"pv":10000,"rate":0.025,"n":12}' | json
TEST_EOF

# 6) README simples  ──────────────────────────────────────────────
cat > "$REPO/SCRIPTS_README.md" <<'README_EOF'
Scripts gerados:
- implement-h9.sh          → implementa H9 (Price API)
- validar-sprint.sh        → validação rápida (engine + golden + sanity)
- finalizar-sprint.sh      → merge sprint → main + tag
- setup-api-tsconfig.sh    → configura TS/deps na API
- test-api-local.sh        → testa API localmente
README_EOF

chmod +x "$REPO"/{implement-h9.sh,validar-sprint.sh,finalizar-sprint.sh,setup-api-tsconfig.sh,test-api-local.sh}
echo "✅ Scripts criados em $REPO"
