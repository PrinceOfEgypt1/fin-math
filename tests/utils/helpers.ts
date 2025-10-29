import { Page, expect } from "@playwright/test";

/**
 * Helper para preencher formulário Price
 */
export async function fillPriceForm(
  page: Page,
  data: { pv: number; rate: number; periods: number },
) {
  await page.fill('[data-testid="pv-input"]', data.pv.toString());
  await page.fill('[data-testid="rate-input"]', data.rate.toString());
  await page.fill('[data-testid="periods-input"]', data.periods.toString());
}

/**
 * Helper para validar métricas exibidas
 */
export async function validateMetrics(
  page: Page,
  expected: { pmt?: number; total?: number; interest?: number },
) {
  if (expected.pmt) {
    const pmtText = await page.textContent('[data-testid="pmt-value"]');
    const pmt = parseFloat(
      pmtText?.replace(/[^\d.,]/g, "").replace(",", ".") || "0",
    );
    expect(Math.abs(pmt - expected.pmt)).toBeLessThan(0.01);
  }

  if (expected.total) {
    const totalText = await page.textContent('[data-testid="total-value"]');
    const total = parseFloat(
      totalText?.replace(/[^\d.,]/g, "").replace(",", ".") || "0",
    );
    expect(Math.abs(total - expected.total)).toBeLessThan(0.01);
  }

  if (expected.interest) {
    const interestText = await page.textContent(
      '[data-testid="interest-value"]',
    );
    const interest = parseFloat(
      interestText?.replace(/[^\d.,]/g, "").replace(",", ".") || "0",
    );
    expect(Math.abs(interest - expected.interest)).toBeLessThan(0.01);
  }
}

/**
 * Helper para validar cronograma (primeiras linhas)
 */
export async function validateScheduleTable(page: Page, expectedRows: number) {
  const rows = await page.locator('[data-testid="schedule-row"]').count();
  expect(rows).toBe(expectedRows);
}

/**
 * Helper para exportar CSV e validar
 */
export async function exportAndValidateCSV(page: Page) {
  const downloadPromise = page.waitForEvent("download");
  await page.click('[data-testid="export-csv-btn"]');
  const download = await downloadPromise;

  expect(download.suggestedFilename()).toMatch(/.*\.csv$/);
  return download;
}

/**
 * Helper para validar acessibilidade básica
 */
export async function checkBasicA11y(page: Page) {
  // Verificar se há heading principal
  const h1 = await page.locator("h1").count();
  expect(h1).toBeGreaterThan(0);

  // Verificar se todos os inputs têm labels
  const inputs = await page.locator("input").count();
  const labels = await page.locator("label").count();
  expect(labels).toBeGreaterThanOrEqual(inputs);
}

/**
 * Helper para medição de performance
 */
export async function measurePerformance(
  page: Page,
  action: () => Promise<void>,
) {
  const startTime = Date.now();
  await action();
  const endTime = Date.now();
  const duration = endTime - startTime;

  console.log(`⏱️  Performance: ${duration}ms`);
  return duration;
}
