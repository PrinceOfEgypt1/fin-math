// packages/api/src/schemas/snapshot.schema.ts
import { z } from "zod";

/**
 * Schema para resposta de snapshot
 */
export const SnapshotResponseSchema = z.object({
  id: z.string().uuid(),
  hash: z.string(),
  input: z.record(z.any()),
  output: z.any(),
  meta: z.object({
    motorVersion: z.string(),
    timestamp: z.string().datetime(),
    endpoint: z.string(),
  }),
});

export type SnapshotResponse = z.infer<typeof SnapshotResponseSchema>;
