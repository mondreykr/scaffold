---
description: Execute scoped work — formal scope-controlled execution from a plan doc
---

Any previous command instructions in this conversation are complete.
You are now executing under /scaffold:do.

**Precondition:** Read `.scaffold/state.md`. Status must be `scoped` and
Next Action must reference a plan doc. If not, stop and say:

> "No plan doc found. Run `/scaffold:scope` to write one,
> or just work without formal scope."

**Boundary:** This command does NOT update core scaffold files (state.md,
roadmap.md, decisions.md, project.md, CLAUDE.md). Scaffold file updates are
checkpoint's job. You write project files and investigation outputs only.

---

## Step 1: Load Scope

Read these files in order:

1. The plan doc referenced in state.md's Next Action
2. `.scaffold/state.md` — for Session Context (if present) and current state
3. `.scaffold/roadmap.md` — for deliverable details and completion status
4. `CLAUDE.md` — for constraints and tech stack
5. `.scaffold/context/` — context docs relevant to the plan being executed.
   These contain detailed specifications (interaction flows, visual design,
   data models, architecture patterns) that inform implementation. When
   building from a spec, this is the primary implementation reference.

---

## Step 2: Determine Starting Point

**Check for already-completed deliverables:**
Compare the plan doc's Scope list against roadmap.md. If any scoped
deliverables are already marked `[x]` in the roadmap, skip them.

**Check for Session Context:**
If state.md has a Session Context section (resuming from pause), read it.
Use it to understand where to pick up.

**User-indicated completions:**
If the user says some deliverables were already completed, skip those.

Present scope:
> "Plan: [filename]. [N] deliverables to execute [out of M — N skipped].
> [If Session Context: 'Resuming from: [next step]']"

---

## Step 3: Research and Propose

Research the codebase to understand how to implement the scoped deliverables.
Read relevant files, understand existing patterns, identify dependencies.

Present your approach:

> "Here's how I'll implement these:
>
> **1. [deliverable]** — [approach summary]
> **2. [deliverable]** — [approach summary]
>
> Approve?"

**STOP. Wait for user approval before executing.**

If the user wants changes, incorporate and re-present.
If the user wants to skip a deliverable or change order, adjust.
If the user wants to re-scope entirely: "Run `/scaffold:scope` to re-scope."

---

## Step 4: Execute

Execute deliverables one at a time. For each:

1. Implement the changes
2. Confirm completion:
   > "Deliverable [N] done: [what was done]. Moving to [N+1]."
3. Move to the next

For single-deliverable plans, combine completion and routing:
> "Done: [what was done]. Run `/scaffold:checkpoint`."

For investigation deliverables with an `Output:` field, write findings to the
specified path in `.scaffold/investigations/`.

---

## Step 5: Complete

When all deliverables are done:

> "All [N] deliverables complete. Run `/scaffold:checkpoint`."

---

## Scope Control

Follow the plan doc's embedded scope instructions. These deliverables are
your scope. Do not expand beyond them.

- Out-of-scope discoveries: note for checkpoint, don't act on them.
  > "Found: [issue]. Out of scope — will note for checkpoint."
- If the user asks for work outside scope:
  > "That's outside the current scope. Add to the plan, or do it now
  > and note for checkpoint?"
- Do NOT add features, refactor surrounding code, or make "while I'm here"
  improvements unless the user explicitly asks.

---

## Escape Hatch

If a deliverable is significantly bigger than expected — needs architectural
decisions, touches unexpected systems, or the approach won't work — STOP:

> "This is more complex than planned: [explain].
> Re-scope with `/scaffold:scope`, or continue?"

Let the user decide.

---

## Context Window Awareness

If context is running low mid-execution (below ~40%), complete the current
deliverable, then suggest:

> "Context is getting long. Suggest `/scaffold:checkpoint` to save progress,
> then `/clear` and `/scaffold:status` to continue fresh."

Do NOT start a new deliverable when context is low.

---

## Boundaries

Do does NOT:
- **Update scaffold files** — checkpoint's responsibility
- **Expand scope** — only the scoped deliverables
- **Skip approach approval** — always present and wait
