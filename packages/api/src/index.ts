import Fastify from "fastify";
import cors from "@fastify/cors";
import { priceRoutes } from "./routes/price.routes";
import { logger } from "./infrastructure/logger";

const app = Fastify({ logger: false });
await app.register(cors, { origin: true });
app.get("/health", async () => ({
  status: "ok",
  motorVersion: "0.1.1",
  timestamp: new Date().toISOString(),
}));
await app.register(priceRoutes);

const start = async () => {
  try {
    await app.listen({ port: 3001, host: "0.0.0.0" });
    logger.info("🚀 API http://localhost:3001");
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
};
start();
