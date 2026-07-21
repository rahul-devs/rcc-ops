# Architecture Overview

## Purpose

This document provides a detailed overview of the RCC-OPS system architecture, including component boundaries, layering, and integration points.

## Scope

RCC-OPS is a Laravel-based operations platform. This overview covers:

- System boundaries and context
- Internal component structure
- Layering and dependency direction
- Integration patterns

## System Context

<!-- TODO: Add C4 context diagram -->

```
┌─────────────────────────────────────────────────┐
│                  External Actors               │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐ │
│  │  Users   │  │ WhatsApp │  │ Other Systems│ │
│  └────┬─────┘  └────┬─────┘  └──────┬───────┘ │
└───────┼─────────────┼───────────────┼─────────┘
        │             │               │
        ▼             ▼               ▼
┌─────────────────────────────────────────────────┐
│                    RCC-OPS                       │
│                                                  │
│  ┌─────────────┐  ┌──────────┐  ┌────────────┐  │
│  │  HTTP/API   │  │  Domain  │  │ Adapters   │  │
│  │  Layer      │  │  Layer   │  │ (External) │  │
│  └─────────────┘  └──────────┘  └────────────┘  │
│                          │                       │
│                   ┌──────┴──────┐                │
│                   │ Event Bus   │                │
│                   └─────────────┘                │
└─────────────────────────────────────────────────┘
```

## Layering

| Layer | Responsibility | Dependencies |
|-------|----------------|--------------|
| Presentation | HTTP controllers, API resources, CLI | Application, Domain |
| Application | Use cases, orchestration, DTOs | Domain |
| Domain | Entities, value objects, domain events, rules | None (innermost) |
| Infrastructure | Persistence, queues, external APIs | Domain, Application |

**Dependency rule:** Dependencies point inward. Domain has no outward dependencies.

## Bounded Contexts

<!-- TODO: Define bounded contexts as domain is clarified -->

| Context | Responsibility | Status |
|---------|----------------|--------|
| _TBD_ | _TBD_ | Draft |

## Component Map

<!-- TODO: Add component diagram and descriptions -->

| Component | Layer | Description |
|-----------|-------|-------------|
| _TBD_ | _TBD_ | _TBD_ |

## Integration Points

| Integration | Type | Documentation |
|-------------|------|---------------|
| WhatsApp | External messaging | [whatsapp-adapter.md](whatsapp-adapter.md) |
| _TBD_ | _TBD_ | _TBD_ |

## Deployment View

<!-- TODO: Add deployment architecture once infrastructure is defined -->

| Environment | Purpose | Infrastructure |
|-------------|---------|----------------|
| Local | Development | _TBD_ |
| Staging | Pre-production validation | _TBD_ |
| Production | Live system | _TBD_ |

## Related Documents

- [event-driven.md](event-driven.md) — event-driven architecture
- [whatsapp-adapter.md](whatsapp-adapter.md) — WhatsApp adapter
- [../docs/architecture.md](../docs/architecture.md) — high-level architecture
- [../docs/decisions.md](../docs/decisions.md) — architecture decisions
