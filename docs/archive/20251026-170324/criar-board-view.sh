#!/bin/bash
set -e

echo "📋 CRIANDO VIEW BOARD (KANBAN)"
echo "=============================="

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
echo "2️⃣ Obtendo ID do campo Status..."
STATUS_FIELD_ID=$(gh api graphql -f query='
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

echo "   Status Field ID: $STATUS_FIELD_ID"

# 3. Criar view Board
echo ""
echo "3️⃣ Criando view Board..."

VIEW_ID=$(gh api graphql -f query='
  mutation {
    createProjectV2View(input: {
      projectId: "'$PROJECT_ID'"
      name: "Board (Kanban)"
      layout: BOARD_LAYOUT
    }) {
      projectV2View {
        id
        name
      }
    }
  }
' --jq '.data.createProjectV2View.projectV2View.id')

echo "   View ID: $VIEW_ID"

# 4. Configurar agrupamento
echo ""
echo "4️⃣ Configurando agrupamento por Status..."

gh api graphql -f query='
  mutation {
    updateProjectV2View(input: {
      viewId: "'$VIEW_ID'"
      groupByFields: [{fieldId: "'$STATUS_FIELD_ID'"}]
    }) {
      projectV2View {
        id
        name
      }
    }
  }
' --jq '.data.updateProjectV2View.projectV2View.name'

echo "   ✅ View configurada!"

echo ""
echo "========================================="
echo "✅ VIEW BOARD CRIADA COM SUCESSO!"
echo "========================================="
echo ""
echo "🔗 https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
