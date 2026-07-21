#!/usr/bin/env bash
# Configure RCC-OPS GitHub Project (v2) — columns, fields, and seed issues.
set -euo pipefail

REPO="rahul-devs/rcc-ops"
OWNER="rahul-devs"
PROJECT_NUMBER=1

export PATH="/c/Program Files/GitHub CLI:$PATH"

if ! gh auth status &>/dev/null; then
  echo "Error: run 'gh auth login' first."
  exit 1
fi

# ---------------------------------------------------------------------------
# GraphQL helpers
# ---------------------------------------------------------------------------

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
  cat > "$tmpfile" <<EOF
{
  "query": "mutation(\$fieldId: ID!, \$options: [ProjectV2SingleSelectFieldOptionInput!]!) { updateProjectV2Field(input: {fieldId: \$fieldId, singleSelectOptions: \$options}) { projectV2Field { ... on ProjectV2SingleSelectField { name options { id name } } } } }",
  "variables": {
    "fieldId": "${field_id}",
    "options": ${options_json}
  }
}
EOF
  gh api graphql --input "$tmpfile"
  rm -f "$tmpfile"
}

get_single_select_field_id() {
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
    --jq ".data.user.projectV2.fields.nodes[] | select(.name == \"${field_name}\") | .id"
}

ensure_field() {
  local field_name="$1"
  shift
  local -a options=("$@")

  local field_id
  field_id=$(get_single_select_field_id "$field_name" || true)

  if [[ -z "$field_id" || "$field_id" == "null" ]]; then
    gh project field-create "$PROJECT_NUMBER" \
      --owner "$OWNER" \
      --name "$field_name" \
      --data-type "SINGLE_SELECT" \
      --single-select-options "$(IFS=,; echo "${options[*]}")" \
      >/dev/null
    echo "  ✓ Created: ${field_name}"
  else
    update_field_options "$field_id" "${options[@]}" >/dev/null
    echo "  ✓ Updated: ${field_name}"
  fi
}

get_project_id() {
  gh api graphql -f query='
    query($owner: String!, $number: Int!) {
      user(login: $owner) {
        projectV2(number: $number) { id }
      }
    }
  ' -f owner="$OWNER" -F number="$PROJECT_NUMBER" \
    --jq '.data.user.projectV2.id'
}

get_status_option_id() {
  local option_name="$1"
  gh api graphql -f query='
    query($owner: String!, $number: Int!) {
      user(login: $owner) {
        projectV2(number: $number) {
          field(name: "Status") {
            ... on ProjectV2SingleSelectField {
              options { id name }
            }
          }
        }
      }
    }
  ' -f owner="$OWNER" -F number="$PROJECT_NUMBER" \
    --jq ".data.user.projectV2.field.options[] | select(.name == \"${option_name}\") | .id"
}

# ---------------------------------------------------------------------------
# Status columns
# ---------------------------------------------------------------------------
echo "==> Configuring Status columns..."

STATUS_COLUMNS=(
  "Inbox"
  "Discovery"
  "RFC Draft"
  "Review"
  "Approved"
  "Ready for Cursor"
  "In Progress"
  "Code Review"
  "RCC Testing"
  "Done"
)

STATUS_FIELD_ID=$(get_single_select_field_id "Status")
update_field_options "$STATUS_FIELD_ID" "${STATUS_COLUMNS[@]}" >/dev/null
echo "  ✓ Status (${#STATUS_COLUMNS[@]} columns)"

# ---------------------------------------------------------------------------
# Custom fields
# ---------------------------------------------------------------------------
echo "==> Configuring custom fields..."

ensure_field "Priority" "Critical" "High" "Medium" "Low"
ensure_field "Domain" "Community" "Match" "Registration" "Finance" "Discipline" "Messaging" "AI" "Platform"
ensure_field "Type" "RFC" "ADR" "Feature" "Bug" "Research" "Task"
ensure_field "Complexity" "XS" "S" "M" "L" "XL"
ensure_field "AI Owner" "ChatGPT" "Claude" "Cursor" "Ollama" "Mixed"

# Milestone: GitHub reserves the name — use built-in field + repo milestones
echo "  ~ Milestone: built-in field (repo milestones M0–M5)"

declare -A MILESTONES=(
  ["M0 Discovery"]="Research, requirements gathering, and problem definition"
  ["M1 Domain"]="Domain model design and bounded context mapping"
  ["M2 Core"]="Core platform engine and rule execution"
  ["M3 WhatsApp"]="WhatsApp adapter and messaging integration"
  ["M4 AI"]="AI-powered features and automation"
  ["M5 RCC Pilot"]="RCC pilot deployment and validation"
)

for title in "${!MILESTONES[@]}"; do
  existing=$(gh api "repos/${REPO}/milestones" --jq ".[] | select(.title==\"${title}\") | .number" 2>/dev/null || true)
  if [[ -z "$existing" ]]; then
    gh api "repos/${REPO}/milestones" \
      -f title="$title" \
      -f description="${MILESTONES[$title]}" \
      --silent
    echo "  ✓ Milestone: ${title}"
  fi
done

# ---------------------------------------------------------------------------
# Seed issues
# ---------------------------------------------------------------------------
echo "==> Creating seed issues..."

declare -a ISSUES=(
  "RFC|RFC-0000 Project Principles|Define the foundational principles governing RCC-OPS design and delivery."
  "RFC|RFC-0001 Ubiquitous Language|Establish the shared vocabulary used across all bounded contexts."
  "RFC|RFC-0002 State Machines|Define state machines for core domain entities and workflows."
  "RFC|RFC-0003 Bounded Contexts|Map bounded contexts and their integration boundaries."
  "ADR|ADR-0001 Modular Monolith|Record the decision to adopt a modular monolith architecture."
  "ADR|ADR-0002 Event-Driven Architecture|Record the decision to use event-driven communication patterns."
  "ADR|ADR-0003 AI Never Owns Business Logic|Record the principle that AI assists but does not own business rules."
  "ADR|ADR-0004 WhatsApp Is an Adapter|Record the decision to treat WhatsApp as an infrastructure adapter."
)

PROJECT_ID=$(get_project_id)
STATUS_FIELD_ID=$(get_single_select_field_id "Status")
INBOX_OPTION_ID=$(get_status_option_id "Inbox")
TYPE_FIELD_ID=$(get_single_select_field_id "Type")

for entry in "${ISSUES[@]}"; do
  IFS='|' read -r kind title body <<< "$entry"

  existing_url=$(gh issue list --repo "$REPO" --search "\"${title}\" in:title" --json url --jq '.[0].url' 2>/dev/null || true)
  if [[ -n "$existing_url" && "$existing_url" != "null" ]]; then
    issue_url="$existing_url"
    echo "  ~ ${title} (exists)"
  else
  label_flag=""
  if [[ "$kind" == "RFC" ]]; then
    label_flag="--label rfc"
  else
    label_flag="--label architecture"
  fi

  issue_url=$(gh issue create \
    --repo "$REPO" \
    --title "$title" \
    --body "$body" \
    --milestone "M0 Discovery" \
    $label_flag)
  echo "  ✓ ${title}"
  fi

  # Add to project
  item_id=$(gh project item-add "$PROJECT_NUMBER" \
    --owner "$OWNER" \
    --url "$issue_url" \
    --format json \
    --jq '.id' 2>/dev/null || true)

  if [[ -z "$item_id" || "$item_id" == "null" ]]; then
    item_id=$(gh api graphql -f query='
      query($owner: String!, $number: Int!) {
        user(login: $owner) {
          projectV2(number: $number) {
            items(first: 100) {
              nodes {
                id
                content {
                  ... on Issue { url }
                }
              }
            }
          }
        }
      }
    ' -f owner="$OWNER" -F number="$PROJECT_NUMBER" \
      --jq ".data.user.projectV2.items.nodes[] | select(.content.url == \"${issue_url}\") | .id")
  fi

  # Set Status → Inbox
  if [[ -n "$item_id" && "$item_id" != "null" ]]; then
    gh project item-edit \
      --id "$item_id" \
      --project-id "$PROJECT_ID" \
      --field-id "$STATUS_FIELD_ID" \
      --single-select-option-id "$INBOX_OPTION_ID" \
      >/dev/null 2>&1 || true

    # Set Type field
    type_option_id=$(gh api graphql -f query='
      query($owner: String!, $number: Int!) {
        user(login: $owner) {
          projectV2(number: $number) {
            field(name: "Type") {
              ... on ProjectV2SingleSelectField {
                options { id name }
              }
            }
          }
        }
      }
    ' -f owner="$OWNER" -F number="$PROJECT_NUMBER" \
      --jq ".data.user.projectV2.field.options[] | select(.name == \"${kind}\") | .id")

    if [[ -n "$type_option_id" && "$type_option_id" != "null" ]]; then
      gh project item-edit \
        --id "$item_id" \
        --project-id "$PROJECT_ID" \
        --field-id "$TYPE_FIELD_ID" \
        --single-select-option-id "$type_option_id" \
        >/dev/null 2>&1 || true
    fi
  fi
done

echo ""
echo "==> Done."
echo "    Project: https://github.com/users/${OWNER}/projects/${PROJECT_NUMBER}"
echo "    Issues:  8 seed items in Inbox (M0 Discovery)"
