#!/bin/bash
# criar-arquivos-faltantes.sh
# Cria TODOS os arquivos que faltam para H21 e H22

cd ~/workspace/fin-math

echo "📦 CRIANDO ARQUIVOS FALTANTES PARA H21 e H22"
echo "============================================="

# 1. CRIAR validator.schema.ts
echo "📝 Criando validator.schema.ts..."
cat > packages/api/src/schemas/validator.schema.ts << 'EOF'
// packages/api/src/schemas/validator.schema.ts
import { z } from "zod";

/**
 * Schema para linha de cronograma no CSV
 */
const ScheduleRowSchema = z.object({
  k: z.number().int().positive(),
  pmt: z.number(),
  interest: z.number(),
  amort: z.number(),
  balance: z.number(),
});

export type ScheduleRow = z.infer<typeof ScheduleRowSchema>;

/**
 * Schema para request de validação
 */
export const ValidateScheduleRequestSchema = z.object({
  input: z.object({
    pv: z.number(),
    rate: z.number(),
    n: z.number().int(),
    system: z.enum(["price", "sac"]),
  }),
  expected: z.array(ScheduleRowSchema),
  actual: z.array(ScheduleRowSchema),
});

export type ValidateScheduleRequest = z.infer<typeof ValidateScheduleRequestSchema>;

/**
 * Schema para diff de validação
 */
export interface Diff {
  k: number;
  field: string;
  expected: number | string;
  actual: number | string;
  diff: number;
}

/**
 * Schema para resposta de validação
 */
export interface ValidateScheduleResponse {
  valid: boolean;
  diffs: Diff[];
  summary: {
    totalRows: number;
    mismatches: number;
    fields: string[];
  };
  input: ValidateScheduleRequest["input"];
  totals: {
    expected: { pmt: number; interest: number; amort: number };
    actual: { pmt: number; interest: number; amort: number };
    diff: { pmt: number; interest: number; amort: number };
  };
}
EOF
echo "✅ validator.schema.ts criado"

# 2. CRIAR snapshot.schema.ts
echo "📝 Criando snapshot.schema.ts..."
cat > packages/api/src/schemas/snapshot.schema.ts << 'EOF'
// packages/api/src/schemas/snapshot.schema.ts
import { z } from "zod";

/**
 * Schema para resposta de snapshot
 */
export const SnapshotResponseSchema = z.object({
  id: z.string().uuid(),
  hash: z.string(),
  input: z.record(z.any()),
  output: z.any(),
  meta: z.object({
    motorVersion: z.string(),
    timestamp: z.string().datetime(),
    endpoint: z.string(),
  }),
});

export type SnapshotResponse = z.infer<typeof SnapshotResponseSchema>;
EOF
echo "✅ snapshot.schema.ts criado"

# 3. CRIAR validator.routes.ts
echo "📝 Criando validator.routes.ts..."
cat > packages/api/src/routes/validator.routes.ts << 'EOF'
// packages/api/src/routes/validator.routes.ts
import { FastifyInstance } from "fastify";
import { postValidateSchedule } from "../controllers/validator.controller";

/**
 * Registra rotas de validação
 */
export async function validatorRoutes(fastify: FastifyInstance) {
  fastify.post("/validate/schedule", postValidateSchedule);
}
EOF
echo "✅ validator.routes.ts criado"

# 4. CRIAR snapshot.routes.ts
echo "📝 Criando snapshot.routes.ts..."
cat > packages/api/src/routes/snapshot.routes.ts << 'EOF'
// packages/api/src/routes/snapshot.routes.ts
import { FastifyInstance } from "fastify";
import { getSnapshot } from "../controllers/snapshot.controller";

/**
 * Registra rotas de snapshots
 */
export async function snapshotRoutes(fastify: FastifyInstance) {
  fastify.get("/snapshot/:id", getSnapshot);
}
EOF
echo "✅ snapshot.routes.ts criado"

# 5. CRIAR snapshot.service.ts (se não existir)
if [ ! -f "packages/api/src/services/snapshot.service.ts" ]; then
    echo "📝 Criando snapshot.service.ts..."
    cat > packages/api/src/services/snapshot.service.ts << 'EOF'
// packages/api/src/services/snapshot.service.ts
import { createHash, randomUUID } from "crypto";

/**
 * Interface para Snapshot armazenado
 */
interface Snapshot {
  id: string;
  hash: string;
  input: any;
  output: any;
  meta: {
    motorVersion: string;
    timestamp: string;
    endpoint: string;
  };
}

/**
 * Service para gestão de snapshots
 */
class SnapshotService {
  private snapshots: Map<string, Snapshot> = new Map();
  private readonly motorVersion = "0.2.0";

  /**
   * Cria novo snapshot
   */
  create(input: any, output: any, endpoint: string): Snapshot {
    const id = randomUUID();
    const hash = this.generateHash(input, output);
    const timestamp = new Date().toISOString();

    const snapshot: Snapshot = {
      id,
      hash,
      input,
      output,
      meta: {
        motorVersion: this.motorVersion,
        timestamp,
        endpoint,
      },
    };

    this.snapshots.set(id, snapshot);
    return snapshot;
  }

  /**
   * Recupera snapshot por ID
   */
  get(id: string): Snapshot | undefined {
    return this.snapshots.get(id);
  }

  /**
   * Gera hash SHA-256 do snapshot
   */
  private generateHash(input: any, output: any): string {
    const data = JSON.stringify({ input, output });
    return createHash("sha256").update(data).digest("hex");
  }
}

export const snapshotService = new SnapshotService();
EOF
    echo "✅ snapshot.service.ts criado"
fi

# 6. CRIAR snapshot.controller.ts (se não existir)
if [ ! -f "packages/api/src/controllers/snapshot.controller.ts" ]; then
    echo "📝 Criando snapshot.controller.ts..."
    cat > packages/api/src/controllers/snapshot.controller.ts << 'EOF'
// packages/api/src/controllers/snapshot.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { snapshotService } from "../services/snapshot.service";

interface SnapshotParams {
  id: string;
}

/**
 * GET /api/snapshot/:id
 */
export async function getSnapshot(
  request: FastifyRequest<{ Params: SnapshotParams }>,
  reply: FastifyReply
) {
  const { id } = request.params;
  const snapshot = snapshotService.get(id);

  if (!snapshot) {
    return reply.status(404).send({
      error: "Snapshot not found",
      id,
    });
  }

  return reply.status(200).send(snapshot);
}
EOF
    echo "✅ snapshot.controller.ts criado"
fi

# 7. CRIAR validator.controller.ts (se não existir)
if [ ! -f "packages/api/src/controllers/validator.controller.ts" ]; then
    echo "📝 Criando validator.controller.ts..."
    cat > packages/api/src/controllers/validator.controller.ts << 'EOF'
// packages/api/src/controllers/validator.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { ValidateScheduleRequestSchema } from "../schemas/validator.schema";
import { validatorService } from "../services/validator.service";

/**
 * POST /api/validate/schedule
 */
export async function postValidateSchedule(
  request: FastifyRequest,
  reply: FastifyReply
) {
  try {
    // Validar body com Zod
    const body = ValidateScheduleRequestSchema.parse(request.body);

    // Executar validação
    const result = validatorService.validate(body);

    // Retornar resultado
    return reply.status(200).send(result);
  } catch (error) {
    if (error instanceof Error) {
      return reply.status(400).send({
        error: "Validation error",
        message: error.message,
      });
    }
    throw error;
  }
}
EOF
    echo "✅ validator.controller.ts criado"
fi

# 8. CORRIGIR server.ts - adicionar imports
echo "📝 Corrigindo imports no server.ts..."
cd packages/api/src

# Criar versão corrigida do server.ts
cat > server.ts << 'EOF'
// packages/api/src/server.ts
import Fastify, { FastifyInstance } from "fastify";
import cors from "@fastify/cors";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { priceRoutes } from "./routes/price.routes";
import { sacRoutes } from "./routes/sac.routes";
import { cetRoutes } from "./routes/cet.routes";
import { snapshotRoutes } from "./routes/snapshot.routes";
import { validatorRoutes } from "./routes/validator.routes";

export async function build(): Promise<FastifyInstance> {
  const fastify = Fastify({
    logger: {
      level: process.env.LOG_LEVEL || "info",
    },
  });

  // CORS
  await fastify.register(cors, {
    origin: true,
  });

  // Swagger
  await fastify.register(swagger, {
    openapi: {
      info: {
        title: "FinMath API",
        description: "API de Matemática Financeira",
        version: "0.2.0",
      },
      servers: [
        {
          url: "http://localhost:3001",
          description: "Servidor de desenvolvimento",
        },
      ],
    },
  });

  await fastify.register(swaggerUi, {
    routePrefix: "/api-docs",
    uiConfig: {
      docExpansion: "list",
      deepLinking: false,
    },
  });

  // Rotas
  await fastify.register(priceRoutes, { prefix: "/api" });
  await fastify.register(sacRoutes, { prefix: "/api" });
  await fastify.register(cetRoutes, { prefix: "/api" });
  await fastify.register(snapshotRoutes, { prefix: "/api" });
  await fastify.register(validatorRoutes, { prefix: "/api" });

  return fastify;
}
EOF
echo "✅ server.ts corrigido com imports"

cd ~/workspace/fin-math

# 9. TESTAR BUILD
echo ""
echo "🔍 Testando build final..."
cd packages/api
pnpm build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ✅ ✅ BUILD COM SUCESSO! ✅ ✅ ✅"
    echo ""
    echo "📦 Arquivos criados:"
    echo "  ✅ packages/api/src/schemas/validator.schema.ts"
    echo "  ✅ packages/api/src/schemas/snapshot.schema.ts"
    echo "  ✅ packages/api/src/services/snapshot.service.ts"
    echo "  ✅ packages/api/src/services/validator.service.ts"
    echo "  ✅ packages/api/src/controllers/snapshot.controller.ts"
    echo "  ✅ packages/api/src/controllers/validator.controller.ts"
    echo "  ✅ packages/api/src/routes/snapshot.routes.ts"
    echo "  ✅ packages/api/src/routes/validator.routes.ts"
    echo "  ✅ packages/api/src/server.ts (atualizado)"
    echo ""
    echo "🎯 Próximos passos:"
    echo "  1. Testar API: pnpm dev"
    echo "  2. Testar endpoints:"
    echo "     - GET http://localhost:3001/api/snapshot/:id"
    echo "     - POST http://localhost:3001/api/validate/schedule"
    echo "  3. Executar testes: pnpm test"
    echo "  4. Commit: git add . && git commit -m 'feat(H21,H22): Implementa Snapshots e Validador'"
else
    echo ""
    echo "❌ Build falhou. Verifique erros acima."
    exit 1
fi
