import { test, expect } from "@playwright/test";
import * as path from "path";

test.describe("Validator Flow - Validação de Cronogramas", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="validator-link"]');
    await expect(page).toHaveTitle(/Validador/);
  });

  test("1. Deve fazer upload de CSV", async ({ page }) => {
    const filePath = path.join(__dirname, "../fixtures/schedule-sample.csv");

    // Upload
    await page.setInputFiles('[data-testid="csv-upload-input"]', filePath);

    // Verificar preview
    await expect(page.locator('[data-testid="csv-preview"]')).toBeVisible();
  });

  test("2. Deve validar cronograma correto", async ({ page }) => {
    const filePath = path.join(__dirname, "../fixtures/schedule-correct.csv");

    await page.setInputFiles('[data-testid="csv-upload-input"]', filePath);
    await page.click('[data-testid="validate-btn"]');

    // Deve mostrar sucesso
    await expect(
      page.locator('[data-testid="validation-success"]'),
    ).toBeVisible();
    await expect(page.locator("text=/✅ Cronograma válido/")).toBeVisible();
  });
});
