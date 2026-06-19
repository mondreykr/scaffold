---
schema_version: 1
---

# Contract — `state.md`

**Purpose.** The forward-looking cursor: where we are now, what's next, what's
blocking. Not a log. The single authority for what's active.

**Band.** Living truth — overwritten in place, never reconstructed from a log.

**Owner(s).** Created by `scaffold-setup`. Maintained by `scaffold-checkpoint`
(primary) and `scaffold-plan` (sets `## Next`). Read by `scaffold-status`.

## Required frontmatter

On the target `.scaffold/state.md`:

```yaml
---
type: state
schema_version: 1
updated: YYYY-MM-DD
---
```

## Required structure

Headings in this order. `Active focus`, `Next`, `Blockers`, `Open Questions`
are mandatory; `Notes` is optional and omitted when empty.

```markdown
# State

## Active focus
[One paragraph. Synopsis + forward-look. ELI5 — plain words, short sentences.
No bullets, no code blocks, no quoted prompts.]

## Next
[The concrete resume action — milestone + phase brief by path. 1–2 sentences
or short bullets.]

## Blockers
None.

## Open Questions
None.

## Notes
[Optional. Transient operational state only. Omit when empty.]
```

## Rules

- `## Next` is the single authority for what's active (milestone + phase brief) —
  never folder order, never a status enum.
- `Blockers` and `Open Questions` are always present; literal `None.` when empty
  (confirms the writer checked).
- When a Blocker/Open Question resolves, remove the line and route the resolution
  to its home (a decision, the roadmap, the commit log, a knowledge doc).
- `Notes` holds only *transient* operational state (dirty DB, temp env), cleared
  when it resolves. Durable run/env facts belong in `architecture.md`.

## Anti-patterns

- Append-log / dated history accreting in any section (Law 1 violation).
- Bullets, code blocks, or quoted prompts in `Active focus`.
- Resolved Blockers/Open Questions left in place.
- Any status keyword stored as the active-cursor signal.
