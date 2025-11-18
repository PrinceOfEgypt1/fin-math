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

export type ValidateScheduleRequest = z.infer<
  typeof ValidateScheduleRequestSchema
>;

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
