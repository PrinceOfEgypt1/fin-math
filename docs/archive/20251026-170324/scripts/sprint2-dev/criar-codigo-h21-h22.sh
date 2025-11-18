#!/bin/bash
# criar-codigo-h21-h22.sh

cd ~/workspace/fin-math

# 1. SCHEMAS
cat > packages/api/src/schemas/snapshot.schema.ts << 'EOF'
import { z } from "zod";

export const SnapshotResponseSchema = z.object({
  id: z.string().uuid(),
  hash: z.string(),
  input: z.record(z.any()),
  output: z.record(z.any()),
  meta: z.object({
    motorVersion: z.string(),
    timestamp: z.string().datetime(),
    calculationType: z.enum(["price", "sac", "cet"]),
  }),
});

export type SnapshotResponse = z.infer<typeof SnapshotResponseSchema>;
EOF

cat > packages/api/src/schemas/validator.schema.ts << 'EOF'
import { z } from "zod";

const ScheduleRowSchema = z.object({
  k: z.number().int().positive(),
  pmt: z.number(),
  interest: z.number(),
  amort: z.number(),
  balance: z.number(),
});

export const ValidateScheduleRequestSchema = z.object({
  type: z.enum(["price", "sac"]),
  params: z.object({
    pv: z.number().positive(),
    rate: z.number().positive(),
    n: z.number().int().positive(),
  }),
  schedule: z.array(ScheduleRowSchema).min(1),
});

export const ValidateScheduleResponseSchema = z.object({
  valid: z.boolean(),
  summary: z.object({
    totalRows: z.number().int(),
    validRows: z.number().int(),
    invalidRows: z.number().int(),
    maxDelta: z.number(),
    maxDeltaPercent: z.number(),
  }),
  diffs: z.array(z.object({
    row: z.number().int(),
    column: z.string(),
    expected: z.number(),
    received: z.number(),
    delta: z.number(),
    deltaPercent: z.number(),
    withinTolerance: z.boolean(),
  })),
});

export type ValidateScheduleRequest = z.infer<typeof ValidateScheduleRequestSchema>;
export type ValidateScheduleResponse = z.infer<typeof ValidateScheduleResponseSchema>;
export type ScheduleRow = z.infer<typeof ScheduleRowSchema>;
EOF

# 2. SERVICES
cat > packages/api/src/services/snapshot.service.ts << 'EOF'
import { createHash, randomUUID } from "crypto";

interface Snapshot {
  id: string;
  hash: string;
  input: any;
  output: any;
  meta: {
    motorVersion: string;
    timestamp: string;
    calculationType: "price" | "sac" | "cet";
  };
}

export class SnapshotService {
  private snapshots: Map<string, Snapshot>;
  private motorVersion: string;

  constructor(motorVersion = "0.2.0") {
    this.snapshots = new Map();
    this.motorVersion = motorVersion;
  }

  create(calculationType: "price" | "sac" | "cet", input: any, output: any): string {
    const id = randomUUID();
    const hash = this.generateHash(input);
    const timestamp = new Date().toISOString();

    const snapshot: Snapshot = {
      id, hash, input, output,
      meta: { motorVersion: this.motorVersion, timestamp, calculationType }
    };

    this.snapshots.set(id, snapshot);
    return id;
  }

  get(id: string): Snapshot | undefined {
    return this.snapshots.get(id);
  }

  generateHash(input: any): string {
    const sortedInput = this.sortObjectKeys(input);
    const hash = createHash("sha256");
    hash.update(JSON.stringify(sortedInput));
    return hash.digest("hex");
  }

  private sortObjectKeys(obj: any): any {
    if (obj === null || typeof obj !== "object" || Array.isArray(obj)) return obj;
    const sorted: any = {};
    Object.keys(obj).sort().forEach(key => sorted[key] = this.sortObjectKeys(obj[key]));
    return sorted;
  }
}

export const snapshotService = new SnapshotService();
EOF

cat > packages/api/src/services/validator.service.ts << 'EOF'
import Decimal from "decimal.js";
import { ValidateScheduleRequest, ValidateScheduleResponse, ScheduleRow } from "../schemas/validator.schema";

export class ValidatorService {
  private toleranceAbsolute = 0.01;

  validateSchedule(request: ValidateScheduleRequest): ValidateScheduleResponse {
    const { type, params, schedule: receivedSchedule } = request;
    const expectedSchedule = this.calculateExpectedSchedule(type, params);
    const diffs = this.compareSchedules(expectedSchedule, receivedSchedule);
    const summary = this.calculateSummary(receivedSchedule.length, diffs);
    const valid = diffs.every(d => d.withinTolerance);
    return { valid, summary, diffs };
  }

  private calculateExpectedSchedule(type: "price" | "sac", params: any): ScheduleRow[] {
    return type === "price" 
      ? this.calculatePriceSchedule(params.pv, params.rate, params.n)
      : this.calculateSacSchedule(params.pv, params.rate, params.n);
  }

  private calculatePriceSchedule(pv: number, rate: number, n: number): ScheduleRow[] {
    const pvDec = new Decimal(pv);
    const rateDec = new Decimal(rate);
    const pmt = pvDec.mul(rateDec).mul(new Decimal(1).plus(rateDec).pow(n))
      .div(new Decimal(1).plus(rateDec).pow(n).minus(1));
    
    const schedule: ScheduleRow[] = [];
    let balance = pvDec;

    for (let k = 1; k <= n; k++) {
      const interest = balance.mul(rateDec);
      let amort = pmt.minus(interest);
      let pmtFinal = pmt;

      if (k === n) {
        amort = balance;
        pmtFinal = interest.plus(amort);
        balance = new Decimal(0);
      } else {
        balance = balance.minus(amort);
      }

      schedule.push({
        k,
        pmt: this.round2(pmtFinal),
        interest: this.round2(interest),
        amort: this.round2(amort),
        balance: this.round2(balance)
      });
    }
    return schedule;
  }

  private calculateSacSchedule(pv: number, rate: number, n: number): ScheduleRow[] {
    const pvDec = new Decimal(pv);
    const amortConst = pvDec.div(n);
    const schedule: ScheduleRow[] = [];
    let balance = pvDec;

    for (let k = 1; k <= n; k++) {
      const interest = balance.mul(rate);
      let amort = amortConst;
      let pmtFinal = interest.plus(amort);

      if (k === n) {
        amort = balance;
        pmtFinal = interest.plus(amort);
        balance = new Decimal(0);
      } else {
        balance = balance.minus(amort);
      }

      schedule.push({
        k,
        pmt: this.round2(pmtFinal),
        interest: this.round2(interest),
        amort: this.round2(amort),
        balance: this.round2(balance)
      });
    }
    return schedule;
  }

  private compareSchedules(expected: ScheduleRow[], received: ScheduleRow[]): any[] {
    const diffs: any[] = [];
    const columns = ["pmt", "interest", "amort", "balance"] as const;
    const minLength = Math.min(expected.length, received.length);

    for (let i = 0; i < minLength; i++) {
      const exp = expected[i];
      const rec = received[i];
      if (exp.k !== rec.k) continue;

      columns.forEach(col => {
        const expectedVal = exp[col];
        const receivedVal = rec[col];
        const delta = Math.abs(expectedVal - receivedVal);
        const deltaPercent = expectedVal !== 0 ? (delta / Math.abs(expectedVal)) * 100 : 0;
        const withinTolerance = delta <= this.toleranceAbsolute;

        if (delta > 0) {
          diffs.push({ row: exp.k, column: col, expected: expectedVal, received: receivedVal, delta, deltaPercent, withinTolerance });
        }
      });
    }
    return diffs;
  }

  private calculateSummary(totalRows: number, diffs: any[]) {
    const invalidRowsSet = new Set(diffs.filter(d => !d.withinTolerance).map(d => d.row));
    return {
      totalRows,
      validRows: totalRows - invalidRowsSet.size,
      invalidRows: invalidRowsSet.size,
      maxDelta: this.round2(new Decimal(Math.max(...diffs.map(d => d.delta), 0))),
      maxDeltaPercent: this.round2(new Decimal(Math.max(...diffs.map(d => d.deltaPercent), 0)))
    };
  }

  private round2(value: Decimal): number {
    return value.toDecimalPlaces(2, Decimal.ROUND_HALF_UP).toNumber();
  }
}

export const validatorService = new ValidatorService();
EOF

# 3. CONTROLLERS
cat > packages/api/src/controllers/snapshot.controller.ts << 'EOF'
import { FastifyRequest, FastifyReply } from "fastify";
import { snapshotService } from "../services/snapshot.service";

interface SnapshotParams {
  id: string;
}

export async function getSnapshot(
  req: FastifyRequest<{ Params: SnapshotParams }>,
  reply: FastifyReply
) {
  const { id } = req.params;
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  
  if (!uuidRegex.test(id)) {
    return reply.status(400).send({
      error: { code: "INVALID_UUID", message: "ID fornecido não é um UUID válido" }
    });
  }

  const snapshot = snapshotService.get(id);
  if (!snapshot) {
    return reply.status(404).send({
      error: { code: "SNAPSHOT_NOT_FOUND", message: "Snapshot não encontrado" }
    });
  }

  return reply.send(snapshot);
}
EOF

cat > packages/api/src/controllers/validator.controller.ts << 'EOF'
import { FastifyRequest, FastifyReply } from "fastify";
import { ValidateScheduleRequestSchema } from "../schemas/validator.schema";
import { validatorService } from "../services/validator.service";
import { snapshotService } from "../services/snapshot.service";

export async function postValidateSchedule(req: FastifyRequest, reply: FastifyReply) {
  const parsed = ValidateScheduleRequestSchema.safeParse(req.body);

  if (!parsed.success) {
    return reply.status(400).send({
      error: {
        code: "VALIDATION_ERROR",
        message: "Validation failed",
        details: parsed.error.errors.map(e => ({ path: e.path, message: e.message }))
      }
    });
  }

  try {
    const result = validatorService.validateSchedule(parsed.data);
    const snapshotId = snapshotService.create(parsed.data.type, { ...parsed.data, _validationType: "schedule_validation" }, result);
    
    return reply.send({
      ...result,
      _meta: { snapshotId, snapshotUrl: `/api/snapshot/${snapshotId}` }
    });
  } catch (error: any) {
    return reply.status(500).send({
      error: { code: "VALIDATION_ERROR", message: error.message || "Erro ao validar cronograma" }
    });
  }
}
EOF

# 4. ROUTES
cat > packages/api/src/routes/snapshot.routes.ts << 'EOF'
import { FastifyInstance } from "fastify";
import { getSnapshot } from "../controllers/snapshot.controller";

export async function snapshotRoutes(app: FastifyInstance) {
  app.get("/snapshot/:id", getSnapshot);
}
EOF

cat > packages/api/src/routes/validator.routes.ts << 'EOF'
import { FastifyInstance } from "fastify";
import { postValidateSchedule } from "../controllers/validator.controller";

export async function validatorRoutes(app: FastifyInstance) {
  app.post("/validate/schedule", postValidateSchedule);
}
EOF

echo "✅ Todos os 8 arquivos criados!"
echo ""
echo "📝 PRÓXIMO PASSO: Modificar manualmente 4 arquivos:"
echo "   1. packages/api/src/server.ts"
echo "   2. packages/api/src/controllers/price.controller.ts"
echo "   3. packages/api/src/controllers/sac.controller.ts"
echo "   4. packages/api/src/controllers/cet.controller.ts"
echo ""
echo "Consulte REFERENCIA_RAPIDA.md para as modificações exatas."
