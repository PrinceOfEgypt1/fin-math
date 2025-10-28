import { test, expect } from "@playwright/test";
import { measurePerformance } from "../utils/helpers";

test.describe("CET Flow - Custo Efetivo Total", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="cet-calculator-link"]');
    await expect(page).toHaveTitle(/CET/);
  });

  test("1. Deve calcular CET básico", async ({ page }) => {
    await page.fill('[data-testid="pv-input"]', "10000");
    await page.fill('[data-testid="pmt-input"]', "946.56");
    await page.fill('[data-testid="periods-input"]', "12");

    const duration = await measurePerformance(page, async () => {
      await page.click('[data-testid="calculate-btn"]');
      await page.waitForSelector('[data-testid="cet-result"]');
    });

    expect(duration).toBeLessThan(200);

    // Validar CET (deve ser próximo de 2.5% a.m. → ~34% a.a.)
    const cetText = await page.textContent('[data-testid="cet-value"]');
    const cet = parseFloat(
      cetText?.replace(/[^\d.,]/g, "").replace(",", ".") || "0",
    );
    expect(cet).toBeGreaterThan(30);
    expect(cet).toBeLessThan(40);
  });

  test("2. Deve adicionar tarifas", async ({ page }) => {
    await page.fill('[data-testid="pv-input"]', "10000");
    await page.fill('[data-testid="pmt-input"]', "946.56");
    await page.fill('[data-testid="periods-input"]', "12");

    // Adicionar tarifa
    await page.click('[data-testid="add-fee-btn"]');
    await page.fill('[data-testid="fee-name-input"]', "TAC");
    await page.fill('[data-testid="fee-value-input"]', "500");
    await page.click('[data-testid="save-fee-btn"]');

    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="cet-result"]');

    // CET deve aumentar com tarifa
    const cetText = await page.textContent('[data-testid="cet-value"]');
    const cet = parseFloat(
      cetText?.replace(/[^\d.,]/g, "").replace(",", ".") || "0",
    );
    expect(cet).toBeGreaterThan(35);
  });

  test("3. Deve usar perfis de instituições", async ({ page }) => {
    await page.fill('[data-testid="pv-input"]', "10000");
    await page.fill('[data-testid="pmt-input"]', "946.56");
    await page.fill('[data-testid="periods-input"]', "12");

    // Selecionar perfil
    await page.selectOption(
      '[data-testid="institution-select"]',
      "banco-do-brasil",
    );

    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="cet-result"]');

    // Verificar que tarifas do perfil foram aplicadas
    const fees = await page.$$('[data-testid="applied-fee"]');
    expect(fees.length).toBeGreaterThan(0);
  });
});
