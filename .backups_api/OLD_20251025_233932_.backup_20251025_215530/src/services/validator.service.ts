// packages/api/src/services/validator.service.ts
import Decimal from "decimal.js";
import {
  ValidateScheduleRequest,
  ValidateScheduleResponse,
  ScheduleRow,
  Diff,
} from "../schemas/validator.schema";

/**
 * Service para validação de cronogramas
 */
class ValidatorService {
  /**
   * Valida cronograma comparando com esperado
   */
  validate(req: ValidateScheduleRequest): ValidateScheduleResponse {
    const { input, expected, actual } = req;

    // Calcular totais esperados e reais
    const expectedTotals = this.calculateTotals(expected);
    const actualTotals = this.calculateTotals(actual);

    // Comparar linha por linha
    const diffs: Diff[] = [];
    const maxLen = Math.max(expected.length, actual.length);

    for (let i = 0; i < maxLen; i++) {
      const exp = expected[i];
      const act = actual[i];

      if (!exp || !act) {
        diffs.push({
          k: exp?.k || act?.k || i + 1,
          field: "missing",
          expected: exp ? "present" : "missing",
          actual: act ? "present" : "missing",
          diff: 0,
        });
        continue;
      }

      // Comparar PMT
      const pmtDiff = this.compare(exp.pmt, act.pmt);
      if (Math.abs(pmtDiff) > 0.01) {
        diffs.push({
          k: exp.k,
          field: "pmt",
          expected: exp.pmt,
          actual: act.pmt,
          diff: pmtDiff,
        });
      }

      // Comparar juros
      const interestDiff = this.compare(exp.interest, act.interest);
      if (Math.abs(interestDiff) > 0.01) {
        diffs.push({
          k: exp.k,
          field: "interest",
          expected: exp.interest,
          actual: act.interest,
          diff: interestDiff,
        });
      }

      // Comparar amortização
      const amortDiff = this.compare(exp.amort, act.amort);
      if (Math.abs(amortDiff) > 0.01) {
        diffs.push({
          k: exp.k,
          field: "amort",
          expected: exp.amort,
          actual: act.amort,
          diff: amortDiff,
        });
      }

      // Comparar saldo
      const balanceDiff = this.compare(exp.balance, act.balance);
      if (Math.abs(balanceDiff) > 0.01) {
        diffs.push({
          k: exp.k,
          field: "balance",
          expected: exp.balance,
          actual: act.balance,
          diff: balanceDiff,
        });
      }
    }

    // Montar resposta
    return {
      valid: diffs.length === 0,
      diffs,
      summary: {
        totalRows: maxLen,
        mismatches: diffs.length,
        fields: Array.from(new Set(diffs.map((d) => d.field))),
      },
      input,
      totals: {
        expected: expectedTotals,
        actual: actualTotals,
        diff: {
          pmt: this.compare(expectedTotals.pmt, actualTotals.pmt),
          interest: this.compare(
            expectedTotals.interest,
            actualTotals.interest,
          ),
          amort: this.compare(expectedTotals.amort, actualTotals.amort),
        },
      },
    };
  }

  /**
   * Calcula totais de um cronograma
   */
  private calculateTotals(schedule: ScheduleRow[]) {
    let pmt = new Decimal(0);
    let interest = new Decimal(0);
    let amort = new Decimal(0);

    for (const row of schedule) {
      pmt = pmt.plus(row.pmt);
      interest = interest.plus(row.interest);
      amort = amort.plus(row.amort);
    }

    return {
      pmt: pmt.toNumber(),
      interest: interest.toNumber(),
      amort: amort.toNumber(),
    };
  }

  /**
   * Compara dois valores com Decimal.js
   */
  private compare(expected: number, actual: number): number {
    return new Decimal(actual).minus(expected).toNumber();
  }
}

export const validatorService = new ValidatorService();
