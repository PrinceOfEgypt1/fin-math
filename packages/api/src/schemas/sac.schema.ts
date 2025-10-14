import { z } from "zod";
export const SacRequestSchema = z.object({
  pv: z.number().min(100),
  rateMonthly: z.number().min(0),
  n: z.number().int().min(1),
  feesT0: z.number().min(0).default(0),
});
export type SacRequest = z.infer<typeof SacRequestSchema>;
