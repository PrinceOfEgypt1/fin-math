// packages/api/src/schemas/price.schema.ts
import { z } from "zod";

export const PriceRequestSchema = z.object({
  pv: z.number().positive().describe("Valor presente (principal)"),
  rate: z.number().positive().describe("Taxa de juros por período"),
  n: z.number().int().positive().describe("Número de períodos"),
});

export type PriceRequest = z.infer<typeof PriceRequestSchema>;

export const PriceResponseSchema = z.object({
  schedule: z.array(
    z.object({
      k: z.number(),
      pmt: z.number(),
      interest: z.number(),
      amort: z.number(),
      balance: z.number(),
    }),
  ),
  snapshotId: z.string().uuid().optional(),
});
