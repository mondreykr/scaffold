# Handoff — Determinism guardrail, `## Deferred`, and dropping `## Notes`

**Date:** 2026-06-22 · **Status:** Implemented in the source (contracts + skills +
ARCHITECTURE + CLAUDE.md). Not yet propagated to any user repo. **This supersedes** the
`state.md ## Notes` and `roadmap` "someday/never / permanent home / does not retire"
language in `20260617-scaffold-restructure.md` (§6 state.md, §6 roadmap.md, §7 routing,
§8 "Added"). Trust THIS doc where they differ.

## What prompted it

Two complaints from Adam about drift in the clarifi reference repo:
1. `roadmap.md` `## Backlog` had become a junk drawer — multi-line paragraph items,
   ground-level bugs/cleanups mixed with program features, shipped/done items never
   removed, `someday/never` cruft.
2. `state.md` `## Notes` had become a second junk drawer — a durable build fact, a
   12-item spec-edit to-do list, and a known bug all parked there, never drained.

## The root-cause reframe (the important part)

Both are **one defect**. Scaffold is a deterministic state machine whose *data is the
document structure itself* (skills compute state by reading `## Next`, the `plan.md`
checkbox, a brief's `## Scope`). The invariant that makes that work: **every datum has
exactly one *computable* home.** Backlog and Notes were the only two sections whose
membership wasn't computable — open-ended buckets — so any datum without an obvious home
landed in them, and nothing drained them. An open-ended section is a *non-deterministic
home*; it silently breaks the machine and bloats by construction.

This was latent in the design (Principles 5 + 7) but never stated as a guardrail, so a
future editor would happily add another soft section. It is now stated up front
(ARCHITECTURE Design Principles + the factory `CLAUDE.md` "essence").

## Decisions (settled with Adam, first-principles)

1. **Determinism guardrail stated up front** — "no catch-all / open-ended section; every
   home is computable." ARCHITECTURE Design Principles (new lead paragraph + sharpened
   Principle 5) and factory `CLAUDE.md`.
2. **`## Backlog` narrowed** — program-altitude future *features* only; one terse `- [ ]`
   line each; **never ticked** (an item leaves by *removal* on promotion or ship, never
   `- [x]`); no `someday/never`; "does not retire / permanent home" framing dropped.
   Flat list — Adam explicitly dropped the Next/Later grouping ("nothing fancy").
3. **`## Deferred` — NEW optional section in `milestones/NN/plan.md`** — the home for
   ground-level work surfaced *inside* a milestone (bug, cleanup, debt, residual,
   doc/spec-reconciliation). Right altitude (the existing "program altitude only" law
   forbade this in the roadmap) and right lifecycle: **retires with the milestone.**
4. **`## Notes` DROPPED entirely from `state.md`.** The logic: you end every session with
   `checkpoint`, whose job is to leave the tree clean — so a persistent "transient mess"
   section is self-contradictory. Every canonical Notes example re-homes deterministically:
   - resume precondition (reseed the DB) → `## Next` (rides with the resume action)
   - durable run/env condition (env points at dev DB until cutover) → `architecture.md`
   - blocker → `## Blockers`
   - where-I-left-off → `## Active focus`
   `state.md` is now exactly four mandatory sections.
5. **Draining ownership (no new skill), not reliant on milestone close** (milestones rarely
   close):
   - **capture** — `plan`/`checkpoint` drop a one-line item into the right home
   - **promote + remove** — `plan` pulls a Deferred/Backlog item into a phase brief and
     removes the line (or leaves it)
   - **remove-shipped** — `checkpoint` removes items it shipped that session (it has the
     diff)
   - **detect stale/already-built** — `audit`'s reality pass (fresh explorer agents — the
     expensive determination Adam flagged) flags items, never deletes
   - **backstop** — milestone close resolves/promotes/drops whatever Deferred remains
   - Accumulation of one-liners is explicitly tolerable; the discipline is one line per
     item + periodic grooming, not a guaranteed-empty list. The on-demand "housekeeping
     exercise" = run `/scaffold-audit`, then act on its flags via `/scaffold-plan`.

## Files changed (source repo)

- `ARCHITECTURE.md` — determinism lead paragraph; Principle 5 sharpened; routing table
  (narrowed Backlog row, new Deferred row, Notes row → "resolve/route, no catch-all");
  State Determination table (Notes signal → Deferred signal); Information Model + Files
  & Folders (plan.md gains deferred); Execution model (new Deferred + milestone-lifecycle
  backstop bullets).
- `CLAUDE.md` (factory) — "The essence" guardrail paragraph.
- `contracts/roadmap.md` — Backlog membership/one-line/never-ticked rules; anti-patterns;
  Owner(s).
- `contracts/milestone-plan.md` — `## Deferred` section + rules + anti-patterns; Purpose;
  Owner(s).
- `contracts/state.md` — Notes removed; transient-state routing rule; anti-patterns.
- `contracts/architecture.md` — anti-pattern reworded (no transient section in state.md).
- skills: `plan` (triage read, backlog routing + Deferred grooming/promotion, no Notes),
  `checkpoint` (5a Deferred grooming, 5b four sections, 5f backlog removal, 6b close
  backstop, sweep anti-patterns + Law-2 + mechanical-fix wording), `audit` (roadmap/state/
  plan conformance, reality-pass staleness check), `status` (Deferred signal),
  `go` (reads Next not Notes; surfaces deferred), `integrate` (durable run/env not Notes),
  `setup` (templates), `cleanup` (backlog altitude-split → Deferred, plan.md gains
  Deferred, drain old Notes).

## Downstream (NOT done here)

clarifi's `.scaffold/` is untouched. Per the source-first rollout: push source → pull via
`/scaffold-update` → then `/scaffold-audit` flags clarifi's drift (junk-drawer Backlog,
fat Notes) and `/scaffold-plan` + `/scaffold-checkpoint` re-home it (backlog debt →
`01-rebuild/plan.md` `## Deferred`; the "pending spec edits" → the spec's own backlog;
durable env facts → `architecture.md`; delete the Notes section).
