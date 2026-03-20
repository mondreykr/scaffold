---
description: Session briefing — read scaffold files and orient on current state
---

**Precondition:** Verify that CLAUDE.md, `.scaffold/project.md`,
`.scaffold/state.md`, and `.scaffold/roadmap.md` exist. If any are missing,
stop and say: "Scaffold files missing — run /scaffold:setup first."

---

## Step 1: Read Context

Read the following files in order:
1. CLAUDE.md
2. .scaffold/project.md
3. .scaffold/state.md
4. .scaffold/roadmap.md

If state.md references a plan doc in its Next Action section, read that plan doc
too — you'll need it for scope details.

Do NOT read .scaffold/decisions.md unless something in state or roadmap references
a decision that needs context — it's reference material, not session briefing.

---

## Step 2: Present Briefing

Give a brief orientation:

1. **Project** — What this is, in one sentence (from .scaffold/project.md)
2. **Phase** — Which phase is `[IN-PROGRESS]`, how many tasks done vs remaining
3. **State** — Current status and any blockers (from .scaffold/state.md)
4. **Open threads** — Open questions or things being figured out
5. **Investigations** — If `.scaffold/investigations/` exists and contains files:
   > **Investigations:** [N] investigation file(s).
   > [list filenames with one-line descriptions]

   Skip this section if the directory doesn't exist or is empty.
6. **Next action** — Route based on state.md Status field (see routing table below)
7. **Health check** — Flag any contradictions between files. Examples:
   - State says something is blocked but roadmap shows it as complete
   - Roadmap shows a task `>>` in progress but state's Next Action doesn't reference it
   - Project scope boundaries say "no X" but roadmap includes X

   If everything is consistent, say so.

8. **Staleness check** — Check the `<!-- Last updated: YYYY-MM-DD -->` date at the
   top of each scaffold file. If any file is more than 7 days old, flag it:
   "[filename] last updated [date] — may be stale."

---

## Step 3: Route to Next Action

Route based on the Status field in state.md:

**Status is `idle`:**
> "No active scope. Run `/scaffold:plan` to scope work."

**Status is `scoped`:**
Read the plan doc referenced in state.md. Present the scoped tasks.
> "Scoped work ready: [task list from plan doc].
> Run `/scaffold:do` to execute."

**Status is `paused`:**
Read Session Context from state.md. Present it.
- If state.md references a plan doc:
  > "Paused session from [date].
  > [Session Context summary]
  > Run `/scaffold:do` to continue, or `/scaffold:plan` to re-scope."
- If state.md does NOT reference a plan doc (paused mid-planning):
  > "Paused mid-planning from [date].
  > [Session Context summary]
  > Run `/scaffold:plan` to continue."

**Status is `user-pending`:**
Scan roadmap for unchecked `[USER]` tasks in the `[IN-PROGRESS]` phase.
> "AI work done. USER tasks pending:
> - [task description]
> Complete them, then run `/scaffold:checkpoint`."

**Status is `blocked`:**
> "Blocked: [reason from state.md].
> Resolve the blocker. If the current scope is still valid, run `/scaffold:do`.
> Otherwise run `/scaffold:plan` to re-scope."

**USER tasks in roadmap (regardless of state):**
Scan the `[IN-PROGRESS]` phase for unchecked `[USER]` tasks. If any exist and
status is NOT `user-pending` (which already handles this), surface them:
> "**User tasks pending:** [N] task(s) require your action:
> - [task description]
> Run `/scaffold:checkpoint` when complete."

---

## Boundaries

Status does NOT:
- **Write any files** — status is read-only
- **Make decisions** — it presents state and routes, nothing else
- **Run other commands** — it tells you what to run next

Keep it short. This is a briefing, not a report. If everything is early/empty,
just say so and ask what the user wants to work on.
