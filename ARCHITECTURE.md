# Essentials Scaffold v2 — Architecture

This is the controlling document for the scaffold system. All commands, workflows, and file behaviors derive from what's defined here.

## Design Principles

1. **State machine.** Every command leaves all state documents accurate and self-consistent. Any command could be the last thing that runs before a week-long gap.
2. **Four deterministic paths.** All work follows one of four defined workflows. No ad-hoc paths.
3. **No plan mode.** All commands run in normal mode. Plan mode (Shift+Tab) is not used or required.
4. **Ceremony scales with complexity.** Plan can take 30 seconds or 30 minutes. Same command, same path, different weight.
5. **A place for everything.** Every piece of information has exactly one canonical home. Documents don't duplicate each other.

## Files

### Core files (5)

| File | Purpose | Updated by |
|------|---------|------------|
| `CLAUDE.md` | Hub — identity, rules, constraints, tech stack. Auto-read by Claude. | setup, checkpoint (rare) |
| `.scaffold/project.md` | Vision — what you're building, for whom, success criteria. | setup, checkpoint (rare) |
| `.scaffold/state.md` | Status — current position, scope, next action, blockers. | plan, checkpoint |
| `.scaffold/roadmap.md` | Progress — phase-grouped tasks with completion tracking. | plan, checkpoint |
| `.scaffold/decisions.md` | Record — decisions logged chronologically, newest first. | plan, checkpoint |

### Artifact directories

| Directory | Contents | Created by |
|-----------|----------|------------|
| `.scaffold/plans/` | Plan documents. One per planning session. | plan |
| `.scaffold/investigations/` | Durable research findings. | do (during investigation tasks) |

### Removed from v1

| Removed | Reason |
|---------|--------|
| `.scaffold/quick/` | Quick tasks use the main workflow. Plan scales down for simple tasks. |
| `.scaffold/continue-here.md` | Pause state captured in state.md Session Context by checkpoint. |

## Commands

### Workflow commands (3)

#### `/scaffold:plan`

**Purpose:** Strategic consultation. Discuss direction, update roadmap, scope work, produce plan doc.

**Reads:** All 5 core files. `.scaffold/investigations/` if relevant. Session Context in state.md if state is `paused` (to pick up planning thread).

**Writes:**
- `.scaffold/roadmap.md` — new/reordered tasks, phase changes
- `.scaffold/state.md` — status, scope, next action pointer
- `.scaffold/decisions.md` — if decisions made during planning
- `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md` — plan document (always)

**Boundary:** Plan does NOT modify non-scaffold files. No code changes. No file creation outside `.scaffold/`. This is enforced in the command text.

**Precondition guards:**
- If state is `scoped`: "You have scoped work that hasn't been executed. Re-plan (replaces scope) or run /scaffold:do first?" Wait for confirmation before proceeding.
- If state is `user-pending`: "Unverified USER tasks from the current plan. Run /scaffold:checkpoint first to handle them, then re-plan." Stop.

**Ends with:**
- Execution session (AI tasks scoped): `"Run /scaffold:do."` State → `scoped`.
- State-only session (no tasks): `"Run /scaffold:checkpoint."` State → `idle`.
- User-action session (only USER tasks): `"Complete your tasks, then /scaffold:checkpoint."` State → `user-pending`.
- Mixed session (AI + USER tasks): `"Run /scaffold:do."` State → `scoped`. Plan notes USER tasks follow after AI execution.

**Inline description shortcut:** If the user provides a description with the command (e.g., `/scaffold:plan fix the login redirect`), plan abbreviates the consultation: skip the interactive consult phase, treat the description as the user's direction, scope it, produce a lightweight plan doc. Same output format, faster path. Even in inline mode, plan assesses complexity — if the work needs more than 3 tasks, architectural decisions, or multi-system changes, switch to full consultation and tell the user why.

**Plan doc format (v2):**

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

Investigation tasks add `Output: .scaffold/investigations/YYYYMMDD-NN-slug.md` to their entry.

**State-only sessions** (no execution): plan doc records what was discussed/changed. Tasks section is omitted. Plan sets state.md status to `idle`.

---

#### `/scaffold:do`

**Purpose:** Execute scoped work. Research, propose approach, get approval, execute.

**Reads:**
- `.scaffold/state.md` — scope and next action pointer
- Plan doc referenced in state.md (if exists)
- `.scaffold/roadmap.md` — task details
- `CLAUDE.md` — constraints

**Writes:** Project files only (code, configs, etc.). MAY write investigation outputs to `.scaffold/investigations/` for investigation tasks.

**Boundary:** Do does NOT update core scaffold files (state.md, roadmap.md, decisions.md, project.md, CLAUDE.md). That is checkpoint's job. This separation prevents conflicts and keeps document ownership clear.

**Precondition:** state.md Next Action must reference a plan doc. If not: `"No scoped work. Run /scaffold:plan first."`

**Execution sequence:**
1. Read plan doc and scope
2. If Session Context exists in state.md (resuming from pause), read it — understand which tasks are done and where to resume
3. Check roadmap for tasks already marked `[x]` — skip completed tasks
4. Research codebase for the scoped tasks
5. Present approach: "Here's how I'll implement these [N] tasks: [approach]. Approve?"
6. Wait for user approval
7. Execute one task at a time
8. After each task, briefly confirm: "Task N done. Moving to task N+1."
9. When all tasks complete: `"Run /scaffold:checkpoint."`

**Scope control:** "These tasks are your scope. Do not expand beyond them. If you discover out-of-scope work, note it for checkpoint but do not act on it. If the user asks for work outside scope, confirm: 'That's outside the current scope. Should I add it to the plan, or do it now and note it for checkpoint?'"

**Escape hatch:** If a task turns out to be bigger than expected (needs architectural decisions, touches unexpected systems), stop and say: `"This is more complex than planned. [explain]. Suggest re-running /scaffold:plan to re-scope."`

**Context window awareness:** If context is running low mid-execution, complete the current task, then suggest checkpoint before starting the next: `"Context is getting long. Suggest running /scaffold:checkpoint to save progress, then /clear and /scaffold:status to continue fresh."`

**Competing context override:** If plan was run earlier in the same session, do's opening instruction explicitly overrides: "Any previous planning instructions in this conversation are complete. You are now in execution mode under /scaffold:do."

---

#### `/scaffold:checkpoint`

**Purpose:** Verify work, update all scaffold files, commit. Also handles mid-session pause and USER task verification.

**Reads:** All 5 core files. Plan doc (if referenced in state.md). Git diff.

**Writes:**
- `.scaffold/roadmap.md` — mark tasks complete, update markers, route deferred items
- `.scaffold/state.md` — status, position, next action, blockers, Session Context
- `.scaffold/decisions.md` — new decisions, resolved blockers
- `.scaffold/project.md` — if vision/scope evolved (rare)
- `CLAUDE.md` — if tech stack or constraints changed (rare)

**Verification rules (from v1, unchanged):**
- Evidence-based: moving a task to `[x]` requires evidence (test output, observed behavior, user confirmation)
- If tests exist, run them. Don't mark done if tests fail.
- If verification isn't possible, note it honestly.

**USER task handling:**
When checkpoint detects unchecked `[USER]` tasks in the current phase:

> "Phase N has pending USER tasks:
> - [task description]
> Completed any? (Say 'not yet' to skip.)"

- If user says "not yet" → proceed with standard checkpoint, preserve plan pointer
- If user confirms → gated walkthrough (same as v1 verify): present done-when criteria, confirm each task, mark `[x]` or note issues

**Mid-session mode:**
Checkpoint detects incomplete scoped tasks (state.md Next Action still has a plan pointer, not all tasks `[x]`). When this happens:

- Ask: "You have incomplete scoped tasks. What would you like to do?"
  - **Pause** — "Save context, I'll continue next session." → Write Session Context, set status to `paused`, preserve plan pointer, commit.
  - **Partial save** — "Record what's done, keep scope active." → Mark completed tasks `[x]`, status stays `scoped`, no Session Context, preserve plan pointer, commit.
  - **Abandon scope** — "I'm done with this scope." → Mark completed tasks `[x]`, clear plan pointer, status `idle`, commit.

Before writing Session Context (pause mode), ask: "Anything I should note for next time? (Context, gotchas, where you left off mentally — or just 'no'.)"

**Session Context** (written during mid-session/pause):
```markdown
## Session Context
<!-- Written by checkpoint mid-session. Cleared on full close-out. -->
**Progress:** [What's done vs remaining]
**Key context:** [Approach notes, gotchas, discoveries]
**Next step:** [Concrete next action when resuming]
```

**Plan doc routing** (on full close-out):
- Deferred Items → route to roadmap phases or Backlog
- Decisions → route to decisions.md
- Investigation outputs → verify files exist in `.scaffold/investigations/`

If USER tasks remain incomplete, defer plan doc routing (Deferred Items and Decisions sections) until USER tasks are verified. Decisions made during the current session (not from the plan doc) should still be logged regardless.

**Phase sign-off gate (from v1, unchanged):**
If all tasks in the `[IN-PROGRESS]` phase are `[x]`, ask for explicit approval before marking `[COMPLETE]` and promoting the next phase.

**Commit:** `git add CLAUDE.md .scaffold/ && git commit -m "checkpoint: [brief summary]"`

**Enhanced mode:** `/scaffold:checkpoint --audit` runs an Explore subagent after commit to verify scaffold claims against codebase (same as v1).

---

### Entry point

#### `/scaffold:status`

**Purpose:** Orient. Read scaffold files, present briefing, route to next action.

**Reads:** CLAUDE.md, project.md, state.md, roadmap.md. If state.md references a plan doc, reads it for scope details. Detects investigations.

**Writes:** Nothing. Status is read-only.

**Routing logic** (based on state.md):

| State | Status says | Route |
|-------|------------|-------|
| `idle` | "No active scope." | "Run `/scaffold:plan` to scope work." |
| `scoped` | "Scoped work ready: [tasks from plan doc]." | "Run `/scaffold:do` to execute." |
| `paused` (has plan doc) | "Paused session from [date]. [Session Context]." | "Run `/scaffold:do` to continue, or `/scaffold:plan` to re-scope." |
| `paused` (no plan doc) | "Paused mid-planning from [date]. [Session Context]." | "Run `/scaffold:plan` to continue." |
| `user-pending` | "AI work done. USER tasks pending: [list]." | "Complete tasks, then `/scaffold:checkpoint`." |
| `blocked` | "Blocked: [reason]." | "Resolve blocker. If scope is still valid, `/scaffold:do`. Otherwise `/scaffold:plan`." |

**Health check, staleness check, investigation scan, USER task scan:** Same as v1.

---

### Utility commands (4)

| Command | Purpose | Changes from v1 |
|---------|---------|-----------------|
| `/scaffold:setup` | Initialize scaffold files and SessionStart hook | Updated CLAUDE.md template (new Working section, updated command references) |
| `/scaffold:update` | Pull latest commands | No change |
| `/scaffold:cleanup` | Migrate old formats | Updated to handle v1→v2 migration |
| `/scaffold:graduate` | Exit scaffold, create snapshot, archive | Updated file list |

## Workflows

### Path 1: Plan + Execute (most common)

```
status → plan → do → checkpoint
```

**When:** New work needs scoping and executing.

**State transitions:** `idle` → `scoped` → `idle`

**Document flow:**
1. status reads files, routes to plan
2. plan writes roadmap + state.md + plan doc
3. do reads plan doc, executes, writes project files
4. checkpoint verifies, writes roadmap + state.md + decisions.md, commits

### Path 2: Plan Only (thinking session)

```
status → plan → checkpoint
```

**When:** Roadmap restructuring, brainstorming, no code changes.

**State transitions:** `idle` → `idle`

**Document flow:**
1. status reads files, routes to plan
2. plan writes roadmap + state.md + decisions.md (state-only plan doc)
3. checkpoint writes state.md + decisions.md, commits

### Path 3: Execute Only (continuation)

```
status → do → checkpoint
```

**When:** Resuming scoped work from a previous session (after /clear, after pause, next day).

**State transitions:** `scoped` → `idle` (or `paused` → `idle`)

**Document flow:**
1. status reads files, detects existing scope, routes to do
2. do reads plan doc, executes, writes project files
3. checkpoint verifies, writes roadmap + state.md + decisions.md, commits

### Path 4: Verify Only (USER task completion)

```
status → checkpoint
```

**When:** User completed their human tasks (deploy, manual testing, etc.) and needs to verify them.

**State transitions:** `user-pending` → `idle` (or `user-pending` → `blocked` if issues)

**Document flow:**
1. status reads files, detects user-pending state, routes to checkpoint
2. checkpoint walks through USER tasks, verifies each, updates roadmap + state.md, commits

### /clear handling

If user `/clear`s between any steps, run status to re-orient. Status reads the files and routes correctly regardless of what was in conversation context.

```
status → plan → /clear → status → do → checkpoint
```

### Pause handling

User says "pause" or "I need to stop" at any point. CLAUDE.md Session Protocol routes to checkpoint. Checkpoint detects incomplete work and writes Session Context.

```
status → plan → do → [pause] → checkpoint(mid-session) → ... → status → do → checkpoint
```

## State Machine

### States (state.md Status field)

| State | Meaning | Next action |
|-------|---------|-------------|
| `idle` | No active scope | `/scaffold:plan` |
| `scoped` | Plan completed, scope set, awaiting execution | `/scaffold:do` |
| `user-pending` | AI work done, USER tasks remain | Complete tasks → `/scaffold:checkpoint` |
| `paused` | Mid-work stop, Session Context has details | `/scaffold:do` or `/scaffold:plan` |
| `blocked` | Something prevents progress | Resolve → `/scaffold:plan` |

### Transitions

```
idle ──plan──→ scoped          (execution session)
idle ──plan──→ idle            (state-only session)
idle ──plan──→ user-pending    (user-action only session)
scoped ──plan──→ scoped        (re-scoped, user confirmed abandoning old scope)
scoped ──do+checkpoint──→ idle          (all work done)
scoped ──do+checkpoint──→ user-pending  (AI done, USER remains)
scoped ──checkpoint──→ paused           (mid-session pause)
scoped ──checkpoint──→ scoped           (partial save, some tasks done, scope continues)
scoped ──checkpoint──→ idle             (abandon scope)
paused ──do+checkpoint──→ idle          (resumed, completed)
paused ──plan──→ scoped                 (re-scoped)
user-pending ──checkpoint──→ idle       (USER tasks verified)
user-pending ──checkpoint──→ blocked    (USER task has issue)
blocked ──plan──→ scoped                (blocker resolved, re-scoped)
blocked ──do+checkpoint──→ idle         (blocker resolved externally, scope still valid)
```

## Document Update Matrix

Which command writes which file:

| File | status | plan | do | checkpoint |
|------|--------|------|----|------------|
| state.md | — | ✓ | — | ✓ |
| roadmap.md | — | ✓ | — | ✓ |
| decisions.md | — | ✓ | — | ✓ |
| project.md | — | — | — | ✓ (rare) |
| CLAUDE.md | — | — | — | ✓ (rare) |
| plan doc | — | ✓ (creates) | — | ✓ (reads for routing) |
| investigations/ | — | — | ✓ | — |
| project files | — | — | ✓ | — |

**Key rule:** Do writes project files. Plan and checkpoint write scaffold files. Never the reverse. This prevents conflicts and keeps ownership clear.

## Absorbed Behaviors

| v1 command | Absorbed into | How |
|------------|---------------|-----|
| `prime` | `do` | Do reads plan doc and executes. No plan mode. No separate context-loading step. |
| `pause` | `checkpoint` | Checkpoint detects incomplete work, writes Session Context to state.md, sets status to `paused`. |
| `resume` | `status` | Status detects `paused` state, presents Session Context, routes to do or plan. |
| `verify` | `checkpoint` | Checkpoint scans for USER tasks, asks about them inline with option to skip. |
| `quick` | `plan` | Plan accepts inline descriptions for quick scoping. Same output format, abbreviated flow. |
| `quick-execute` | `do` | Do executes whatever plan scoped, whether it's 1 quick task or 6 complex tasks. |

## CLAUDE.md Template Changes (v2)

### New: Working section

```markdown
## Working
- Before making code changes: research the relevant code, present your approach, get approval
- One task at a time. Verify each works before starting the next.
- Only work on tasks in the current scope (see state.md Next Action)
- Out-of-scope discoveries get noted for checkpoint, not acted on now
```

### Updated: Session Protocol

```markdown
### Session Protocol
| User says | Action |
|-----------|--------|
| "status" | Run `/scaffold:status` |
| "plan" / "let's think" | Run `/scaffold:plan` |
| "do it" / "go ahead" / "execute" | Run `/scaffold:do` — always invoke the command, do not begin execution without it |
| "checkpoint" / "save" | Run `/scaffold:checkpoint` |
| "pause" / "I need to stop" | Run `/scaffold:checkpoint` (mid-session) |
| "decision: [X]" | Log in `.scaffold/decisions.md` |
```

### Updated: Command Reference

```markdown
### Command Reference
| Command | Role |
|---------|------|
| `/scaffold:status` | Orient — read state, suggest next action |
| `/scaffold:plan` | Plan — update roadmap, scope work, produce plan doc |
| `/scaffold:do` | Execute — research, propose, get approval, build |
| `/scaffold:checkpoint` | Save — verify, update files, commit |
| `/scaffold:cleanup` | Migrate existing project to current format |
| `/scaffold:update` | Update scaffold commands to latest version |
| `/scaffold:graduate` | Exit scaffold to heavier framework |
```

## AI Instruction Strategy

Commands are markdown files loaded into Claude's context as instructions. This creates specific challenges:

### Principle 1: One active command at a time

Each command has a clear start, body, and end. After it completes and produces output, its instructions are "spent." The next command's instructions take precedence via recency.

### Principle 2: Explicit boundaries prevent bleeding

Every command states what it does NOT do:
- Plan: "Do NOT modify non-scaffold files."
- Do: "Do NOT update scaffold files."
- Checkpoint: "Do NOT make code changes."

These are stated as hard prohibitions, not suggestions.

### Principle 3: Clear handoffs eliminate ambiguity

Every command ends with an explicit next step:
- Plan → "Run `/scaffold:do`."
- Do → "Run `/scaffold:checkpoint`."
- Checkpoint → "Run `/scaffold:plan` to determine next steps."

### Principle 4: CLAUDE.md provides the persistent behavioral layer

The Working section in CLAUDE.md applies at all times, across all sessions. Commands provide session-specific instructions. CLAUDE.md provides the baseline. This means execution behavior (research first, propose, get approval, one task at a time) is always active, not dependent on which command was run.

### Principle 5: Gates prevent premature advancement

Interactive phases (plan's consultation, do's approach approval) require explicit user response before proceeding. The instruction says "STOP. Wait for user response." not "proceed if the answer seems obvious."

### Principle 6: Plan's closing releases the lock

Plan ends with: "Planning complete. Execution will begin when you run `/scaffold:do`." This frames the plan restriction as complete, not ongoing. If do is run in the same session, Claude understands plan is done and do is the active instruction.

## Edge Cases

**User wants to work without running plan first:**
Status detects no scope → routes to plan. If user insists, CLAUDE.md Working rules guide execution, but there's no plan doc for checkpoint to reference. Checkpoint handles gracefully by asking what was done and recording it.

**Plan scopes work, user /clears, comes back a week later:**
Status reads state.md (scoped), reads plan doc for scope details. Routes to do. Context survives via files.

**Do discovers the task is much bigger than planned:**
Do's escape hatch: "This is more complex than planned. [reason]. Suggest re-running /scaffold:plan to re-scope." Let user decide.

**Checkpoint finds tests failing:**
Report to user. Don't mark done. Let user decide: fix now or note issues in state.md.

**Mid-execution session crash:**
State.md still has scope. Plan doc still exists. Status detects scoped state, routes to do to continue. Do checks roadmap for already-completed tasks and skips them.

**USER tasks need verification mid-checkpoint:**
Checkpoint asks about them inline. User can say "not yet" to skip. Checkpoint preserves plan pointer and USER task state.

**Multiple plan docs exist:**
Plan doc naming includes date and sequence number. Commands always reference the specific plan doc via state.md pointer, not by scanning. Old plan docs accumulate as history — they're small and serve as the running record. Graduate cleans them up.

**User re-plans from scoped state:**
Plan detects existing scope and warns: "You have scoped work. Re-planning replaces it. Proceed?" If confirmed, plan creates new scope. Old plan doc remains in `.scaffold/plans/` as history.

**User re-plans from user-pending state:**
Plan refuses: "Unverified USER tasks. Run /scaffold:checkpoint first." This prevents losing the plan doc's deferred items and decisions that checkpoint needs for routing.

**Do is interrupted and re-run same session:**
Conversation history shows what was already done. If re-run after /clear, do checks roadmap for `[x]` tasks (from prior checkpoint) and skips them. For un-checkpointed work, do asks: "If resuming interrupted execution, tell me which tasks are already complete."

**Checkpoint with no prior scaffold commands:**
User chatted, made decisions, never ran plan or do. No plan doc exists. Checkpoint reviews the conversation, captures any decisions to decisions.md, updates state.md, commits. No plan doc routing (nothing to route).

**User edits scaffold files manually:**
Commands trust the files. Status health check detects inconsistencies (e.g., state says blocked but roadmap shows nothing blocked). Commands re-read files before acting.

**Paused mid-planning (not mid-execution):**
No plan doc exists yet (plan hadn't finished). Checkpoint sets status to `paused` with Session Context noting "mid-plan." Status detects paused + no plan doc → routes to plan (not do).
