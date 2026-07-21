# WhatsApp Adapter

## Purpose

This document describes the WhatsApp adapter — the integration layer between RCC-OPS and the WhatsApp messaging platform. The adapter handles inbound and outbound message flows while keeping the domain layer independent of WhatsApp-specific APIs.

## Scope

| In Scope | Out of Scope |
|----------|--------------|
| Message send/receive abstraction | WhatsApp Business API account setup |
| Webhook handling | Message content business rules |
| Adapter interface definition | UI for message management |

## Architecture

```
┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  WhatsApp    │────►│  WhatsApp        │────►│  Domain /       │
│  Platform    │◄────│  Adapter         │◄────│  Application    │
│  (External)  │     │  (Infrastructure)│     │  Layer          │
└──────────────┘     └──────────────────┘     └─────────────────┘
                              │
                              ▼
                     ┌──────────────────┐
                     │  Event Bus       │
                     └──────────────────┘
```

## Adapter Interface

<!-- TODO: Define adapter contract once integration requirements are confirmed -->

```php
// Placeholder — interface to be defined during implementation

interface WhatsAppAdapterInterface
{
    // sendMessage(...)
    // handleWebhook(...)
}
```

## Inbound Flow

1. WhatsApp platform sends webhook to RCC-OPS endpoint
2. Adapter validates and parses the payload
3. Adapter emits a domain event (e.g. `_EventNameTBD_`)
4. Domain handlers process the event

## Outbound Flow

1. Application layer requests message send via adapter
2. Adapter formats payload for WhatsApp API
3. Adapter sends request and handles response
4. Adapter emits confirmation or failure event

## Configuration

<!-- TODO: Define configuration keys once provider is selected -->

| Key | Description | Required |
|-----|-------------|----------|
| _TBD_ | _TBD_ | _TBD_ |

## Error Handling

| Scenario | Strategy |
|----------|----------|
| API rate limiting | _TBD_ |
| Invalid webhook payload | _TBD_ |
| Delivery failure | _TBD_ |

## Security

<!-- TODO: Define security requirements -->
- Webhook signature verification: _TBD_
- Credential management: _TBD_

## Related Documents

- [event-driven.md](event-driven.md) — event-driven architecture
- [../docs/events.md](../docs/events.md) — event catalog
- [overview.md](overview.md) — architecture overview
