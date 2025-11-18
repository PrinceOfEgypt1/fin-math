#!/bin/bash
set -e

echo "📋 CONVERTENDO VIEW PARA BOARD LAYOUT"
echo "======================================"

VIEW_ID="PVTV_lAHOBapiIc4BF030zgIKICY"
STATUS_FIELD_ID="PVTSSF_lAHOBapiIc4BF030zg3DR2o"

echo "View ID: $VIEW_ID"
echo "Status Field ID: $STATUS_FIELD_ID"

echo ""
echo "🔄 Convertendo para BOARD layout..."

gh api graphql -f query='
  mutation {
    updateProjectV2View(input: {
      viewId: "'$VIEW_ID'"
      layout: BOARD_LAYOUT
      groupByFields: [{fieldId: "'$STATUS_FIELD_ID'"}]
    }) {
      projectV2View {
        id
        name
        layout
      }
    }
  }
' --jq '.data.updateProjectV2View.projectV2View'

echo ""
echo "✅ CONCLUÍDO!"
echo "🔗 https://github.com/users/PrinceOfEgypt1/projects/3"
