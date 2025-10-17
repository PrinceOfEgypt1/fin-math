# Exemplos de API - Sprint 2 (H21 e H22)

## 📖 Índice

- [H21 - Snapshots](#h21---snapshots)
  - [Cenário 1: Criar e Recuperar Snapshot via Price](#cenário-1-criar-e-recuperar-snapshot-via-price)
  - [Cenário 2: Criar e Recuperar Snapshot via CET](#cenário-2-criar-e-recuperar-snapshot-via-cet)
  - [Cenário 3: Snapshot não encontrado](#cenário-3-snapshot-não-encontrado)
  - [Cenário 4: Verificar integridade (hash)](#cenário-4-verificar-integridade-hash)
- [H22 - Validator](#h22---validator)
  - [Cenário 5: Validação válida (sem diferenças)](#cenário-5-validação-válida-sem-diferenças)
  - [Cenário 6: Validação com diferenças mínimas](#cenário-6-validação-com-diferenças-mínimas)
  - [Cenário 7: Validação com diferença crítica](#cenário-7-validação-com-diferença-crítica)
  - [Cenário 8: Validação de totais](#cenário-8-validação-de-totais)
  - [Cenário 9: Erro de validação - tamanhos diferentes](#cenário-9-erro-de-validação---tamanhos-diferentes)

---

## 🔷 H21 - Snapshots

### Cenário 1: Criar e Recuperar Snapshot via Price

**Contexto:** Cliente faz cálculo Price e quer guardar o resultado para auditoria futura.

**Passo 1: Calcular Price (cria snapshot automaticamente)**

```bash
curl -X POST http://localhost:3001/api/price \
  -H "Content-Type: application/json" \
  -d '{
    "pv": 100000,
    "rate": 0.01,
    "n": 12
  }'
```

**Resposta:**

```json
{
  "schedule": [
    {
      "period": 1,
      "pmt": 8884.88,
      "interest": 1000.0,
      "amort": 7884.88,
      "balance": 92115.12
    },
    {
      "period": 2,
      "pmt": 8884.88,
      "interest": 921.15,
      "amort": 7963.73,
      "balance": 84151.39
    }
    // ... 10 períodos restantes
  ],
  "snapshotId": "a3c58690f1b2"
}
```

**Passo 2: Recuperar Snapshot**

```bash
curl http://localhost:3001/api/snapshot/a3c58690f1b2
```

**Resposta:**

```json
{
  "id": "a3c58690f1b2",
  "hash": "ebcf7d2f52007a73159a34b6c1e8d4f5a9b7c3e2d1f0a8b6c4d2e0f1a3b5c7d9",
  "motorVersion": "0.2.0",
  "createdAt": "2025-10-17T23:45:12.345Z",
  "data": {
    "input": {
      "pv": 100000,
      "rate": 0.01,
      "n": 12
    },
    "output": {
      "schedule": [
        /* cronograma completo */
      ]
    }
  }
}
```

---

### Cenário 2: Criar e Recuperar Snapshot via CET

**Contexto:** Cliente calcula CET e quer rastrear qual motorVersion foi usada.

**Request:**

```bash
curl -X POST http://localhost:3001/api/cet/basic \
  -H "Content-Type: application/json" \
  -d '{
    "pv": 100000,
    "rate": 0.12,
    "n": 12,
    "iof": 150,
    "tac": 50
  }'
```

**Resposta:**

```json
{
  "cet": 0.13107666176908728,
  "effectiveRate": 0.13107666176908728,
  "schedule": [
    {
      "period": 0,
      "pmt": -100200.0,
      "interest": 0,
      "amort": 0,
      "balance": 100200.0
    },
    {
      "period": 1,
      "pmt": 8884.88,
      "interest": 1002.0,
      "amort": 7882.88,
      "balance": 92317.12
    }
    // ...
  ],
  "snapshotId": "b7f9e3d4a2c1"
}
```

**Recuperar snapshot do CET:**

```bash
curl http://localhost:3001/api/snapshot/b7f9e3d4a2c1
```

---

### Cenário 3: Snapshot não encontrado

**Request:**

```bash
curl http://localhost:3001/api/snapshot/invalid-id-123
```

**Resposta:** `404 Not Found`

```json
{
  "error": "Snapshot not found"
}
```

---

### Cenário 4: Verificar integridade (hash)

**Contexto:** Cliente quer verificar se os dados do snapshot não foram alterados.

**Passo 1: Recuperar snapshot**

```bash
SNAPSHOT=$(curl -s http://localhost:3001/api/snapshot/a3c58690f1b2)
```

**Passo 2: Extrair hash e dados**

```bash
STORED_HASH=$(echo $SNAPSHOT | jq -r '.hash')
DATA=$(echo $SNAPSHOT | jq -r '.data')
```

**Passo 3: Recalcular hash**

```bash
# Em Node.js ou similar
const crypto = require('crypto');
const calculatedHash = crypto
  .createHash('sha256')
  .update(JSON.stringify(data))
  .digest('hex');

// Comparar
if (calculatedHash === storedHash) {
  console.log('✅ Integridade verificada');
} else {
  console.log('❌ Dados foram alterados!');
}
```

---

## 🔶 H22 - Validator

### Cenário 5: Validação válida (sem diferenças)

**Contexto:** Cliente recalculou cronograma e quer confirmar que está idêntico ao esperado.

**Request:**

```bash
curl -X POST http://localhost:3001/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "pv": 100000,
      "rate": 0.12,
      "n": 3,
      "system": "price"
    },
    "expected": [
      {
        "k": 1,
        "pmt": 41634.86,
        "interest": 1000.00,
        "amort": 40634.86,
        "balance": 59365.14
      },
      {
        "k": 2,
        "pmt": 41634.86,
        "interest": 593.65,
        "amort": 41041.21,
        "balance": 18323.93
      },
      {
        "k": 3,
        "pmt": 41634.86,
        "interest": 183.24,
        "amort": 41451.62,
        "balance": 0.00
      }
    ],
    "actual": [
      {
        "k": 1,
        "pmt": 41634.86,
        "interest": 1000.00,
        "amort": 40634.86,
        "balance": 59365.14
      },
      {
        "k": 2,
        "pmt": 41634.86,
        "interest": 593.65,
        "amort": 41041.21,
        "balance": 18323.93
      },
      {
        "k": 3,
        "pmt": 41634.86,
        "interest": 183.24,
        "amort": 41451.62,
        "balance": 0.00
      }
    ]
  }'
```

**Resposta:**

```json
{
  "valid": true,
  "diffs": [],
  "totals": {
    "expected": {
      "totalPmt": 124904.58,
      "totalInterest": 1776.89,
      "totalAmort": 123127.69
    },
    "actual": {
      "totalPmt": 124904.58,
      "totalInterest": 1776.89,
      "totalAmort": 123127.69
    },
    "allClose": true
  },
  "summary": {
    "totalPeriods": 3,
    "periodsWithDiffs": 0,
    "fieldsWithDiffs": []
  }
}
```

---

### Cenário 6: Validação com diferenças mínimas

**Contexto:** Há pequenas diferenças de arredondamento (dentro da tolerância de 0.01).

**Request:**

```bash
curl -X POST http://localhost:3001/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "pv": 100000,
      "rate": 0.12,
      "n": 2,
      "system": "price"
    },
    "expected": [
      {
        "k": 1,
        "pmt": 59246.75,
        "interest": 1000.00,
        "amort": 58246.75,
        "balance": 41753.25
      },
      {
        "k": 2,
        "pmt": 59246.75,
        "interest": 417.53,
        "amort": 58829.22,
        "balance": 0.00
      }
    ],
    "actual": [
      {
        "k": 1,
        "pmt": 59246.75,
        "interest": 1000.00,
        "amort": 58246.75,
        "balance": 41753.25
      },
      {
        "k": 2,
        "pmt": 59246.76,
        "interest": 417.53,
        "amort": 58829.23,
        "balance": 0.00
      }
    ]
  }'
```

**Resposta:**

```json
{
  "valid": true,
  "diffs": [],
  "totals": {
    "expected": {
      "totalPmt": 118493.5,
      "totalInterest": 1417.53,
      "totalAmort": 117075.97
    },
    "actual": {
      "totalPmt": 118493.51,
      "totalInterest": 1417.53,
      "totalAmort": 117075.98
    },
    "allClose": true
  },
  "summary": {
    "totalPeriods": 2,
    "periodsWithDiffs": 0,
    "fieldsWithDiffs": [],
    "note": "Diferenças menores que 0.01 são consideradas válidas"
  }
}
```

---

### Cenário 7: Validação com diferença crítica

**Contexto:** Há erro de cálculo significativo (> 0.01).

**Request:**

```bash
curl -X POST http://localhost:3001/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "pv": 100000,
      "rate": 0.12,
      "n": 2,
      "system": "price"
    },
    "expected": [
      {
        "k": 1,
        "pmt": 59246.75,
        "interest": 1000.00,
        "amort": 58246.75,
        "balance": 41753.25
      },
      {
        "k": 2,
        "pmt": 59246.75,
        "interest": 417.53,
        "amort": 58829.22,
        "balance": 0.00
      }
    ],
    "actual": [
      {
        "k": 1,
        "pmt": 59246.75,
        "interest": 1000.00,
        "amort": 58246.75,
        "balance": 41753.25
      },
      {
        "k": 2,
        "pmt": 59246.75,
        "interest": 420.00,
        "amort": 58826.75,
        "balance": 0.00
      }
    ]
  }'
```

**Resposta:**

```json
{
  "valid": false,
  "diffs": [
    {
      "period": 2,
      "field": "interest",
      "expected": 417.53,
      "actual": 420.0,
      "diff": 2.47
    },
    {
      "period": 2,
      "field": "amort",
      "expected": 58829.22,
      "actual": 58826.75,
      "diff": -2.47
    }
  ],
  "totals": {
    "expected": {
      "totalPmt": 118493.5,
      "totalInterest": 1417.53,
      "totalAmort": 117075.97
    },
    "actual": {
      "totalPmt": 118493.5,
      "totalInterest": 1420.0,
      "totalAmort": 117073.5
    },
    "allClose": false
  },
  "summary": {
    "totalPeriods": 2,
    "periodsWithDiffs": 1,
    "fieldsWithDiffs": ["interest", "amort"],
    "maxDiff": {
      "field": "interest",
      "period": 2,
      "value": 2.47
    }
  }
}
```

---

### Cenário 8: Validação de totais

**Contexto:** Cliente quer verificar apenas se os totais batem (sem importar diferenças locais).

**Request:**

```bash
curl -X POST http://localhost:3001/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "pv": 50000,
      "rate": 0.12,
      "n": 6,
      "system": "price"
    },
    "expected": [
      {"k": 1, "pmt": 9723.54, "interest": 500.00, "amort": 9223.54, "balance": 40776.46},
      {"k": 2, "pmt": 9723.54, "interest": 407.76, "amort": 9315.78, "balance": 31460.68},
      {"k": 3, "pmt": 9723.54, "interest": 314.61, "amort": 9408.93, "balance": 22051.75},
      {"k": 4, "pmt": 9723.54, "interest": 220.52, "amort": 9503.02, "balance": 12548.73},
      {"k": 5, "pmt": 9723.54, "interest": 125.49, "amort": 9598.05, "balance": 2950.68},
      {"k": 6, "pmt": 9723.54, "interest": 29.51, "amort": 9694.03, "balance": 0.00}
    ],
    "actual": [
      {"k": 1, "pmt": 9723.54, "interest": 500.00, "amort": 9223.54, "balance": 40776.46},
      {"k": 2, "pmt": 9723.54, "interest": 407.76, "amort": 9315.78, "balance": 31460.68},
      {"k": 3, "pmt": 9723.54, "interest": 314.61, "amort": 9408.93, "balance": 22051.75},
      {"k": 4, "pmt": 9723.54, "interest": 220.52, "amort": 9503.02, "balance": 12548.73},
      {"k": 5, "pmt": 9723.54, "interest": 125.49, "amort": 9598.05, "balance": 2950.68},
      {"k": 6, "pmt": 9723.54, "interest": 29.51, "amort": 9694.03, "balance": 0.00}
    ]
  }'
```

**Resposta:**

```json
{
  "valid": true,
  "diffs": [],
  "totals": {
    "expected": {
      "totalPmt": 58341.24,
      "totalInterest": 1597.89,
      "totalAmort": 56743.35
    },
    "actual": {
      "totalPmt": 58341.24,
      "totalInterest": 1597.89,
      "totalAmort": 56743.35
    },
    "allClose": true
  },
  "summary": {
    "totalPeriods": 6,
    "periodsWithDiffs": 0,
    "fieldsWithDiffs": []
  }
}
```

**Análise:** Os totais batem perfeitamente, indicando que o cronograma está matematicamente correto.

---

### Cenário 9: Erro de validação - tamanhos diferentes

**Contexto:** Expected tem 12 períodos, mas actual tem apenas 11 (erro de implementação).

**Request:**

```bash
curl -X POST http://localhost:3001/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "pv": 100000,
      "rate": 0.12,
      "n": 12,
      "system": "price"
    },
    "expected": [
      {"k": 1, "pmt": 8884.88, "interest": 1000.00, "amort": 7884.88, "balance": 92115.12},
      {"k": 2, "pmt": 8884.88, "interest": 921.15, "amort": 7963.73, "balance": 84151.39}
      // ... 10 períodos (total: 12)
    ],
    "actual": [
      {"k": 1, "pmt": 8884.88, "interest": 1000.00, "amort": 7884.88, "balance": 92115.12},
      {"k": 2, "pmt": 8884.88, "interest": 921.15, "amort": 7963.73, "balance": 84151.39}
      // ... 9 períodos (total: 11)
    ]
  }'
```

**Resposta:** `400 Bad Request`

```json
{
  "error": "Schedule size mismatch",
  "details": {
    "expected": 12,
    "actual": 11
  }
}
```

---

## 🔗 Cenários Combinados (H21 + H22)

### Cenário 10: Auditoria completa com validação

**Contexto:** Cliente quer calcular, guardar snapshot, e depois validar recálculo.

**Passo 1: Calcular e guardar**

```bash
RESPONSE=$(curl -s -X POST http://localhost:3001/api/price \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12}')

SNAPSHOT_ID=$(echo $RESPONSE | jq -r '.snapshotId')
SCHEDULE=$(echo $RESPONSE | jq '.schedule')

echo "Snapshot ID: $SNAPSHOT_ID"
```

**Passo 2: Recalcular (simular recálculo)**

```bash
RECALC=$(curl -s -X POST http://localhost:3001/api/price \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12}')

RECALC_SCHEDULE=$(echo $RECALC | jq '.schedule')
```

**Passo 3: Validar**

```bash
curl -X POST http://localhost:3001/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d "{
    \"input\": {\"pv\":100000,\"rate\":0.12,\"n\":12,\"system\":\"price\"},
    \"expected\": $SCHEDULE,
    \"actual\": $RECALC_SCHEDULE
  }"
```

**Passo 4: Recuperar snapshot original para auditoria**

```bash
curl http://localhost:3001/api/snapshot/$SNAPSHOT_ID
```

---

## 📊 Casos de Uso Práticos

### Caso 1: Regressão Testing

```bash
# Guardar cronograma "dourado" (golden file)
curl -X POST /api/price -d '{"pv":100000,"rate":0.12,"n":12}' > golden.json

# Após mudança no código, recalcular
curl -X POST /api/price -d '{"pv":100000,"rate":0.12,"n":12}' > new.json

# Validar se não houve regressão
curl -X POST /api/validate/schedule \
  -d '{"input":{...}, "expected": [golden], "actual": [new]}'
```

### Caso 2: Auditoria Regulatória

```bash
# Calcular empréstimo (gera snapshot automaticamente)
LOAN=$(curl -X POST /api/cet/basic -d '{...}')
SNAPSHOT_ID=$(echo $LOAN | jq -r '.snapshotId')

# 6 meses depois, auditor solicita evidência
curl /api/snapshot/$SNAPSHOT_ID

# Auditor pode verificar:
# - Hash para integridade
# - motorVersion para reproduzir cálculo
# - createdAt para timestamp
```

### Caso 3: Debugging de Diferenças

```bash
# Sistema A calculou cronograma
curl -X POST /api/price -d '{...}' > system_a.json

# Sistema B (legado) calculou diferente
# ... obter cronograma de sistema_b.json

# Identificar exatamente onde difere
curl -X POST /api/validate/schedule \
  -d '{"input":{...}, "expected": [A], "actual": [B]}'

# Resposta mostra: "maxDiff: { field: 'interest', period: 8, value: 12.50 }"
# → Investigar cálculo de juros no período 8
```

---

## 🧪 Testando os Exemplos

### Setup

```bash
# 1. Iniciar servidor
cd ~/workspace/fin-math/packages/api
pnpm dev

# 2. Em outro terminal, testar exemplos
cd ~/workspace/fin-math/docs/sprint2

# 3. Executar testes (opcional - criar script)
bash test-examples.sh
```

### Script de teste (test-examples.sh)

```bash
#!/bin/bash
BASE_URL="http://localhost:3001"

echo "🧪 Testando exemplos da API..."

# Cenário 1: Price + Snapshot
echo "1. POST /api/price"
RESPONSE=$(curl -s -X POST $BASE_URL/api/price \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12}')

SNAPSHOT_ID=$(echo $RESPONSE | jq -r '.snapshotId')
echo "   ✅ snapshotId: $SNAPSHOT_ID"

# Recuperar snapshot
echo "2. GET /api/snapshot/$SNAPSHOT_ID"
curl -s $BASE_URL/api/snapshot/$SNAPSHOT_ID | jq '.id, .hash' | head -2
echo "   ✅ Snapshot recuperado"

# Validação
echo "3. POST /api/validate/schedule"
VALID=$(curl -s -X POST $BASE_URL/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d '{"input":{"pv":100000,"rate":0.12,"n":1,"system":"price"},"expected":[{"k":1,"pmt":112000,"interest":1000,"amort":111000,"balance":0}],"actual":[{"k":1,"pmt":112000,"interest":1000,"amort":111000,"balance":0}]}')

echo $VALID | jq '.valid'
echo "   ✅ Validação executada"

echo ""
echo "✅ Todos os exemplos testados com sucesso!"
```

---

## 📚 Swagger UI

Todos esses exemplos também estão disponíveis no **Swagger UI interativo:**

🔗 **http://localhost:3001/api-docs**

Você pode:

- ✅ Testar todos os endpoints diretamente no navegador
- ✅ Ver schemas completos de request/response
- ✅ Copiar exemplos em curl, JavaScript, Python, etc

---

## 💡 Dicas

1. **Use jq para formatar JSON:** `curl ... | jq`
2. **Salve responses:** `curl ... > response.json`
3. **Use variáveis:** `SNAPSHOT_ID=$(curl ... | jq -r '.snapshotId')`
4. **Teste sempre em localhost primeiro**
5. **Valide hash para garantir integridade**

---

## 📞 Suporte

**Problemas com exemplos?**

- Verificar se servidor está rodando: `curl http://localhost:3001/api-docs`
- Ver logs do servidor: `cd packages/api && pnpm dev`
- Consultar [Troubleshooting](../troubleshooting-guide.md)
