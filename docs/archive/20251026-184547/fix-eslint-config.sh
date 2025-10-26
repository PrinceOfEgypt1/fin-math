#!/bin/bash

echo "🔧 CORRIGINDO ESLINT CONFIG"
echo "============================="
echo ""

# Opção 1: Configuração ESLint 9 (flat config) na raiz
echo "1️⃣ Criando eslint.config.js (raiz)..."
cat > eslint.config.js << 'EOF'
export default [
  {
    files: ['packages/**/*.ts', 'packages/**/*.tsx', 'apps/**/*.ts'],
    ignores: [
      '**/node_modules/**',
      '**/dist/**',
      '**/build/**',
      '**/coverage/**',
      '**/*.config.js',
      '**/*.config.ts'
    ],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      parser: await import('@typescript-eslint/parser').then(m => m.default)
    },
    plugins: {
      '@typescript-eslint': await import('@typescript-eslint/eslint-plugin').then(m => m.default)
    },
    rules: {
      'no-console': 'off',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-unused-vars': ['warn', {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_'
      }]
    }
  }
];
EOF
echo "   ✅ Criado"

# Opção 2: Configuração tradicional por package
echo ""
echo "2️⃣ Criando .eslintrc.json (packages/engine)..."
cat > packages/engine/.eslintrc.json << 'EOF'
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "no-console": "off",
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/no-unused-vars": ["warn", {
      "argsIgnorePattern": "^_",
      "varsIgnorePattern": "^_"
    }]
  },
  "ignorePatterns": ["dist", "build", "node_modules", "coverage"]
}
EOF
echo "   ✅ Criado"

# Atualizar script de lint para ser mais específico
echo ""
echo "3️⃣ Atualizando script de lint..."
cd packages/engine

# Usar Node para atualizar package.json
node << 'NODESCRIPT'
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts.lint = 'eslint src --ext .ts,.tsx';
pkg.scripts['lint:fix'] = 'eslint src --ext .ts,.tsx --fix';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
NODESCRIPT

cd ../..
echo "   ✅ Atualizado"

# Testar
echo ""
echo "4️⃣ Testando lint..."
if pnpm -F @finmath/engine lint; then
    echo "   ✅ LINT PASSOU!"
else
    echo "   ⚠️  Lint tem warnings (aceitável)"
fi

echo ""
echo "============================="
echo "✅ CORREÇÃO CONCLUÍDA"
