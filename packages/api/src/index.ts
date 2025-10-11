import Fastify from "fastify";
import cors from "@fastify/cors";
import { routes } from "./routes";
const app = Fastify({ logger: true });
await app.register(cors, { origin: true });
await app.register(routes, { prefix: "/v1/api" });
const port = Number(process.env.PORT || 3000);
app.listen({ port, host: "0.0.0.0" }).then(() => {
  app.log.info(`FinMath API rodando em http://localhost:${port}/v1/api`);
});
