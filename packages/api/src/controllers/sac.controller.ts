// packages/api/src/controllers/sac.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { SacRequestSchema } from "../schemas/sac.schema";
import { generateSacSchedule } from "@finmath/engine";
import { snapshotService } from "../services/snapshot.service";
import Decimal from "decimal.js";

export async function postSac(request: FastifyRequest, reply: FastifyReply) {
  try {
    const body = SacRequestSchema.parse(request.body);

    const result = generateSacSchedule({
      pv: new Decimal(body.pv),
      annualRate: new Decimal(body.rate),
      n: body.n,
    });

    const snapshot = snapshotService.create(body, result, "/api/sac");

    return reply.status(200).send({
      schedule: result.schedule,
      amortConst: result.amortConst,
      snapshotId: snapshot.id,
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
