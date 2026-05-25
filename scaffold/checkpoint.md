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

If state.md's `## Next` references a plan doc in `.scaffold/plans/`, read
that plan doc for task verification and routing.

Determine what kind of checkpoint this is:

**A. Full close-out** — All scoped deliverables are complete, or no plan doc
was active (freeform session). Proceed through all steps.

**B. Mid-session** — Plan doc is active and scoped deliverables remain
incomplete (state.md's Next references a plan doc; not all deliverables
`[x]` in roadmap). Go to Step 2.

**C. No plan doc** — Freeform session, no plan doc was active. Skip plan
doc routing (Step 6). Update files from conversation context.

---

## Step 2: Mid-Session Handling

*Skip if full close-out or no plan doc was active.*

Ask:
> "Incomplete scoped work. What would you like to do?
> - **Pause** — Save current state, continue next session
> - **Partial save** — Record what's done, keep plan doc active
> - **Abandon** — Done with this scope"

Wait for response.

**If Pause:**
Ask: "Anything I should note for next time? (Context, gotchas, where you
left off mentally — or just 'no'.)"

Wait for response. Then:
- Update state.md's **Active focus** to reflect the paused situation —
  fold the user's response into the paragraph (progress / where their head
  was / what to pick up). One paragraph; no separate Session Context section.
- Update state.md's **Next** with the concrete resume action.
- Preserve the plan-doc reference in Next.
- Skip Steps 3-6. Go directly to Step 7 (Review) and Step 8 (Commit).

**If Partial save:**
- Mark completed deliverables `[x]` in roadmap with today's date.
- Update state.md's Active focus to reflect progress.
- Preserve the plan-doc reference in Next.
- Skip Step 3. Proceed to Step 5 (partial updates), then Steps 7-8.

**If Abandon:**
- Mark completed deliverables `[x]` in roadmap with today's date.
- Clear the plan-doc reference from state.md's Next; replace with a brief
  pointer to the new direction (or "Run /scaffold:plan to determine next steps.").
- Update Active focus to reflect that the scope was abandoned and why.
- Proceed to Step 5, then Steps 7-8.

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

State is forward-looking. Four sections only: Active focus, Next, Blockers,
Open Questions. No status field, no Session Context.

- **Active focus** — one paragraph. Synopsis of where the work sits and
  what's in flight. Rewrite to reflect this session's outcome.
  Forward-looking, not retrospective journaling.
  **ELI5 — explain it like the reader is five.** Plain words, short
  sentences, no jargon shortcuts, no status-report officialese. If a
  five-year-old wouldn't follow the gist, rewrite it.
- **Next** — concrete next action.
  - Full close-out, all done: "Run /scaffold:plan or start working."
  - Pause / partial save: preserve plan-doc reference + name the concrete
    resume step.
  - USER tasks pending after AI work: "USER tasks pending: [list].
    Complete, then `/scaffold:checkpoint`. Plan: [plan file path]"
  - Abandon: brief pointer to new direction.
- **Blockers** — add new (write the blocking condition). Remove resolved
  ones (do not retain a "Closed" archive). For each resolved blocker, add
  to decisions.md (Category: Resolved Blocker) so the resolution lives
  somewhere durable. If no blockers, write "None."
- **Open Questions** — add new, remove answered. Answered questions: the
  answer is captured in the artifact, decision, or conversation that
  resolved it; no need to retain in state. If no open questions, write
  "None."
- Update `<!-- Last updated -->` date.

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
- Preserve the plan-doc reference in state.md's Next
- Session decisions (from conversation, not plan doc) are still logged in Step 5c

**If no incomplete USER tasks:**
- **Deferred section** → route to roadmap phases or Backlog as specified
- **Decisions section** → route to decisions.md (if not already logged in Step 5c)
- **Investigation outputs** → verify files exist in `.scaffold/investigations/`
- Clear the plan-doc reference from state.md's Next (replace with the full-close-out Next per Step 5b)

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

**Route to next:** Present options based on resulting content.
- If plan doc still active (paused/partial): "Next session, `/scaffold:status`
  picks up. Or `/scaffold:do` to resume now."
- If USER tasks pending: "Complete your tasks, then checkpoint again."
- If blockers present: "Resolve [blocker summary], then `/scaffold:plan`."
- Otherwise: "Run `/scaffold:plan`, start working, or done for now."

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
