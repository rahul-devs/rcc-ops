# Rules

## Purpose

This document catalogs the business rules enforced by RCC-OPS. Rules define constraints, validations, and decision logic applied during workflow execution.

> **Important:** Do not invent business rules in this document. Rules must be defined and approved by stakeholders before being recorded here.

## Conventions

- Rules are identified by a stable ID (e.g. `RULE-001`)
- Each rule includes: description, scope, conditions, and enforcement point
- Rules link to workflows and events where applicable

## Rule Index

| ID | Name | Status | Workflow |
|----|------|--------|----------|
| _TBD_ | _TBD_ | Draft | _TBD_ |

## Rule Template

Use this template when adding a new rule:

---

### RULE-XXX: _Rule Name_

**Status:** Draft | Active | Deprecated

**Description:** _What does this rule enforce?_

**Scope:** _Where does this rule apply?_

**Conditions:**
- _Condition placeholder_

**Action:** _What happens when conditions are met or violated?_

**Enforcement Point:** _Where in the system is this rule applied?_

**Related Workflows:** See [workflows.md](workflows.md)

**Related Events:** See [events.md](events.md)

---

## Related Documents

- [workflows.md](workflows.md) — operational workflows
- [events.md](events.md) — domain events
- [../rfcs/RFC-0001-rulebook.md](../rfcs/RFC-0001-rulebook.md) — rulebook RFC
