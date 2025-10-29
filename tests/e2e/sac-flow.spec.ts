import { test, expect } from "@playwright/test";
import {
  fillPriceForm,
  validateMetrics,
  validateScheduleTable,
  measurePerformance,
} from "../utils/helpers";
import sacData from "../fixtures/sac-data.json" with { type: "json" };

test.describe("SAC Flow - Sistema de Amortização Constante", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="sac-calculator-link"]');
    await expect(page).toHaveTitle(/SAC/);
  });

  test("1. Deve calcular SAC básico corretamente", async ({ page }) => {
    await fillPriceForm(page, sacData.basic);

    const duration = await measurePerformance(page, async () => {
      await page.click('[data-testid="calculate-btn"]');
      await page.waitForSelector('[data-testid="results-section"]');
    });

    expect(duration).toBeLessThan(150);

    // Validar primeira e última parcela
    const firstPMT = await page.textContent(
      '[data-testid="schedule-row"]:nth-child(1) [data-testid="pmt-cell"]',
    );
    const firstValue = parseFloat(
      firstPMT?.replace(/[^\d.,]/g, "").replace(",", ".") || "0",
    );
    expect(Math.abs(firstValue - sacData.basic.expectedFirstPMT)).toBeLessThan(
      0.01,
    );
  });

  test("2. Deve ter amortização constante", async ({ page }) => {
    await fillPriceForm(page, sacData.basic);
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="results-section"]');

    // Verificar que amortização é constante
    const amortizations = await page.$$eval(
      '[data-testid="amortization-cell"]',
      (cells) =>
        cells
          .slice(0, 3)
          .map((c) =>
            parseFloat(
              c.textContent?.replace(/[^\d.,]/g, "").replace(",", ".") || "0",
            ),
          ),
    );

    expect(amortizations[0]).toBeCloseTo(amortizations[1], 2);
    expect(amortizations[1]).toBeCloseTo(amortizations[2], 2);
  });

  test("3. Deve ter parcelas decrescentes", async ({ page }) => {
    await fillPriceForm(page, sacData.basic);
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="results-section"]');

    const pmts = await page.$$eval('[data-testid="pmt-cell"]', (cells) =>
      cells
        .slice(0, 3)
        .map((c) =>
          parseFloat(
            c.textContent?.replace(/[^\d.,]/g, "").replace(",", ".") || "0",
          ),
        ),
    );

    expect(pmts[0]).toBeGreaterThan(pmts[1]);
    expect(pmts[1]).toBeGreaterThan(pmts[2]);
  });

  test("4. Deve comparar com Price", async ({ page }) => {
    await fillPriceForm(page, sacData.basic);
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="results-section"]');

    // Clicar em comparar
    await page.click('[data-testid="compare-with-price-btn"]');

    // Verificar comparação
    await expect(
      page.locator('[data-testid="comparison-table"]'),
    ).toBeVisible();
  });
});
