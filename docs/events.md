# Events

## Purpose

This document catalogs the domain events emitted and consumed by RCC-OPS. Events are the primary mechanism for decoupled communication in the event-driven architecture.

## Conventions

- Events are identified by a stable name (e.g. `EntityCreated`)
- Each event includes: payload schema, producer, consumers, and related workflows
- Event names use past-tense verbs describing what happened

## Event Index

| Event | Producer | Consumers | Status |
|-------|----------|-----------|--------|
| _TBD_ | _TBD_ | _TBD_ | Draft |

## Event Template

Use this template when adding a new event:

---

### _EventName_

**Status:** Draft | Active | Deprecated

**Description:** _What happened?_

**Producer:** _Which component or workflow emits this event?_

**Payload:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| _TBD_ | _TBD_ | _TBD_ | _TBD_ |

**Consumers:**
- _Consumer placeholder_

**Related Workflows:** See [workflows.md](workflows.md)

**Related Rules:** See [rules.md](rules.md)

---

## Event Flow Diagram

<!-- TODO: Add event flow diagram once events are defined -->

```
[Producer] --EventName--> [Event Bus] --EventName--> [Consumer]
```

## Related Documents

- [workflows.md](workflows.md) — operational workflows
- [rules.md](rules.md) — business rules
- [architecture.md](architecture.md) — system architecture
- [../architecture/event-driven.md](../architecture/event-driven.md) — event-driven design
