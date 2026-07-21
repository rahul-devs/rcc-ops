# GitHub Project

## Purpose

This document defines the RCC-OPS GitHub Project board (Projects v2). RCC-OPS is an **RFC-driven project** — implementation work does not begin until an RFC is Approved.

## Project Board

| Field | Value |
|-------|-------|
| **Title** | RCC-OPS |
| **Owner** | [rahul-devs](https://github.com/rahul-devs) |
| **Repository** | [rahul-devs/rcc-ops](https://github.com/rahul-devs/rcc-ops) |
| **URL** | [Project #1](https://github.com/users/rahul-devs/projects/1) |

## Columns (Status)

| Column | Purpose |
|--------|---------|
| Inbox | New items awaiting triage |
| Discovery | Research, requirements, problem exploration |
| RFC Draft | RFC or ADR being written or revised |
| Review | Design under architectural review |
| Approved | Accepted — implementation may proceed |
| Ready for Cursor | Approved and queued for implementation |
| In Progress | Active development |
| Code Review | Code review in progress |
| RCC Testing | RCC pilot validation and integration testing |
| Done | Completed and verified |

### The Gate

```
RFC Draft → Review → Approved → Ready for Cursor → In Progress
```

Work that skips approval must not enter implementation columns.

## Custom Fields

### Priority

Critical · High · Medium · Low

### Domain

Community · Match · Registration · Finance · Discipline · Messaging · AI · Platform

### Type

RFC · ADR · Feature · Bug · Research · Task

### Milestone

Uses GitHub's **built-in Milestone field**, linked to repository milestones:

| Value | Scope |
|-------|-------|
| M0 Discovery | Research and problem definition |
| M1 Domain | Domain model and bounded contexts |
| M2 Core | Core platform engine |
| M3 WhatsApp | WhatsApp integration |
| M4 AI | AI features and automation |
| M5 RCC Pilot | Pilot deployment and validation |

### Complexity

XS · S · M · L · XL

### AI Owner

ChatGPT · Claude · Cursor · Ollama · Mixed

## Seed Issues (M0 Discovery)

| Issue | Type |
|-------|------|
| RFC-0000 Project Principles | RFC |
| RFC-0001 Ubiquitous Language | RFC |
| RFC-0002 State Machines | RFC |
| RFC-0003 Bounded Contexts | RFC |
| ADR-0001 Modular Monolith | ADR |
| ADR-0002 Event-Driven Architecture | ADR |
| ADR-0003 AI Never Owns Business Logic | ADR |
| ADR-0004 WhatsApp Is an Adapter | ADR |

All seed issues are assigned to **M0 Discovery** and placed in **Inbox**.

## Setup

```bash
gh auth login
gh auth refresh -s project,repo
./scripts/configure-github-project.sh
```

## Related Documents

- [ROADMAP.md](../ROADMAP.md) — delivery roadmap
- [CONTRIBUTING.md](../CONTRIBUTING.md) — contribution workflow
- [rfcs/](../rfcs/) — RFC proposals
