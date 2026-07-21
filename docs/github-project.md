# GitHub Project

## Purpose

This document defines the RCC-OPS GitHub Project board. RCC-OPS is an **RFC-driven project** — Cursor never starts work unless an RFC is Approved. This gate prevents architecture drift.

## Project Board

| Field | Value |
|-------|-------|
| **Title** | RCC-OPS |
| **Owner** | [rahul-devs](https://github.com/rahul-devs) |
| **Repository** | [rahul-devs/rcc-ops](https://github.com/rahul-devs/rcc-ops) |

## Columns (RFC-Driven Pipeline)

Issues and pull requests flow through these stages. **No card may reach 💻 Ready For Cursor without passing ✅ Approved.**

| Column | Purpose | Actor |
|--------|---------|-------|
| 📥 Inbox | New items awaiting triage | Human |
| 🔬 Discovery | Research, requirements, problem exploration | Human |
| 📝 RFC Draft | RFC being written or revised | Human |
| 👨‍💼 Review (Claude) | RFC under architectural review | Claude |
| ✅ Approved | RFC accepted — implementation may proceed | Claude |
| 💻 Ready For Cursor | Approved and queued for implementation | Cursor |
| 🚧 In Progress | Active development | Cursor |
| 👀 Code Review | Code review in progress | Human / Claude |
| 🧪 RCC Testing | RCC pilot validation and integration testing | Human |
| ✅ Done | Completed and verified | — |

### The Gate

```
📝 RFC Draft → 👨‍💼 Review (Claude) → ✅ Approved → 💻 Ready For Cursor → 🚧 In Progress
```

Work that skips RFC approval must not enter implementation columns. This is the primary mechanism for preventing architecture drift.

## Custom Fields

### Priority

| Value | Use For |
|-------|---------|
| Critical | Blocks delivery or production |
| High | Important, time-sensitive |
| Medium | Normal priority |
| Low | Nice to have, deferrable |

### Domain

| Value | Use For |
|-------|---------|
| Community | Community features |
| Match | Match scheduling and results |
| Registration | Registration workflows |
| Finance | Financial operations |
| Discipline | Discipline management |
| Messaging | Messaging and notifications |
| AI | AI-powered features |
| Platform | Core platform and infrastructure |

### Type

| Value | Use For |
|-------|---------|
| RFC | Request for Comments — design proposal |
| ADR | Architecture Decision Record |
| Feature | New functionality |
| Bug | Defect fix |
| Task | Operational or maintenance work |
| Spike | Time-boxed investigation |
| Research | Open-ended exploration |

### Milestone

Uses GitHub's **built-in Milestone field**, linked to repository milestones. A custom field named "Milestone" is reserved by GitHub Projects.

| Value | Scope |
|-------|-------|
| M0 Discovery | Research and problem definition |
| M1 Domain | Domain model and bounded contexts |
| M2 Core | Core platform engine |
| M3 WhatsApp | WhatsApp integration |
| M4 AI | AI features and automation |
| M5 RCC Pilot | Pilot deployment and validation |

### Estimated Complexity

| Value | Meaning |
|-------|---------|
| XS | Trivial, < 1 hour |
| S | Small, < 1 day |
| M | Medium, 1–3 days |
| L | Large, 1 week |
| XL | Extra large, multi-week |

### AI Owner

| Value | Use For |
|-------|---------|
| ChatGPT | ChatGPT-led work |
| Claude | Claude-led review or design |
| Cursor | Cursor-led implementation |
| Ollama | Local model work |
| Mixed | Multiple AI tools involved |

## Labels

| Label | Use For |
|-------|---------|
| `architecture` | System design and structural decisions |
| `ddd` | Domain-driven design |
| `event-driven` | Event-driven architecture |
| `documentation` | Documentation updates |
| `backend` | Server-side work |
| `api` | API endpoints and contracts |
| `database` | Database schema and migrations |
| `laravel` | Laravel framework |
| `whatsapp` | WhatsApp integration |
| `llm` | Large language model features |
| `finance` | Financial operations |
| `discipline` | Discipline management |
| `registration` | Registration workflows |
| `community` | Community features |
| `match` | Match scheduling and results |
| `waiting-list` | Waiting list management |
| `penalty` | Penalty rules |
| `payment` | Payment processing |
| `breaking-change` | Breaking API or schema change |
| `needs-review` | Awaiting review |
| `blocked` | Blocked by dependency or decision |

## Setup

```bash
# 1. Authenticate (one-time)
gh auth login
gh auth refresh -s project,repo

# 2. Run the setup script
./scripts/setup-github-project.sh
```

## Usage Guidelines

1. **New work** enters via 📥 Inbox.
2. **Non-trivial changes** require an RFC — set Type to `RFC` and move through the RFC columns.
3. **Claude reviews** all RFCs at 👨‍💼 Review (Claude) before approval.
4. **Only Approved RFCs** may move to 💻 Ready For Cursor.
5. **Set custom fields** on every card: Priority, Domain, Type, Milestone, Complexity, AI Owner.
6. **Apply labels** for filtering and automation.

## Related Documents

- [ROADMAP.md](../ROADMAP.md) — delivery roadmap
- [CONTRIBUTING.md](../CONTRIBUTING.md) — contribution workflow
- [rfcs/](../rfcs/) — RFC proposals
