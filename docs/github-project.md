# GitHub Project

## Purpose

This document defines the RCC-OPS GitHub Project board — columns, milestones, and labels used to track delivery from discovery through production.

## Project Board

| Field | Value |
|-------|-------|
| **Title** | RCC-OPS |
| **Owner** | [rahul-devs](https://github.com/rahul-devs) |
| **Repository** | [rahul-devs/rcc-ops](https://github.com/rahul-devs/rcc-ops) |

## Columns (Pipeline)

Issues and pull requests flow through these stages:

| Column | Purpose |
|--------|---------|
| 📥 Inbox | New items awaiting triage |
| 🔍 Discovery | Research, requirements, and problem exploration |
| 📖 RFC | Design proposals under review |
| 🏛 Architecture | Architecture decisions and structural design |
| 🧠 Domain Model | Domain modeling and bounded context work |
| 💻 Ready | Fully specified and ready for implementation |
| 🚧 In Progress | Active development |
| 👀 Review | Code or design review in progress |
| 🧪 Testing | QA, integration testing, and validation |
| ✅ Done | Completed and verified |

## Milestones

| Milestone | Scope |
|-----------|-------|
| **M0 Discovery** | Research, requirements gathering, and problem definition |
| **M1 Domain** | Domain model design and bounded context mapping |
| **M2 Core Engine** | Core platform engine and rule execution |
| **M3 WhatsApp** | WhatsApp adapter and messaging integration |
| **M4 AI** | AI-powered features and automation |
| **M5 RCC Pilot** | RCC pilot deployment and validation |
| **M6 Production** | Production hardening and launch |

## Labels

### Area

| Label | Use For |
|-------|---------|
| `architecture` | System design and structural decisions |
| `domain` | Domain model and bounded contexts |
| `backend` | Server-side and API work |
| `frontend` | UI and client-side work |
| `ai` | AI and machine learning features |
| `whatsapp` | WhatsApp integration |
| `finance` | Financial operations and billing |
| `discipline` | Discipline management |
| `registration` | Registration workflows |
| `messaging` | Messaging and notifications |
| `match` | Match scheduling and results |
| `community` | Community features |

### Process

| Label | Use For |
|-------|---------|
| `discussion` | Open questions and conversations |
| `rfc` | Request for Comments proposals |
| `good first issue` | Good for newcomers |
| `high priority` | Urgent or critical work |
| `blocked` | Blocked by dependency or decision |

## Setup

The project board, milestones, and labels can be created automatically:

```bash
# 1. Authenticate (one-time)
gh auth login
gh auth refresh -s project,repo

# 2. Run the setup script
./scripts/setup-github-project.sh
```

## Usage Guidelines

1. **New work** enters via 📥 Inbox — create an issue or link a PR to the project.
2. **Assign a milestone** (M0–M6) to indicate delivery phase.
3. **Apply area labels** to categorize work by domain or layer.
4. **Move cards** through columns as work progresses; do not skip specification stages for non-trivial features.
5. **RFC-required changes** must pass through 📖 RFC before reaching 💻 Ready.

## Related Documents

- [ROADMAP.md](../ROADMAP.md) — delivery roadmap
- [CONTRIBUTING.md](../CONTRIBUTING.md) — contribution workflow
- [rfcs/](../rfcs/) — RFC proposals
