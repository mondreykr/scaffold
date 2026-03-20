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

If state.md references a plan doc in Next Action, read it. You'll need it
for task verification and routing.

Determine what kind of checkpoint this is:

**A. Full close-out** — All scoped tasks are complete (or no tasks were scoped).
Proceed through all steps below.

**B. Mid-session** — Scoped tasks remain incomplete (state.md Next Action has
a plan pointer, but not all tasks are `[x]` in roadmap). Go to Step 2
(Mid-Session Handling) first.

**C. No plan doc** — No plan doc exists. The user worked without running plan,
or this is a state-only checkpoint. Skip plan doc routing. Proceed through
verification and file updates based on conversation context.

---

## Step 2: Mid-Session Handling

*Skip this step if all scoped tasks are complete or no tasks were scoped.*

Ask:
> "You have incomplete scoped tasks. What would you like to do?
> - **Pause** — Save context, I'll continue next session
> - **Partial save** — Record what's done, keep scope active
> - **Abandon** — I'm done with this scope"

Wait for response.

**If Pause:**
Ask: "Anything I should note for next time? (Context, gotchas, where you
left off mentally — or just 'no'.)"

Wait for response. Then:
- Write Session Context to state.md (see Session Context format below)
- Set status to `paused`
- Preserve plan pointer in Next Action
- Skip Steps 3-6. Go directly to Step 7 (Review) and Step 8 (Commit).

**If Partial save:**
- Mark completed tasks `[x]` in roadmap with today's date
- Keep status as `scoped`
- Preserve plan pointer in Next Action
- Clear Session Context if present (it's now stale — roadmap reflects current progress)
- Skip Step 3 (USER tasks). Proceed to Step 5 (Update Files) with
  partial updates only, then Step 7 and 8.

**If Abandon:**
- Mark completed tasks `[x]` in roadmap with today's date
- Clear plan pointer from Next Action
- Set status to `idle`
- Proceed to Step 5 (Update Files), then Step 7 and 8.

**Session Context format** (written to state.md during pause):
```markdown
## Session Context
<!-- Written by checkpoint mid-session. Cleared on full close-out. -->
**Progress:** [What's done vs remaining — reference specific task names]
**Key context:** [Approach notes, gotchas, discoveries from user + session]
**Next step:** [Concrete next action when resuming]
```

---

## Step 3: USER Task Check

*Skip if mid-session pause or partial save.*

Scan the `[IN-PROGRESS]` phase in roadmap.md for unchecked `[USER]` tasks.

If none exist, skip to Step 4.

If unchecked `[USER]` tasks exist:

> "Phase [N] has pending USER tasks:
> - [task description]
> - [task description]
> Completed any? (Say 'not yet' to skip.)"

**If user says "not yet":**
Proceed with standard checkpoint. Preserve plan pointer if one exists.
USER tasks remain unchecked.

**If user confirms completion:**
Walk through each completed `[USER]` task one at a time:

For each task:
1. Present what was expected (from plan doc's done-when criteria if available,
   or from roadmap task description)
2. If the done-when criteria reference specific file paths or artifacts,
   check whether they exist. Report: "Found: [path]" or "Missing: [path]"
3. Ask: "Task: [title]. Did you complete this? What happened?"
4. Process the response:
   - **Pass** — user confirms, consistent with done-when criteria.
     Will mark `[x]` in roadmap.
   - **Issue** — completed but something went wrong. Ask: "Should this be a
     blocker (blocks further work) or a follow-up task (add to roadmap)?"
   - **Not done** — leave `[ ]` in roadmap.

**GATE: Do not proceed to the next USER task until the current one is resolved.**

---

## Step 4: Verify AI Work

*Skip if no code changes were made this session.*

Before updating scaffold files, check that claims about this session's work
are accurate:

1. **If code was changed and test/lint/build commands exist** (check
   package.json scripts, Makefile, pytest, cargo test, go test, etc.):
   - Run them. If they fail, report results to the user.
   - Do NOT record work as "done" in roadmap if tests are failing.
   - Let the user decide: fix now, or checkpoint with issues noted in state.md.

2. **Evidence-based updates:**
   - Moving a task to `[x]` in roadmap requires evidence it works (test output,
     observed behavior, or user confirmation).
   - Removing an item from "Blockers" requires evidence the blocker is resolved.
   - "It should work" or "I didn't change anything that would break it" is NOT
     evidence. Run verification if possible.

3. **If verification is not possible** (no tests, can't run the app, etc.):
   - Note this honestly in state.md: "Completed X — not yet verified (no tests)"
   - Do NOT claim verified completion.

If verification reveals issues, present them before proceeding. Let the user
decide whether to fix now or note and move on.

---

## Step 5: Update Scaffold Files

Review everything done and discussed this session. Then update files:

### 5a. `.scaffold/roadmap.md` (always update)

- Mark completed tasks `[x]` with completion date: `- [x] Task name (YYYY-MM-DD)`
- Mark verified USER tasks `[x]`: `- [x] [USER] Task name (YYYY-MM-DD)`
- Update or remove `>>` markers on tasks no longer in progress
- Route deferred items from plan doc to appropriate phase or Backlog
  (only on full close-out with no incomplete USER tasks — see Step 6)

**Phase sign-off gate:**
If ALL tasks in the `[IN-PROGRESS]` phase are now `[x]`, ask the user:

> "All Phase N tasks complete. Mark Phase N as [COMPLETE] and promote
> Phase N+1 to [IN-PROGRESS]?"

Wait for explicit approval before changing phase status.

- Update the `<!-- Last updated: YYYY-MM-DD -->` comment at the top

### 5b. `.scaffold/state.md` (always update)

- Status → determined by checkpoint type:
  - Full close-out, all done: `idle`
  - Full close-out, USER tasks remain: `user-pending`
  - Pause: `paused`
  - Partial save: `scoped`
  - Abandon: `idle`
  - Blocker discovered: `blocked`
- Current Position → reflect what was accomplished this session
- Next Action →
  - If `idle`: "Run /scaffold:plan to determine next steps."
  - If `scoped`: preserve plan pointer
  - If `paused`: preserve plan pointer
  - If `user-pending`: "User tasks pending: [list]. Complete them,
    then run /scaffold:checkpoint. Plan: [plan file path]"
  - If `blocked`: note the blocker and suggest resolution path
- Clear Session Context on full close-out. Preserve on pause/partial.
- Update Blockers — add new blockers, remove resolved ones
- **Resolved blocker routing:** For each blocker removed, add an entry to
  `.scaffold/decisions.md` with Category: Resolved Blocker
- Update Open Questions — add new ones, remove answered ones
- Update the `<!-- Last updated -->` date

### 5c. `.scaffold/decisions.md` (update only if decisions were made)

- Add new entries at the TOP of the file (below header, above existing entries)
  with today's date, category, context, decision, reasoning, and status
- Include decisions made during this session (from conversation context)
- Skip trivial decisions (variable names, minor styling)
- If a decision's status changed (Active → Revisiting or Reversed), update
  in place. If Reversed, move to `## Archived` section.
- If 20+ active entries: suggest archiving older stable ones
- If updated, update the `<!-- Last updated -->` date

### 5d. `.scaffold/project.md` (update only if vision/scope evolved)

- Update "What is this?" if understanding sharpened
- Update "Scope boundaries" if inclusions/exclusions changed
- Update "What does success look like?" if the goal shifted
- If updated, update the `<!-- Last updated -->` date

### 5e. CLAUDE.md (update only if structural things changed)

- Update "Tech stack" if technologies added or changed
- Update "Hard constraints" if new constraints emerged
- Skip if nothing structural changed

---

## Step 6: Plan Doc Routing

*Only on full close-out. Skip on pause, partial save, or abandon.*

If a plan doc exists, read it for routing:

**Check for incomplete USER tasks first.**
If any `[USER]` tasks from the plan doc are NOT marked `[x]` in roadmap:
- Do NOT route Deferred Items or Decisions from the plan doc
- Preserve plan pointer in state.md
- These will be routed when USER tasks are verified in a future checkpoint
- Note: decisions made during the current session (not from the plan doc)
  are still logged in Step 5c regardless.

**If no incomplete USER tasks (or no USER tasks at all):**
- **Deferred section** → route each item to the appropriate roadmap phase
  or Backlog as specified
- **Decisions section** → route each to decisions.md (if not already logged
  in Step 5c)
- **Investigation tasks with Output fields** → verify the output files exist
  in `.scaffold/investigations/`. Note in summary if found.
- Clear the plan pointer from state.md Next Action

---

## Step 7: Review Before Committing

- Re-read all updated files. Flag any contradictions between them.
- Run `git diff .scaffold/` to see what changed
- For each file updated, show the specific changes:
  - What was added
  - What was removed
  - What was reworded
- Present the changes and ask:
  > "These are the checkpoint changes. Anything to adjust before I commit?"
- Wait for confirmation before proceeding to git commit
- If the user requests changes, make them and show the updated diff
- Only commit after explicit approval

---

## Step 8: Commit

If git is initialized:
`git add CLAUDE.md .scaffold/ && git commit -m "checkpoint: [brief summary of session]"`

If the commit fails, show the error and stop. Don't retry automatically.

List any open questions or loose threads heading into next session.

**Route to next action:**
- If `idle`: "Run `/scaffold:plan` to determine next steps."
- If `scoped`: "Run `/scaffold:do` to continue execution."
- If `paused`: "Next session, `/scaffold:status` will pick up where you left off."
- If `user-pending`: "Complete your tasks, then `/scaffold:checkpoint`."
- If `blocked`: "Resolve [blocker], then `/scaffold:plan`."

---

## Enhanced Mode (`/scaffold:checkpoint --audit`)

If "--audit" appears in the arguments, after the standard checkpoint completes
(including user approval and git commit), launch an Explore subagent
(thoroughness: "very thorough") to verify scaffold claims against the codebase:

1. **Done items** — Do completed roadmap items actually exist in the code?
2. **In progress items** — Do they have recent changes or uncommitted work?
3. **Blockers** — Can you find evidence of these issues in the code?
4. **Tech stack** — Does CLAUDE.md's tech stack match actual dependencies?
5. **Decisions** — Do active decisions match what the code actually does?

Report discrepancies: "Audit found N issues:" followed by specifics.
Do NOT modify scaffold files — report only, let the user decide what to fix.

---

## Boundaries

Checkpoint does NOT:
- **Make code changes** — it verifies and records, not implements
- **Make strategic decisions** — that is plan's job
- **Execute tasks** — that is do's job
- **Guess at outcomes** — evidence or user confirmation required
