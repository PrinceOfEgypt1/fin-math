import { z } from "zod";

export const CETBasicRequestSchema = z.object({
  pv: z.number().positive("Valor presente deve ser positivo"),
  pmt: z.number().positive("Valor da parcela deve ser positivo"),
  n: z.number().int().positive().max(480, "Número de parcelas deve ser <= 480"),
  feesT0: z.array(z.number().nonnegative()).default([]),
  baseAnnual: z.number().int().positive().default(12),
});

export type CETBasicRequest = z.infer<typeof CETBasicRequestSchema>;

export const CETBasicResponseSchema = z.object({
  irrMonthly: z.number(),
  cetAnnual: z.number(),
  valorLiquido: z.number(),
  totalFees: z.number(),
  cashflows: z.array(z.number()),
  meta: z.object({
    motorVersion: z.string(),
    calculationId: z.string(),
    timestamp: z.string(),
  }),
});

export type CETBasicResponse = z.infer<typeof CETBasicResponseSchema>;
