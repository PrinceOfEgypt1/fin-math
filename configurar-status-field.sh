#!/bin/bash
# configurar-status-field.sh
# Configura opções do campo Status via GraphQL API

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

# 2. Obter ID do campo Status e opções atuais
echo ""
echo "2️⃣ Obtendo campo Status..."
FIELD_INFO=$(gh api graphql -f query='
  query {
    node(id: "'$PROJECT_ID'") {
      ... on ProjectV2 {
        field(name: "Status") {
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
  }
' --jq '.data.node.field')

FIELD_ID=$(echo "$FIELD_INFO" | jq -r '.id')
echo "   Status Field ID: $FIELD_ID"

echo ""
echo "3️⃣ Opções atuais:"
echo "$FIELD_INFO" | jq -r '.options[] | "   • \(.name)"'

# 3. Adicionar novas opções se não existirem
echo ""
echo "4️⃣ Configurando opções necessárias..."

# Função para adicionar opção
add_option() {
  local option_name=$1
  local option_color=$2
  
  # Verificar se já existe
  EXISTS=$(echo "$FIELD_INFO" | jq -r ".options[] | select(.name == \"$option_name\") | .name")
  
  if [ -z "$EXISTS" ]; then
    echo "   Adicionando: $option_name"
    gh api graphql -f query='
      mutation {
        updateProjectV2Field(input: {
          projectId: "'$PROJECT_ID'"
          fieldId: "'$FIELD_ID'"
          name: "Status"
          singleSelectOptions: [{
            name: "'$option_name'"
            color: "'$option_color'"
          }]
        }) {
          projectV2Field {
            ... on ProjectV2SingleSelectField {
              id
            }
          }
        }
      }
    ' > /dev/null
    echo "   ✅ $option_name adicionado"
  else
    echo "   ⏭️  $option_name já existe"
  fi
}

# Adicionar nossas 4 opções
add_option "📦 Backlog" "GRAY"
add_option "🚧 In Progress" "YELLOW"
add_option "👀 In Review" "BLUE"
add_option "✅ Done" "GREEN"

echo ""
echo "========================================="
echo "✅ CONFIGURAÇÃO CONCLUÍDA!"
echo "========================================="
echo ""
echo "Verificar no board:"
echo "https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
