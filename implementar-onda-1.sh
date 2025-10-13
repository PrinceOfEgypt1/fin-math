#!/bin/bash
# ============================================
# SCRIPT: implementar-onda-1.sh
# OBJETIVO: Implementar H10 (Day Count + Pró-rata)
# ONDA: 1
# ============================================

set -e

echo "🚀 IMPLEMENTANDO ONDA 1: H10 (Day Count + Pró-rata)"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ============================================
# 1. IMPLEMENTAR DAY COUNT NO MOTOR
# ============================================
echo "📦 1. Implementando Day Count no motor..."

# Criar diretório
mkdir -p packages/engine/src/day-count

# 1.1 Criar index.ts (exports)
cat > packages/engine/src/day-count/index.ts << 'EOF'
/**
 * Day Count Module
 * Implements day count conventions and pro-rata interest calculations
 */

export { DayCountConvention, daysBetween, yearFraction } from './conventions';
export { calculateProRataInterest, type ProRataInput, type ProRataResult } from './pro-rata';
EOF

# 1.2 Criar conventions.ts
cat > packages/engine/src/day-count/conventions.ts << 'EOF'
import { Decimal } from 'decimal.js';

/**
 * Day count conventions supported
 */
export type DayCountConvention = '30/360' | 'ACT/365' | 'ACT/360';

/**
 * Calculate days between two dates using specified convention
 * 
 * @param startDate - Start date (inclusive)
 * @param endDate - End date (exclusive)
 * @param convention - Day count convention to use
 * @returns Number of days according to convention
 * 
 * @example
 * daysBetween(new Date('2025-01-01'), new Date('2025-02-01'), '30/360') // 30
 * daysBetween(new Date('2025-01-01'), new Date('2025-02-01'), 'ACT/365') // 31
 */
export function daysBetween(
  startDate: Date,
  endDate: Date,
  convention: DayCountConvention
): number {
  if (convention === '30/360') {
    return days30_360(startDate, endDate);
  }
  
  // ACT/365 and ACT/360 use actual days
  return actualDays(startDate, endDate);
}

/**
 * Calculate year fraction between two dates
 * 
 * @param startDate - Start date (inclusive)
 * @param endDate - End date (exclusive)
 * @param convention - Day count convention to use
 * @returns Year fraction as Decimal
 * 
 * @example
 * yearFraction(new Date('2025-01-01'), new Date('2025-07-01'), 'ACT/365')
 * // Returns ~0.4959 (181 days / 365)
 */
export function yearFraction(
  startDate: Date,
  endDate: Date,
  convention: DayCountConvention
): Decimal {
  const days = daysBetween(startDate, endDate, convention);
  
  const divisor = convention === 'ACT/360' ? 360 : 365;
  
  return new Decimal(days).div(divisor);
}

/**
 * Calculate actual days between dates (calendar days)
 */
function actualDays(startDate: Date, endDate: Date): number {
  const start = new Date(startDate);
  const end = new Date(endDate);
  
  // Remove time component
  start.setHours(0, 0, 0, 0);
  end.setHours(0, 0, 0, 0);
  
  const diffMs = end.getTime() - start.getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  
  return diffDays;
}

/**
 * Calculate days using 30/360 convention
 * Each month is considered to have 30 days
 */
function days30_360(startDate: Date, endDate: Date): number {
  let y1 = startDate.getFullYear();
  let m1 = startDate.getMonth() + 1;
  let d1 = startDate.getDate();
  
  let y2 = endDate.getFullYear();
  let m2 = endDate.getMonth() + 1;
  let d2 = endDate.getDate();
  
  // Adjust day 31 to day 30
  if (d1 === 31) d1 = 30;
  if (d2 === 31 && d1 >= 30) d2 = 30;
  
  return 360 * (y2 - y1) + 30 * (m2 - m1) + (d2 - d1);
}
EOF

# 1.3 Criar pro-rata.ts
cat > packages/engine/src/day-count/pro-rata.ts << 'EOF'
import { Decimal } from 'decimal.js';
import { round2 } from '../core/decimal';
import { yearFraction, type DayCountConvention } from './conventions';

/**
 * Input for pro-rata interest calculation
 */
export interface ProRataInput {
  principal: Decimal;
  annualRate: Decimal;
  startDate: Date;
  endDate: Date;
  convention: DayCountConvention;
}

/**
 * Result of pro-rata interest calculation
 */
export interface ProRataResult {
  interest: Decimal;
  yearFraction: Decimal;
  days: number;
  convention: DayCountConvention;
}

/**
 * Calculate pro-rata interest for a period
 * 
 * Formula: Interest = Principal × Annual_Rate × Year_Fraction
 * 
 * @param input - Calculation input parameters
 * @returns Pro-rata interest result
 * 
 * @example
 * calculateProRataInterest({
 *   principal: new Decimal('100000'),
 *   annualRate: new Decimal('0.12'),
 *   startDate: new Date('2025-01-01'),
 *   endDate: new Date('2025-02-01'),
 *   convention: 'ACT/365'
 * })
 * // Returns { interest: 1019.18, yearFraction: 0.0849..., days: 31 }
 */
export function calculateProRataInterest(input: ProRataInput): ProRataResult {
  const { principal, annualRate, startDate, endDate, convention } = input;
  
  // Calculate year fraction
  const yf = yearFraction(startDate, endDate, convention);
  
  // Calculate interest: P × r × t
  const interest = principal.mul(annualRate).mul(yf);
  
  // Calculate actual days for reference
  const diffMs = endDate.getTime() - startDate.getTime();
  const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  
  return {
    interest: round2(interest),
    yearFraction: yf,
    days,
    convention
  };
}
EOF

echo "  ✅ Código do motor criado (3 arquivos)"

# 1.4 Atualizar barrel export do motor
cat > packages/engine/src/index.ts << 'EOF'
/**
 * @finmath/engine
 * Financial mathematics calculation engine
 */

// Core utilities
export * from './core/decimal';

// Amortization systems
export * from './amortization/price';
export * from './amortization/sac';

// Day count conventions
export * from './day-count';

// Version
export const ENGINE_VERSION = '0.3.0';
EOF

echo "  ✅ Barrel export atualizado (ENGINE_VERSION: 0.3.0)"
echo ""

# ============================================
# 2. CRIAR TESTES UNITÁRIOS
# ============================================
echo "🧪 2. Criando testes unitários..."

mkdir -p packages/engine/test/unit/day-count

# 2.1 Testes de conventions
cat > packages/engine/test/unit/day-count/conventions.test.ts << 'EOF'
import { describe, it, expect } from 'vitest';
import { daysBetween, yearFraction } from '../../../src/day-count/conventions';
import { Decimal } from 'decimal.js';

describe('Day Count Conventions', () => {
  describe('30/360', () => {
    it('should calculate days for full month (Jan to Feb)', () => {
      const start = new Date('2025-01-01');
      const end = new Date('2025-02-01');
      expect(daysBetween(start, end, '30/360')).toBe(30);
    });

    it('should calculate days for partial month', () => {
      const start = new Date('2025-01-15');
      const end = new Date('2025-02-15');
      expect(daysBetween(start, end, '30/360')).toBe(30);
    });

    it('should handle day 31 adjustments', () => {
      const start = new Date('2025-01-31');
      const end = new Date('2025-03-31');
      expect(daysBetween(start, end, '30/360')).toBe(60);
    });

    it('should calculate year fraction', () => {
      const start = new Date('2025-01-01');
      const end = new Date('2025-07-01');
      const yf = yearFraction(start, end, '30/360');
      expect(yf.toNumber()).toBeCloseTo(0.4932, 4); // 180/365
    });
  });

  describe('ACT/365', () => {
    it('should calculate actual days for January (31 days)', () => {
      const start = new Date('2025-01-01');
      const end = new Date('2025-02-01');
      expect(daysBetween(start, end, 'ACT/365')).toBe(31);
    });

    it('should calculate actual days for February (28 days)', () => {
      const start = new Date('2025-02-01');
      const end = new Date('2025-03-01');
      expect(daysBetween(start, end, 'ACT/365')).toBe(28);
    });

    it('should calculate year fraction', () => {
      const start = new Date('2025-01-01');
      const end = new Date('2025-07-01');
      const yf = yearFraction(start, end, 'ACT/365');
      expect(yf.toNumber()).toBeCloseTo(0.4959, 4); // 181/365
    });
  });

  describe('ACT/360', () => {
    it('should use actual days with 360 divisor', () => {
      const start = new Date('2025-01-01');
      const end = new Date('2025-02-01');
      expect(daysBetween(start, end, 'ACT/360')).toBe(31);
      
      const yf = yearFraction(start, end, 'ACT/360');
      expect(yf.toNumber()).toBeCloseTo(0.0861, 4); // 31/360
    });
  });
});
EOF

# 2.2 Testes de pro-rata
cat > packages/engine/test/unit/day-count/pro-rata.test.ts << 'EOF'
import { describe, it, expect } from 'vitest';
import { calculateProRataInterest } from '../../../src/day-count/pro-rata';
import { Decimal } from 'decimal.js';

describe('Pro-Rata Interest', () => {
  it('should calculate pro-rata interest for 1 month (ACT/365)', () => {
    const result = calculateProRataInterest({
      principal: new Decimal('100000'),
      annualRate: new Decimal('0.12'),
      startDate: new Date('2025-01-01'),
      endDate: new Date('2025-02-01'),
      convention: 'ACT/365'
    });

    expect(result.interest.toNumber()).toBeCloseTo(1019.18, 2);
    expect(result.days).toBe(31);
    expect(result.convention).toBe('ACT/365');
  });

  it('should calculate pro-rata interest for 1 month (30/360)', () => {
    const result = calculateProRataInterest({
      principal: new Decimal('100000'),
      annualRate: new Decimal('0.12'),
      startDate: new Date('2025-01-01'),
      endDate: new Date('2025-02-01'),
      convention: '30/360'
    });

    expect(result.interest.toNumber()).toBeCloseTo(986.30, 2);
    expect(result.days).toBe(31);
    expect(result.convention).toBe('30/360');
  });

  it('should calculate pro-rata interest for 6 months', () => {
    const result = calculateProRataInterest({
      principal: new Decimal('50000'),
      annualRate: new Decimal('0.10'),
      startDate: new Date('2025-01-01'),
      endDate: new Date('2025-07-01'),
      convention: 'ACT/365'
    });

    expect(result.interest.toNumber()).toBeCloseTo(2479.45, 2);
    expect(result.days).toBe(181);
  });
});
EOF

echo "  ✅ Testes unitários criados (2 arquivos, 10 casos)"
echo ""

# ============================================
# 3. CRIAR GOLDEN FILES
# ============================================
echo "📄 3. Criando Golden Files..."

mkdir -p packages/engine/test/golden/onda1

# Golden File 1: 30/360
cat > packages/engine/test/golden/onda1/DAYCOUNT_001.json << 'EOF'
{
  "id": "DAYCOUNT_001",
  "description": "Pro-rata interest with 30/360 convention",
  "motorVersion": "0.3.0",
  "input": {
    "principal": "100000.00",
    "annualRate": "0.12",
    "startDate": "2025-01-01",
    "endDate": "2025-02-01",
    "convention": "30/360"
  },
  "expected": {
    "interest": "986.30",
    "yearFraction": "0.082191780821917808",
    "days": 31,
    "convention": "30/360"
  },
  "tolerance": {
    "interest": 0.01
  }
}
EOF

# Golden File 2: ACT/365
cat > packages/engine/test/golden/onda1/DAYCOUNT_002.json << 'EOF'
{
  "id": "DAYCOUNT_002",
  "description": "Pro-rata interest with ACT/365 convention",
  "motorVersion": "0.3.0",
  "input": {
    "principal": "100000.00",
    "annualRate": "0.12",
    "startDate": "2025-01-01",
    "endDate": "2025-02-01",
    "convention": "ACT/365"
  },
  "expected": {
    "interest": "1019.18",
    "yearFraction": "0.084931506849315068",
    "days": 31,
    "convention": "ACT/365"
  },
  "tolerance": {
    "interest": 0.01
  }
}
EOF

# Golden File 3: ACT/360
cat > packages/engine/test/golden/onda1/DAYCOUNT_003.json << 'EOF'
{
  "id": "DAYCOUNT_003",
  "description": "Pro-rata interest with ACT/360 convention",
  "motorVersion": "0.3.0",
  "input": {
    "principal": "50000.00",
    "annualRate": "0.10",
    "startDate": "2025-01-01",
    "endDate": "2025-07-01",
    "convention": "ACT/360"
  },
  "expected": {
    "interest": "2513.89",
    "yearFraction": "0.502777777777777778",
    "days": 181,
    "convention": "ACT/360"
  },
  "tolerance": {
    "interest": 0.01
  }
}
EOF

echo "  ✅ Golden Files criados (3 arquivos)"
echo ""

# ============================================
# 4. CRIAR RUNNER DE GOLDEN FILES
# ============================================
echo "🏃 4. Criando runner de Golden Files..."

cat > packages/engine/test/golden/onda1/runner.test.ts << 'EOF'
import { describe, it, expect } from 'vitest';
import { readdirSync, readFileSync } from 'fs';
import { join } from 'path';
import { calculateProRataInterest } from '../../../src/day-count/pro-rata';
import { Decimal } from 'decimal.js';

describe('Golden Files - ONDA 1 (Day Count)', () => {
  const goldenDir = __dirname;
  const goldenFiles = readdirSync(goldenDir)
    .filter(f => f.startsWith('DAYCOUNT_') && f.endsWith('.json'));

  goldenFiles.forEach(filename => {
    it(`should match ${filename}`, () => {
      const filepath = join(goldenDir, filename);
      const golden = JSON.parse(readFileSync(filepath, 'utf-8'));

      const result = calculateProRataInterest({
        principal: new Decimal(golden.input.principal),
        annualRate: new Decimal(golden.input.annualRate),
        startDate: new Date(golden.input.startDate),
        endDate: new Date(golden.input.endDate),
        convention: golden.input.convention
      });

      // Validate interest
      const interestDiff = Math.abs(
        result.interest.toNumber() - parseFloat(golden.expected.interest)
      );
      expect(interestDiff).toBeLessThanOrEqual(golden.tolerance.interest);

      // Validate other fields
      expect(result.days).toBe(golden.expected.days);
      expect(result.convention).toBe(golden.expected.convention);
      
      // Year fraction should match (with tolerance)
      const yfDiff = Math.abs(
        result.yearFraction.toNumber() - parseFloat(golden.expected.yearFraction)
      );
      expect(yfDiff).toBeLessThanOrEqual(0.0001);
    });
  });
});
EOF

echo "  ✅ Runner de Golden Files criado"
echo ""

# ============================================
# 5. IMPLEMENTAR API
# ============================================
echo "🌐 5. Implementando API..."

# 5.1 Criar schema Zod
mkdir -p packages/api/src/schemas

cat > packages/api/src/schemas/day-count.schema.ts << 'EOF'
import { z } from 'zod';

export const dayCountRequestSchema = z.object({
  principal: z.number().positive(),
  annualRate: z.number().min(0).max(1),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  convention: z.enum(['30/360', 'ACT/365', 'ACT/360'])
});

export type DayCountRequest = z.infer<typeof dayCountRequestSchema>;
EOF

# 5.2 Criar route
mkdir -p packages/api/src/routes

cat > packages/api/src/routes/day-count.routes.ts << 'EOF'
import { FastifyPluginAsync } from 'fastify';
import { Decimal } from 'decimal.js';
import { calculateProRataInterest, ENGINE_VERSION } from '@finmath/engine';
import { dayCountRequestSchema } from '../schemas/day-count.schema';
import { createApiError } from '../infrastructure/errors';

export const dayCountRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.post('/day-count', {
    schema: {
      description: 'Calculate pro-rata interest using day count conventions',
      tags: ['day-count'],
      body: {
        type: 'object',
        required: ['principal', 'annualRate', 'startDate', 'endDate', 'convention'],
        properties: {
          principal: { type: 'number', description: 'Principal amount' },
          annualRate: { type: 'number', description: 'Annual interest rate (decimal)' },
          startDate: { type: 'string', format: 'date', description: 'Start date (YYYY-MM-DD)' },
          endDate: { type: 'string', format: 'date', description: 'End date (YYYY-MM-DD)' },
          convention: { 
            type: 'string', 
            enum: ['30/360', 'ACT/365', 'ACT/360'],
            description: 'Day count convention' 
          }
        }
      },
      response: {
        200: {
          type: 'object',
          properties: {
            calculationId: { type: 'string' },
            motorVersion: { type: 'string' },
            result: {
              type: 'object',
              properties: {
                interest: { type: 'number' },
                yearFraction: { type: 'number' },
                days: { type: 'number' },
                convention: { type: 'string' }
              }
            }
          }
        }
      }
    },
    handler: async (request, reply) => {
      const calculationId = request.id;
      
      try {
        // Validate request
        const body = dayCountRequestSchema.parse(request.body);
        
        fastify.log.info({ calculationId, input: body }, 'Calculating pro-rata interest');
        
        // Calculate
        const result = calculateProRataInterest({
          principal: new Decimal(body.principal),
          annualRate: new Decimal(body.annualRate),
          startDate: new Date(body.startDate),
          endDate: new Date(body.endDate),
          convention: body.convention
        });
        
        fastify.log.info({ calculationId, result }, 'Calculation completed');
        
        return reply.status(200).send({
          calculationId,
          motorVersion: ENGINE_VERSION,
          result: {
            interest: result.interest.toNumber(),
            yearFraction: result.yearFraction.toNumber(),
            days: result.days,
            convention: result.convention
          }
        });
      } catch (error) {
        throw createApiError(error, calculationId);
      }
    }
  });
};
EOF

# 5.3 Atualizar server.ts para incluir nova rota
cat > packages/api/src/server.ts << 'EOF'
import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import { randomUUID } from 'crypto';
import { createLogger } from './infrastructure/logger';
import { errorHandler } from './infrastructure/errors';
import { dayCountRoutes } from './routes/day-count.routes';
import { ENGINE_VERSION } from '@finmath/engine';

const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3001;

async function buildServer() {
  const fastify = Fastify({
    logger: createLogger(),
    genReqId: () => randomUUID()
  });

  // Security
  await fastify.register(helmet);
  await fastify.register(cors);

  // Swagger
  await fastify.register(swagger, {
    openapi: {
      info: {
        title: 'FinMath API',
        version: ENGINE_VERSION,
        description: 'Financial mathematics calculation API'
      },
      tags: [
        { name: 'health', description: 'Health check' },
        { name: 'day-count', description: 'Day count conventions' }
      ]
    }
  });

  await fastify.register(swaggerUi, {
    routePrefix: '/api-docs'
  });

  // Error handler
  fastify.setErrorHandler(errorHandler);

  // Health check
  fastify.get('/health', {
    schema: {
      description: 'Health check endpoint',
      tags: ['health'],
      response: {
        200: {
          type: 'object',
          properties: {
            status: { type: 'string' },
            motorVersion: { type: 'string' },
            timestamp: { type: 'string' }
          }
        }
      }
    },
    handler: async (request, reply) => {
      return reply.status(200).send({
        status: 'healthy',
        motorVersion: ENGINE_VERSION,
        timestamp: new Date().toISOString()
      });
    }
  });

  // Routes
  await fastify.register(dayCountRoutes, { prefix: '/api' });

  return fastify;
}

async function start() {
  const server = await buildServer();
  
  try {
    await server.listen({ port: PORT, host: '0.0.0.0' });
    server.log.info(`Server listening on port ${PORT}`);
    server.log.info(`Swagger UI: http://localhost:${PORT}/api-docs`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
}

if (require.main === module) {
  start();
}

export { buildServer };
EOF

echo "  ✅ API implementada (3 arquivos)"
echo ""

# ============================================
# 6. CRIAR TESTES DE INTEGRAÇÃO
# ============================================
echo "🧪 6. Criando testes de integração da API..."

cat > packages/api/test/integration/day-count.test.ts << 'EOF'
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { buildServer } from '../../src/server';
import type { FastifyInstance } from 'fastify';

describe('Day Count API Integration', () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await buildServer();
    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  describe('POST /api/day-count', () => {
    it('should calculate pro-rata interest with 30/360', async () => {
      const response = await server.inject({
        method: 'POST',
        url: '/api/day-count',
        payload: {
          principal: 100000,
          annualRate: 0.12,
          startDate: '2025-01-01',
          endDate: '2025-02-01',
          convention: '30/360'
        }
      });

      expect(response.statusCode).toBe(200);
      
      const body = JSON.parse(response.body);
      expect(body.calculationId).toBeDefined();
      expect(body.motorVersion).toBe('0.3.0');
      expect(body.result.interest).toBeCloseTo(986.30, 2);
      expect(body.result.days).toBe(31);
      expect(body.result.convention).toBe('30/360');
    });

    it('should calculate pro-rata interest with ACT/365', async () => {
      const response = await server.inject({
        method: 'POST',
        url: '/api/day-count',
        payload: {
          principal: 100000,
          annualRate: 0.12,
          startDate: '2025-01-01',
          endDate: '2025-02-01',
          convention: 'ACT/365'
        }
      });

      expect(response.statusCode).toBe(200);
      
      const body = JSON.parse(response.body);
      expect(body.result.interest).toBeCloseTo(1019.18, 2);
      expect(body.result.convention).toBe('ACT/365');
    });

    it('should validate required fields', async () => {
      const response = await server.inject({
        method: 'POST',
        url: '/api/day-count',
        payload: {
          principal: 100000
          // Missing fields
        }
      });

      expect(response.statusCode).toBe(400);
      
      const body = JSON.parse(response.body);
      expect(body.error.code).toBe('VALIDATION_ERROR');
    });

    it('should validate convention enum', async () => {
      const response = await server.inject({
        method: 'POST',
        url: '/api/day-count',
        payload: {
          principal: 100000,
          annualRate: 0.12,
          startDate: '2025-01-01',
          endDate: '2025-02-01',
          convention: 'INVALID'
        }
      });

      expect(response.statusCode).toBe(400);
      
      const body = JSON.parse(response.body);
      expect(body.error.code).toBe('VALIDATION_ERROR');
    });
  });
});
EOF

echo "  ✅ Testes de integração criados (4 casos)"
echo ""

# ============================================
# 7. ATUALIZAR PACKAGE.JSON DO MOTOR
# ============================================
echo "📝 7. Atualizando package.json do motor..."

cd packages/engine

# Atualizar versão
npm version 0.3.0 --no-git-tag-version > /dev/null 2>&1

cd ../..

echo "  ✅ Versão do motor: 0.3.0"
echo ""

# ============================================
# 8. INSTALAR DEPENDÊNCIA ZOD NA API
# ============================================
echo "📦 8. Instalando dependência zod na API..."

cd packages/api
pnpm add zod > /dev/null 2>&1
cd ../..

echo "  ✅ Zod instalado"
echo ""

# ============================================
# RESUMO FINAL
# ============================================
echo "=========================================="
echo "✅ ONDA 1 IMPLEMENTADA COM SUCESSO!"
echo "=========================================="
echo ""
echo "📊 Arquivos criados:"
echo "   Motor:"
echo "   - src/day-count/index.ts"
echo "   - src/day-count/conventions.ts"
echo "   - src/day-count/pro-rata.ts"
echo "   - test/unit/day-count/conventions.test.ts"
echo "   - test/unit/day-count/pro-rata.test.ts"
echo "   - test/golden/onda1/DAYCOUNT_001-003.json"
echo "   - test/golden/onda1/runner.test.ts"
echo ""
echo "   API:"
echo "   - src/schemas/day-count.schema.ts"
echo "   - src/routes/day-count.routes.ts"
echo "   - src/server.ts (atualizado)"
echo "   - test/integration/day-count.test.ts"
echo ""
echo "🎯 PRÓXIMO PASSO:"
echo "   Execute: ./validar-onda-1.sh"
echo ""

