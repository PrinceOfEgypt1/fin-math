#!/usr/bin/env bash
set -euo pipefail

# ===== Paths base =====
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

TS="$(date +'%Y%m%d_%H%M%S')"
BACKUPS_ROOT="$ROOT/.backups_api"
BACKUP_DIR="$BACKUPS_ROOT/$TS"
MANIFEST="$BACKUP_DIR/manifest.txt"

mkdir -p "$BACKUP_DIR"
: > "$MANIFEST"

# ===== Funções util =====
backup_file() {
  local rel="$1"
  if [ -f "$rel" ]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    cp -f "$rel" "$BACKUP_DIR/$rel"
    echo "$rel" >> "$MANIFEST"
  fi
}

restore_all() {
  cd "$ROOT"
  if [ ! -f "$MANIFEST" ]; then
    echo "⚠️  Manifest não encontrado para rollback: $MANIFEST"
    return 0
  fi
  echo "↩️  Restaurando a partir de $BACKUP_DIR"
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
}

write_file() {
  local rel="$1"
  local tmp="$2"
  mkdir -p "$(dirname "$rel")"
  backup_file "$rel"
  mv -f "$tmp" "$rel"
}

on_error() {
  echo "❌ Erro detectado. Iniciando rollback automático..."
  restore_all
  exit 1
}
trap on_error ERR

# ===== Tira do caminho backups antigos dentro de packages/api =====
mkdir -p "$BACKUPS_ROOT"
while IFS= read -r d; do
  base="$(basename "$d")"
  mv "$d" "$BACKUPS_ROOT/OLD_${TS}_${base}"
  echo "📦 Movido backup antigo: $d -> $BACKUPS_ROOT/OLD_${TS}_${base}"
done < <(find "$ROOT/packages/api" -maxdepth 1 -type d -name ".backup_*" -print || true)

# ===== PATCHES =====

# 1) controllers/irr.controller.ts (solver local + irr.npv(r,cfs))
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/src/controllers/irr.controller.ts
import { Request, Response } from "express";
import { irr as irrModule } from "finmath-engine"; // npv(r, cfs)
import Decimal from "decimal.js";
import { z } from "zod";

const IRRRequestSchema = z.object({
  cashFlows: z.array(z.number()).min(2),
  initialGuess: z.number().optional().default(0.1),
  maxIterations: z.number().optional().default(200),
  tolerance: z.number().optional().default(1e-6),
});

function solveIRRWithBisection(cashFlows: number[], opts?: { tol?: number; maxIter?: number }) {
  const tol = opts?.tol ?? 1e-6;
  const maxIter = opts?.maxIter ?? 200;

  let low = -0.9999;
  let high = 1.0;
  const npvAt = (r: number) => irrModule.npv(r, cashFlows).toNumber();

  let fLow = npvAt(low);
  let fHigh = npvAt(high);

  let expandCount = 0;
  while (fLow * fHigh > 0 && expandCount < 12) {
    high *= 2;
    fHigh = npvAt(high);
    expandCount++;
    if (fLow * fHigh <= 0) break;
    low = Math.max(-0.9999, low - 0.5);
    fLow = npvAt(low);
  }

  if (fLow * fHigh > 0) {
    return { converged: false, iterations: 0, irr: null as number | null, method: "bisection" as const };
  }

  let iterations = 0;
  let mid = 0;
  for (; iterations < maxIter; iterations++) {
    mid = (low + high) / 2;
    const fMid = npvAt(mid);

    if (Math.abs(fMid) < tol || Math.abs(high - low) < tol) {
      return { converged: true, iterations, irr: mid, method: "bisection" as const };
    }

    if (fLow * fMid <= 0) {
      high = mid;
      fHigh = fMid;
    } else {
      low = mid;
      fLow = fMid;
    }
  }

  return { converged: false, iterations, irr: mid, method: "bisection" as const };
}

export async function calculateIRREndpoint(req: Request, res: Response) {
  try {
    const validated = IRRRequestSchema.parse(req.body);

    const result = solveIRRWithBisection(validated.cashFlows, {
      tol: validated.tolerance,
      maxIter: validated.maxIterations,
    });

    const npvValue =
      result.irr != null
        ? irrModule.npv(result.irr, validated.cashFlows)
        : null;

    return res.status(200).json({
      success: true,
      data: {
        irr: result.irr,
        iterations: result.iterations,
        method: result.method,
        converged: result.converged,
        npv: npvValue ? new Decimal(npvValue).toNumber() : null,
      },
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(400).json({ success: false, error: message });
  }
}
EOF
write_file "packages/api/src/controllers/irr.controller.ts" "$tmp"

# 2) routes/irr.routes.ts (plugin Fastify + solver local)
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/src/routes/irr.routes.ts
import type { FastifyInstance, FastifyPluginOptions } from "fastify";
import { z } from "zod";
import { irr as irrModule } from "finmath-engine";

function solveIRRWithBisection(cashFlows: number[], opts?: { tol?: number; maxIter?: number }) {
  const tol = opts?.tol ?? 1e-6;
  const maxIter = opts?.maxIter ?? 200;

  let low = -0.9999;
  let high = 1.0;
  const npvAt = (r: number) => irrModule.npv(r, cashFlows).toNumber();

  let fLow = npvAt(low);
  let fHigh = npvAt(high);

  let expandCount = 0;
  while (fLow * fHigh > 0 && expandCount < 12) {
    high *= 2;
    fHigh = npvAt(high);
    expandCount++;
    if (fLow * fHigh <= 0) break;
    low = Math.max(-0.9999, low - 0.5);
    fLow = npvAt(low);
  }

  if (fLow * fHigh > 0) {
    return { converged: false, iterations: 0, irr: null as number | null, method: "bisection" as const };
  }

  let iterations = 0;
  let mid = 0;
  for (; iterations < maxIter; iterations++) {
    mid = (low + high) / 2;
    const fMid = npvAt(mid);

    if (Math.abs(fMid) < tol || Math.abs(high - low) < tol) {
      return { converged: true, iterations, irr: mid, method: "bisection" as const };
    }

    if (fLow * fMid <= 0) {
      high = mid;
      fHigh = fMid;
    } else {
      low = mid;
      fLow = fMid;
    }
  }

  return { converged: false, iterations, irr: mid, method: "bisection" as const };
}

export async function irrRoutes(app: FastifyInstance, _opts: FastifyPluginOptions) {
  app.post("/irr", async (request, reply) => {
    const schema = z.object({
      cashFlows: z.array(z.number()).min(2),
      initialGuess: z.number().optional().default(0.1),
      maxIterations: z.number().optional().default(200),
      tolerance: z.number().optional().default(1e-6),
    });

    try {
      const body = schema.parse(request.body);

      const result = solveIRRWithBisection(body.cashFlows, {
        tol: body.tolerance,
        maxIter: body.maxIterations,
      });

      const npvValue =
        result.irr != null
          ? irrModule.npv(result.irr, body.cashFlows)
          : null;

      return reply.status(200).send({
        success: true,
        data: {
          irr: result.irr,
          iterations: result.iterations,
          method: result.method,
          converged: result.converged,
          npv: npvValue ? npvValue.toNumber() : null,
        },
      });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(400).send({ success: false, error: message });
    }
  });
}

export default irrRoutes;
EOF
write_file "packages/api/src/routes/irr.routes.ts" "$tmp"

# 3) controllers/perfis.controller.ts (já com catch/param seguro)
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/src/controllers/perfis.controller.ts
import { Request, Response } from "express";
import { listarPerfis, buscarPerfil } from "../services/perfis.service";

export async function listarPerfisEndpoint(_req: Request, res: Response) {
  try {
    const perfis = await listarPerfis();
    return res.json({
      success: true,
      version: "2025-01",
      data: perfis.map((p) => ({
        id: p.id,
        instituicao: p.instituicao,
        vigencia: p.vigencia,
      })),
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(500).json({ success: false, error: message });
  }
}

export async function buscarPerfilEndpoint(req: Request, res: Response) {
  try {
    const { id } = (req.params ?? {}) as { id?: string };
    if (!id) {
      return res
        .status(400)
        .json({ success: false, error: "Parâmetro id ausente" });
    }

    const perfil = await buscarPerfil(id);
    if (!perfil) {
      return res
        .status(404)
        .json({ success: false, error: "Perfil não encontrado" });
    }
    return res.json({ success: true, data: perfil });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(500).json({ success: false, error: message });
  }
}
EOF
write_file "packages/api/src/controllers/perfis.controller.ts" "$tmp"

# 4) controllers/comparador.controller.ts (catch ok)
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/src/controllers/comparador.controller.ts
import { Request, Response } from "express";
import { compararCenarios } from "../services/comparador.service";
import { z } from "zod";

const ComparadorSchema = z.object({
  cenarios: z
    .array(
      z.object({
        id: z.string(),
        nome: z.string(),
        pv: z.number().positive(),
        i: z.number().positive(),
        n: z.number().int().positive(),
      }),
    )
    .min(2),
});

export async function compararCenariosEndpoint(req: Request, res: Response) {
  try {
    const validated = ComparadorSchema.parse(req.body);
    const resultado = await compararCenarios(validated.cenarios);

    return res.json({
      success: true,
      data: resultado,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(400).json({ success: false, error: message });
  }
}
EOF
write_file "packages/api/src/controllers/comparador.controller.ts" "$tmp"

# 5) controllers/xlsx-export.controller.ts (catch ok)
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/src/controllers/xlsx-export.controller.ts
import { Request, Response } from "express";
import { exportToXLSX } from "../services/xlsx-export.service";

export async function exportScheduleXLSX(req: Request, res: Response) {
  try {
    const { schedule, pv, i, n } = req.body;

    const buffer = await exportToXLSX(schedule, pv, i, n);

    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    );
    res.setHeader(
      "Content-Disposition",
      "attachment; filename=cronograma.xlsx",
    );
    return res.send(buffer);
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(500).json({ success: false, error: message });
  }
}
EOF
write_file "packages/api/src/controllers/xlsx-export.controller.ts" "$tmp"

# 6) services/comparador.service.ts (guard ok)
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/src/services/comparador.service.ts
import Decimal from "decimal.js";

export interface CenarioInput {
  id: string;
  nome: string;
  pv: number;
  i: number;
  n: number;
}

export interface CenarioResultado {
  id: string;
  nome: string;
  pmt: number;
  totalPago: number;
  cetAnual: number;
  economiaVsMelhor?: number;
}

export interface ComparadorResultado {
  melhorCenario: string;
  justificativa: string;
  resultados: CenarioResultado[];
}

function calcularPMT(pv: number, i: number, n: number): number {
  const I = new Decimal(i);
  const N = new Decimal(n);
  const PV = new Decimal(pv);
  const num = PV.mul(I);
  const den = new Decimal(1).minus(new Decimal(1).plus(I).pow(N.neg()));
  return num.div(den).toNumber();
}

function estimarCETAnual(iMensal: number): number {
  return new Decimal(1).plus(iMensal).pow(12).minus(1).mul(100).toNumber();
}

export async function compararCenarios(cenarios: CenarioInput[]): Promise<ComparadorResultado> {
  const resultados: CenarioResultado[] = cenarios.map((c) => {
    const pmt = calcularPMT(c.pv, c.i, c.n);
    const totalPago = pmt * c.n;
    const cetAnual = estimarCETAnual(c.i);
    return { id: c.id, nome: c.nome, pmt, totalPago, cetAnual };
  });

  resultados.sort((a, b) => a.totalPago - b.totalPago);

  if (resultados.length === 0) {
    throw new Error("Nenhum cenário calculado");
  }

  const melhor = resultados[0]!;

  resultados.forEach((r) => {
    r.economiaVsMelhor = r.totalPago - melhor.totalPago;
  });

  return {
    melhorCenario: melhor.id,
    justificativa: `${melhor.nome} tem o menor total pago (R$ ${melhor.totalPago.toFixed(2)}) e menor CET (${melhor.cetAnual.toFixed(2)}% a.a.)`,
    resultados,
  };
}
EOF
write_file "packages/api/src/services/comparador.service.ts" "$tmp"

# 7) routes/perfis.routes.ts (Fastify)
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/src/routes/perfis.routes.ts
import type { FastifyInstance, FastifyPluginOptions } from "fastify";
import { listarPerfis, buscarPerfil } from "../services/perfis.service";

export async function perfisRoutes(app: FastifyInstance, _opts: FastifyPluginOptions) {
  app.get("/perfis", async (_req, reply) => {
    try {
      const perfis = await listarPerfis();
      return reply.send({
        success: true,
        version: "2025-01",
        data: perfis.map((p) => ({
          id: p.id,
          instituicao: p.instituicao,
          vigencia: p.vigencia,
        })),
      });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(500).send({ success: false, error: message });
    }
  });

  app.get("/perfis/:id", async (req, reply) => {
    try {
      const id = (req.params as { id?: string })?.id;
      if (!id) {
        return reply.status(400).send({ success: false, error: "Parâmetro id ausente" });
      }
      const perfil = await buscarPerfil(id);
      if (!perfil) {
        return reply.status(404).send({ success: false, error: "Perfil não encontrado" });
      }
      return reply.send({ success: true, data: perfil });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(500).send({ success: false, error: message });
    }
  });
}

export default perfisRoutes;
EOF
write_file "packages/api/src/routes/perfis.routes.ts" "$tmp"

# 8) routes/comparador.routes.ts (Fastify)
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/src/routes/comparador.routes.ts
import type { FastifyInstance, FastifyPluginOptions } from "fastify";
import { z } from "zod";
import { compararCenarios } from "../services/comparador.service";

export async function comparadorRoutes(app: FastifyInstance, _opts: FastifyPluginOptions) {
  app.post("/comparar", async (request, reply) => {
    const Schema = z.object({
      cenarios: z.array(
        z.object({
          id: z.string(),
          nome: z.string(),
          pv: z.number().positive(),
          i: z.number().positive(),
          n: z.number().int().positive(),
        })
      ).min(2),
    });

    try {
      const { cenarios } = Schema.parse(request.body);
      const resultado = await compararCenarios(cenarios);
      return reply.send({ success: true, data: resultado });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(400).send({ success: false, error: message });
    }
  });
}

export default comparadorRoutes;
EOF
write_file "packages/api/src/routes/comparador.routes.ts" "$tmp"

# 9) server.ts — garantir imports default
SV="packages/api/src/server.ts"
backup_file "$SV"
sed -i 's|import { irrRoutes } from "./routes/irr.routes";|import irrRoutes from "./routes/irr.routes";|' "$SV" || true
sed -i 's|import { perfisRoutes } from "./routes/perfis.routes";|import perfisRoutes from "./routes/perfis.routes";|' "$SV" || true
sed -i 's|import { comparadorRoutes } from "./routes/comparador.routes";|import comparadorRoutes from "./routes/comparador.routes";|' "$SV" || true

# 10) tests/integration/irr.test.ts — Fastify (sem supertest)
tmp="$(mktemp)"
cat > "$tmp" <<'EOF'
// packages/api/test/integration/irr.test.ts
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { build } from "../../src/server";
import type { FastifyInstance } from "fastify";

describe("POST /api/irr", () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await build();
    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  it("deve calcular IRR de fluxo simples", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/api/irr",
      payload: { cashFlows: [-1000, 300, 400, 500] },
    });

    expect(response.statusCode).toBe(200);
    const body = response.json();
    expect(body.success).toBe(true);
    expect(typeof body.data.irr).toBe("number");
    expect(body.data.converged).toBe(true);
  });

  it("deve validar entrada", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/api/irr",
      payload: { cashFlows: [-1000] },
    });

    expect(response.statusCode).toBe(400);
  });
});
EOF
write_file "packages/api/test/integration/irr.test.ts" "$tmp"

echo "🧾 Backup criado em: $BACKUP_DIR"
echo "🛠  Arquivos alterados listados em: $MANIFEST"

# ===== Build & Test (rodar só dentro de packages/api) =====
echo "▶️  Build e testes (API)…"
cd "$ROOT/packages/api"
pnpm run build
pnpm run test:integration

echo "✅ Patches aplicados com sucesso."
