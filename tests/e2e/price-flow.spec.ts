import { test, expect } from "@playwright/test";
import {
  fillPriceForm,
  validateMetrics,
  validateScheduleTable,
  exportAndValidateCSV,
  checkBasicA11y,
  measurePerformance,
} from "../utils/helpers";
import priceData from "../fixtures/price-data.json";

test.describe("Price Flow - Sistema de Amortização Price", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');
    await expect(page).toHaveTitle(/Price/);
  });

  test("1. Deve calcular Price básico corretamente", async ({ page }) => {
    // Preencher formulário
    await fillPriceForm(page, priceData.basic);

    // Clicar em calcular
    const duration = await measurePerformance(page, async () => {
      await page.click('[data-testid="calculate-btn"]');
      await page.waitForSelector('[data-testid="results-section"]');
    });

    // Validar performance (≤150ms conforme spec)
    expect(duration).toBeLessThan(150);

    // Validar resultados
    await validateMetrics(page, {
      pmt: priceData.basic.expectedPMT,
      total: priceData.basic.expectedTotal,
      interest: priceData.basic.expectedInterest,
    });

    // Validar cronograma
    await validateScheduleTable(page, priceData.basic.periods);
  });

  test("2. Deve calcular Price de longo prazo", async ({ page }) => {
    await fillPriceForm(page, priceData.longTerm);
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="results-section"]');

    await validateMetrics(page, {
      pmt: priceData.longTerm.expectedPMT,
    });
  });

  test("3. Deve validar campos obrigatórios", async ({ page }) => {
    // Tentar calcular sem preencher
    await page.click('[data-testid="calculate-btn"]');

    // Deve mostrar erros
    await expect(page.locator('[role="alert"]')).toHaveCount(3);

    // Validar mensagens de erro
    await expect(page.locator('[data-testid="pv-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="rate-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="periods-error"]')).toBeVisible();
  });

  test("4. Deve exportar CSV com sucesso", async ({ page }) => {
    // Calcular primeiro
    await fillPriceForm(page, priceData.basic);
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="results-section"]');

    // Exportar CSV
    const download = await exportAndValidateCSV(page);

    // Validar conteúdo do CSV
    const path = await download.path();
    expect(path).toBeTruthy();
  });

  test("5. Deve ter acessibilidade básica", async ({ page }) => {
    await checkBasicA11y(page);

    // Navegar por teclado
    await page.keyboard.press("Tab");
    await page.keyboard.press("Tab");
    await page.keyboard.press("Tab");

    // Verificar foco visível
    const focused = await page.evaluate(() => {
      return document.activeElement?.tagName;
    });
    expect(["INPUT", "BUTTON"]).toContain(focused);
  });

  test("6. Deve ter Explain Panel", async ({ page }) => {
    await fillPriceForm(page, priceData.basic);
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="results-section"]');

    // Verificar Explain Panel
    const explainPanel = page.locator('[data-testid="explain-panel"]');
    await expect(explainPanel).toBeVisible();

    // Verificar fórmulas
    await expect(explainPanel.locator("text=/PMT/")).toBeVisible();
  });
});
