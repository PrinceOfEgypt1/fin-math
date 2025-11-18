import { z } from "zod";

const dateStringSchema = z.string().refine((val) => !isNaN(Date.parse(val)), {
  message: "Invalid date format. Use ISO 8601 (YYYY-MM-DD)",
});

export const dayCountRequestSchema = z.object({
  startDate: dateStringSchema,
  endDate: dateStringSchema,
  convention: z.enum(["30/360", "ACT/365", "ACT/360", "ACT/ACT"]),
});

export type DayCountRequest = z.infer<typeof dayCountRequestSchema>;

export const dayCountResponseSchema = z.object({
  days: z.number().int(),
  yearFraction: z.number(),
  convention: z.string(),
  startDate: z.string(),
  endDate: z.string(),
});

export type DayCountResponse = z.infer<typeof dayCountResponseSchema>;
