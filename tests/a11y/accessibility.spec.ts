import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test.describe("Accessibility Tests - WCAG 2.1 AA", () => {
  test("Home page should not have accessibility violations", async ({
    page,
  }) => {
    await page.goto("/");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("Price calculator should not have accessibility violations", async ({
    page,
  }) => {
    await page.goto("/price");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("SAC calculator should not have accessibility violations", async ({
    page,
  }) => {
    await page.goto("/sac");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("Comparator page should not have accessibility violations", async ({
    page,
  }) => {
    await page.goto("/comparator");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("Comparator with results should not have accessibility violations", async ({
    page,
  }) => {
    await page.goto("/comparator");

    // Preencher formulário
    await page.fill('input[type="number"]', '10000');
    await page.fill('input[id*="taxa"]', '1.5');
    await page.fill('input[id*="parcela"]', '12');

    // Submeter
    await page.click('button[type="submit"]');

    // Aguardar resultados
    await page.waitForSelector('[role="region"]', { state: "visible" });

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });
});

test.describe("Keyboard Navigation Tests", () => {
  test("Should navigate through comparator form with keyboard", async ({
    page,
  }) => {
    await page.goto("/comparator");

    // Iniciar na primeira input
    await page.keyboard.press("Tab");
    await page.keyboard.press("Tab");
    await page.keyboard.press("Tab");

    // Verificar se o primeiro input está focado
    const firstInput = page.locator('input[type="number"]').first();
    await expect(firstInput).toBeFocused();

    // Navegar para próximos campos
    await page.keyboard.press("Tab");
    await page.keyboard.press("Tab");

    // Navegar até o botão
    await page.keyboard.press("Tab");

    const submitButton = page.locator('button[type="submit"]');
    await expect(submitButton).toBeFocused();
  });

  test("Should have visible focus indicators", async ({ page }) => {
    await page.goto("/comparator");

    // Focar no primeiro botão/link
    await page.keyboard.press("Tab");

    // Verificar se há outline visível (pode variar por navegador)
    const focusedElement = page.locator(":focus");
    await expect(focusedElement).toBeVisible();
  });
});

test.describe("Screen Reader Tests", () => {
  test("Should have proper heading hierarchy", async ({ page }) => {
    await page.goto("/comparator");

    // Verificar H1
    const h1 = page.locator("h1");
    await expect(h1).toBeVisible();
    await expect(h1).toHaveText(/Comparador PRICE vs SAC/);

    // Verificar H2 (deve existir e ser descendente de H1)
    const h2 = page.locator("h2").first();
    await expect(h2).toBeVisible();
  });

  test("Should have proper labels for inputs", async ({ page }) => {
    await page.goto("/comparator");

    // Todos os inputs devem ter labels associados
    const inputs = page.locator('input[type="number"]');
    const count = await inputs.count();

    for (let i = 0; i < count; i++) {
      const input = inputs.nth(i);
      const id = await input.getAttribute("id");
      const label = page.locator(`label[for="${id}"]`);

      await expect(label).toBeVisible();
    }
  });

  test("Should announce results to screen readers", async ({ page }) => {
    await page.goto("/comparator");

    // Preencher e submeter
    const inputs = page.locator('input[type="number"]');
    await inputs.nth(0).fill("10000");
    await inputs.nth(1).fill("1.5");
    await inputs.nth(2).fill("12");

    await page.click('button[type="submit"]');

    // Verificar aria-live region
    const liveRegion = page.locator('[role="region"][aria-live="polite"]');
    await expect(liveRegion).toBeVisible();
  });

  test("Should have main landmark", async ({ page }) => {
    await page.goto("/");

    const main = page.locator("main");
    await expect(main).toBeVisible();
    await expect(main).toHaveAttribute("id", "main-content");
  });

  test("Should have skip link", async ({ page }) => {
    await page.goto("/");

    const skipLink = page.locator('a[href="#main-content"]');
    await expect(skipLink).toBeInViewport({ ratio: 0 }); // Pode estar oculto mas deve existir
  });
});
