import { FastifyPluginAsync } from "fastify";
import { Decimal } from "decimal.js";
import { calculateProRataInterest, ENGINE_VERSION } from "@finmath/engine";
import { dayCountRequestSchema } from "../schemas/day-count.schema";
import { ValidationError } from "../infrastructure/errors";

export const dayCountRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.post("/day-count", {
    schema: {
      description: "Calculate pro-rata interest using day count conventions",
      tags: ["day-count"],
      body: {
        type: "object",
        required: [
          "principal",
          "annualRate",
          "startDate",
          "endDate",
          "convention",
        ],
        properties: {
          principal: { type: "number", description: "Principal amount" },
          annualRate: {
            type: "number",
            description: "Annual interest rate (decimal)",
          },
          startDate: {
            type: "string",
            format: "date",
            description: "Start date (YYYY-MM-DD)",
          },
          endDate: {
            type: "string",
            format: "date",
            description: "End date (YYYY-MM-DD)",
          },
          convention: {
            type: "string",
            enum: ["30/360", "ACT/365", "ACT/360"],
            description: "Day count convention",
          },
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
                interest: { type: "number" },
                yearFraction: { type: "number" },
                days: { type: "number" },
                convention: { type: "string" },
              },
            },
          },
        },
      },
    },
    handler: async (request, reply) => {
      const calculationId = request.id;

      try {
        const body = dayCountRequestSchema.parse(request.body);

        fastify.log.info(
          { calculationId, input: body },
          "Calculating pro-rata interest",
        );

        const result = calculateProRataInterest({
          principal: new Decimal(body.principal),
          annualRate: new Decimal(body.annualRate),
          startDate: new Date(body.startDate),
          endDate: new Date(body.endDate),
          convention: body.convention,
        });

        fastify.log.info({ calculationId, result }, "Calculation completed");

        return reply.status(200).send({
          calculationId,
          motorVersion: ENGINE_VERSION,
          result: {
            interest: result.interest.toNumber(),
            yearFraction: result.yearFraction.toNumber(),
            days: result.days,
            convention: result.convention,
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
