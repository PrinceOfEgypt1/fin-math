// packages/api/src/controllers/sac.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { SacRequestSchema } from "../schemas/sac.schema";
import { snapshotService } from "../services/snapshot.service";

export async function postSac(request: FastifyRequest, reply: FastifyReply) {
  try {
    const body = SacRequestSchema.parse(request.body);

    // TODO: Implementar SAC quando disponível no motor
    return reply.status(501).send({
      error: {
        code: "NOT_IMPLEMENTED",
        message: "SAC system not yet implemented in engine",
        details: "Use POST /api/price for now",
      },
    });
  } catch (error: any) {
    return reply.status(400).send({
      error: {
        code: "VALIDATION_ERROR",
        message: "Validation failed",
        details: error.errors || [{ message: error.message }],
      },
    });
  }
}
