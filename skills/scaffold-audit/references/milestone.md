---
schema_version: 2
---

# Contract — `milestones/NN-slug/milestone.md`

**Purpose.** One milestone's phase plan: the phase checklist (the disk-derivable
"is it done?" signal), the objectives, the done-contract, and the deferred-work list
(ground-level work surfaced inside this milestone but not scheduled into a phase).

**Band.** Execution — temporal; retires in place with its milestone.

**Owner(s).** Seeded by `scaffold-setup`, authored/updated by `scaffold-plan` (incl.
grooming `## Deferred` — promote an item into a phase or leave it), ticked by
`scaffold-checkpoint` (which also adds deferred items surfaced that session and removes
ones shipped), built from an old roadmap body by `scaffold-cleanup`. Read by
`scaffold-status`, `scaffold-go`; `## Deferred` reality-checked by `scaffold-audit`
(flags items already built or stale).

## Required frontmatter

```yaml
---
type: milestone
schema_version: 2
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# Milestone NN — <slug>

## Objectives
[What this milestone achieves.]

## Phases
- [ ] NN-slug — one-liner
- [x] NN-slug — one-liner (YYYY-MM-DD)

## Done-contract
[What "this milestone is complete" means.]

## Deferred
[OPTIONAL — omit when empty. Ground-level work surfaced inside this milestone but not
scheduled into a phase: a bug, a cleanup, deferred debt, a review residual, a doc/spec
reconciliation. One line each.]
- [ ] <deferred item, one line>
```

## Rules

- The phase checklist is the authority for "phase done?" — a checked box + a date,
  not a status enum.
- Keep completion annotations **terse** (a date, not prose) so the file stays a
  bounded checklist, never an append-log (Law 1). Verbose narrative → git.
- Phase numbers reset per milestone; the slug namespaces them. `NN` admits
  interstitials (`09.1`); migration never renumbers.
- A wholly human-owned phase may carry a `[USER]` tag on its `## Phases` line;
  `scaffold-checkpoint` verifies it with the user before ticking. (Item-level `[USER]`
  deliverables live in the phase plan's `## Scope`.)
- **`## Deferred` membership — the one computable test.** Ask: *is this work tied to the
  active milestone — its scope, its code, or its goal?* **Tied → it belongs here** (it's
  moot or owned elsewhere once this milestone closes): a bug, cleanup, debt, residual, or
  doc/spec-reconciliation task surfaced inside the milestone and not yet scheduled into a
  phase. **Not tied (or no milestone is active) → NOT here** → `roadmap.md` `## Backlog`.
  Scheduled work is a phase plan, not a `## Deferred` line. A spec-reconciliation task
  ("update SPEC §X to match the code") is tied work and lives here; if the milestone's
  spec maintains its own backlog you may route it there instead, but `## Deferred` is
  always a valid, computable home — never leave it homeless.
- **One line each, `- [ ]`, never ticked.** Items leave by removal — promoted into a
  phase (by `scaffold-plan`) or shipped (by `scaffold-checkpoint`) — never checked
  `- [x]`. Detail lives in git / the eventual plan, not in the line.
- **Retires with the milestone.** At close, every remaining `## Deferred` item is
  resolved, promoted, or dropped — it never graveyards in a retired milestone.
  Accumulation of one-liners mid-milestone is tolerable; the discipline is one line per
  item plus periodic grooming, not a guaranteed-empty list.

## Anti-patterns

- Per-phase narrative accreting in the file (append-log; Law 1).
- A status enum substituting for the checkbox + date signal.
- Renumbering interstitial phases on migration.
- A program-altitude feature in `## Deferred` (belongs in `roadmap.md` `## Backlog`).
- A multi-line / paragraph `## Deferred` item, or a `- [x]` checked deferred item.
