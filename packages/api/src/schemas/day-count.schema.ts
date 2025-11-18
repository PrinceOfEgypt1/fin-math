import { z } from "zod";

export const dayCountRequestSchema = z.object({
  principal: z.number().positive(),
  annualRate: z.number().min(0).max(1),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  convention: z.enum(["30/360", "ACT/365", "ACT/360"]),
});

export type DayCountRequest = z.infer<typeof dayCountRequestSchema>;
