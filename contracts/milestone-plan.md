---
schema_version: 1
---

# Contract — `milestones/NN-slug/plan.md`

**Purpose.** One milestone's phase plan: the phase checklist (the disk-derivable
"is it done?" signal), the objectives, and the done-contract.

**Band.** Execution — temporal; retires in place with its milestone.

**Owner(s).** Seeded by `scaffold-setup`, authored/updated by `scaffold-plan`, ticked
by `scaffold-checkpoint`, built from an old roadmap body by `scaffold-cleanup`. Read
by `scaffold-status`, `scaffold-go`.

## Required frontmatter

```yaml
---
type: milestone-plan
schema_version: 1
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
```

## Rules

- The phase checklist is the authority for "phase done?" — a checked box + a date,
  not a status enum.
- Keep completion annotations **terse** (a date, not prose) so the file stays a
  bounded checklist, never an append-log (Law 1). Verbose narrative → git.
- Phase numbers reset per milestone; the slug namespaces them. `NN` admits
  interstitials (`09.1`); migration never renumbers.

## Anti-patterns

- Per-phase narrative accreting in the file (append-log; Law 1).
- A status enum substituting for the checkbox + date signal.
- Renumbering interstitial phases on migration.
