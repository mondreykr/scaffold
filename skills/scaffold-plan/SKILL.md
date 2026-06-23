---
name: scaffold-plan
description: Persist an agreed direction into the scaffold docs — the single authoring skill. Routes each thing to its one home: a backlog idea to roadmap, a new chunk to a milestone + plan.md, how-to-build-it to phase briefs, a cross-cutting truth shift to architecture.md, and always updates state.md's Next cursor. Proposes ADRs (Adam-gated) and sweeps stale briefs on a pivot. Use whenever the user wants to plan, scope, decide what to build next, add a milestone or phase, capture a decision or requirement, or write down a direction you've agreed on — even if they only say "plan this", "let's scope it", or "write that down". Writes scaffold docs only, never code.
---

# scaffold-plan

The single scaffold-**authoring** skill. The conversation that precedes you needs no
skill — discussion is just discussion. Your job is to **persist** the direction you and
Adam agreed on into the right docs, routing each thing to its one home.

**Boundary.** You write scaffold docs only. Never code (that's `scaffold-go`) and never
the post-build coherence sweep / write-back of build results (that's
`scaffold-checkpoint`). You only ever *propose* an ADR — never write to `decisions/`
without Adam's explicit approval.

**Precondition.** `CLAUDE.md` and the four `.scaffold/` truth docs (`project.md`,
`architecture.md`, `roadmap.md`, `state.md`) exist. If any is missing, stop: "Scaffold
files missing or incomplete — run /scaffold-setup first."

**Frontmatter.** Every `.scaffold/` doc you create or touch carries `type` /
`schema_version: 1` / `updated:`; set `updated:` to today on every file you write.
`CLAUDE.md` is exempt.

---

## Precondition guards

Read `state.md` and `roadmap.md` first.

- **Blockers present** (`## Blockers` ≠ "None."): "State shows blockers: [reason].
  Resolved? If yes, we plan forward; if not, let's address the blocker first." Wait.
- **Executed-but-unrecorded work** — `go` ran in *this* conversation but no `checkpoint`
  followed (the brief's `plan.md` box is still unchecked). This is a *conversation-context*
  signal, not a disk fact (on a cold resume the unchecked box can't distinguish "done but
  unrecorded" from "not started"). When this session knows work was done: "There's
  executed-but-unrecorded work on [brief]. Run /scaffold-checkpoint first to record it,
  then re-plan." Stop — don't proceed.

## Inline description

If the user invoked with a description (e.g. "plan add an export endpoint"), treat it as
the agreed direction: run Phase 1 (triage) silently, then assess weight. A one-line
backlog idea → do the minimum (route to `roadmap.md` Backlog) and confirm, no full flow.
Anything that creates a milestone, authors briefs, shifts architecture truth, or touches a
decision → proceed to Phase 2.

## Phase 1: Triage (silent)

Read, absorbing context (don't present yet):

1. `state.md` — Active focus, Next, Blockers, Open Questions
2. `roadmap.md` — `## Milestones` index + `## Backlog`
3. `project.md` — identity, scope boundaries
4. `architecture.md` — current technical truth + referenced ADRs
5. `CLAUDE.md` — orientation, constraints

Then the **active milestone** (per `state.md` Next — *not* folder order; highest `NN` is
only a fallback when Next is silent): its `plan.md` (checklist, objectives,
done-contract, `## Deferred` list); the phase brief Next points at, if any; its `spec/` if present (follow a
pointer to an external/shared spec; don't crack open its internals); and any
`knowledge/` doc relevant to the direction. Scan `decisions/` and `investigations/` by
filename; read any directly relevant.

Assess internally: where does the direction land (backlog idea / new milestone /
new-or-changed briefs / a requirement / an architecture-truth shift / a decision)? **Is
it a pivot** (reverses a prior decision, or reorders/replaces phases in the active
milestone)? — if so, downstream unexecuted briefs may now be stale. **Does any intended
brief depend on a not-yet-approved decision?** — if so, the ADR gate resolves first.

## Phase 2: Confirm direction (interactive — WAIT)

Skip only if the inline description was an unambiguous one-liner. Restate in one sentence
and confirm: "So the direction is [restatement]. Right?" Wait. The user's direction
overrides the docs. If it's still fuzzy, surface what the docs suggest and ask — don't
author against a guess. If the direction changes mid-discussion, drop the stale proposal
and re-confirm before authoring.

## Phase 3: Resolve the decision gate FIRST

**Ordering rule (hard):** never author a brief premised on an unratified decision. If the
direction rests on a significant, durable, cross-cutting choice (tenancy, auth, a
foundational pivot) not yet in `decisions/`, resolve it before authoring anything that
depends on it.

A choice clears the **ADR bar** only if a reader would want the *why* of it in a year —
not a routine guardrail or build-record. If it clears the bar:

1. **Propose** the full draft, ADR-shaped:
   > **NNNN — [title]** · **Status:** Proposed
   > **Context** [what forces a choice] · **Decision** [the ruling] · **Why** [rationale]
   > · **Alternatives considered** [options + why rejected] · **Consequences** [what this
   > commits us to]
2. **STOP. Wait for Adam's explicit approval.** No ADR is written without it.
3. On approval: write `.scaffold/decisions/NNNN-slug.md` — frontmatter `type: decision`,
   then `# NNNN — <title>`, a `**Status:** Accepted` line, and `## Context` / `## Decision`
   / `## Why` / `## Alternatives considered` / `## Consequences`. `NNNN` is the next
   sequential decision number, zero-padded to **4 digits** (distinct from the 2-digit
   milestone/phase `NN`). If architectural, **in the same turn** add/update its
   referencing statement in `architecture.md` (`[[NNNN-…]]` — the references are the
   index; omitting it silently breaks the index).
4. **Superseding:** flip the prior file's `Status:` to `Superseded by [[NNNN-…]]`, write a
   NEW file, update the referencing architecture statement — same turn. Never edit the
   original ruling.

If the choice doesn't clear the bar, write no ADR — it's a guardrail, not a recorded
decision.

## Phase 4: Announce the write-set

Before writing anything, state exactly what you'll touch and how:

> "Here's what I'll write:
> - `roadmap.md` — [add backlog line / update milestone index entry]
> - `milestones/02-slug/` — **new milestone**, `plan.md` seeded
> - `milestones/NN-slug/phases/07-slug.md` — **new phase brief**
> - `milestones/NN-slug/plan.md` — add Phase 07 to the checklist
> - `architecture.md` — [truth shift, if any]
> - `project.md` — [scope/identity change, if any]
> - `state.md` — Active focus + set Next
>
> Approve?"

Wait for approval. Adjust if Adam changes anything.

## Phase 5: Author (route by the model — one home each)

Write only what the direction calls for. **Every datum has exactly one home below — never
invent a catch-all / "misc" / "notes" section to park something that doesn't obviously
fit.** Route it to its real home; if it genuinely seems to need a new kind of section,
that's a system-design question to raise with Adam, not a bucket to add mid-session.

- **The Backlog↔Deferred test (one computable rule):** *is this tied to the active
  milestone — its scope, its code, or its goal?* **Not tied (or no milestone is active) →
  `roadmap.md` `## Backlog`** (it outlives any current milestone — typically a future
  feature/capability). **Tied → the active milestone's `plan.md` `## Deferred`** (it's moot
  or owned elsewhere once the milestone closes — typically a bug, cleanup, debt, residual,
  or doc/spec-reconciliation surfaced inside the work). "Altitude" is not the rule; tied-ness
  is. Either way: one terse `- [ ]` line, never ticked — an item leaves by removal when
  promoted or shipped.
- **Grooming Deferred + Backlog (when the direction touches them).** You own *promotion*:
  pull a `## Deferred` or `## Backlog` item into a phase brief (authoring it per below) and
  **remove the promoted line in the same write**, or leave the item if Adam decides not to
  schedule it yet. Don't delete an item as "done" on your own judgment — shipped-removal is
  `checkpoint`'s (it has the diff) and stale-detection is `audit`'s (it checks the code).
- **A new milestone** → create `.scaffold/milestones/NN-slug/` (`NN` = milestone counter;
  slug is a sticky namespace — choose deliberately). Seed `plan.md` (frontmatter
  `type: milestone-plan`; `# Milestone NN — <slug>`; `## Objectives`; `## Phases`
  checklist with checkbox + completion-date slot; `## Done-contract`). Add the milestone
  to `roadmap.md`'s `## Milestones` (`[planned]`/`[active]` token + one-liner + folder
  pointer). If it warrants heavy scoping, create `spec/` — the spec itself or a pointer
  file to one living elsewhere; never crack open a pointer'd spec's internals.
- **One or more phase briefs** → `.scaffold/milestones/NN-slug/phases/NN-slug.md`, and add
  each phase to that milestone's `plan.md` checklist. Phase numbers reset per milestone;
  the slug namespaces them. **Interstitials allowed** (`09.1` for a surgical phase
  inserted after a frozen plan) — preserve them, never renumber siblings. Brief shape:

  ```markdown
  ---
  type: phase-brief
  schema_version: 1
  updated: [today]
  ---

  # Phase NN — <slug>

  ## Objective
  [What this phase delivers, in a sentence or two.]

  ## Scope
  [The deliverables `scaffold-go` executes — crisp and self-contained. Number them, and
  mark human-owned items `[USER]` (e.g. `2. [USER] Create the OAuth app — client ID in
  .env`). Out-of-scope discoveries route to checkpoint, never silent expansion.]

  ## Approach
  [Key decisions, strategy, what to watch out for. Reference the live spec/references or
  the controlling ADR by pointer — never copy their content here.]

  ## Acceptance
  [Verifiable criteria — how `checkpoint` confirms the phase is done.]
  ```

  For an investigation deliverable, note `Output: .scaffold/investigations/YYYYMMDD-slug.md`
  in its scope line.
- **A requirement / product constraint** → `project.md`, as **plain truth** (in `## Scope`
  or `## Not building`) — **never a checkbox** (checkboxes are a `project.md` anti-pattern).
  A *verifiable invariant* routes instead to where it's tested: a phase brief's
  `## Acceptance`, a milestone done-contract, the `spec/`, or a `knowledge/` invariants
  doc — not a truth doc.
- **A cross-cutting technical-truth shift** → `architecture.md`, in place, **only** when
  the direction changes *how the system is built* at a cross-cutting level (not a routine
  detail). Tiebreak: changes on *re-platform* (business rule stays) → `architecture.md`;
  changes only when the *business rule* changes → `knowledge/`. `checkpoint` is the
  primary owner (it sees the diff); `plan` touches it only on a discussed truth shift, and
  applies the ADR coupling rule when relevant.
- **A durable cross-cutting invariant settled in discussion** → `knowledge/*.md`, in place,
  in the contract's form (invariant + why + a pointer to where code enforces it). Only when
  it is load-bearing AND has no single code home (a localized value belongs in code; a
  re-platform fact in `architecture.md`). `checkpoint` is the band's primary owner and most
  rules graduate at close; `plan` writes one here only when the discussion itself settled a
  durable invariant with no code to wait on.
- **Where we are now** → always update `state.md`:
  - **Active focus** — one paragraph reflecting the new plan. ELI5: plain words, short
    sentences, no jargon, no officialese.
  - **Next** — set the active cursor: the milestone + the phase brief to execute next
    (by path), e.g. "Execute `milestones/01-rebuild/phases/07-slug.md` — say 'go ahead'
    or run /scaffold-go." **This is the authority for what's active.**
  - **Blockers / Open Questions** — update only if the discussion resolved or surfaced
    one; remove resolved lines (history is git).
  - **No `## Notes` section** — `state.md` has no transient-state bucket. A precondition on
    resuming (reseed the DB first) rides in `## Next`; a durable run/env condition goes to
    `architecture.md`; a blocker to `## Blockers`.

## Phase 6: Pivot — stale-brief sweep

**Run whenever the direction is a pivot** (a decision reversed, or phases
reordered/replaced/inserted in the active milestone). Because briefs *persist*, a
pre-written downstream brief can silently go stale when a later change lands.

For **every unexecuted brief** in the active milestone (executed ones are history —
leave them):
1. Re-read it against the change just made.
2. If its scope/approach/acceptance now conflicts, **flag and rewrite it in place** to
   match — or, if it no longer belongs, propose removing it and updating the `plan.md`
   checklist.
3. Report each brief as `OK / rewritten / removed` in the summary.

This is `plan`'s half of the staleness obligation; `checkpoint`'s coherence sweep is the
backstop that also catches brief-vs-decision drift.

## Phase 7: Summary + route

Report per file: roadmap / milestone-index changes; milestone created (if any); briefs
authored or rewritten (+ checklist updates); architecture / project / knowledge changes;
decision proposed and its status (proposed / approved+written / declined); state updates
(Active focus + the new Next cursor); stale-brief sweep results (if a pivot). Then:

> "[Summary]. Ready to build — say 'go ahead' or run /scaffold-go. Or keep planning."

---

## Edge cases

- **User wants something not on the roadmap:** their direction wins — route it to its home
  in Phase 5.
- **User doesn't know what to work on:** stay in Phase 2. Surface the milestone index +
  open questions and help them choose; don't author against a guess.
- **Direction depends on an unratified decision:** resolve the ADR gate (Phase 3) first.
- **Mid-discussion pivot:** drop stale proposals, re-confirm (Phase 2), author, then run
  the Phase 6 sweep.
- **Files are stale (>7 days):** flag it; offer to refresh now or note it for the next
  `/scaffold-checkpoint` (which sweeps).

## Boundaries

Plan does NOT: write code or modify project files (`scaffold-go`); write to `decisions/`
without Adam's explicit approval (propose only — the log is Adam-gated); own the coherence
sweep / write-back of build results (`scaffold-checkpoint`); author briefs premised on an
unratified decision (resolve the gate first); or skip the write-set announcement (Adam
sees the shape before it lands).
