/**
 * Testes E2E para HU-24: Comparação PRICE vs SAC
 * @packageDocumentation
 */

import { test, expect } from "@playwright/test";

test.describe("HU-24: Comparação PRICE vs SAC", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("http://localhost:5173/#comparison");
  });

  test("CT-24.1: Deve calcular corretamente PRICE vs SAC", async ({ page }) => {
    // Preencher formulário
    await page.fill('input[placeholder="10000"]', "10000");
    await page.fill('input[placeholder="1"]', "1");
    await page.fill('input[placeholder="12"]', "12");

    // Clicar em calcular
    await page.click('button:has-text("Comparar Sistemas")');

    // Aguardar resultados
    await page.waitForSelector("text=R$ 888.49", { timeout: 5000 });

    // Verificar PRICE
    const pricePmt = await page.textContent(".text-blue-400");
    expect(pricePmt).toContain("888.49");

    // Verificar SAC
    const sacFirst = await page.textContent(".text-purple-400");
    expect(sacFirst).toContain("933.33");

    // Verificar economia
    const savings = await page.textContent(".text-green-400");
    expect(savings).toContain("11.88");
  });

  test("CT-24.4: Deve navegar corretamente via menu", async ({ page }) => {
    await page.goto("http://localhost:5173");

    // Clicar no menu Comparar
    await page.click('button:has-text("Comparar")');

    // Verificar URL
    expect(page.url()).toContain("#comparison");

    // Verificar que a página carregou
    await expect(page.locator('h1:has-text("PRICE vs SAC")')).toBeVisible();
  });

  test("CT-24.3: Deve ser responsivo em mobile", async ({ page }) => {
    // Simular viewport mobile
    await page.setViewportSize({ width: 375, height: 667 });

    // Verificar que elementos são visíveis
    await expect(page.locator('h1:has-text("PRICE vs SAC")')).toBeVisible();

    // Preencher e calcular
    await page.fill('input[placeholder="10000"]', "10000");
    await page.click('button:has-text("Comparar Sistemas")');

    // Verificar que resultados aparecem
    await page.waitForSelector("text=R$", { timeout: 5000 });
  });

  test("CT-24.5: Deve calcular em menos de 100ms", async ({ page }) => {
    await page.fill('input[placeholder="10000"]', "10000");
    await page.fill('input[placeholder="1"]', "1");
    await page.fill('input[placeholder="12"]', "12");

    const startTime = Date.now();
    await page.click('button:has-text("Comparar Sistemas")');
    await page.waitForSelector("text=R$ 888.49");
    const endTime = Date.now();

    const duration = endTime - startTime;
    expect(duration).toBeLessThan(100);
  });
});
