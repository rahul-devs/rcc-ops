#!/usr/bin/env bash
# Setup GitHub Project, milestones, and labels for RCC-OPS.
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
  ["domain"]="5319e7|Domain model and bounded contexts"
  ["discussion"]="d4c5f9|Open questions and conversations"
  ["rfc"]="fef2c0|Request for Comments proposals"
  ["backend"]="0e8a16|Server-side and API work"
  ["frontend"]="1d76db|UI and client-side work"
  ["ai"]="bfd4f2|AI and machine learning features"
  ["whatsapp"]="25d366|WhatsApp integration"
  ["finance"]="fbca04|Financial operations and billing"
  ["discipline"]="e99695|Discipline management"
  ["registration"]="c5def5|Registration workflows"
  ["messaging"]="84b6eb|Messaging and notifications"
  ["match"]="f9d0c4|Match scheduling and results"
  ["community"]="d93f0b|Community features"
  ["good first issue"]="7057ff|Good for newcomers"
  ["high priority"]="b60205|Urgent or critical work"
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
# Milestones
# ---------------------------------------------------------------------------
echo "==> Creating milestones..."

declare -A MILESTONES=(
  ["M0 Discovery"]="Research, requirements gathering, and problem definition"
  ["M1 Domain"]="Domain model design and bounded context mapping"
  ["M2 Core Engine"]="Core platform engine and rule execution"
  ["M3 WhatsApp"]="WhatsApp adapter and messaging integration"
  ["M4 AI"]="AI-powered features and automation"
  ["M5 RCC Pilot"]="RCC pilot deployment and validation"
  ["M6 Production"]="Production hardening and launch"
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

# Link project to repository
gh project link "$PROJECT_NUMBER" --owner "$OWNER" --repo "$REPO" 2>/dev/null || true
echo "  ✓ Linked to ${REPO}"

# ---------------------------------------------------------------------------
# Status columns (Kanban board)
# ---------------------------------------------------------------------------
echo "==> Configuring board columns..."

COLUMNS=(
  "📥 Inbox"
  "🔍 Discovery"
  "📖 RFC"
  "🏛 Architecture"
  "🧠 Domain Model"
  "💻 Ready"
  "🚧 In Progress"
  "👀 Review"
  "🧪 Testing"
  "✅ Done"
)

COLUMN_COLORS=(
  "GRAY"
  "BLUE"
  "YELLOW"
  "PURPLE"
  "PURPLE"
  "GREEN"
  "YELLOW"
  "ORANGE"
  "BLUE"
  "GREEN"
)

# Build singleSelectOptions JSON array
options_json="["
for i in "${!COLUMNS[@]}"; do
  [[ "$i" -gt 0 ]] && options_json+=","
  options_json+="{\"name\":\"${COLUMNS[$i]}\",\"color\":\"${COLUMN_COLORS[$i]}\",\"description\":\"\"}"
done
options_json+="]"

# Fetch project ID and Status field ID via GraphQL
read -r PROJECT_ID FIELD_ID <<< "$(gh api graphql -f query='
  query($owner: String!, $number: Int!) {
    user(login: $owner) {
      projectV2(number: $number) {
        id
        fields(first: 20) {
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
  --jq '[.data.user.projectV2.id, (.data.user.projectV2.fields.nodes[] | select(.name == "Status") | .id)] | @tsv')"

if [[ -z "$FIELD_ID" || "$FIELD_ID" == "null" ]]; then
  echo "  ! Status field not found — creating custom Pipeline field..."
  gh project field-create "$PROJECT_NUMBER" \
    --owner "$OWNER" \
    --name "Pipeline" \
    --data-type "SINGLE_SELECT" \
    --single-select-options "$(IFS=,; echo "${COLUMNS[*]}")"
else
  gh api graphql -f query='
    mutation($input: UpdateProjectV2FieldInput!) {
      updateProjectV2Field(input: $input) {
        projectV2Field {
          ... on ProjectV2SingleSelectField {
            name
            options { name }
          }
        }
      }
    }
  ' -f input="{\"fieldId\":\"${FIELD_ID}\",\"singleSelectOptions\":${options_json}}" \
    --silent
  echo "  ✓ Updated Status columns"
fi

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
echo "  Milestones: M0 – M6"
echo "  Columns:  ${#COLUMNS[@]} pipeline stages"
echo ""
echo "  Open the board:"
echo "    gh project view ${PROJECT_NUMBER} --owner ${OWNER} --web"
echo ""
