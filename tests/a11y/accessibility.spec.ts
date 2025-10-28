import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

/**
 * Testes de Acessibilidade com axe-core
 *
 * Valida conformidade WCAG 2.2 Nível AA
 */

test.describe("Auditoria de Acessibilidade - WCAG 2.2 AA", () => {
  test("Página Principal deve ser acessível", async ({ page }) => {
    await page.goto("/");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .analyze();

    // Não deve haver violations bloqueantes
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("Calculadora Price deve ser acessível", async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("Calculadora SAC deve ser acessível", async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="sac-calculator-link"]');

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("Calculadora CET deve ser acessível", async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="cet-calculator-link"]');

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("Dashboard com resultados deve ser acessível", async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');

    // Preencher e calcular
    await page.fill('[data-testid="pv-input"]', "10000");
    await page.fill('[data-testid="rate-input"]', "2.5");
    await page.fill('[data-testid="periods-input"]', "12");
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="results-section"]');

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("Formulários devem ter labels adequados", async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa"])
      .include("form")
      .analyze();

    // Verificar regra específica de labels
    const labelViolations = accessibilityScanResults.violations.filter(
      (v) => v.id === "label",
    );
    expect(labelViolations).toEqual([]);
  });

  test("Contraste de cores deve ser adequado", async ({ page }) => {
    await page.goto("/");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2aa"])
      .analyze();

    // Verificar regras de contraste
    const contrastViolations = accessibilityScanResults.violations.filter(
      (v) => v.id === "color-contrast",
    );
    expect(contrastViolations).toEqual([]);
  });

  test("Elementos interativos devem ser acessíveis por teclado", async ({
    page,
  }) => {
    await page.goto("/");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa"])
      .analyze();

    // Verificar navegação por teclado
    const keyboardViolations = accessibilityScanResults.violations.filter(
      (v) => v.id === "keyboard" || v.id === "focus-order-semantics",
    );
    expect(keyboardViolations).toEqual([]);
  });

  test("Imagens devem ter texto alternativo", async ({ page }) => {
    await page.goto("/");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a"])
      .analyze();

    const imageAltViolations = accessibilityScanResults.violations.filter(
      (v) => v.id === "image-alt",
    );
    expect(imageAltViolations).toEqual([]);
  });

  test("Tabelas devem ter headers adequados", async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');

    // Calcular para mostrar tabela
    await page.fill('[data-testid="pv-input"]', "10000");
    await page.fill('[data-testid="rate-input"]', "2.5");
    await page.fill('[data-testid="periods-input"]', "12");
    await page.click('[data-testid="calculate-btn"]');
    await page.waitForSelector('[data-testid="schedule-table"]');

    const accessibilityScanResults = await new AxeBuilder({ page })
      .include('[data-testid="schedule-table"]')
      .analyze();

    const tableViolations = accessibilityScanResults.violations.filter(
      (v) => v.id.includes("table") || v.id.includes("th"),
    );
    expect(tableViolations).toEqual([]);
  });
});

test.describe("Testes de Navegação por Teclado", () => {
  test("Deve navegar por formulário usando Tab", async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');

    // Navegar com Tab
    await page.keyboard.press("Tab"); // Primeiro input
    let focused = await page.evaluate(() => document.activeElement?.id);
    expect(focused).toBeTruthy();

    await page.keyboard.press("Tab"); // Segundo input
    focused = await page.evaluate(() => document.activeElement?.id);
    expect(focused).toBeTruthy();

    await page.keyboard.press("Tab"); // Terceiro input
    focused = await page.evaluate(() => document.activeElement?.id);
    expect(focused).toBeTruthy();

    await page.keyboard.press("Tab"); // Botão calcular
    focused = await page.evaluate(() => document.activeElement?.tagName);
    expect(focused).toBe("BUTTON");
  });

  test("Deve ativar botão com Enter", async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');

    // Preencher campos
    await page.fill('[data-testid="pv-input"]', "10000");
    await page.fill('[data-testid="rate-input"]', "2.5");
    await page.fill('[data-testid="periods-input"]', "12");

    // Focar botão
    await page.focus('[data-testid="calculate-btn"]');

    // Pressionar Enter
    await page.keyboard.press("Enter");

    // Deve mostrar resultados
    await expect(page.locator('[data-testid="results-section"]')).toBeVisible();
  });

  test("Deve fechar modal com Escape", async ({ page }) => {
    await page.goto("/");

    // Abrir modal de ajuda (se existir)
    await page
      .click('[data-testid="help-btn"]', { timeout: 5000 })
      .catch(() => {
        console.log("Botão de ajuda não encontrado, pulando teste");
      });

    // Verificar se modal abriu
    const modal = page.locator('[role="dialog"]');
    if (await modal.isVisible()) {
      // Pressionar Escape
      await page.keyboard.press("Escape");

      // Modal deve fechar
      await expect(modal).not.toBeVisible();
    }
  });
});

test.describe("Testes de Leitor de Tela", () => {
  test("Landmarks devem estar presentes", async ({ page }) => {
    await page.goto("/");

    // Verificar landmarks ARIA
    const main = await page.locator('main, [role="main"]').count();
    expect(main).toBeGreaterThan(0);

    const navigation = await page.locator('nav, [role="navigation"]').count();
    expect(navigation).toBeGreaterThan(0);
  });

  test("Headings devem ter hierarquia correta", async ({ page }) => {
    await page.goto("/");

    // Deve ter exatamente um h1
    const h1Count = await page.locator("h1").count();
    expect(h1Count).toBe(1);

    // Não deve pular níveis (h1 -> h3 sem h2)
    const headings = await page.$$eval("h1, h2, h3, h4, h5, h6", (elements) =>
      elements.map((el) => parseInt(el.tagName[1])),
    );

    for (let i = 1; i < headings.length; i++) {
      const diff = headings[i] - headings[i - 1];
      expect(diff).toBeLessThanOrEqual(1);
    }
  });

  test('Status messages devem usar role="status"', async ({ page }) => {
    await page.goto("/");
    await page.click('[data-testid="price-calculator-link"]');

    // Calcular
    await page.fill('[data-testid="pv-input"]', "10000");
    await page.fill('[data-testid="rate-input"]', "2.5");
    await page.fill('[data-testid="periods-input"]', "12");
    await page.click('[data-testid="calculate-btn"]');

    // Verificar mensagem de sucesso
    const status = await page
      .locator('[role="status"], [role="alert"]')
      .count();
    expect(status).toBeGreaterThan(0);
  });
});
