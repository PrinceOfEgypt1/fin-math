#!/usr/bin/env node
const { readFileSync } = require('fs');

const REQUIRED_LABEL = process.env.FENIX_GOLDEN_LABEL || 'golden:update';
const PR_LABELS = (process.env.PR_LABELS || '').split(',').map(s => s.trim()).filter(Boolean);

const changed = readFileSync(0, 'utf8').split('\n').filter(Boolean);
const touchesGolden = changed.some(f => /test\/golden\//.test(f));

if (touchesGolden && !PR_LABELS.includes(REQUIRED_LABEL)) {
  console.error(`❌ Atualização de Golden requer label: ${REQUIRED_LABEL}`);
  process.exit(1);
}
console.log('✅ Golden guard: ok');
