// packages/api/src/schemas/sac.schema.ts
import { z } from "zod";

export const SacRequestSchema = z.object({
  pv: z.number().positive().describe("Valor presente (principal)"),
  rate: z.number().positive().describe("Taxa de juros por período"),
  n: z.number().int().positive().describe("Número de períodos"),
});

export type SacRequest = z.infer<typeof SacRequestSchema>;
