#!/usr/bin/env bash
# Setup GitHub Project, milestones, and labels for RCC-OPS.
# RFC-driven workflow: Cursor never starts work unless an RFC is Approved.
#
# Prerequisites: gh CLI authenticated with project scope.
#   gh auth login
#   gh auth refresh -s project,repo

set -euo pipefail

REPO="rahul-devs/rcc-ops"
OWNER="rahul-devs"
PROJECT_TITLE="RCC-OPS"

# ---------------------------------------------------------------------------
# Auth check
# ---------------------------------------------------------------------------
if ! gh auth status &>/dev/null; then
  echo "Error: gh CLI is not authenticated."
  echo "Run: gh auth login"
  echo "Then: gh auth refresh -s project,repo"
  exit 1
fi

echo "==> Setting up GitHub Project for ${REPO}"

# ---------------------------------------------------------------------------
# Labels
# ---------------------------------------------------------------------------
echo "==> Creating labels..."

declare -A LABELS=(
  ["architecture"]="0075ca|System design and structural decisions"
  ["ddd"]="5319e7|Domain-driven design"
  ["event-driven"]="1d76db|Event-driven architecture"
  ["documentation"]="0075ca|Documentation updates"
  ["backend"]="0e8a16|Server-side and API work"
  ["api"]="84b6eb|API endpoints and contracts"
  ["database"]="c2e0c6|Database schema and migrations"
  ["laravel"]="fbca04|Laravel framework"
  ["whatsapp"]="25d366|WhatsApp integration"
  ["llm"]="bfd4f2|Large language model features"
  ["finance"]="fbca04|Financial operations and billing"
  ["discipline"]="e99695|Discipline management"
  ["registration"]="c5def5|Registration workflows"
  ["community"]="d93f0b|Community features"
  ["match"]="f9d0c4|Match scheduling and results"
  ["waiting-list"]="fef2c0|Waiting list management"
  ["penalty"]="b60205|Penalty rules and enforcement"
  ["payment"]="0e8a16|Payment processing"
  ["breaking-change"]="b60205|Breaking API or schema change"
  ["needs-review"]="d4c5f9|Awaiting review"
  ["blocked"]="000000|Blocked by dependency or decision"
)

for name in "${!LABELS[@]}"; do
  IFS='|' read -r color description <<< "${LABELS[$name]}"
  gh label create "$name" \
    --repo "$REPO" \
    --color "$color" \
    --description "$description" \
    --force
  echo "  ✓ ${name}"
done

# ---------------------------------------------------------------------------
# Milestones (repo-level)
# ---------------------------------------------------------------------------
echo "==> Creating milestones..."

declare -A MILESTONES=(
  ["M0 Discovery"]="Research, requirements gathering, and problem definition"
  ["M1 Domain"]="Domain model design and bounded context mapping"
  ["M2 Core"]="Core platform engine and rule execution"
  ["M3 WhatsApp"]="WhatsApp adapter and messaging integration"
  ["M4 AI"]="AI-powered features and automation"
  ["M5 RCC Pilot"]="RCC pilot deployment and validation"
)

for title in "${!MILESTONES[@]}"; do
  description="${MILESTONES[$title]}"
  existing=$(gh api "repos/${REPO}/milestones" --jq ".[] | select(.title==\"${title}\") | .number" 2>/dev/null || true)
  if [[ -n "$existing" ]]; then
    echo "  ~ ${title} (already exists)"
  else
    gh api "repos/${REPO}/milestones" \
      -f title="$title" \
      -f description="$description" \
      --silent
    echo "  ✓ ${title}"
  fi
done

# ---------------------------------------------------------------------------
# Project
# ---------------------------------------------------------------------------
echo "==> Creating project board..."

existing_project=$(gh project list --owner "$OWNER" --format json \
  --jq ".projects[] | select(.title==\"${PROJECT_TITLE}\") | .number" 2>/dev/null || true)

if [[ -n "$existing_project" ]]; then
  PROJECT_NUMBER="$existing_project"
  echo "  ~ Project '${PROJECT_TITLE}' already exists (#${PROJECT_NUMBER})"
else
  PROJECT_NUMBER=$(gh project create \
    --owner "$OWNER" \
    --title "$PROJECT_TITLE" \
    --format json \
    --jq '.number')
  echo "  ✓ Created project '${PROJECT_TITLE}' (#${PROJECT_NUMBER})"
fi

gh project link "$PROJECT_NUMBER" --owner "$OWNER" --repo "$REPO" 2>/dev/null || true
echo "  ✓ Linked to ${REPO}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Update a single-select field's options via GraphQL
update_field_options() {
  local field_id="$1"
  shift
  local -a options=("$@")
  local -a colors=("GRAY" "BLUE" "YELLOW" "PURPLE" "GREEN" "ORANGE" "RED" "PINK")

  local options_json="["
  for i in "${!options[@]}"; do
    [[ "$i" -gt 0 ]] && options_json+=","
    local color="${colors[$((i % ${#colors[@]}))]}"
    options_json+="{\"name\":\"${options[$i]}\",\"color\":\"${color}\",\"description\":\"\"}"
  done
  options_json+="]"

  local tmpfile
  tmpfile=$(mktemp)
  cat > "$tmpfile" <<GRAPHQL_EOF
{
  "query": "mutation(\$fieldId: ID!, \$options: [ProjectV2SingleSelectFieldOptionInput!]!) { updateProjectV2Field(input: {fieldId: \$fieldId, singleSelectOptions: \$options}) { projectV2Field { ... on ProjectV2SingleSelectField { name options { name } } } } }",
  "variables": {
    "fieldId": "${field_id}",
    "options": ${options_json}
  }
}
GRAPHQL_EOF

  gh api graphql --input "$tmpfile" --silent
  rm -f "$tmpfile"
}

# Get field ID by name, or empty string if not found
get_field_id() {
  local field_name="$1"
  gh api graphql -f query='
    query($owner: String!, $number: Int!) {
      user(login: $owner) {
        projectV2(number: $number) {
          fields(first: 50) {
            nodes {
              ... on ProjectV2SingleSelectField {
                id
                name
              }
            }
          }
        }
      }
    }
  ' -f owner="$OWNER" -F number="$PROJECT_NUMBER" \
    --jq ".data.user.projectV2.fields.nodes[] | select(.name == \"${field_name}\") | .id" 2>/dev/null || true
}

# Ensure a custom single-select field exists with the given options
ensure_field() {
  local field_name="$1"
  shift
  local -a options=("$@")

  local field_id
  field_id=$(get_field_id "$field_name")

  if [[ -z "$field_id" || "$field_id" == "null" ]]; then
    gh project field-create "$PROJECT_NUMBER" \
      --owner "$OWNER" \
      --name "$field_name" \
      --data-type "SINGLE_SELECT" \
      --single-select-options "$(IFS=,; echo "${options[*]}")" \
      >/dev/null
    echo "  ✓ Created field: ${field_name}"
  else
    update_field_options "$field_id" "${options[@]}"
    echo "  ✓ Updated field: ${field_name}"
  fi
}

# ---------------------------------------------------------------------------
# Status columns — RFC-driven pipeline
# ---------------------------------------------------------------------------
echo "==> Configuring RFC-driven pipeline columns..."

COLUMNS=(
  "📥 Inbox"
  "🔬 Discovery"
  "📝 RFC Draft"
  "👨‍💼 Review (Claude)"
  "✅ Approved"
  "💻 Ready For Cursor"
  "🚧 In Progress"
  "👀 Code Review"
  "🧪 RCC Testing"
  "✅ Done"
)

STATUS_FIELD_ID=$(get_field_id "Status")

if [[ -z "$STATUS_FIELD_ID" || "$STATUS_FIELD_ID" == "null" ]]; then
  gh project field-create "$PROJECT_NUMBER" \
    --owner "$OWNER" \
    --name "Status" \
    --data-type "SINGLE_SELECT" \
    --single-select-options "$(IFS=,; echo "${COLUMNS[*]}")"
  echo "  ✓ Created Status field"
else
  update_field_options "$STATUS_FIELD_ID" "${COLUMNS[@]}"
  echo "  ✓ Updated Status columns"
fi

# ---------------------------------------------------------------------------
# Custom fields
# ---------------------------------------------------------------------------
echo "==> Configuring custom fields..."

ensure_field "Priority" "Critical" "High" "Medium" "Low"
ensure_field "Domain" "Community" "Match" "Registration" "Finance" "Discipline" "Messaging" "AI" "Platform"
ensure_field "Type" "RFC" "ADR" "Feature" "Bug" "Task" "Spike" "Research"
ensure_field "Estimated Complexity" "XS" "S" "M" "L" "XL"
ensure_field "AI Owner" "ChatGPT" "Claude" "Cursor" "Ollama" "Mixed"

# Milestone uses GitHub's built-in field (linked to repo milestones M0–M5).
# A custom field named "Milestone" is reserved by GitHub Projects.
echo "  ~ Milestone: using built-in field (repo milestones M0–M5)"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
PROJECT_URL=$(gh project view "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.url')

echo ""
echo "========================================"
echo "  GitHub Project setup complete!"
echo "========================================"
echo ""
echo "  Project:  ${PROJECT_TITLE} (#${PROJECT_NUMBER})"
echo "  URL:      ${PROJECT_URL}"
echo "  Labels:   ${#LABELS[@]} created/updated"
echo "  Milestones: M0 – M5"
echo "  Columns:  ${#COLUMNS[@]} RFC-driven pipeline stages"
echo "  Fields:   Priority, Domain, Type, Milestone (built-in),"
echo "            Estimated Complexity, AI Owner"
echo ""
echo "  Rule: Cursor never starts work unless an RFC is Approved."
echo ""
echo "  Open the board:"
echo "    gh project view ${PROJECT_NUMBER} --owner ${OWNER} --web"
echo ""
