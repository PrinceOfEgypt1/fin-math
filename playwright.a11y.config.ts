import { defineConfig, devices } from "@playwright/test";

/**
 * Configuração do Playwright para testes de acessibilidade
 * Baseada na configuração principal mas com testDir específico
 */
export default defineConfig({
  testDir: "./tests/a11y",
  timeout: 30 * 1000,
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  reporter: [
    ["html", { outputFolder: "playwright-report-a11y" }],
    ["json", { outputFile: "docs/a11y/results.json" }],
    ["list"],
  ],

  use: {
    baseURL: "http://localhost:5173",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
    actionTimeout: 10 * 1000,
    navigationTimeout: 15 * 1000,
  },

  webServer: {
    command: "pnpm -F @finmath/ui dev",
    url: "http://localhost:5173",
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },

  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1920, height: 1080 },
      },
    },
  ],
});
