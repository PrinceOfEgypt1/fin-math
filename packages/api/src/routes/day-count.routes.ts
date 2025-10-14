import { FastifyPluginAsync } from "fastify";
import {
  daysBetween,
  yearFraction,
  type DayCountConvention,
} from "@finmath/engine";
import { dayCountRequestSchema } from "../validation/day-count.schema.js";

export const dayCountRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.post(
    "/day-count",
    {
      schema: {
        description: "Calculate days between dates and year fraction",
        tags: ["Day Count"],
        body: {
          type: "object",
          required: ["startDate", "endDate", "convention"],
          properties: {
            startDate: { type: "string", format: "date" },
            endDate: { type: "string", format: "date" },
            convention: {
              type: "string",
              enum: ["30/360", "ACT/365", "ACT/360", "ACT/ACT"],
            },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              days: { type: "integer" },
              yearFraction: { type: "number" },
              convention: { type: "string" },
              startDate: { type: "string" },
              endDate: { type: "string" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      const validation = dayCountRequestSchema.safeParse(request.body);

      if (!validation.success) {
        return reply.status(400).send({
          error: "Validation failed",
          details: validation.error.format(),
        });
      }

      const { startDate, endDate, convention } = validation.data;

      const start = new Date(startDate);
      const end = new Date(endDate);

      const days = daysBetween(start, end, convention as DayCountConvention);
      const yf = yearFraction(start, end, convention as DayCountConvention);

      return {
        days,
        yearFraction: yf,
        convention,
        startDate,
        endDate,
      };
    },
  );
};
