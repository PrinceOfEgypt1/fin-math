import { z } from "zod";

export const PriceRequestSchema = z.object({
  pv: z.number().min(100),
  annualRate: z.number().min(0),
  n: z.number().int().min(1).max(360), // ✅ 30 anos (razoável)
  feesT0: z.number().min(0).default(0).optional(),
  daycount: z.enum(["30/360", "ACT/365"]).default("30/360").optional(),
  proRata: z.boolean().default(true).optional(),
  firstDueDate: z.string().optional(),
});

export type PriceRequest = z.infer<typeof PriceRequestSchema>;

export const PriceResponseSchema = z.object({
  pmt: z.number(),
  schedule: z.array(
    z.object({
      k: z.number().int().min(1),
      pmt: z.number(),
      interest: z.number(),
      amort: z.number(),
      balance: z.number(),
      date: z.string().optional(),
    }),
  ),
  totals: z.object({
    totalPaid: z.number(),
    totalInterest: z.number(),
    feesT0: z.number(),
  }),
  meta: z.object({
    calculationId: z.string(),
    motorVersion: z.string(),
    durationMs: z.number(),
  }),
});
