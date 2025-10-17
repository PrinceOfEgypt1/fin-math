// packages/api/src/controllers/snapshot.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { snapshotService } from "../services/snapshot.service";

interface SnapshotParams {
  id: string;
}

/**
 * GET /api/snapshot/:id
 */
export async function getSnapshot(
  request: FastifyRequest<{ Params: SnapshotParams }>,
  reply: FastifyReply,
) {
  const { id } = request.params;
  const snapshot = snapshotService.get(id);

  if (!snapshot) {
    return reply.status(404).send({
      error: "Snapshot not found",
      id,
    });
  }

  return reply.status(200).send(snapshot);
}
