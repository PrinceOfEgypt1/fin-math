import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test.describe("Accessibility Tests - WCAG 2.1 AA", () => {
  test("Home page should not have critical/serious accessibility violations", async ({
    page,
  }) => {
    await page.goto("/");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    // Apenas violations críticas e sérias causam falha
    const criticalViolations = accessibilityScanResults.violations.filter(
      (v) => v.impact === "critical" || v.impact === "serious",
    );

    expect(criticalViolations).toEqual([]);
  });

  test("Comparador PRICE vs SAC should not have critical/serious accessibility violations", async ({
    page,
  }) => {
    await page.goto("/comparador");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    const criticalViolations = accessibilityScanResults.violations.filter(
      (v) => v.impact === "critical" || v.impact === "serious",
    );

    expect(criticalViolations).toEqual([]);
  });

  test("Calculadora should not have critical/serious accessibility violations", async ({
    page,
  }) => {
    await page.goto("/calculadora");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    const criticalViolations = accessibilityScanResults.violations.filter(
      (v) => v.impact === "critical" || v.impact === "serious",
    );

    expect(criticalViolations).toEqual([]);
  });

  test("All pages should have valid HTML lang attribute", async ({ page }) => {
    await page.goto("/");

    const lang = await page.getAttribute("html", "lang");
    expect(lang).toBe("pt-BR");
  });

  test("All pages should have a main landmark", async ({ page }) => {
    await page.goto("/");

    const main = await page.locator("main").count();
    expect(main).toBeGreaterThanOrEqual(1);
  });
});
