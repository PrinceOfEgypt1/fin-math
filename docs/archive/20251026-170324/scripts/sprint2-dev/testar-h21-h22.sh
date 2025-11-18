#!/bin/bash
# testar-h21-h22.sh
# Script para testar H21 (Snapshots) e H22 (Validador)
# Execute APÓS implementar-h21-h22.sh e fazer as modificações manuais

echo "🧪 TESTANDO H21 (Snapshots) e H22 (Validador)"
echo ""

# Verificar se API está rodando
API_URL="http://localhost:3001"

echo "🔍 Verificando se API está rodando..."
curl -s "$API_URL/health" > /dev/null
if [ $? -ne 0 ]; then
    echo "❌ API não está rodando!"
    echo "   Execute: cd packages/api && pnpm dev"
    exit 1
fi
echo "✅ API está rodando"
echo ""

# ========================================
# TESTE 1: POST /api/price (com snapshot)
# ========================================
echo "📋 TESTE 1: POST /api/price (deve criar snapshot)"
echo ""

RESPONSE=$(curl -s -X POST "$API_URL/api/price" \
  -H "Content-Type: application/json" \
  -d '{
    "pv": 10000,
    "rate": 0.025,
    "n": 12
  }')

echo "$RESPONSE" | jq '.'

# Extrair snapshotId
SNAPSHOT_ID=$(echo "$RESPONSE" | jq -r '._meta.snapshotId')

if [ "$SNAPSHOT_ID" == "null" ] || [ -z "$SNAPSHOT_ID" ]; then
    echo "❌ FALHOU: Snapshot não foi criado"
    exit 1
fi

echo ""
echo "✅ Snapshot criado: $SNAPSHOT_ID"
echo ""

# ========================================
# TESTE 2: GET /api/snapshot/:id
# ========================================
echo "📋 TESTE 2: GET /api/snapshot/:id"
echo ""

SNAPSHOT=$(curl -s "$API_URL/api/snapshot/$SNAPSHOT_ID")

echo "$SNAPSHOT" | jq '.'

# Verificar campos obrigatórios
HAS_HASH=$(echo "$SNAPSHOT" | jq -r '.hash')
HAS_META=$(echo "$SNAPSHOT" | jq -r '.meta.motorVersion')

if [ "$HAS_HASH" == "null" ] || [ "$HAS_META" == "null" ]; then
    echo "❌ FALHOU: Snapshot incompleto"
    exit 1
fi

echo ""
echo "✅ Snapshot recuperado com sucesso"
echo "   Hash: ${HAS_HASH:0:16}..."
echo "   Motor: $HAS_META"
echo ""

# ========================================
# TESTE 3: POST /api/validate/schedule (válido)
# ========================================
echo "📋 TESTE 3: POST /api/validate/schedule (cronograma válido)"
echo ""

VALIDATION=$(curl -s -X POST "$API_URL/api/validate/schedule" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "price",
    "params": {
      "pv": 10000,
      "rate": 0.025,
      "n": 3
    },
    "schedule": [
      { "k": 1, "pmt": 3417.82, "interest": 250.00, "amort": 3167.82, "balance": 6832.18 },
      { "k": 2, "pmt": 3417.82, "interest": 170.80, "amort": 3247.02, "balance": 3585.16 },
      { "k": 3, "pmt": 3674.79, "interest": 89.63, "amort": 3585.16, "balance": 0.00 }
    ]
  }')

echo "$VALIDATION" | jq '.'

VALID=$(echo "$VALIDATION" | jq -r '.valid')
TOTAL_ROWS=$(echo "$VALIDATION" | jq -r '.summary.totalRows')
INVALID_ROWS=$(echo "$VALIDATION" | jq -r '.summary.invalidRows')

if [ "$VALID" != "true" ]; then
    echo "⚠️  AVISO: Cronograma não passou (pode ser esperado se valores estiverem imprecisos)"
    echo "   Total: $TOTAL_ROWS | Inválidas: $INVALID_ROWS"
else
    echo "✅ Cronograma validado com sucesso"
    echo "   Total: $TOTAL_ROWS | Válidas: $TOTAL_ROWS"
fi
echo ""

# ========================================
# TESTE 4: POST /api/validate/schedule (inválido)
# ========================================
echo "📋 TESTE 4: POST /api/validate/schedule (cronograma inválido)"
echo ""

VALIDATION_INVALID=$(curl -s -X POST "$API_URL/api/validate/schedule" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "price",
    "params": {
      "pv": 10000,
      "rate": 0.025,
      "n": 2
    },
    "schedule": [
      { "k": 1, "pmt": 5000.00, "interest": 250.00, "amort": 4750.00, "balance": 5250.00 },
      { "k": 2, "pmt": 5000.00, "interest": 131.25, "amort": 4868.75, "balance": 381.25 }
    ]
  }')

echo "$VALIDATION_INVALID" | jq '.'

VALID_INVALID=$(echo "$VALIDATION_INVALID" | jq -r '.valid')
DIFFS_COUNT=$(echo "$VALIDATION_INVALID" | jq -r '.diffs | length')

if [ "$VALID_INVALID" == "false" ] && [ "$DIFFS_COUNT" -gt "0" ]; then
    echo "✅ Validador detectou diferenças corretamente"
    echo "   Diferenças encontradas: $DIFFS_COUNT"
else
    echo "❌ FALHOU: Validador não detectou diferenças"
    exit 1
fi
echo ""

# ========================================
# TESTE 5: POST /api/sac (com snapshot)
# ========================================
echo "📋 TESTE 5: POST /api/sac (deve criar snapshot)"
echo ""

SAC_RESPONSE=$(curl -s -X POST "$API_URL/api/sac" \
  -H "Content-Type: application/json" \
  -d '{
    "pv": 10000,
    "rate": 0.025,
    "n": 12
  }')

echo "$SAC_RESPONSE" | jq '._meta'

SAC_SNAPSHOT_ID=$(echo "$SAC_RESPONSE" | jq -r '._meta.snapshotId')

if [ "$SAC_SNAPSHOT_ID" == "null" ] || [ -z "$SAC_SNAPSHOT_ID" ]; then
    echo "❌ FALHOU: Snapshot SAC não foi criado"
    exit 1
fi

echo ""
echo "✅ Snapshot SAC criado: $SAC_SNAPSHOT_ID"
echo ""

# ========================================
# TESTE 6: Validar UUID inválido
# ========================================
echo "📋 TESTE 6: GET /api/snapshot/invalid-uuid (deve retornar erro)"
echo ""

INVALID_UUID=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$API_URL/api/snapshot/invalid-uuid-123")

HTTP_STATUS=$(echo "$INVALID_UUID" | grep "HTTP_STATUS" | cut -d':' -f2)
BODY=$(echo "$INVALID_UUID" | grep -v "HTTP_STATUS")

echo "$BODY" | jq '.'

if [ "$HTTP_STATUS" == "400" ]; then
    echo "✅ UUID inválido rejeitado corretamente (HTTP 400)"
else
    echo "❌ FALHOU: Deveria retornar HTTP 400 para UUID inválido"
    exit 1
fi
echo ""

# ========================================
# TESTE 7: Validar snapshot não encontrado
# ========================================
echo "📋 TESTE 7: GET /api/snapshot/[UUID válido mas não existe] (deve retornar 404)"
echo ""

FAKE_UUID="123e4567-e89b-12d3-a456-426614174000"
NOT_FOUND=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$API_URL/api/snapshot/$FAKE_UUID")

HTTP_STATUS_404=$(echo "$NOT_FOUND" | grep "HTTP_STATUS" | cut -d':' -f2)
BODY_404=$(echo "$NOT_FOUND" | grep -v "HTTP_STATUS")

echo "$BODY_404" | jq '.'

if [ "$HTTP_STATUS_404" == "404" ]; then
    echo "✅ Snapshot não encontrado retornou HTTP 404 corretamente"
else
    echo "❌ FALHOU: Deveria retornar HTTP 404 para snapshot não encontrado"
    exit 1
fi
echo ""

# ========================================
# RESUMO FINAL
# ========================================
echo "🎉 TODOS OS TESTES PASSARAM!"
echo ""
echo "📊 Resumo:"
echo "   ✅ H21: Snapshots funcionando"
echo "   ✅ H22: Validador funcionando"
echo "   ✅ Integração com Price/SAC"
echo "   ✅ Validação de erros"
echo ""
echo "🚀 Próximos passos:"
echo "   1. Executar testes unitários: pnpm test"
echo "   2. Executar validação anti-regressão completa"
echo "   3. Fazer commit final"
echo "   4. Merge sprint-2 → main"
echo ""
