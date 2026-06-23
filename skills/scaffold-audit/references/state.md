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

Exactly these four headings, in this order — all mandatory. There is **no `## Notes`
section** (see the transient-state rule below).

```markdown
# State

## Active focus
[One paragraph. Synopsis + forward-look. ELI5 — plain words, short sentences.
No bullets, no code blocks, no quoted prompts.]

## Next
[The concrete resume action — milestone + phase brief by path. 1–2 sentences
or short bullets. Carries any precondition on resuming (e.g. "reseed the dev DB
first").]

## Blockers
None.

## Open Questions
None.
```

## Rules

- `## Next` is the single authority for what's active (milestone + phase brief) —
  never folder order, never a status enum.
- `Blockers` and `Open Questions` are always present; literal `None.` when empty
  (confirms the writer checked).
- When a Blocker/Open Question resolves, remove the line and route the resolution
  to its home (a decision, the roadmap, the commit log, a knowledge doc).
- **Transient operational state has no section here.** `state.md` is the forward
  cursor, and `checkpoint` (the session boundary) leaves the tree clean — so a
  persistent "transient mess" section is self-contradictory, and a catch-all is a
  non-deterministic home (it bloats). Route each case to its real home:
  - a **precondition on resuming** (reseed the DB, restart a service) → fold into
    `## Next` with the resume action;
  - a **durable run/env condition** (env points at a dev DB for this milestone) →
    `architecture.md` `## Run / env`;
  - something **blocking** → `## Blockers`;
  - **where you left off mid-work** → `## Active focus`.

## Anti-patterns

- A `## Notes` (or any catch-all / "misc" / "scratch") section — removed by design; it
  is a non-deterministic home.
- Durable truth, deferred work, or a to-do list parked in any section — **including
  disguised as prose inside `## Active focus`** (the one free-text section; "we still
  need to reconcile X" is a deferred item, not a status). Route it: durable run/env →
  `architecture.md`; deferred work → the milestone `plan.md` `## Deferred` or `roadmap.md`
  `## Backlog`; an undecided question → `## Open Questions`.
- Append-log / dated history accreting in any section (Law 1 violation).
- Bullets, code blocks, or quoted prompts in `Active focus`.
- Resolved Blockers/Open Questions left in place.
- Any status keyword stored as the active-cursor signal.
