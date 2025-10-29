import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      "@finmath/engine": path.resolve(__dirname, "../engine/src"),
    },
  },
  server: {
    port: 5173,
    host: "0.0.0.0",
    strictPort: false,
  },
  build: {
    outDir: "dist",
    sourcemap: true,
  },
  optimizeDeps: {
    include: ["react", "react-dom"],
  },
});
