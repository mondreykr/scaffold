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

1. **Project** — What this is, in one sentence (from project.md)
2. **Phase** — Which phase is `[IN-PROGRESS]`, how many deliverables done vs remaining
3. **State** — Current status and any blockers (from state.md)
4. **Open threads** — Open questions or things being figured out
5. **Context docs** — If `.scaffold/context/` exists and contains files,
   list filenames with one-line descriptions. These are controlling documents
   (specs, architecture docs) that inform current and future phases.
   Skip if empty or absent.
6. **Investigations** — If `.scaffold/investigations/` exists and contains files,
   list filenames with one-line descriptions. Skip if empty or absent.
7. **Next action** — Route based on state.md Status (see Step 3)
8. **Health check** — Flag contradictions between files:
   - State says blocked but roadmap shows it as complete
   - Roadmap shows a deliverable as in progress but state doesn't reference it
   - Project scope boundaries say "no X" but roadmap includes X
   - If consistent, say so.
9. **Staleness check** — If any scaffold file's `<!-- Last updated -->` date is
   more than 7 days old, flag it.

---

## Step 3: Route to Next Action

Present options based on state.md Status. Suggest, don't mandate.

**Status is `idle`:**
> "No active scope. What would you like to work on?
> `/scaffold:plan` to discuss direction, or just tell me what you need."

**Status is `scoped`:**
Read the plan doc. Present the scoped deliverables.
> "Plan doc ready: [deliverable list].
> Say 'go ahead', run `/scaffold:do` for formal execution, or keep working."

**Status is `paused`:**
Read Session Context from state.md. Present it.
- If plan doc exists:
  > "Paused from [date]. [Session Context summary].
  > Continue working, `/scaffold:do`, or `/scaffold:plan` to re-scope."
- If no plan doc:
  > "Paused mid-work from [date]. [Session Context summary].
  > Continue or `/scaffold:plan` to figure out next steps."

**Status is `user-pending`:**
Scan roadmap for unchecked `[USER]` deliverables in the `[IN-PROGRESS]` phase.
> "AI work done. USER tasks pending:
> - [deliverable description]
> Complete them, then `/scaffold:checkpoint`."

**Status is `blocked`:**
> "Blocked: [reason].
> If resolved, continue working or `/scaffold:plan` to discuss direction."

**USER deliverables in roadmap (regardless of state):**
If unchecked `[USER]` deliverables exist and status is NOT `user-pending`,
surface them as a note:
> "**Reminder:** [N] USER task(s) pending in Phase [N]."

---

## Boundaries

Status does NOT:
- **Write any files** — read-only
- **Make decisions** — presents state and options
- **Run other commands** — tells you what's available

Keep it short. This is a briefing, not a report. If everything is early/empty,
just say so and ask what the user wants to work on.
