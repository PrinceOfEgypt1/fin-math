// packages/api/src/index.ts
import { build } from "./server";

const start = async () => {
  try {
    const fastify = await build();
    const port = Number(process.env.PORT) || 3001;
    const host = process.env.HOST || "0.0.0.0";

    await fastify.listen({ port, host });

    console.log(`✅ Server listening at http://localhost:${port}`);
    console.log(`📚 Swagger UI: http://localhost:${port}/api-docs`);
  } catch (err) {
    console.error("❌ Error starting server:", err);
    process.exit(1);
  }
};

start();
