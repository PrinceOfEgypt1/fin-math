import { chromium, Browser, Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";
import * as fs from "fs";
import * as path from "path";

interface A11yResult {
  url: string;
  timestamp: string;
  violations: any[];
  passes: number;
  incomplete: number;
  inapplicable: number;
}

/**
 * Gera relatório de acessibilidade para todas as páginas
 */
async function generateA11yReport() {
  const browser: Browser = await chromium.launch();
  const page: Page = await browser.newPage();

  const urls = [
    { path: "/", name: "Home" },
    { path: "/price", name: "Price Calculator" },
    { path: "/sac", name: "SAC Calculator" },
    { path: "/cet", name: "CET Calculator" },
    { path: "/comparator", name: "Comparator" },
  ];

  const results: A11yResult[] = [];

  for (const { path: urlPath, name } of urls) {
    console.log(`🔍 Auditando: ${name} (${urlPath})`);

    await page.goto(`http://localhost:5173${urlPath}`);

    const accessibilityResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .analyze();

    results.push({
      url: urlPath,
      timestamp: new Date().toISOString(),
      violations: accessibilityResults.violations,
      passes: accessibilityResults.passes.length,
      incomplete: accessibilityResults.incomplete.length,
      inapplicable: accessibilityResults.inapplicable.length,
    });

    console.log(`  ✓ Passes: ${accessibilityResults.passes.length}`);
    console.log(`  ⚠️  Violations: ${accessibilityResults.violations.length}`);
    console.log(`  ❓ Incomplete: ${accessibilityResults.incomplete.length}`);
  }

  await browser.close();

  // Salvar resultados
  const outputDir = path.join(__dirname, "../../docs/a11y");
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const outputPath = path.join(outputDir, "a11y-report.json");
  fs.writeFileSync(outputPath, JSON.stringify(results, null, 2));

  // Gerar relatório Markdown
  const markdown = generateMarkdownReport(results);
  const mdPath = path.join(outputDir, "a11y-report.md");
  fs.writeFileSync(mdPath, markdown);

  console.log(`\n✅ Relatório gerado: ${mdPath}`);

  // Resumo
  const totalViolations = results.reduce(
    (sum, r) => sum + r.violations.length,
    0,
  );
  console.log(`\n📊 RESUMO:`);
  console.log(`   Total de páginas: ${results.length}`);
  console.log(`   Total de violations: ${totalViolations}`);

  if (totalViolations > 0) {
    console.log(
      `\n⚠️  ATENÇÃO: Foram encontradas ${totalViolations} violations!`,
    );
    process.exit(1);
  } else {
    console.log(`\n✅ Todas as páginas passaram na auditoria!`);
  }
}

function generateMarkdownReport(results: A11yResult[]): string {
  let md = `# Relatório de Acessibilidade - FinMath\n\n`;
  md += `**Data:** ${new Date().toLocaleDateString("pt-BR")}\n\n`;
  md += `**Padrão:** WCAG 2.2 Nível AA\n\n`;
  md += `**Ferramenta:** axe-core\n\n`;
  md += `---\n\n`;

  // Resumo
  md += `## Resumo Geral\n\n`;
  md += `| Página | Passes | Violations | Incomplete |\n`;
  md += `|--------|--------|------------|------------|\n`;

  for (const result of results) {
    const status = result.violations.length === 0 ? "✅" : "❌";
    md += `| ${status} ${result.url} | ${result.passes} | ${result.violations.length} | ${result.incomplete} |\n`;
  }

  md += `\n---\n\n`;

  // Detalhes das violations
  md += `## Detalhes das Violations\n\n`;

  for (const result of results) {
    if (result.violations.length > 0) {
      md += `### ${result.url}\n\n`;

      for (const violation of result.violations) {
        md += `#### ❌ ${violation.id}\n\n`;
        md += `**Impacto:** ${violation.impact}\n\n`;
        md += `**Descrição:** ${violation.description}\n\n`;
        md += `**Help:** ${violation.help}\n\n`;
        md += `**Tags:** ${violation.tags.join(", ")}\n\n`;
        md += `**Elementos afetados:** ${violation.nodes.length}\n\n`;

        if (violation.nodes.length > 0) {
          md += `**Exemplos:**\n\n`;
          for (const node of violation.nodes.slice(0, 3)) {
            md += `- \`${node.html}\`\n`;
          }
          md += `\n`;
        }

        md += `---\n\n`;
      }
    }
  }

  // Recomendações
  md += `## Recomendações\n\n`;
  md += `Para corrigir as violations encontradas:\n\n`;
  md += `1. Consulte a documentação do axe-core para cada violation\n`;
  md += `2. Utilize o Playwright Inspector para debug\n`;
  md += `3. Teste com leitores de tela (NVDA, JAWS, VoiceOver)\n`;
  md += `4. Valide com usuários reais\n\n`;

  return md;
}

// Executar
generateA11yReport().catch(console.error);
