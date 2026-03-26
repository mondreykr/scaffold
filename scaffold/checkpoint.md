---
description: Save session progress — verify work, update scaffold files, commit
argument-hint: [--audit]
---

**Precondition:** Verify that CLAUDE.md, `.scaffold/state.md`, and
`.scaffold/roadmap.md` exist. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

**Boundary:** This command does NOT make code changes or modify project files.
You update scaffold files and commit only.

---

## Step 1: Assess Session State

Read `.scaffold/state.md`, `.scaffold/roadmap.md`, and CLAUDE.md.

If state.md references a plan doc in Next Action, read it for task verification
and routing.

Determine what kind of checkpoint this is:

**A. Full close-out** — All scoped deliverables are complete, or no scope existed
(freeform session). Proceed through all steps.

**B. Mid-session** — Scoped deliverables remain incomplete (state.md references a
plan doc, not all deliverables `[x]` in roadmap). Go to Step 2.

**C. No plan doc** — Freeform session. No plan doc exists. Skip plan doc routing
(Step 6). Update files from conversation context.

---

## Step 2: Mid-Session Handling

*Skip if full close-out or no scope.*

Ask:
> "Incomplete scoped work. What would you like to do?
> - **Pause** — Save context, continue next session
> - **Partial save** — Record what's done, keep scope active
> - **Abandon** — Done with this scope"

Wait for response.

**If Pause:**
Ask: "Anything I should note for next time? (Context, gotchas, where you
left off mentally — or just 'no'.)"

Wait for response. Then:
- Write Session Context to state.md (see format below)
- Set status to `paused`
- Preserve plan pointer in Next Action
- Skip Steps 3-6. Go directly to Step 7 (Review) and Step 8 (Commit).

**If Partial save:**
- Mark completed deliverables `[x]` in roadmap with today's date
- Keep status as `scoped`
- Preserve plan pointer
- Clear Session Context if present (stale — roadmap now reflects progress)
- Skip Step 3. Proceed to Step 5 (partial updates), then Steps 7-8.

**If Abandon:**
- Mark completed deliverables `[x]` in roadmap with today's date
- Clear plan pointer from Next Action
- Set status to `idle`
- Proceed to Step 5, then Steps 7-8.

**Session Context format:**
```markdown
## Session Context
<!-- Written by checkpoint mid-session. Cleared on full close-out. -->
**Progress:** [What's done vs remaining — reference deliverable names]
**Key context:** [Approach notes, gotchas, discoveries]
**Next step:** [Concrete next action when resuming]
```

---

## Step 3: USER Task Check

*Skip if mid-session pause or partial save.*

Scan the `[IN-PROGRESS]` phase in roadmap.md for unchecked `[USER]` deliverables.

If none exist, skip to Step 4.

If unchecked `[USER]` deliverables exist:

> "Phase [N] has pending USER tasks:
> - [deliverable description]
> Completed any? (Say 'not yet' to skip.)"

**If user says "not yet":**
Proceed with standard checkpoint. Preserve plan pointer if one exists.

**If user confirms completion:**
Walk through each completed `[USER]` deliverable one at a time:

For each:
1. Present what was expected (from plan doc's done-when criteria if available,
   or from roadmap description)
2. If done-when criteria reference specific file paths, check whether they exist.
   Report: "Found: [path]" or "Missing: [path]"
3. Ask: "Task: [title]. Did you complete this? What happened?"
4. Process response:
   - **Pass** — user confirms, consistent with criteria. Mark `[x]` in roadmap.
   - **Issue** — completed but something went wrong. Ask: "Blocker or follow-up task?"
   - **Not done** — leave `[ ]`.

**GATE: Resolve each USER task before moving to the next.**

---

## Step 4: Verify AI Work

*Skip if no code changes were made this session.*

Before updating scaffold files, verify claims:

1. **If tests exist** (package.json scripts, Makefile, pytest, etc.):
   - Run them. If they fail, report.
   - Do NOT mark done if tests fail.
   - User decides: fix now, or checkpoint with issues noted.

2. **Evidence-based updates:**
   - `[x]` requires evidence (test output, observed behavior, user confirmation).
   - Removing a blocker requires evidence it's resolved.
   - "It should work" is NOT evidence.

3. **If verification isn't possible:**
   - Note honestly: "Completed X — not yet verified (no tests)"

---

## Step 5: Update Scaffold Files

### 5a. `.scaffold/roadmap.md` (always update)

- Mark completed deliverables `[x]` with date: `- [x] Deliverable (YYYY-MM-DD)`
- Mark verified USER deliverables `[x]`: `- [x] [USER] Deliverable (YYYY-MM-DD)`
- Update progress sub-bullets on in-progress deliverables
- Route deferred items from plan doc (only on full close-out — see Step 6)

**Phase sign-off gate:**
If ALL deliverables in the `[IN-PROGRESS]` phase are `[x]`, AND all phase
criteria are met, ask:

> "All Phase N deliverables complete. Phase criteria:
> 1. [criterion] — met/not met
> 2. [criterion] — met/not met
> Mark Phase N as [COMPLETE] and promote Phase N+1?"

Wait for explicit approval.

- Update the `<!-- Last updated -->` date

### 5b. `.scaffold/state.md` (always update)

- Status → determined by outcome:
  - Full close-out, all done: `idle`
  - Full close-out, USER tasks remain: `user-pending`
  - Pause: `paused`
  - Partial save: `scoped`
  - Abandon: `idle`
  - Blocker discovered: `blocked`
- Current Position → reflect what was accomplished
- Next Action →
  - If `idle`: "Run /scaffold:plan or start working."
  - If `scoped`: preserve plan pointer
  - If `paused`: preserve plan pointer
  - If `user-pending`: "USER tasks pending: [list]. Complete, then checkpoint.
    Plan: [plan file path]"
  - If `blocked`: note blocker and suggest resolution
- Clear Session Context on full close-out. Preserve on pause. Clear on partial save (stale).
- Update Blockers — add new, remove resolved
- **Resolved blocker routing:** For each blocker removed, add to decisions.md
  (Category: Resolved Blocker)
- Update Open Questions
- Update `<!-- Last updated -->` date

### 5c. `.scaffold/decisions.md` (if decisions were made)

- Add new entries at TOP (below header, above existing)
- Include decisions from session conversation
- Skip trivial decisions
- If status changed (Active → Reversed), move to `## Archived`
- If 20+ active entries, suggest archiving older stable ones
- Update `<!-- Last updated -->` date

### 5d. `.scaffold/project.md` (if requirements confirmed or vision evolved)

- Update Requirements section if new requirements confirmed
- Update vision/scope if they evolved
- Update `<!-- Last updated -->` date

### 5e. CLAUDE.md (if structural things changed)

- Update Tech stack or Hard constraints if changed

---

## Step 6: Plan Doc Routing

*Only on full close-out with a plan doc. Skip on pause, partial, or abandon.*

**Check for incomplete USER tasks first.**
If any `[USER]` deliverables from the plan doc are NOT `[x]` in roadmap:
- Do NOT route Deferred or Decisions from the plan doc
- Preserve plan pointer
- Session decisions (from conversation, not plan doc) are still logged in Step 5c

**If no incomplete USER tasks:**
- **Deferred section** → route to roadmap phases or Backlog as specified
- **Decisions section** → route to decisions.md (if not already logged in Step 5c)
- **Investigation outputs** → verify files exist in `.scaffold/investigations/`
- Clear plan pointer from state.md

---

## Step 7: Review Before Committing

- Re-read all updated files. Flag contradictions.
- Run `git diff .scaffold/` to see changes
- Show what was added, removed, reworded per file
- Ask: "Checkpoint changes ready. Anything to adjust?"
- Wait for confirmation. Only commit after approval.

---

## Step 8: Commit

If git is initialized:
`git add CLAUDE.md .scaffold/ && git commit -m "checkpoint: [brief summary]"`

If commit fails, show error and stop.

List open questions or loose threads for next session.

**Artifact detection:** Check if the session produced major artifacts that
should be integrated into scaffold — specs (completed SPEC.md files),
architecture documents, design system docs, or substantial research findings
that go beyond a single investigation. If detected:

> "This session produced [artifact description]. Consider running
> `/scaffold:integrate [path]` to absorb it into scaffold."

This is a suggestion, not a gate. The user decides whether and when to integrate.

**Route to next:** Present options based on resulting state.
- If `idle`: "Run `/scaffold:plan`, start working, or done for now."
- If `scoped`: "`/scaffold:do` or 'go ahead' to continue."
- If `paused`: "Next session, `/scaffold:status` picks up."
- If `user-pending`: "Complete your tasks, then checkpoint again."
- If `blocked`: "Resolve [blocker], then `/scaffold:plan`."

---

## Enhanced Mode (`/scaffold:checkpoint --audit`)

After standard checkpoint completes (including commit), launch an Explore
subagent (thoroughness: "very thorough") to verify scaffold claims:

1. Done items — do they exist in the code?
2. In progress items — recent changes or uncommitted work?
3. Blockers — evidence in the code?
4. Tech stack — matches actual dependencies?
5. Decisions — match what the code does?

Report discrepancies. Do NOT modify files — report only.

---

## Boundaries

Checkpoint does NOT:
- **Make code changes** — verifies and records, not implements
- **Make strategic decisions** — plan does that
- **Execute tasks** — do does that, or freeform collaboration
- **Guess at outcomes** — evidence or user confirmation required
