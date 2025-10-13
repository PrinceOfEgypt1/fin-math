import { z } from "zod";

export const priceRequestSchema = z.object({
  pv: z.number().positive(),
  annualRate: z.number().min(0).max(1),
  n: z.number().int().positive().max(360),
});

export type PriceRequest = z.infer<typeof priceRequestSchema>;
