---
description: Execute the active phase brief — scope-controlled execution from state.md's Next
---

Any previous command instructions in this conversation are complete.
You are now executing under /scaffold:go.

**Precondition:** Read `.scaffold/state.md`. The `## Next` section must
reference a phase brief at
`.scaffold/milestones/NN-slug/phases/NN-slug.md`. If not, stop and say:

> "No active phase brief. Run `/scaffold:plan` to author one and set
> `state.md` Next, or just work without formal scope."

**Boundary:** This command writes PROJECT files only (code, config, assets) —
and MAY drop an opportunistic research record in
`.scaffold/investigations/`. It does NOT touch scaffold truth or execution
docs: no edits to `state.md`, `roadmap.md`, `architecture.md`, `project.md`,
`knowledge/`, `decisions/`, the milestone `plan.md`, or `CLAUDE.md` — and it
does NOT tick the `plan.md` phase checklist. All scaffold write-back,
including marking the phase complete, is `/scaffold:checkpoint`'s job.

---

## Step 1: Load Scope

`state.md`'s `## Next` is the single authority for what's active — the
milestone and the current phase brief. Read these in order:

1. The phase brief referenced in `state.md`'s `## Next`
   (`.scaffold/milestones/NN-slug/phases/NN-slug.md`) — its `## Scope`
   section is what you execute.
2. `.scaffold/state.md` — for Active focus context and any `## Notes`
   (transient operational state — e.g. "dev DB is dirty, re-seed first").
3. The active milestone's `plan.md` — for objectives and the phase's place
   in the checklist.
4. `.scaffold/architecture.md` — for the technical truth (stack, tenancy,
   data-access, conventions, how to run).
5. The active milestone's `spec/` if present (the contract, or a pointer to
   one elsewhere) — for a predetermined milestone its `references/` are the
   live rulebook.
6. `.scaffold/knowledge/` — durable domain/behavioral rules relevant to the
   brief.
7. `CLAUDE.md` — for constraints and working norms.

---

## Step 2: Determine Starting Point

**Check for already-completed work:**
Read the active milestone's `plan.md` checklist. If the phase this brief
covers is already ticked (checkbox + date), say so and stop — there's nothing
to execute.

**The checkbox is not the only done-signal.** Only `checkpoint` ticks it, so a
phase can be *done but not yet ticked* — e.g. a context crash between `go` and
`checkpoint`. Before executing, do a quick pass to see whether the brief's
scope deliverables **already exist in the code** (you research the codebase in
Step 3 regardless — check existence first). If they already exist, do NOT
rebuild: say so and route to `/scaffold:checkpoint` to record the completion.
Only within a genuinely in-progress phase do you use Active focus to find where
to pick up.

**Use Active focus for resume context:**
`state.md`'s Active focus describes where the work currently sits. Use it to
understand where to resume — especially after a pause.

**User-indicated completions:**
If the user says part of the scope is already done, skip it.

Present scope:
> "Phase: [brief filename]. [N] scope items to execute
> [out of M — N already done]."

---

## Step 3: Research and Propose

Research the codebase to understand how to implement the brief's scope. Read
relevant files, understand existing patterns, identify dependencies.

Present your approach:

> "Here's how I'll implement this:
>
> **1. [scope item]** — [approach summary]
> **2. [scope item]** — [approach summary]
>
> Approve?"

**STOP. Wait for user approval before executing.**

If the user wants changes, incorporate and re-present.
If the user wants to skip an item or change order, adjust.
If the work needs re-scoping: "Run `/scaffold:plan` to re-scope this phase."

---

## Step 4: Execute

Execute scope items one at a time. For each:

1. Implement the changes (project files only).
2. Confirm completion:
   > "Item [N] done: [what was done]. Moving to [N+1]."
3. Move to the next.

For single-item briefs, combine completion and routing:
> "Done: [what was done]. Run `/scaffold:checkpoint`."

If the work produces a research/analysis output worth keeping (a spike, a gap
map, a security investigation), write it to
`.scaffold/investigations/YYYYMMDD-slug.md`. This is opportunistic — nothing
obligates you to create one. If that research yields a candidate ruling, leave
the analysis here and let `/scaffold:checkpoint` *propose* the ADR (decisions
are Adam-gated; `go` never writes one).

---

## Step 5: Complete

When all scope items are done:

> "Phase scope complete. Run `/scaffold:checkpoint`."

Do NOT tick the `plan.md` checklist yourself — checkpoint marks the phase
complete after verifying.

If you resolved a `## Notes` operational item during execution (e.g. you
re-seeded the dirty dev DB it warned about), surface it so `checkpoint` can
clear that note — you don't write `state.md` yourself.

---

## Scope Control

The brief's `## Scope` is your scope. Do not expand beyond it.

- Out-of-scope discoveries: note for checkpoint, don't act on them.
  > "Found: [issue]. Out of scope — will note for checkpoint."
- If the user asks for work outside scope:
  > "That's outside this phase's scope. Add it to the brief via
  > `/scaffold:plan`, or do it now and note for checkpoint?"
- Do NOT add features, refactor surrounding code, or make "while I'm here"
  improvements unless the user explicitly asks.

---

## Escape Hatch

If a scope item is significantly bigger than expected — needs an
architectural decision, touches unexpected systems, or the approach won't
work — STOP:

> "This is more complex than the brief planned: [explain].
> Re-scope with `/scaffold:plan`, or continue?"

A scope item that turns out to hinge on an unmade architectural decision is a
hard stop: ADRs are Adam-gated and routed through `/scaffold:plan`, not
invented mid-execution. Let the user decide.

---

## Context Window Awareness

If the session has grown long mid-execution and several large scope items are
behind you, complete the current scope item, then suggest:

> "Context is getting long. Suggest `/scaffold:checkpoint` to save progress,
> then `/clear` and `/scaffold:status` to continue fresh."

Don't start a fresh scope item late in a long session — checkpoint first.

---

## Boundaries

Go does NOT:
- **Write scaffold truth/execution docs** — `state.md`, `roadmap.md`,
  `architecture.md`, `project.md`, `knowledge/`, `decisions/`, the milestone
  `plan.md`, `CLAUDE.md` are all checkpoint's (or plan's) responsibility.
- **Tick the `plan.md` phase checklist** — checkpoint marks completion.
- **Propose or write ADRs** — Adam-gated, routed through plan/checkpoint.
- **Expand scope** — only the brief's scope items.
- **Skip approach approval** — always present and wait.

Go MAY: write project files; write an opportunistic
`investigations/YYYYMMDD-slug.md`.
