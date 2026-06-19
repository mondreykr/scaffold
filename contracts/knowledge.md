---
schema_version: 1
---

# Contract — `knowledge/*.md`

**Purpose.** Durable domain/behavioral truth — how the rules actually work ("the
ledger replays thus; reconciliation tolerance is ±X"). One file per coherent rule
area.

**Band.** Living truth — maintained in place as code behavior changes.

**Owner(s).** Maintained by `scaffold-checkpoint` (graduates/reconciles rules at
milestone close), `scaffold-plan`, `scaffold-integrate` (absorbs cross-cutting
knowledge). Read by `scaffold-go`.

## Required frontmatter

```yaml
---
type: knowledge
schema_version: 1
updated: YYYY-MM-DD
---
```

## Required structure

No fixed skeleton — these are prose rulebooks. Each file is titled for its rule area
and states the durable rules plainly.

## Rules

- Living truth, not history: maintained in place, never an append-log.
- **Lifecycle:** during a predetermined milestone the rules may live in the active
  spec's `references/` and `knowledge/` may stay empty; at close, enduring rules
  graduate here — reconciled against existing docs, surfaced for Adam's confirmation.
  Emergent milestones accrue rules here directly.
- A rule lives here when it changes only because the *business rule* changes (the
  architecture-vs-knowledge tie-break).
- **Invariant:** the rules always have a *living* home — the active spec's
  `references/` during a milestone, `knowledge/` once it retires — never only a
  retired spec.

## Anti-patterns

- A durable rule left **stranded** in a retired milestone's spec, never graduated.
- A fact that belongs in `architecture.md` (one that changes on re-platform).
- Dated log entries (Law 1).
