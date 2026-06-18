---
description: Authoring — persist agreed direction into the scaffold docs (roadmap, milestones, phase briefs, state)
argument-hint: [description]
---

You are the single scaffold-**authoring** command. The conversation that
precedes you needs no command of its own — discussion is just discussion.
Your job is to **persist** the direction you and Adam have agreed on into the
right scaffold docs, routing each thing to its one home.

**Boundary:** You write scaffold docs only. You never write code (that is
`/scaffold:go`) and you never own the post-build coherence sweep / write-back
of build results (that is `/scaffold:checkpoint`). You only ever *propose* an
ADR — you never write to `decisions/` without Adam's explicit approval.

**Precondition:** Verify the living-truth docs exist: `CLAUDE.md`,
`.scaffold/project.md`, `.scaffold/state.md`, `.scaffold/roadmap.md`,
`.scaffold/architecture.md`. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

---

## Precondition Guards

Read `.scaffold/state.md` and `.scaffold/roadmap.md` before proceeding.

**If `## Blockers` has content other than "None.":**
> "State shows blockers: [reason from Blockers section]. Resolved? If yes,
> we plan forward. If not, let's address the blocker first."

Wait for confirmation.

**If this session shows executed-but-unrecorded work** — `go` ran in *this*
conversation but no `checkpoint` followed (the brief's `plan.md` checkbox is
still unchecked). This is a **conversation-context** signal, not a disk fact:
on a cold resume the unchecked box alone cannot tell "done but unrecorded" from
"not started," so this guard only fires when the current session knows work was
done. When it does:
> "There's executed-but-unrecorded work on [brief]. Run `/scaffold:checkpoint`
> first to record it, then re-plan."

Stop. Do not proceed. (On a cold resume with no such context, catching a
dangling executed-but-unticked phase is `status`/`checkpoint`'s job, not this
guard's — don't pretend to detect from disk what isn't there.)

---

## Check for Inline Description

If the user provided a description with the command (e.g.,
`/scaffold:plan add an export endpoint`), treat it as the agreed direction:

1. Run Phase 1 (triage) silently to read context.
2. Assess weight: more than a one-liner-to-roadmap? Does it create a
   milestone, author briefs, shift architecture truth, or touch a decision?
   - If it is a one-line backlog idea, do the minimum (route to
     `roadmap.md` Backlog) and confirm — no full flow.
   - Otherwise proceed to Phase 2 to confirm direction before authoring.

---

## Phase 1: Triage (silent)

Read in this order. Do not present findings yet — absorb context:

1. `.scaffold/state.md` — Active focus, Next, Blockers, Open Questions, Notes
2. `.scaffold/roadmap.md` — `## Milestones` index + `## Backlog`
3. `.scaffold/project.md` — identity, scope boundaries, requirements
4. `.scaffold/architecture.md` — current technical truth + referenced ADRs
5. `CLAUDE.md` — orientation, constraints

Then read the **active milestone** (the one `state.md` Next points at — *not*
folder order; highest `NN` is only a fallback when Next is silent):
- `.scaffold/milestones/NN-slug/plan.md` — phase checklist, objectives, done-contract
- The phase brief `state.md` Next points at, if any
- `.scaffold/milestones/NN-slug/spec/` — if present (the live rulebook while the
  milestone runs); a `spec/` may be a pointer to an external/shared spec — follow it
- `.scaffold/knowledge/` — read docs relevant to the direction at hand

Scan `.scaffold/decisions/` and `.scaffold/investigations/` by filename; read
any directly relevant to the direction.

Assess internally:
- Where does the agreed direction land — backlog idea, new milestone, new/changed
  phase briefs, a requirement, an architecture-truth shift, a decision?
- **Is this a pivot?** Does it reverse a prior decision or reorder/replace phases
  in the active milestone? If so, downstream unexecuted briefs may now be stale.
- **Does any intended brief depend on a not-yet-approved decision?** If so, the
  ADR gate must be resolved before that brief is authored (see Ordering Rule).

---

## Phase 2: Confirm Direction (interactive — WAIT for user)

**Skip only if the inline description was an unambiguous one-liner.**

Restate the agreed direction in one sentence and confirm:

> "So the direction is [one-sentence restatement]. Right?"

Wait for confirmation. The user's direction overrides the scaffold docs. If
the direction is still fuzzy, surface what the docs suggest as next work and
ask what they're thinking — do not author against a guess.

If mid-discussion the direction changes, drop the stale proposal and re-confirm
the new one before authoring.

---

## Phase 3: Resolve the Decision Gate FIRST

**Ordering rule (hard):** never author a brief premised on an unratified
decision. If the direction rests on a significant, durable, cross-cutting
choice (tenancy, auth, a foundational pivot) that is not yet recorded in
`decisions/`, resolve it before authoring anything that depends on it.

A significant choice clears the **ADR bar** only if a reader would want the
*why* of it in a year — not a routine guardrail. If it clears the bar:

1. **Propose** the ADR — present the full draft, ADR-shaped:
   > **Decision NNNN — [title]**
   > **Status:** Proposed
   > **Context:** [what forces a choice]
   > **Decision:** [the ruling]
   > **Why:** [rationale]
   > **Alternatives considered:** [options + why rejected]
   > **Consequences:** [what this commits us to]
2. **STOP. Wait for Adam's explicit approval.** No ADR is written without it —
   this file is curated by Adam, not by command judgment.
3. On approval: write `.scaffold/decisions/NNNN-slug.md` (next sequential,
   zero-padded). If the decision is architectural, **in the same turn** add or
   update its referencing statement in `architecture.md` (the references are
   the index — leaving it out silently breaks the index).
4. **Superseding** an existing ADR: flip the prior file's `Status:` line to
   `Superseded by [[NNNN-...]]`, write the new file, and update the referencing
   architecture statement — same turn. Never edit the original ruling.

If the choice does not clear the bar, do not write an ADR — it is a guardrail,
not a recorded decision.

---

## Phase 4: Announce the Write-Set

Before writing anything, state exactly what you intend to touch and how — so
Adam sees the shape of the change before it lands:

> "Here's what I'll write:
> - `roadmap.md` — [add backlog line / update milestone index entry]
> - `milestones/02-slug/` — **new milestone**, with `plan.md` seeded
> - `milestones/NN-slug/phases/07-slug.md` — **new phase brief**
> - `milestones/NN-slug/plan.md` — add Phase 07 to the checklist
> - `architecture.md` — [truth shift, if any]
> - `project.md` — [new requirement, if any]
> - `state.md` — Active focus + set Next
>
> Approve?"

Wait for approval. Adjust if Adam changes anything.

---

## Phase 5: Author (route by the coverage matrix)

Write only what the agreed direction calls for. Each thing has exactly one home.

### New feature idea, one line
→ `roadmap.md` `## Backlog`. A future-feature one-liner lives here permanently
(it does not retire with a milestone).

### A new milestone (a fresh durable chunk of work)
→ Create `.scaffold/milestones/NN-slug/` (`NN` = milestone counter,
disambiguated from product version; slug is a sticky namespace — choose it
deliberately). Seed `plan.md` with the phase checklist (each phase a checkbox +
completion-date slot), objectives, and the milestone's done-contract. Add the
milestone to `roadmap.md`'s `## Milestones` index (one-liner + status +
folder pointer). If the work warrants heavy scoping, create `spec/` — either the
spec itself or a pointer file to a spec living elsewhere (shared or in `docs/`);
do not crack open a pointer'd spec's internals.

### One or more phase briefs (how to build phase X of the active milestone)
→ `.scaffold/milestones/NN-slug/phases/NN-slug.md`, and add each phase to that
milestone's `plan.md` checklist. Phase numbers reset per milestone; the slug
namespaces them. **Interstitials are allowed** (`09.1` for a surgical phase
inserted after a frozen plan) — preserve them, never renumber siblings.

A phase brief contains:

```markdown
# Phase NN: [title]
<!-- Milestone: NN-slug · Brief authored: YYYY-MM-DD -->

## Goal
[What and why — 1-3 sentences.]

## Scope
Build these. Present your approach before starting. Do not expand beyond this.

1. [Deliverable] — [done-when condition]
2. [Deliverable] — [done-when condition]
3. [USER] [Deliverable] — [done-when condition]

## Approach
[Key decisions, strategy, what to watch out for. Reference the live spec/
references or the controlling ADR by pointer — never copy their content here.]

## Acceptance
[Verifiable criteria — how `checkpoint` confirms the phase is done.]
```

For an investigation deliverable, add to its entry:
`Output: .scaffold/investigations/YYYYMMDD-slug.md`.

`go` executes from a brief's `## Scope`; keep scope crisp and self-contained.

### A requirement
→ `project.md` Requirements section (verifiable checkbox).

### A cross-cutting technical-truth shift
→ `architecture.md`, in place — **only** when the agreed direction *changes how
the system is built* at a cross-cutting level (not a routine detail). Tiebreak:
if a fact would change when you re-platform but the business rule stays →
`architecture.md`; if it changes only when the *business rule* changes →
`knowledge/`. `checkpoint` is the primary owner of `architecture.md` (it sees
the diff); `plan` touches it only on a discussed truth shift.

### A durable business/behavioral rule established in discussion
→ `knowledge/*.md`, in place. (Most rules graduate at milestone close via
`checkpoint`; `plan` writes one here only when the discussion itself settled a
durable rule with no code to wait on.)

### Where we are now
→ Always update `state.md`:
- **Active focus** — one paragraph reflecting the new plan.
  **ELI5 — explain it like the reader is five.** Plain words, short sentences,
  no jargon, no status-report officialese. If a five-year-old wouldn't follow
  the gist, rewrite it.
- **Next** — set the active cursor: the milestone + the phase brief to execute
  next, e.g. "Execute `milestones/01-rebuild/phases/07-slug.md` — say 'go
  ahead' or run `/scaffold:go`." **This is the authority for what's active.**
- **Blockers / Open Questions** — update only if the discussion resolved or
  surfaced something. Resolved/answered lines are removed (history is git).
- **Notes** — leave transient operational notes (dirty DB, temp env) intact
  unless the discussion cleared them.

Update the `<!-- Last updated -->` date on every file you touched.

---

## Phase 6: Pivot — Stale-Brief Sweep

**Run this whenever the direction is a pivot** — a decision reversed, or phases
reordered/replaced/inserted in the active milestone. Because briefs now
*persist* (they are no longer thrown away just-in-time), a pre-written
downstream brief can silently go stale when a later change lands.

For **every unexecuted brief** in the active milestone (executed ones are
history — leave them):
1. Re-read it against the change just made.
2. If its scope, approach, or acceptance now conflicts with the new plan,
   **flag it and rewrite it** in place to match — or, if it no longer belongs,
   propose removing it and updating the `plan.md` checklist.
3. Report each brief as `OK / rewritten / removed` in the summary.

This is `plan`'s half of the staleness obligation; `checkpoint`'s coherence
sweep is the backstop that also catches brief-vs-decision drift.

---

## Phase 7: Summary

Report what was written, per file:
- Roadmap / milestone-index changes
- Milestone created (if any)
- Phase briefs authored or rewritten (+ checklist updates)
- Architecture / project / knowledge changes (if any)
- Decision proposed and its status (proposed / approved+written / declined)
- State updates (Active focus + the new Next cursor)
- Stale-brief sweep results (if a pivot)

Then route forward:

> "[Summary]. Ready to build — say 'go ahead' or run `/scaffold:go`. Or keep
> planning."

---

## Edge Cases

- **User wants something not on the roadmap:** their direction wins — route it
  to its home (backlog, new milestone, or brief) in Phase 5.
- **User doesn't know what to work on:** stay in Phase 2. Surface the milestone
  index + open questions and help them choose. Don't author against a guess.
- **Direction depends on an unratified decision:** resolve the ADR gate
  (Phase 3) first; never author dependent briefs ahead of it.
- **Mid-discussion pivot:** drop stale proposals, re-confirm the new direction
  (Phase 2), then author — and run the Phase 6 sweep.
- **Files are stale (>7 days):** flag it; offer to refresh during this session
  or via `/scaffold:checkpoint --reconcile`.

---

## Boundaries

Plan does NOT:
- **Write code or modify project files** — that is `/scaffold:go`.
- **Write to `decisions/` without Adam's explicit approval** — it only proposes
  ADRs; the decision log is Adam-gated.
- **Own the coherence sweep / write-back of build results** — that is
  `/scaffold:checkpoint`.
- **Author briefs premised on an unratified decision** — resolve the gate first.
- **Use plan mode** — all work happens in normal mode.
- **Skip the write-set announcement** — Adam sees the shape before it lands.
