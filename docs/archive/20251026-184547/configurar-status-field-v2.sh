#!/bin/bash
set -e

echo "📋 CONFIGURANDO CAMPO STATUS DO BOARD"
echo "======================================"

PROJECT_NUMBER=3
OWNER="PrinceOfEgypt1"

# 1. Obter ID do projeto
echo "1️⃣ Obtendo ID do projeto..."
PROJECT_ID=$(gh api graphql -f query='
  query {
    user(login: "'$OWNER'") {
      projectV2(number: '$PROJECT_NUMBER') {
        id
      }
    }
  }
' --jq '.data.user.projectV2.id')

echo "   Project ID: $PROJECT_ID"

# 2. Obter ID do campo Status
echo ""
echo "2️⃣ Obtendo campo Status..."
FIELD_ID=$(gh api graphql -f query='
  query {
    node(id: "'$PROJECT_ID'") {
      ... on ProjectV2 {
        field(name: "Status") {
          ... on ProjectV2SingleSelectField {
            id
          }
        }
      }
    }
  }
' --jq '.data.node.field.id')

echo "   Status Field ID: $FIELD_ID"

# 3. Atualizar com nossas 4 opções
echo ""
echo "3️⃣ Substituindo opções..."

gh api graphql -f query='
  mutation {
    updateProjectV2Field(input: {
      projectId: "'$PROJECT_ID'"
      fieldId: "'$FIELD_ID'"
      singleSelectOptions: [
        {name: "📦 Backlog", color: GRAY, description: "HUs planejadas"},
        {name: "🚧 In Progress", color: YELLOW, description: "Em desenvolvimento"},
        {name: "👀 In Review", color: BLUE, description: "PR aberto"},
        {name: "✅ Done", color: GREEN, description: "Concluído"}
      ]
    }) {
      projectV2Field {
        ... on ProjectV2SingleSelectField {
          id
          options {
            id
            name
          }
        }
      }
    }
  }
'

echo ""
echo "========================================="
echo "✅ CONFIGURAÇÃO CONCLUÍDA!"
echo "========================================="
echo ""
echo "4️⃣ Verificando opções configuradas..."

gh api graphql -f query='
  query {
    node(id: "'$PROJECT_ID'") {
      ... on ProjectV2 {
        field(name: "Status") {
          ... on ProjectV2SingleSelectField {
            options {
              name
            }
          }
        }
      }
    }
  }
' --jq '.data.node.field.options[] | "   ✅ \(.name)"'

echo ""
echo "🔗 Verificar no board:"
echo "   https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
