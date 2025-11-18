import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],

  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      "@/components": path.resolve(__dirname, "./src/components"),
      "@/pages": path.resolve(__dirname, "./src/pages"),
      "@/hooks": path.resolve(__dirname, "./src/hooks"),
      "@/lib": path.resolve(__dirname, "./src/lib"),
      "@/types": path.resolve(__dirname, "./src/types"),
      "@/styles": path.resolve(__dirname, "./src/styles"),
    },
  },

  server: {
    port: 5173,
    strictPort: true,
    open: true,
    host: true,
  },

  build: {
    outDir: "dist",
    sourcemap: true,
    // Performance budget (Guia de Excelência)
    chunkSizeWarningLimit: 600,
    rollupOptions: {
      output: {
        manualChunks: {
          // Code splitting para otimização
          "react-vendor": ["react", "react-dom"],
          finmath: ["finmath-engine", "decimal.js"],
          charts: ["recharts"],
          animations: ["framer-motion"],
        },
      },
    },
  },

  optimizeDeps: {
    include: [
      "react",
      "react-dom",
      "finmath-engine",
      "decimal.js",
      "recharts",
      "framer-motion",
      "lucide-react",
    ],
  },

  // Performance: Limite de tamanho JS ≤ 170 kB gzip (Guia)
  preview: {
    port: 4173,
    strictPort: true,
  },
});
