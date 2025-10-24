#!/usr/bin/env node
const { readFileSync } = require('fs');

const forbidden = [/^(?:\.github\/|infra\/|scripts\/)/];

const changed = readFileSync(0, 'utf8').split('\n').filter(Boolean);
const hit = changed.filter(f => forbidden.some(rx => rx.test(f)));

if (hit.length) {
  console.error('❌ Paths proibidos alterados:\n' + hit.map(x => ' - ' + x).join('\n'));
  process.exit(1);
}
console.log('✅ Forbidden paths: ok');
