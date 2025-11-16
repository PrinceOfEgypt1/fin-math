// packages/engine/test/golden.spec.ts
import { describe, it, expect } from "vitest";
import fs from "node:fs";
import path from "node:path";
import * as engine from "../src/index";

const approx = (a: number, b: number, tol: number) =>
  Math.abs(Number(a) - Number(b)) <= Number(tol);

const GF_DIR = path.resolve(__dirname, "../golden/starter");
const FILE_RE = /^(JC_|EQ_|SER_|PRICE_|SAC_|NPVIRR_|CETBASIC_).+\.json$/i;

const files = fs.existsSync(GF_DIR)
  ? fs.readdirSync(GF_DIR).filter((f) => FILE_RE.test(f))
  : [];

if (files.length === 0) {
  console.warn(
    `[golden] nenhum arquivo encontrado em ${GF_DIR}. Rode o seed_artifacts.sh primeiro.`,
  );
}

const to2 = (x: any) => Math.round((Number(x) + Number.EPSILON) * 100) / 100;

describe("Golden Files — validação do motor", () => {
  for (const fname of files) {
    const full = path.join(GF_DIR, fname);
    const gf = JSON.parse(fs.readFileSync(full, "utf-8"));

    const id: string = gf.test_id ?? fname.replace(/\.json$/, "");
    const tol: number = gf.tolerance ?? 0.01;

    it(`${id} — ${gf.description ?? ""}`.trim(), () => {
      if (id.startsWith("JC_")) {
        const { inputs, expected } = gf;
        if ("fv" in expected) {
          const out = engine.interest
            .fv(inputs.pv, inputs.i_m, Number(inputs.n))
            .toNumber();
          expect(approx(out, expected.fv, tol)).toBe(true);
        } else if ("pv" in expected) {
          const out = engine.interest
            .pv(inputs.fv, inputs.i_m, Number(inputs.n))
            .toNumber();
          expect(approx(out, expected.pv, tol)).toBe(true);
        } else {
          throw new Error("JC_* sem campo expected.fv/pv");
        }
      } else if (id.startsWith("EQ_")) {
        const { inputs, expected } = gf;
        if ("rate_a" in expected) {
          const out = engine.rate.monthlyToAnnual(inputs.rate_m).toNumber();
          expect(approx(out, expected.rate_a, 1e-6)).toBe(true);
        } else if ("rate_m" in expected) {
          const out = engine.rate.annualToMonthly(inputs.rate_a).toNumber();
          expect(approx(out, expected.rate_m, 1e-6)).toBe(true);
        } else {
          throw new Error("EQ_* sem campo expected.rate_a/rate_m");
        }
      } else if (id.startsWith("SER_")) {
        const { inputs, expected } = gf;
        const due = inputs.kind === "ant";
        const out = engine.series
          .pmt(inputs.pv, inputs.i_m, Number(inputs.n), due)
          .toNumber();
        expect(approx(out, expected.pmt, tol)).toBe(true);
      } else if (id.startsWith("PRICE_")) {
        const { inputs, expected } = gf;
        const out = engine.amortization.price(
          Number(inputs.pv),
          Number(inputs.rateMonthly),
          Number(inputs.n),
        );
        const tolPrice = Math.max(tol, 0.05);

        // Debug para diagnóstico
        if (id === "PRICE_001" || id === "PRICE_003" || id === "PRICE_005") {
        }

        expect(approx(to2(out.pmt), to2(expected.pmt), tolPrice)).toBe(true);
        expect(
          approx(
            to2(out.totalInterest),
            to2(expected.total_interest),
            tolPrice,
          ),
        ).toBe(true);
        expect(
          approx(to2(out.totalPaid), to2(expected.total_paid), tolPrice),
        ).toBe(true);
      } else if (id.startsWith("SAC_")) {
        const { inputs, expected } = gf;
        const out = engine.amortization.sac(
          inputs.pv,
          inputs.rateMonthly,
          Number(inputs.n),
        );
        const amortConst = (out as any).amortConst ?? (out as any).amort_const;
        expect(approx(amortConst, expected.amort_constante, tol)).toBe(true);
        expect(approx(out.totalInterest, expected.total_interest, tol)).toBe(
          true,
        );
        expect(approx(out.totalPaid, expected.total_paid, tol)).toBe(true);
      } else if (id.startsWith("NPVIRR_")) {
        const { inputs, expected } = gf;
        const irr = engine.irr.irrBisection(inputs.cashflows) ?? 0;
        expect(approx(irr, expected.irrMonthly, 1e-4)).toBe(true);
      } else if (id.startsWith("CETBASIC_")) {
        const { inputs, expected } = gf;
        const out = engine.cet.cetBasic(
          inputs.pv,
          inputs.pmt,
          Number(inputs.n),
          inputs.feesT0 ?? [],
          inputs.baseAnnual ?? 12,
        );
        expect(approx(out.irrMonthly, expected.irrMonthly, 1e-4)).toBe(true);
        expect(approx(out.cetAnnual, expected.cetAnnual, 1e-4)).toBe(true);
      } else {
        throw new Error(`Prefixo de teste não suportado: ${id}`);
      }
    });
  }
});
