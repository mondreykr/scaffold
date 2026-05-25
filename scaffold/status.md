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

If state.md's `## Next` references a plan doc in `.scaffold/plans/`,
read that plan doc too — you'll need it for scope details.

Do NOT read .scaffold/decisions.md unless something in state or roadmap
references a decision that needs context — it's reference material, not
session briefing.

---

## Step 2: Derive Signals From Content

State is content-derived, not status-keyword-driven. Compute the following
signals from what you just read:

- **Plan doc active?** `## Next` in state.md references a file in
  `.scaffold/plans/` AND that plan doc still has incomplete scoped
  deliverables.
- **USER tasks pending?** Roadmap's `[IN-PROGRESS]` phase has unchecked
  `[USER]` deliverables AND no other unchecked AI deliverables in that phase.
- **Blocked?** `## Blockers` in state.md has content other than "None."
- **Otherwise:** continue active focus, or start a new direction.

These signals drive routing in Step 4. They are not mutually exclusive
(you can be blocked AND have a plan doc active) — surface all that apply.

---

## Step 3: Present Briefing

Give a brief orientation:

1. **Project** — What this is, in one sentence (from project.md)
2. **Phase** — Which phase is `[IN-PROGRESS]`, how many deliverables done vs remaining
3. **Active focus** — From state.md, one paragraph synopsis
4. **Open threads** — Blockers and Open Questions from state.md (skip if both "None.")
5. **Knowledge docs** — If `.scaffold/knowledge/` exists and contains files,
   list filenames with one-line descriptions. These are controlling documents
   (specs, architecture docs) that inform current and future phases.
   Skip if empty or absent.
6. **Investigations** — If `.scaffold/investigations/` exists and contains files,
   list filenames with one-line descriptions. Skip if empty or absent.
7. **Next action** — Route per Step 4 based on the signals from Step 2
8. **Health check** — Flag contradictions between files:
   - State Blockers says blocked but roadmap shows it as complete
   - Roadmap shows a deliverable as in progress but state doesn't reference it
   - Project scope boundaries say "no X" but roadmap includes X
   - If consistent, say so.
9. **Staleness check** — If any scaffold file's `<!-- Last updated -->` date is
   more than 7 days old, flag it.

---

## Step 4: Route to Next Step

Present options based on the signals from Step 2. Suggest, don't mandate.
Surface multiple signals if multiple apply.

**Plan doc active:**
Read the plan doc. Present the scoped deliverables.
> "Plan doc ready: [deliverable list].
> Say 'go ahead', run `/scaffold:do` for formal execution, or keep working."

**USER tasks pending (no plan doc active):**
Surface the USER deliverables.
> "AI work done. USER tasks pending:
> - [deliverable description]
> Complete them, then `/scaffold:checkpoint`."

**Blocked:**
> "Blocked: [content of Blockers section].
> If resolved, continue working or `/scaffold:plan` to discuss direction."

**Otherwise:**
> "Active focus: [synopsis from state.md]. Next: [content of Next section].
> Continue working, or `/scaffold:plan` to recalibrate."

**USER deliverables in roadmap (regardless of other signals):**
If unchecked `[USER]` deliverables exist anywhere and weren't already the
primary route above, surface them as a note:
> "**Reminder:** [N] USER task(s) pending in Phase [N]."

---

## Boundaries

Status does NOT:
- **Write any files** — read-only
- **Make decisions** — presents state and options
- **Run other commands** — tells you what's available

Keep it short. This is a briefing, not a report. If everything is early/empty,
just say so and ask what the user wants to work on.
