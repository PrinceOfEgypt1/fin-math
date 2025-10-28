#!/usr/bin/env node
const { readFileSync } = require('fs');

const labels = (process.env.PR_LABELS || '')
  .split(',')
  .map(s => s.trim())
  .filter(Boolean);

const allowRegexes = [];
// PRs de infra podem alterar .github/**
if (labels.includes('infra:update')) {
  allowRegexes.push(/^\.github\//);
}
// Allowlist extra opcional via regex separados por ';'
if (process.env.FENIX_FORBID_ALLOW) {
  for (const pat of process.env.FENIX_FORBID_ALLOW.split(';').map(s=>s.trim()).filter(Boolean)) {
    try { allowRegexes.push(new RegExp(pat)); } catch {}
  }
}

const forbidden = [/^(?:\.github\/|infra\/|scripts\/)/];
const changed = readFileSync(0, 'utf8').split('\n').filter(Boolean);

const isAllowed = (file) => allowRegexes.some(rx => rx.test(file));
const hits = changed.filter(f => !isAllowed(f) && forbidden.some(rx => rx.test(f)));

if (hits.length) {
  console.error('❌ Paths proibidos alterados:\n' + hits.map(x => ' - ' + x).join('\n'));
  console.error('ℹ️  Dica: adicione label "infra:update" ao PR ou use FENIX_FORBID_ALLOW="^\\.github/" temporariamente.');
  process.exit(1);
}
console.log('✅ Forbidden paths: ok');
