import { defineConfig, devices } from "@playwright/test";

/**
 * Configuração Playwright para FinMath
 *
 * Testes E2E com:
 * - Múltiplos browsers (Chromium, Firefox, WebKit)
 * - Viewport responsivo
 * - Screenshots e vídeos em falhas
 * - Relatórios HTML
 * - Paralelização
 */
export default defineConfig({
  testDir: "./tests/e2e",

  /* Timeout por teste */
  timeout: 30 * 1000,

  /* Configurações globais */
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  /* Reporter */
  reporter: [
    ["html", { outputFolder: "test-results/html" }],
    ["json", { outputFile: "test-results/results.json" }],
    ["junit", { outputFile: "test-results/junit.xml" }],
    ["list"],
  ],

  /* Configurações compartilhadas */
  use: {
    /* URL base */
    baseURL: "http://localhost:5173",

    /* Coletar traces em falhas */
    trace: "on-first-retry",

    /* Screenshots */
    screenshot: "only-on-failure",

    /* Vídeo */
    video: "retain-on-failure",

    /* Timeout de ação */
    actionTimeout: 10 * 1000,

    /* Timeout de navegação */
    navigationTimeout: 15 * 1000,
  },

  /* Configurar servidor local */
  webServer: {
    command: "pnpm dev",
    url: "http://localhost:5173",
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },

  /* Projetos - Browsers diferentes */
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1920, height: 1080 },
      },
    },

    {
      name: "firefox",
      use: {
        ...devices["Desktop Firefox"],
        viewport: { width: 1920, height: 1080 },
      },
    },

    {
      name: "webkit",
      use: {
        ...devices["Desktop Safari"],
        viewport: { width: 1920, height: 1080 },
      },
    },

    /* Mobile viewports */
    {
      name: "mobile-chrome",
      use: { ...devices["Pixel 5"] },
    },
    {
      name: "mobile-safari",
      use: { ...devices["iPhone 12"] },
    },

    /* Tablet */
    {
      name: "tablet",
      use: {
        ...devices["iPad Pro"],
        viewport: { width: 1024, height: 1366 },
      },
    },
  ],
});
