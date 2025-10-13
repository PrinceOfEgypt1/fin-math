import { FastifyPluginAsync } from "fastify";
import { Decimal } from "decimal.js";
import { generatePriceSchedule, ENGINE_VERSION } from "@finmath/engine";
import { priceRequestSchema } from "../schemas/price.schema";
import { ValidationError } from "../infrastructure/errors";

export const priceRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.post("/price", {
    schema: {
      description: "Calculate PRICE amortization schedule",
      tags: ["amortization"],
      body: {
        type: "object",
        required: ["pv", "annualRate", "n"],
        properties: {
          pv: { type: "number", description: "Present value (principal)" },
          annualRate: {
            type: "number",
            description: "Annual interest rate (decimal)",
          },
          n: { type: "number", description: "Number of periods (months)" },
        },
      },
      response: {
        200: {
          type: "object",
          properties: {
            calculationId: { type: "string" },
            motorVersion: { type: "string" },
            result: {
              type: "object",
              properties: {
                pmt: { type: "number" },
                schedule: {
                  type: "array",
                  items: {
                    type: "object",
                    properties: {
                      period: { type: "number" },
                      pmt: { type: "number" },
                      interest: { type: "number" },
                      amortization: { type: "number" },
                      balance: { type: "number" },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    handler: async (request, reply) => {
      const calculationId = request.id;

      try {
        const body = priceRequestSchema.parse(request.body);

        fastify.log.info(
          { calculationId, input: body },
          "Calculating PRICE schedule",
        );

        const result = generatePriceSchedule({
          pv: new Decimal(body.pv),
          annualRate: new Decimal(body.annualRate),
          n: body.n,
        });

        fastify.log.info(
          { calculationId, pmt: result.pmt.toNumber() },
          "Calculation completed",
        );

        return reply.status(200).send({
          calculationId,
          motorVersion: ENGINE_VERSION,
          result: {
            pmt: result.pmt.toNumber(),
            schedule: result.schedule.map((row) => ({
              period: row.period,
              pmt: row.pmt.toNumber(),
              interest: row.interest.toNumber(),
              amortization: row.amortization.toNumber(),
              balance: row.balance.toNumber(),
            })),
          },
        });
      } catch (error) {
        if (error instanceof Error) {
          throw new ValidationError(error.message, undefined, calculationId);
        }
        throw error;
      }
    },
  });
};
