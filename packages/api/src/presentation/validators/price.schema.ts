import { z } from "zod";
export const PriceRequestSchema = z.object({
  pv: z.number().positive().min(100).max(10_000_000),
  rate: z.number().positive().min(0.0001).max(1.0),
  n: z.number().int().positive().min(1).max(480),
  daycount: z.enum(["30360", "ACT365"]).optional().default("30360"),
  prorata: z.boolean().optional().default(false),
  feesT0: z
    .array(
      z.object({ name: z.string().min(1), value: z.number().nonnegative() }),
    )
    .optional()
    .default([]),
});
export type PriceRequest = z.infer<typeof PriceRequestSchema>;
export const PriceResponseSchema = z.object({
  pmt: z.number(),
  totalInterest: z.number(),
  totalPaid: z.number(),
  schedule: z.array(
    z.object({
      period: z.number(),
      date: z.string(),
      payment: z.number(),
      interest: z.number(),
      amortization: z.number(),
      balance: z.number(),
    }),
  ),
  meta: z.object({
    calculationId: z.string().uuid(),
    motorVersion: z.string(),
    timestamp: z.string(),
  }),
});
export type PriceResponse = z.infer<typeof PriceResponseSchema>;
