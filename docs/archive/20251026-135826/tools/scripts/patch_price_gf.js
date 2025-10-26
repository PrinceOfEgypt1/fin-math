const fs = require("fs");
const path = require("path");

const GF_DIR = path.join(__dirname, "../../packages/engine/golden/starter");
const FILE_RE = /^PRICE_.+\.json$/i;

const to2 = (x) => Math.round((Number(x) + Number.EPSILON) * 100) / 100;
const pmtPrice = (pv, i, n) => {
  if (n <= 0) return 0;
  if (i === 0) return pv / n;
  const a = Math.pow(1 + i, n);
  return pv * ((i * a) / (a - 1));
};

const files = fs.readdirSync(GF_DIR).filter((f) => FILE_RE.test(f));
if (!files.length) {
  console.log("[patch] Nenhum PRICE_*.json em", GF_DIR);
  process.exit(0);
}

let patched = 0;
for (const fname of files) {
  const full = path.join(GF_DIR, fname);
  const gf = JSON.parse(fs.readFileSync(full, "utf-8"));
  const { inputs } = gf;
  if (
    !inputs ||
    typeof inputs.pv !== "number" ||
    typeof inputs.rateMonthly !== "number"
  ) {
    console.warn(`[patch] Pulando ${fname}: inputs inválidos`);
    continue;
  }
  const pv = Number(inputs.pv);
  const i = Number(inputs.rateMonthly);
  const n = Number(inputs.n);

  const pmt = to2(pmtPrice(pv, i, n));
  const total_paid = to2(pmt * n);
  const total_interest = to2(total_paid - pv);

  gf.expected = {
    ...(gf.expected || {}),
    pmt,
    total_interest,
    total_paid,
  };

  fs.writeFileSync(full, JSON.stringify(gf, null, 2));
  console.log(
    `[patch] ${fname} -> PMT=${pmt} total_interest=${total_interest} total_paid=${total_paid}`,
  );
  patched++;
}

console.log(`\n[patch] Concluído. Atualizados: ${patched}`);
