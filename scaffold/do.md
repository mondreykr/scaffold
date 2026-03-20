---
description: Execute scoped work — research, propose approach, get approval, build
---

Any previous planning instructions in this conversation are complete.
You are now in execution mode under /scaffold:do.

**Precondition:** Read `.scaffold/state.md`. Check the "Next Action" section
for a plan doc pointer. If Next Action has no plan doc pointer, or says
"Run /scaffold:plan", stop and say:

> "No scoped work. Run `/scaffold:plan` first."

**Boundary:** This command does NOT update core scaffold files (state.md,
roadmap.md, decisions.md, project.md, CLAUDE.md). Scaffold file updates are
checkpoint's job. You write project files and investigation outputs only.

---

## Step 1: Load Scope

Read these files in order:

1. The plan doc referenced in state.md's Next Action
2. `.scaffold/state.md` — for Session Context (if present) and current state
3. `.scaffold/roadmap.md` — for task details and completion status
4. `CLAUDE.md` — for constraints and tech stack

---

## Step 2: Determine Starting Point

**Check for already-completed tasks:**
Compare the plan doc's Tasks list against roadmap.md. If any scoped tasks
are already marked `[x]` in the roadmap, skip them.

**Check for Session Context:**
If state.md has a Session Context section (resuming from pause), read it.
It contains progress notes, key context, and the next concrete step from
the previous session. Use this to understand where to pick up.

**User-indicated completions:**
If the user says some tasks were already completed (e.g., from a prior
session that wasn't checkpointed), skip those tasks.

Present scope:
> "Plan: [filename]. [N] tasks to execute [out of M total — N skipped as complete].
> [If Session Context exists: 'Resuming from: [next step from Session Context]']"

---

## Step 3: Research and Propose

Research the codebase to understand how to implement the scoped tasks.
Read relevant files, understand existing patterns, identify dependencies.

Present your approach:

> "Here's how I'll implement these [N] tasks:
>
> **Task 1: [title]** — [approach summary]
> **Task 2: [title]** — [approach summary]
> [...]
>
> Approve?"

**STOP. Wait for user approval before executing.**

If the user wants changes to the approach, incorporate them and re-present.
If the user wants to skip a task or change order, adjust.
If the user wants to re-plan entirely, stop: "Run `/scaffold:plan` to re-scope."

---

## Step 4: Execute

Execute tasks one at a time. For each task:

1. Implement the changes
2. Briefly confirm completion:
   > "Task [N] done: [what was done]. Moving to task [N+1]."
3. Move to the next task

For investigation tasks with an `Output:` field in the plan doc, write
findings to the specified path in `.scaffold/investigations/`.

---

## Step 5: Complete

When all tasks are done:

For single-task plans, combine completion and routing:
> "Done: [what was done]. Run `/scaffold:checkpoint`."

For multi-task plans:
> "All [N] tasks complete. Run `/scaffold:checkpoint`."

---

## Scope Control

These tasks are your scope. Do not expand beyond them.

- If you discover out-of-scope work needed, note it for checkpoint:
  > "Found: [issue]. Out of scope — will note for checkpoint."
- If the user asks for work outside the current scope, confirm:
  > "That's outside the current scope. Should I add it to the plan,
  > or do it now and note it for checkpoint?"
- Do NOT add features, refactor surrounding code, or make "while I'm here"
  improvements unless the user explicitly asks.

---

## Escape Hatch

If a task turns out to be significantly bigger than planned — needs
architectural decisions, touches unexpected systems, or reveals that the
approach won't work — STOP and say:

> "This is more complex than planned: [explain what changed].
> Suggest running `/scaffold:plan` to re-scope. Continue anyway,
> or re-plan?"

Let the user decide.

---

## Context Window Awareness

If context is running low mid-execution (below ~40% remaining), complete
the current task, then suggest:

> "Context is getting long. Suggest running `/scaffold:checkpoint` to save
> progress, then `/clear` and `/scaffold:status` to continue fresh."

Do NOT start a new task when context is low.

---

## Boundaries

Do does NOT:
- **Update scaffold files** — state.md, roadmap.md, decisions.md are
  checkpoint's responsibility
- **Use plan mode** — all execution happens in normal mode
- **Expand scope** — only the scoped tasks, nothing else
- **Skip approach approval** — always present and wait for approval
