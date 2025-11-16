// packages/api/src/schemas/cet.schema.ts
import { z } from "zod";

export const CetBasicRequestSchema = z.object({
  pv: z.number().positive().describe("Valor financiado"),
  rate: z.number().positive().describe("Taxa de juros mensal"),
  n: z.number().int().positive().describe("Número de parcelas"),
  iof: z.number().nonnegative().optional().describe("IOF (opcional)"),
  tac: z.number().nonnegative().optional().describe("TAC (opcional)"),
});

export type CetBasicRequest = z.infer<typeof CetBasicRequestSchema>;
