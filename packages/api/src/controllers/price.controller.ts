// packages/api/src/controllers/price.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { PriceRequestSchema } from "../schemas/price.schema";
import { generatePriceSchedule } from "@finmath/engine";
import { snapshotService } from "../services/snapshot.service";
import Decimal from "decimal.js";

export async function postPrice(request: FastifyRequest, reply: FastifyReply) {
  try {
    const body = PriceRequestSchema.parse(request.body);

    const result = generatePriceSchedule({
      pv: new Decimal(body.pv),
      annualRate: new Decimal(body.rate),
      n: body.n,
    });

    const snapshot = snapshotService.create(body, result, "/api/price");

    return reply.status(200).send({
      schedule: result.schedule,
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
