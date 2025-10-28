import { test, expect } from "@playwright/test";
import { fillPriceForm } from "../utils/helpers";
import priceData from "../fixtures/price-data.json";

test.describe("Export Flow - Exportações", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');
    await fillPriceForm(page, priceData.basic);
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="results-section"]');
  });

  test("1. Deve exportar CSV", async ({ page }) => {
    const downloadPromise = page.waitForEvent("download");
    await page.click('[data-testid="export-csv-btn"]');
    const download = await downloadPromise;

    expect(download.suggestedFilename()).toMatch(/schedule.*\.csv$/);
  });

  test("2. Deve exportar PDF", async ({ page }) => {
    const downloadPromise = page.waitForEvent("download");
    await page.click('[data-testid="export-pdf-btn"]');
    const download = await downloadPromise;

    expect(download.suggestedFilename()).toMatch(/schedule.*\.pdf$/);
  });
});
