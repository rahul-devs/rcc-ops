# Event-Driven Architecture

## Purpose

This document describes the event-driven design patterns used in RCC-OPS. Events enable loose coupling between components and support asynchronous processing, auditability, and extensibility.

## Principles

1. **Events represent facts** — An event describes something that has already happened (past tense).
2. **Producers don't know consumers** — Event emitters are unaware of who handles the event.
3. **Handlers are idempotent** — Consumers must handle duplicate events safely.
4. **Events are immutable** — Once emitted, an event payload does not change.

## Event Lifecycle

```
[Domain Action]
      │
      ▼
[Domain Event Raised]
      │
      ▼
[Event Dispatcher]
      │
      ├──► [Synchronous Listener]
      │
      └──► [Queue Job] ──► [Async Handler]
```

## Event Categories

<!-- TODO: Define event categories as domain emerges -->

| Category | Description | Examples |
|----------|-------------|----------|
| Domain Events | Business-significant occurrences | _TBD_ |
| Integration Events | Cross-boundary communication | _TBD_ |
| System Events | Infrastructure-level signals | _TBD_ |

## Implementation (Laravel)

<!-- TODO: Fill in once Laravel is scaffolded -->

| Concern | Approach | Notes |
|---------|----------|-------|
| Event classes | Laravel Events | _TBD_ |
| Dispatching | Event facade / `event()` helper | _TBD_ |
| Listeners | Event listeners / subscribers | _TBD_ |
| Async processing | Queued listeners / jobs | _TBD_ |
| Persistence | Event store (if applicable) | _TBD_ |

## Event Catalog

See [../docs/events.md](../docs/events.md) for the full event catalog.

## Error Handling

<!-- TODO: Define retry and dead-letter strategies -->

| Scenario | Strategy |
|----------|----------|
| Handler failure | _TBD_ |
| Poison message | _TBD_ |
| Ordering requirements | _TBD_ |

## Testing Events

<!-- TODO: Define testing approach -->

- _Testing strategy placeholder_

## Related Documents

- [../docs/events.md](../docs/events.md) — event catalog
- [overview.md](overview.md) — architecture overview
- [whatsapp-adapter.md](whatsapp-adapter.md) — adapter event integration
