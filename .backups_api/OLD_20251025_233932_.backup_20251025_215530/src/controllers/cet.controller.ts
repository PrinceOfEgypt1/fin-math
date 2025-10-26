// packages/api/src/controllers/cet.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { CetBasicRequestSchema } from "../schemas/cet.schema";
import { cetBasic, generatePriceSchedule } from "@finmath/engine";
import { snapshotService } from "../services/snapshot.service";
import Decimal from "decimal.js";

export async function postCetBasic(
  request: FastifyRequest,
  reply: FastifyReply,
) {
  try {
    const body = CetBasicRequestSchema.parse(request.body);

    const priceResult = generatePriceSchedule({
      pv: new Decimal(body.pv),
      annualRate: new Decimal(body.rate),
      n: body.n,
    });

    const pmt = priceResult.schedule[0]?.pmt.toNumber() || 0;

    const feesT0 = [];
    if (body.iof) feesT0.push(body.iof);
    if (body.tac) feesT0.push(body.tac);

    const cetResult = cetBasic(body.pv, pmt, body.n, feesT0);

    const result = {
      cet: cetResult.cetAnnual,
      irrMonthly: cetResult.irrMonthly,
      schedule: priceResult.schedule,
    };

    const snapshot = snapshotService.create(body, result, "/api/cet/basic");

    return reply.status(200).send({
      ...result,
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
