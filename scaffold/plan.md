---
description: Strategic consultation — discuss direction, update roadmap, scope work, produce plan doc
argument-hint: [description]
---

**Precondition:** Verify that all five scaffold files exist: CLAUDE.md,
`.scaffold/project.md`, `.scaffold/state.md`, `.scaffold/roadmap.md`,
`.scaffold/decisions.md`. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

**Boundary:** This command does NOT modify non-scaffold files. No code changes.
No file creation outside `.scaffold/`. You will update scaffold files only.

---

## Precondition Guards

Read `.scaffold/state.md` Status field before proceeding.

**If status is `scoped`:**
> "You have scoped work that hasn't been executed. Re-plan (replaces scope)
> or run `/scaffold:do` first?"

Wait for explicit confirmation before proceeding. If the user says to run do
instead, stop.

**If status is `user-pending`:**
> "Unverified USER tasks from the current plan. Run `/scaffold:checkpoint`
> first to handle them, then re-plan."

Stop. Do not proceed.

**If status is `blocked`:**
> "State shows blocked: [reason from state.md]. Is this resolved?
> If yes, we'll plan forward. If not, let's address the blocker first."

Wait for confirmation. If the user says the blocker is resolved, proceed
(it will be cleared during this plan session or at checkpoint). If not,
help the user think through the blocker before planning.

---

## Behavioral Principle: User Comprehension

User comprehension is a prerequisite for forward progress. When the user
expresses uncertainty — "I don't understand", "help me understand", "I'm
not sure", "what does that mean", or any language signaling confusion —
that becomes the top priority before the planning flow continues.

**How to respond to expressed uncertainty:**

Use AskUserQuestion to offer 2-4 concrete aspects the user might be
uncertain about. Let them point to what needs clarification rather than
having to articulate it from scratch. Then address only what they selected.

**When presenting options and decisions throughout planning:**

Explain choices in terms of outcomes the user cares about, not
implementation details. If a concept is technical, lead with what it
means for the project in plain terms.

**What this does NOT mean:**

- Don't probe for hidden uncertainty — respond to expressed uncertainty
- If the user says "yes", "proceed", or gives a clear affirmative, move
  forward. Don't second-guess clear signals.
- Don't quiz after every statement — read the room
- Don't be patronizing — if they clearly understand, keep moving

---

## Check for Inline Description

If the user provided a description with the command (e.g.,
`/scaffold:plan fix the login redirect`), this is the **inline shortcut**.

1. Treat the description as the user's stated direction — skip Phase 2
   (consultation). The user already told you what they want.
2. Assess complexity silently: does this need more than 3 tasks,
   architectural decisions, or changes across multiple subsystems?
   - If yes: switch to full consultation. Say: "This looks bigger than a
     quick scope — [reason]. Let me walk through the full planning flow."
     Proceed to Phase 1 and Phase 2 as normal.
   - If no: run Phase 1 (triage) silently to read all files, then skip
     Phase 2 (consultation), proceed directly to Phase 3 with the
     description as direction.

---

## Phase 1: Triage (silent)

Read in this order. Do not present findings yet — just absorb context:
1. .scaffold/state.md — Status, Current Position, Next Action, Blockers,
   Open Questions, Session Context (if present)
2. .scaffold/roadmap.md — phase structure, `[IN-PROGRESS]` phase, task states
3. .scaffold/project.md — scope boundaries and success criteria
4. .scaffold/decisions.md — recent active decisions only
5. CLAUDE.md — constraints and tech stack

Scan `.scaffold/investigations/` — if the directory exists and contains files,
note them. Read any that look relevant based on filename.

If state.md has Session Context (resuming from a paused planning session),
read it to pick up the thread.

Assess (internally, for Phase 2):
- Which phase is `[IN-PROGRESS]`? What tasks are `[x]`, `>>`, or `[ ]`?
- Are there blockers or open questions that need resolving first?
- Are there blockers that are stale or already resolved?
- Are any scaffold files stale (>7 days since last update)?
- What kind of work is likely needed? (investigate / design / build / validate / debug)
- Are there investigation files that inform the current phase?

---

## Phase 2: Consult (interactive — WAIT for user)

**Skip this phase if inline shortcut is active.**

Present a brief structured assessment:

- **Where we are:** 1-2 sentences on current state (phase, recent completions)
- **What the docs suggest:** what roadmap/state point to as next work
- **Flags:** blockers (including stale/resolved ones), stale files,
  contradictions, open questions
- **Prior research:** if investigation files exist, note them briefly

Then ask:

> "That's what I see in the scaffold files. What are you thinking?
> Do you have a direction in mind, concerns, or ideas?"

**CRITICAL — Do NOT skip this step. Do NOT propose tasks yet.**

Even if the scaffold files make the next step obvious, the user may have:
- Context that isn't captured in the files
- Concerns about the current approach
- A completely different direction in mind
- Questions they need answered before deciding

Rationalizations that are NOT valid reasons to skip consultation:
- "The roadmap clearly says X is next" — the user may have changed their mind
- "This is a continuation of previous work" — the user may want to pivot
- "The task is simple enough to just start" — the user wants to understand first
- "I already know what to do from the files" — the files may be stale or incomplete

STOP. Wait for the user to respond before proceeding.

---

## Phase 3: Propose Roadmap Changes (interactive — user approves)

After the user shares their direction (or from the inline description),
restate it before proposing changes:

> "So the direction is [one-sentence restatement]. That right?"

Wait for confirmation. If the user corrects you, use their correction.
The user's stated direction overrides whatever the scaffold files suggest.

**Propose roadmap changes:**

Show proposed changes to roadmap.md:
- New tasks to add (and which phase)
- Tasks to reorder or move between phases
- Items to move to Backlog
- New phases to create
- Phase status changes (if applicable)

Format proposals clearly:
```
Proposed roadmap changes:
- Phase 2 — [Title]: add "Task X", add "Task Y"
- Backlog: move "Item Z" from Phase 3
```

For human-owned tasks, use the `[USER]` marker:
```
- [ ] [USER] Task description
```

**Wait for explicit approval before writing changes to roadmap.md.**

If the user modifies the proposal, incorporate their changes. Write the
approved changes to `.scaffold/roadmap.md`. Update the `<!-- Last updated -->`
date.

---

## Phase 4: Scope Work (interactive — user approves)

**Determine what kind of session this is:**
- Does the scope include AI tasks (code changes)? → execution session
- Does the scope include only `[USER]` tasks? → user-action session
- Is there no execution at all (just roadmap/state changes)? → state-only session
- Both AI and USER tasks? → mixed session

**If state-only session:** Skip to Phase 5.

**If execution or mixed session:**

From the roadmap tasks in the `[IN-PROGRESS]` phase, propose which tasks
are in scope for the next execute:

> "Which of these should be in scope?
> [list tasks with brief descriptions]
> All of them, or a subset?"

The user controls ambition level. Default to fewer tasks.
3 well-scoped tasks > 7 ambitious ones.

**Task sizing:**
- If a task can't be stated in 1-2 sentences, it's too big — break it down
- If you're uncertain whether a task fits, defer it
- Investigation tasks: cap at 2-3 focused questions per execute

Wait for the user to confirm scope.

**USER task boundary rule:**
Execute scope stops at the first `[USER]` task:
- AI tasks before the first `[USER]` task: scope those for execute. USER
  tasks appear in the plan doc but are outside execute scope.
- First task(s) are `[USER]` (no AI tasks before): user-action session.
- AI tasks after a `[USER]` task: deferred to next plan cycle. Note in
  plan doc Deferred section.

**First-time phase activation check:**
If this is the first execute targeting this phase (just promoted from
`[PLANNED]`), review task sequence and ask if the order makes sense.

---

## Phase 5: Write Plan Doc + Update State

**Write the plan doc** to `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`
(create the directory if needed).

**Naming convention:**
- `YYYYMMDD` — date without dashes
- `NN` — zero-padded sequence counter (scan `.scaffold/plans/` for existing
  files starting with today's date). First file of the day is 01.
- `phase-N` — primary phase number
- `slug` — brief descriptor

**Plan doc format:**

```markdown
# Plan: [brief title]
<!-- Generated: YYYY-MM-DD -->
<!-- Plan: .scaffold/plans/YYYYMMDD-NN-phase-N-slug.md -->

## Goal
[What and why — 1-3 sentences]

## Tasks
1. [Task title] — [done-when condition]
2. [Task title] — [done-when condition]
3. [USER] [Task title] — [done-when condition]

## Approach
[Key decisions, strategy, things to watch out for.
For simple tasks this is 1-2 sentences. For complex tasks it's a paragraph.]

## Deferred
[Items to route to roadmap at checkpoint. Omit section if none.]

## Decisions
[Decisions to log to decisions.md at checkpoint. Omit section if none.]
```

For investigation tasks, add to the task entry:
`Output: .scaffold/investigations/YYYYMMDD-NN-slug.md`

**For state-only sessions:** Omit the Tasks section. The plan doc records
what was discussed and changed. It serves as a session record.

**Update state.md:**
- Clear Session Context if present (planning picked up from pause — that
  context is now consumed)
- Status →
  - Execution/mixed session: `scoped`
  - State-only session: `idle`
  - User-action session: `user-pending`
- Current Position → reflect any roadmap changes made
- Next Action →
  - Execution/mixed: "Run `/scaffold:do`.
    Plan: `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`"
    If mixed, append: "After execution: `/scaffold:checkpoint`, then complete
    [N] user tasks and `/scaffold:checkpoint` again."
  - User-action: "User tasks pending. Complete them, then `/scaffold:checkpoint`.
    Plan: `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`"
  - State-only: "No execute needed — state documents updated.
    Run /scaffold:plan to determine next steps."
- Update Blockers and Open Questions if they changed during planning
- Update the `<!-- Last updated -->` date

**Update decisions.md** if decisions were made during planning (add entries
at the TOP, below header, above existing entries). Update its
`<!-- Last updated -->` date.

---

## Phase 6: Summary

Present what was updated and where:
- Roadmap changes written
- Plan doc location
- State.md updates

**Execution or mixed session:**
> "Planning complete. Execution will begin when you run `/scaffold:do`.
> Or `/clear` first for a fresh context window, then `/scaffold:status`
> and `/scaffold:do`."

**State-only session:**
> "Planning complete. State documents updated. Run `/scaffold:checkpoint`."

**User-action session:**
> "Planning complete. No AI execution needed. Complete the user tasks
> listed in the plan doc, then run `/scaffold:checkpoint`."

---

## Edge Cases

- **User wants something not on the roadmap:** User's direction wins.
  Add to roadmap during Phase 3.
- **User doesn't know what to work on:** Present options from roadmap and
  state, help them choose. Stay in Phase 2 until they have direction.
- **Files are stale:** Flag in Phase 2, suggest running checkpoint --audit
  first or updating files during this plan session.
- **Mid-planning pivot:** If the user changes direction during planning,
  restart from Phase 3 with the new direction. Don't carry stale proposals.
- **No codebase changes needed:** State-only path. Update roadmap/state,
  produce record document, done.

---

## Boundaries

Plan does NOT:
- **Modify non-scaffold files** — no code changes, no project files
- **Execute tasks** — that is /scaffold:do
- **Use plan mode** — all work happens in normal mode
- **Skip user consultation** — always consult the user (inline shortcut is the only defined exception)
