---
name: scaffold-go
description: Execute the active phase plan in a scaffold project — a thin executor. Requires a FINALIZED plan (validated against current code); refuses a draft or a stale plan and routes you to finalize. Loads the scope that state.md's Next points at and builds it under tight scope control. Writes project files (and optionally an investigation record) only; never scaffold truth or execution docs. Use whenever the user wants to execute a phase, implement the current plan, build the next thing, or resume in-progress work — even if they only say "go", "build it", "run the phase", or "let's implement this".
---

# scaffold-go

Execute exactly the phase plan that `state.md`'s `## Next` points at. `go` is a **thin
executor**: it does not research or propose an approach — that was done and approved at
**finalize** (`/scaffold-plan --final`). `go` computes the plan's state, and only a
**final & fresh** plan runs. Scope-controlled — the plan's `## Scope` is the boundary,
and out-of-scope discoveries route to checkpoint rather than expanding the work.

**Precondition.** Read `.scaffold/state.md`. `## Next` must reference a phase plan at
`.scaffold/milestones/NN-slug/phases/NN-slug.md`. If not, stop: "No active phase plan.
Run /scaffold-plan to author one and set state.md Next, or just work without formal scope."

**Version guard.** If any `.scaffold/` doc carries `schema_version: 1`, a `type:
milestone-plan` / `type: phase-brief`, or a milestone folder holds a `plan.md` (the current
name is `milestone.md`), the repo predates the current format — stop: "Old scaffold format
(pre-rename) — run /scaffold-cleanup to migrate first; the current skills will misread it."

**Boundary.** Writes PROJECT files only (code, config, assets) — and MAY drop an
opportunistic research record in `.scaffold/investigations/`. It does NOT touch scaffold
truth or execution docs: no edits to `state.md`, `roadmap.md`, `architecture.md`,
`project.md`, `knowledge/`, `decisions/`, the milestone's `milestone.md`, or `CLAUDE.md` — and it
does NOT tick the `milestone.md` phase checklist. All scaffold write-back, including marking the
phase complete, is `/scaffold-checkpoint`'s job.

---

## Step 1: Load scope

`state.md`'s `## Next` is the single authority for what's active — the milestone and the
current phase plan. Read these in order:

1. The phase plan referenced in `## Next` — its `## Scope` is what you execute.
2. `.scaffold/state.md` — Active focus context and `## Next` (which carries any
   precondition on resuming, e.g. "reseed the dev DB first"). There is no `## Notes`
   section.
3. The active milestone's `milestone.md` — objectives and the phase's place in the checklist.
4. `.scaffold/architecture.md` — technical truth (stack, tenancy, data-access,
   conventions, how to run).
5. The active milestone's `spec/` if present (the contract, or a pointer to one elsewhere)
   — for a predetermined milestone its `references/` are the live rulebook.
6. `.scaffold/knowledge/` — durable domain/behavioral rules relevant to the plan.
7. `CLAUDE.md` — constraints and working norms.

## Step 2: Check the plan is executable (deterministic)

`go` runs only a **final & fresh** plan. Compute the state from the plan's `## Targets`
section — this is a hash comparison, it judges nothing:

1. **No `## Targets`** → **draft**. Stop:
   > "This plan isn't finalized. Run `/scaffold-plan --final` to validate it against the
   > current code — or just work freeform (status → work → checkpoint)."

   Do **not** try to research or propose an approach yourself — a draft is `plan`'s to
   finalize, and freeform is scaffold's existing wing-it path, not a `go` override.
2. **`## Targets` present** → read its `_as of <sha>_` stamp and compare to HEAD:
   - `git rev-parse "<sha>"` **≠** `git rev-parse HEAD` → **stale**. Stop:
     > "Validated `as of <sha>`; code has moved. Re-finalize with `/scaffold-plan --final`."
   - HEAD matches, but a target file is dirty (`git status --porcelain -- <target paths>`
     is non-empty) → **stale** (the validation no longer describes what's on disk). Same
     stop + re-finalize message.
   - HEAD matches and no target is dirty → **final & fresh**. Proceed.

(If the repo has no git, there is no sha to check — treat a plan with `## Targets` as
fresh and note that staleness can't be verified without git.)

## Step 3: Determine starting point

**Check for already-completed work.** Read the `milestone.md` checklist. If the phase this
plan covers is already ticked (checkbox + date), say so and stop — nothing to execute.

**The checkbox is not the only done-signal.** Only `checkpoint` ticks it, so a phase can
be *done but not yet ticked* — e.g. a context crash between `go` and `checkpoint`. Before
executing, check whether the plan's scope deliverables **already exist in the code**
(the `## Targets` files are where to look). If they exist, do NOT rebuild: say so and
route to `/scaffold-checkpoint` to record the completion. Only within a genuinely
in-progress phase do you use Active focus to find where to pick up.

**Use Active focus for resume context** — it describes where the work currently sits; use
it to understand where to resume, especially after a pause. **If the user says part of the
scope is already done, skip it.**

Present scope and confirm the start (the approach was approved at finalize — you do **not**
re-propose it):
> "Phase: [plan filename], final & fresh. [N] scope items to execute [out of M — N
> already done]. Starting now."

## Step 4: Execute

Execute scope items one at a time. For each:

1. Implement the changes (project files only).
2. Confirm: "Item [N] done: [what was done]. Moving to [N+1]."
3. Move to the next.

For single-item plans, combine completion and routing: "Done: [what was done]. Run
/scaffold-checkpoint."

If the work produces a research/analysis output worth keeping (a spike, a gap map, a
security investigation), write it to `.scaffold/investigations/YYYYMMDD-slug.md` (date as
`YYYYMMDD`, no hyphens). **Stamp it with `type: investigation` / `schema_version: 2` /
`updated: <today>` frontmatter** — it is the one scaffold doc `go` writes, and it must be
born conformant. Opportunistic — nothing obligates you to create one. If that
research yields a candidate ruling, leave the analysis here and let `/scaffold-checkpoint`
*propose* the ADR (decisions are Adam-gated; `go` never writes one).

## Step 5: Complete

When all scope items are done:
> "Phase scope complete. Run /scaffold-checkpoint."

Do NOT tick the `milestone.md` checklist yourself — checkpoint marks the phase complete after
verifying. If you resolved a resume precondition that `## Next` warned about (e.g.
re-seeded the dirty dev DB), surface it so `checkpoint` can update `## Next` — you don't
write `state.md` yourself. Likewise surface any ground-level issue you hit but left alone,
so `checkpoint` can log it in the milestone's `## Deferred`.

---

## Scope control

The plan's `## Scope` is your scope. Do not expand beyond it.

- Out-of-scope discoveries: note for checkpoint, don't act.
  > "Found: [issue]. Out of scope — will note for checkpoint."
- If the user asks for work outside scope:
  > "That's outside this phase's scope. Add it to the plan via /scaffold-plan, or do it
  > now and note for checkpoint?"
- Do NOT add features, refactor surrounding code, or make "while I'm here" improvements
  unless the user explicitly asks.

## Escape hatch

If a scope item is significantly bigger than expected — needs an architectural decision,
touches unexpected systems, or the approach won't work — STOP:
> "This is more complex than the plan anticipated: [explain]. Re-scope with /scaffold-plan,
> or continue?"

A scope item that turns out to hinge on an unmade architectural decision is a hard stop:
ADRs are Adam-gated and routed through `/scaffold-plan`, not invented mid-execution. Let
the user decide.

## Context window awareness

If the session has grown long mid-execution and several large scope items are behind you,
complete the current item, then suggest:
> "Context is getting long. Suggest /scaffold-checkpoint to save progress, then /clear and
> /scaffold-status to continue fresh."

Don't start a fresh scope item late in a long session — checkpoint first.

---

## Boundaries

Go does NOT: execute a draft or stale plan (only final & fresh — refuse and route to
finalize/re-finalize); research or propose an approach (that is `plan`'s finalize pass —
`go` executes the already-approved approach); write scaffold truth/execution docs
(`state.md`, `roadmap.md`, `architecture.md`, `project.md`, `knowledge/`, `decisions/`,
the milestone's `milestone.md`, `CLAUDE.md` are all checkpoint's or plan's job); tick the
`milestone.md` phase checklist (checkpoint marks completion); propose or write ADRs (Adam-gated,
routed through plan/checkpoint); or expand scope (only the plan's scope items).

Go MAY: write project files; write an opportunistic `investigations/YYYYMMDD-slug.md`.
