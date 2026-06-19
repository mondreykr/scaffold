---
name: scaffold-audit
description: Deep, independent, read-only review of a scaffold project — grade every .scaffold/ doc hard against its format, verify the docs against the actual code, and check no durable rule is stranded in a retired milestone. Spins up fresh agents; always does all three (conformance gates the rest); changes nothing. Use whenever the user wants a thorough audit, a deep check, a conformance or reality review, or to validate the scaffold before a release, after a long gap, or after heavy hand-editing — even if they only say "audit", "check the scaffold", or "is everything consistent". The light always-on version is built into /scaffold-checkpoint.
---

# scaffold-audit

The deep, independent review. Where `checkpoint`'s inline sweep *samples*, audit grades
the whole tree hard and checks it against reality. It is **read-only** — it reports drift
and never edits. Depth is already chosen by invoking audit at all, so it **always does all
three passes, no asking**: conformance, then reality, then stranded-rules.

**Boundary.** Read-only. Audit grades and reports; it writes nothing. Every fix routes
back through the skill that owns the doc (`plan`/`checkpoint`/`integrate`/`cleanup`) —
audit never edits, proposes ADRs, or touches code.

**Run it independently.** To grade without the bias of the working session's context,
dispatch **fresh read-only subagents** (Explore / general-purpose) rather than judging
from memory: one (or more) for the conformance pass over the doc tree, and — only after
conformance clears — one or more for the reality pass against the code. Synthesize their
findings here. Each agent is told it is grading, not fixing.

**Precondition.** `.scaffold/` exists with truth docs. If not: "No scaffold here — run
/scaffold-setup (fresh) or /scaffold-cleanup (migrate an old layout)."

---

## Step 1: Inventory

List every doc in scope: `CLAUDE.md`, the four `.scaffold/` truth docs, all of
`knowledge/`, `decisions/`, `investigations/`, and every `milestones/NN-slug/`
(`plan.md`, `spec/`, `phases/*`). Read each doc's frontmatter `type:` — that is
authoritative and selects which conformance rules apply (filename/location is only a
fallback). Ignore `.gitkeep` placeholders.

**Two gates before grading.** (1) If the tree *wholesale* lacks `type`/`schema_version`
frontmatter (a pre-current-format / un-migrated layout), stop and report: "This scaffold
predates the current format — run /scaffold-cleanup to migrate, then re-audit," rather
than flooding per-doc 'missing frontmatter' findings. (2) A *missing* mandatory truth doc
(`project` / `architecture` / `roadmap` / `state`) is itself a conformance finding — the
four are always present in a current scaffold.

## Step 2: Conformance pass (runs FIRST — gates the rest)

Grade each doc hard against the rules for its `type`. Score: required sections present,
correctly named, in order; frontmatter valid (`type`/`schema_version`/`updated`;
`CLAUDE.md` exempt); anti-patterns absent; brevity (no bloat that signals a Law-1
append-log). The criteria, by type:

- **`claude-md`** (CLAUDE.md, no frontmatter) — has `## Skill Reference` (the 9 skills),
  `## Core Principle`, `## About this project` (orientation + pointer into `.scaffold/`),
  optional `## Hard constraints`. ✗ tech-stack/run-env inline (belongs in
  `architecture.md`); ✗ user-identity/personal calibration (belongs in `~/.claude/`); ✗ a
  "Key Documents" list.
- **`project`** — `# <Product>` then `## What it is` / `## Who it's for` / `## Why` /
  `## Scope` / `## Not building`. ✗ requirement/acceptance **checkboxes**; ✗ restating
  *how it's built*; ✗ duplicating `CLAUDE.md`'s orientation.
- **`architecture`** — `# Architecture` + the topic sections that apply (Stack, Tenancy/
  isolation, Auth, Data access, Deployment, Conventions, Run/env); each significant truth
  references the ADR that set it (`[[NNNN-…]]`). ✗ a **separate ADR index file** (the
  inline references *are* the index); ✗ business/behavioral rules that belong in
  `knowledge/`; ✗ run/env duplicated into `state.md`.
- **`roadmap`** — `# Roadmap`, `## Milestones` (each line a `[done] | [active] |
  [planned]` token + one-liner + folder pointer), `## Backlog`. ✗ per-phase build detail
  (belongs in a `plan.md`); ✗ a status token outside the fixed set; ✗ a dangling folder
  pointer.
- **`state`** — `# State`, then `## Active focus` / `## Next` / `## Blockers` /
  `## Open Questions` in that order (mandatory), `## Notes` optional. `## Next` is the
  active cursor; `Blockers`/`Open Questions` carry literal `None.` when empty. ✗ an
  append-log / dated history in any section; ✗ bullets/code/quoted prompts in Active
  focus; ✗ resolved Blockers/Questions left in place; ✗ a status keyword as the cursor.
- **`knowledge`** — a prose rulebook titled for its rule area; living truth, maintained
  in place. ✗ a dated append-log; ✗ a fact that belongs in `architecture.md`.
- **`decision`** — `# NNNN — <title>`, a `**Status:**` line (`Accepted` | `Superseded by
  [[NNNN-…]]` | `Proposed`), then Context / Decision / Why / Alternatives considered /
  Consequences. **4-digit** numbering. ✗ an edited (vs superseded) ruling; ✗ a
  build-record dressed up as an ADR; ✗ 2-digit numbering (collides with `NN`).
- **`investigation`** — a titled, dated analysis (no fixed skeleton). Filename
  `YYYYMMDD-slug` — **no hyphens in the date**. ✗ a hyphenated date (`2026-06-11-*`); ✗
  edited later as if living truth; ✗ strategic cross-project analysis (belongs outside
  the repo).
- **`milestone-plan`** — `# Milestone NN — <slug>`, `## Objectives`, `## Phases` (checkbox
  + completion date), `## Done-contract`. ✗ per-phase narrative accreting (append-log); ✗
  a status enum substituting for the checkbox+date; ✗ renumbered interstitials.
- **`phase-brief`** — `# Phase NN — <slug>`, `## Objective` / `## Scope` / `## Approach` /
  `## Acceptance`. ✗ a brief premised on an unratified ADR; ✗ renumbered interstitials.
- **`spec-pointer`** — a short file naming + linking the external/shared spec and why it
  lives outside. ✗ absorbing the external spec's internals into `.scaffold/`; ✗ treating
  a still-live spec as frozen. (An embedded full spec keeps its own convention — don't
  grade it against scaffold frontmatter.)

Report each doc as **conforms / minor / malformed**, with the specific rule for each
finding.

## Step 3: Reality pass (gated by conformance)

Verify the scaffold's claims against the actual code:

- **Ticked phases really built** — for each `[x]` phase in an active/closed `plan.md`,
  the deliverables exist in the code.
- **Architecture matches the real stack** — `architecture.md`'s Stack / Data access /
  Deployment reflect the manifests and code, not an aspiration.
- **ADRs match reality** — an `Accepted` ADR's ruling is actually what the code does (a
  contradiction means the ADR is stale or silently violated).
- **Standing blockers are real** — each `state.md` Blocker is corroborated by the code /
  state, not stale or already resolved.
- **In-flight / uncommitted work** — flag uncommitted changes or recent edits the docs
  don't yet reflect (a checkpoint may be overdue).

**The gate (hard):** if a doc is malformed enough that its state can't be read reliably
(e.g. `## Next` doesn't resolve, a `plan.md` checklist is unparseable), report the reality
of that area as **unreliable — fix conformance first**, rather than guessing. Don't infer
through a broken doc.

## Step 4: Stranded-rules check

Confirm no retired milestone holds an **un-graduated durable rule** — a rule that should
have graduated to `knowledge/` at close but still lives only in a retired milestone's
`spec/references/`. The invariant: a durable rule always has a *living* home
(`knowledge/`), never only a retired spec. Flag any orphan for a `checkpoint`
graduation pass.

## Step 5: Report

Return findings **prioritized** (malformed/blocking first, then reality contradictions,
then minor conformance), each naming the doc, the specific rule, and **which skill owns
the fix**:

- format / section / frontmatter drift → `scaffold-checkpoint` (sweep) or
  `scaffold-cleanup` (structural)
- a truth/identity/brief change → `scaffold-plan`
- a stranded rule / milestone-close graduation → `scaffold-checkpoint`
- an absorbed-artifact issue → `scaffold-integrate`
- an ADR that should change → propose via `scaffold-plan`/`scaffold-checkpoint`
  (Adam-gated)

End by stating audit changed nothing, and what to run next.

## Boundaries

Audit does NOT: write or edit any doc (read-only — it routes fixes to the owning skill);
propose or write ADRs (it flags; the gated proposal is plan/checkpoint's); touch code; or
skip a pass (all three always run — conformance first, gating reality).
