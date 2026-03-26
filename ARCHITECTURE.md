# Essentials Scaffold — Architecture

This is the controlling document. All commands, workflows, and file behaviors derive from what's defined here.

## Design Principles

1. **State machine.** Every command leaves all state documents accurate and self-consistent. Any command could be the last thing that runs before a week-long gap.
2. **Commands are optional tools, not mandatory gates.** The minimum ceremony is status → work → checkpoint. Everything else is available when you need it.
3. **No plan mode dependency.** All commands run in normal mode. Shift+Tab plan mode is available as a complementary tool but the scaffold doesn't require it.
4. **Ceremony scales with the user.** The user decides how much structure they want per session. The system supports freeform collaboration and formal scoped execution equally.
5. **A place for everything.** Every piece of information has exactly one canonical home. Documents don't duplicate each other.
6. **Don't tell Claude what it already knows.** Commands and rules only instruct behaviors Claude wouldn't do by default.

## Information Model

Four layers of information, each with a distinct home:

| Layer | What it is | Where it lives | Example |
|-------|-----------|----------------|---------|
| **Requirements** | What the product must do. Verifiable rules. | `.scaffold/project.md` | "Validate only SLDPRT and SLDASM files" |
| **Deliverables** | Chunks of work that span sessions. Trackable outcomes. | `.scaffold/roadmap.md` | "User management API" |
| **Phase criteria** | When is this phase done? Acceptance conditions. | `.scaffold/roadmap.md` (per phase) | "Users can CRUD through validated endpoints" |
| **Tasks** | Atomic action steps for a single session. Ephemeral. | Plan docs (`.scaffold/plans/`) | "Implement PUT /users/:id with Zod validation" |

**The test for roadmap items:** Can this item survive multiple plan/do/checkpoint cycles and still make sense? If yes, it's a deliverable (roadmap). If it can be done in one session, it's a task (plan doc).

**Decisions** (`.scaffold/decisions.md`) record the WHY — rationale and rejected alternatives. They are not requirements (what) or tasks (how).

## Files

### Core files (5)

| File | Purpose | Updated by |
|------|---------|------------|
| `CLAUDE.md` | Hub — identity, rules, constraints, tech stack. Auto-read by Claude. | setup, checkpoint (rare) |
| `.scaffold/project.md` | Vision, scope, requirements (verifiable checkboxes). | setup, plan (requirements), checkpoint (rare) |
| `.scaffold/state.md` | Status — current position, scope pointer, next action, blockers. | plan, scope, checkpoint |
| `.scaffold/roadmap.md` | Phases with criteria (numbered) and deliverables (checkboxes). | plan, checkpoint |
| `.scaffold/decisions.md` | Rationale log — decisions with context, reasoning, rejected alternatives. | plan, checkpoint |

### Artifact directories

| Directory | Contents | Created by |
|-----------|----------|------------|
| `.scaffold/plans/` | Plan docs. Scope contracts + records for complex/multi-actor work. | scope |
| `.scaffold/investigations/` | Durable research findings. | do (during investigation tasks) |

### Roadmap format

```markdown
## Phase 1 — Setup [COMPLETE]
- [x] Project initialization (2026-03-01)
- [x] Auth integration (2026-03-02)

## Phase 2 — Core Features [IN-PROGRESS]
Phase complete when:
1. Users can create, read, update, delete accounts
2. All endpoints validate input and return proper errors
3. Integration tests pass for all CRUD operations

- [x] Data model (2026-03-03)
- [ ] User management API
  - POST, GET done. PUT, DELETE remaining.
- [ ] Input validation
- [ ] Integration tests
- [ ] [USER] Deploy to staging

## Phase 3 — Dashboard [PLANNED]
Phase complete when:
1. Dashboard renders real user activity data

- [ ] Activity data model
- [ ] Dashboard UI

## Backlog
- Mobile app
- Public API
```

- Phase criteria are **numbered** (not checkboxes). Evaluated as a set during phase sign-off.
- Deliverables are **checkboxes**. Checked when the outcome is achieved.
- Sub-bullets under deliverables are **progress notes**, not tasks.
- `[USER]` marks deliverables requiring human action.
- `[IN-PROGRESS]` / `[COMPLETE]` / `[PLANNED]` — only one phase IN-PROGRESS at a time.
- Phase sign-off requires explicit user approval during checkpoint.

### project.md format (requirements section)

```markdown
## Requirements
- [ ] Validate only SLDPRT and SLDASM files
- [ ] All validation rules are blockers (no warnings)
- [ ] PreState performance: < 2 seconds, fail-open
- [ ] BOM traversal: immediate children only
```

Requirements are verifiable product rules. Checkboxes — checked by checkpoint when evidence confirms they're met. Requirements are stable (set early, refined rarely). They are NOT the same as deliverables or tasks.

### state.md format

```markdown
<!-- Last updated: YYYY-MM-DD -->
# State

## Status
[idle / scoped / user-pending / paused / blocked]

## Current Position
[1-3 sentences orienting someone picking this up cold.]

## Next Action
[What to do next. If scoped: plan doc pointer. If idle: "work on X" or "run /scaffold:plan".]

## Session Context
<!-- Written by checkpoint mid-session. Cleared on full close-out. -->
[Only present when paused. Progress, key context, next step.]

## Blockers
- [Things preventing progress]

## Open Questions
- [Unknowns needing answers]
```

## Commands

### Workflow commands (4 + status)

Commands are tools you reach for when you need them. The minimum session is status → work → checkpoint. Plan, scope, and do are available when the situation warrants them.

---

#### `/scaffold:status`

**Purpose:** Orient. Read scaffold files, present briefing, suggest next actions as options.

**Reads:** CLAUDE.md, project.md, state.md, roadmap.md. If state.md references a plan doc, reads it for scope details. Detects investigations.

**Writes:** Nothing. Status is read-only.

**Briefing:** Project summary, phase progress, state, open threads, investigations, health check, staleness check. Keep it short — a briefing, not a report.

**Routing** (suggests options, does not mandate):

| State | What status says |
|-------|-----------------|
| `idle` | "No active scope. What would you like to work on? (`/scaffold:plan` to discuss direction)" |
| `scoped` | "Plan doc ready: [scope summary]. Say 'go ahead' or `/scaffold:do` to execute." |
| `paused` (has plan doc) | "Paused from [date]. [Session Context]. Continue working, `/scaffold:do`, or `/scaffold:plan` to re-scope." |
| `paused` (no plan doc) | "Paused mid-work from [date]. [Session Context]. Continue or `/scaffold:plan`." |
| `user-pending` | "USER tasks pending: [list]. Complete them, then `/scaffold:checkpoint`." |
| `blocked` | "Blocked: [reason]. If resolved, continue working or `/scaffold:plan`." |

---

#### `/scaffold:plan`

**Purpose:** Consultation. "Help me figure out what's next." Read state, discuss direction, update roadmap and scaffold files. Does NOT write plan docs.

**Reads:** All 5 core files. `.scaffold/investigations/` if relevant. Session Context if present.

**Writes:**
- `.scaffold/roadmap.md` — new/reordered deliverables, phase changes, phase criteria
- `.scaffold/state.md` — current position, blockers, open questions
- `.scaffold/decisions.md` — if decisions made during discussion
- `.scaffold/project.md` — if new requirements emerged (rare)

**Boundary:** Plan does NOT modify non-scaffold files. No code changes. Plan does NOT write plan docs (scope does that).

**Precondition guards:**
- If state is `scoped`: "You have a scoped plan. Continuing will clear it. Proceed, or work from the existing plan?" Wait for confirmation.
- If state is `user-pending`: "Unverified USER tasks. Run `/scaffold:checkpoint` first." Stop.
- If state is `blocked`: "Blocked: [reason]. Is this resolved?" Wait for confirmation.

**Flow:**
1. Triage (silent) — read all files, assess state
2. Consult (interactive) — present assessment, ask user for direction. WAIT for response.
3. Discuss — help user figure out what to do. Answer questions. Evaluate options.
4. Update — write approved changes to roadmap, state, decisions, project (requirements).
5. Summary — "Roadmap updated. [what changed]. Ready to work — just start, or `/scaffold:scope` for a formal plan."

**Inline shortcut:** `/scaffold:plan fix the redirect` — treat description as direction, run triage silently, skip open-ended consultation, go to discuss/update. Still assess complexity — if it's bigger than expected, say so.

**Ends with options, not directives.** Plan presents what the user can do next, not what they must do.

---

#### `/scaffold:scope`

**Purpose:** Write a plan doc. Formalize the current plan into a scope contract. Can be invoked at any point in a session — delivers fresh doc-writing instructions regardless of context depth.

**Reads:** `.scaffold/state.md`, `.scaffold/roadmap.md`, `CLAUDE.md`, conversation context.

**Writes:**
- `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md` — plan document
- `.scaffold/state.md` — status → `scoped`, Next Action → plan doc pointer

**Precondition guards:**
- If state is `user-pending`: "Unverified USER tasks. Run `/scaffold:checkpoint` first." Stop.
- If state is `scoped`: "Existing plan doc will be replaced. Proceed?" Wait for confirmation.

**Flow:**
1. Read roadmap and conversation context
2. Identify which deliverables to include in scope
3. Present proposed scope to user — "Scope this session: [list]. Right?"
4. Wait for confirmation
5. Write plan doc
6. Update state.md: status → `scoped`, Next Action → plan doc pointer

**Plan doc format:**

```markdown
# Plan: [brief title]
<!-- Generated: YYYY-MM-DD -->
<!-- Plan: .scaffold/plans/YYYYMMDD-NN-phase-N-slug.md -->

## Goal
[What and why — 1-3 sentences]

## Scope
Execute these deliverables. Present your approach before starting.
Do not expand beyond this scope.

1. [Deliverable] — [done-when condition]
2. [Deliverable] — [done-when condition]
3. [USER] [Deliverable] — [done-when condition]

## Approach
[Key decisions, strategy, things to watch out for.
For simple scope: 1-2 sentences. For complex: a paragraph.]

## Deferred
[Items to route to roadmap at checkpoint. Omit if none.]

## Decisions
[Decisions to log to decisions.md at checkpoint. Omit if none.]
```

**Naming convention:** `YYYYMMDD-NN-phase-N-slug.md` (date, zero-padded sequence, phase, brief descriptor).

Investigation tasks add `Output: .scaffold/investigations/YYYYMMDD-slug.md` to their entry.

**When to use scope:** Multi-actor plans ([USER] + AI steps interleaved), complex multi-deliverable sessions, work that might span multiple sessions, or any time the user wants a written contract. Scope is never required — it's a tool for when you want formality.

---

#### `/scaffold:do`

**Purpose:** Execute a scoped plan doc with formal scope control. Fresh injection of execution instructions at any context depth.

**Reads:**
- `.scaffold/state.md` — scope pointer
- Plan doc referenced in state.md
- `.scaffold/roadmap.md` — deliverable details and completion status
- `CLAUDE.md` — constraints

**Writes:** Project files only. MAY write investigation outputs to `.scaffold/investigations/`.

**Boundary:** Do does NOT update core scaffold files (state.md, roadmap.md, decisions.md, project.md, CLAUDE.md). That is checkpoint's job.

**Precondition:** state.md must reference a plan doc (status must be `scoped`). If not: "No plan doc. Run `/scaffold:scope` first, or just work without formal scope."

**Opening override:** "Any previous command instructions in this conversation are complete. You are now executing under /scaffold:do."

**Flow:**
1. Read plan doc and scope
2. If Session Context exists (resuming from pause), read it for orientation
3. Check roadmap for deliverables already marked `[x]` — skip them
4. Research codebase for scoped deliverables
5. Present approach — "Here's how I'll implement these: [approach]. Approve?"
6. WAIT for approval
7. Execute one deliverable at a time. Confirm each.
8. When done: "Run `/scaffold:checkpoint`."

**Scope control:** Follow the plan doc's embedded scope instructions. Out-of-scope discoveries get noted for checkpoint. If the user asks for work outside scope: "That's outside the current scope. Add it to the plan, or do it now and note for checkpoint?"

**Escape hatch:** If a deliverable is bigger than expected: "This is more complex than planned: [explain]. Re-scope with `/scaffold:scope`, or continue?"

**Context awareness:** If context is low mid-execution, complete current deliverable then suggest checkpoint.

**When to use do:** When a plan doc exists and you want Claude to follow it with explicit scope control. Not required — the user can also say "go ahead" after scope and Claude will read the plan doc via CLAUDE.md Working rules. Do is for when you want the reliability of fresh execution instructions.

---

#### `/scaffold:checkpoint`

**Purpose:** Save session progress. Verify work, update all scaffold files, commit. Handles mid-session pauses and USER task verification.

**Reads:** All 5 core files. Plan doc (if referenced in state.md). Git diff. Conversation context.

**Writes:**
- `.scaffold/roadmap.md` — mark deliverables complete, route deferred items
- `.scaffold/state.md` — status, position, next action, session context, blockers
- `.scaffold/decisions.md` — new decisions, resolved blockers
- `.scaffold/project.md` — requirements (if new ones confirmed, rare)
- `CLAUDE.md` — tech stack, constraints (if changed, rare)

**Boundary:** Checkpoint does NOT make code changes or modify project files.

**Step 1: Assess session state**

- **A. Full close-out** — all scoped work complete, or no scope existed (freeform session). Proceed through all steps.
- **B. Mid-session** — scoped work incomplete (plan doc pointer exists, not all deliverables done). Go to Step 2.
- **C. No plan doc** — freeform session, no plan doc. Skip plan doc routing. Update files from conversation context.

**Step 2: Mid-session handling** *(skip if full close-out or no scope)*

Ask: "Incomplete scoped work. What would you like to do?"
- **Pause** — write Session Context, status → `paused`, preserve plan pointer, commit.
  - Before writing: "Anything I should note for next time?"
- **Partial save** — mark completed deliverables, status stays `scoped`, clear stale Session Context, commit.
- **Abandon** — mark completed deliverables, clear plan pointer, status → `idle`, commit.

**Session Context format:**
```markdown
## Session Context
<!-- Written by checkpoint mid-session. Cleared on full close-out. -->
**Progress:** [What's done vs remaining — reference deliverable names]
**Key context:** [Approach notes, gotchas, discoveries]
**Next step:** [Concrete next action when resuming]
```

**Step 3: USER task check** *(skip if mid-session pause or partial save)*

Scan `[IN-PROGRESS]` phase for unchecked `[USER]` deliverables. If any:
> "Phase N has pending USER tasks: [list]. Completed any? ('not yet' to skip.)"

If confirmed: gated walkthrough — present done-when criteria, verify each, mark or note issues.

**Step 4: Verify AI work** *(skip if no code changes)*

- Run tests if they exist. Don't mark done if tests fail.
- Evidence-based: `[x]` requires evidence (test output, observed behavior, user confirmation).
- If verification isn't possible, note honestly.

**Step 5: Update scaffold files**

- **roadmap.md** — mark completed deliverables `[x]` with date, route deferred items, phase sign-off gate (all done → ask user to mark `[COMPLETE]`)
- **state.md** — status (idle/scoped/paused/user-pending/blocked), current position, next action, clear Session Context on full close-out, update blockers/open questions
- **decisions.md** — log decisions from session, log resolved blockers
- **project.md** — update requirements if new ones confirmed (rare)
- **CLAUDE.md** — update tech stack or constraints if changed (rare)

**Step 6: Plan doc routing** *(only on full close-out with plan doc)*

- If USER tasks incomplete: defer plan doc routing (Deferred/Decisions sections). Preserve plan pointer. Session decisions still logged in Step 5.
- If no incomplete USER tasks: route Deferred to roadmap, route Decisions to decisions.md, verify investigation outputs exist, clear plan pointer.

**Step 7: Review before committing**

Show changes, ask for approval. Wait for confirmation.

**Step 8: Commit**

`git add CLAUDE.md .scaffold/ && git commit -m "checkpoint: [brief summary]"`

Route to next: present options based on resulting state.

**Enhanced mode:** `--audit` runs an Explore subagent after commit to verify scaffold claims against codebase.

---

### Utility commands (4)

| Command | Purpose |
|---------|---------|
| `/scaffold:setup` | Initialize scaffold files and SessionStart hook |
| `/scaffold:update` | Pull latest commands |
| `/scaffold:cleanup` | Migrate formats (v1→v2→v3) |
| `/scaffold:graduate` | Consolidate, archive, hand off |

## Workflows

Commands are optional. These are common patterns, not mandatory sequences.

### Freeform (minimum ceremony)

```
status → work with Claude → checkpoint
```

No plan, no scope, no do. Just collaborate and save. Checkpoint handles everything from conversation context.

### Guided (consultation)

```
status → plan → work with Claude → checkpoint
```

Plan helps figure out what to do and updates the roadmap. Then you just work. No formal scope needed.

### Scoped (formal execution)

```
status → [plan →] scope → do → checkpoint
```

Scope writes a plan doc. Do executes it with formal scope control. For complex or multi-actor work.

### Verify (USER task completion)

```
status → checkpoint
```

USER tasks done. Checkpoint verifies and updates.

### Mix and match

Commands can be invoked at any point. Run plan 200k tokens into a session when you need to recalibrate. Run scope when a complex plan emerges from freeform work. Run do when you have a plan doc and want reliable execution. Run checkpoint whenever you want to save.

## State Machine

### States

| State | Meaning | How you got here |
|-------|---------|-----------------|
| `idle` | No active scope. Working or waiting. | Checkpoint close-out, plan consultation, initial state |
| `scoped` | Plan doc exists, awaiting or mid-execution. | Scope wrote a plan doc |
| `user-pending` | AI work done, USER deliverables remain. | Checkpoint with incomplete USER items |
| `paused` | Mid-session stop, Session Context has details. | Checkpoint mid-session pause |
| `blocked` | Something prevents progress. | Checkpoint or plan discovered blocker |

### Transitions

```
idle ──scope──→ scoped            (plan doc written)
idle ──plan──→ idle               (consultation, roadmap updated)
idle ──checkpoint──→ idle         (freeform work saved)

scoped ──scope──→ scoped          (new plan doc replaces old, user confirmed)
scoped ──plan──→ idle             (re-consulted, scope cleared, user confirmed)
scoped ──do+checkpoint──→ idle    (all done)
scoped ──do+checkpoint──→ user-pending (AI done, USER remains)
scoped ──checkpoint──→ paused     (mid-session pause)
scoped ──checkpoint──→ scoped     (partial save)
scoped ──checkpoint──→ idle       (abandon scope)

paused ──scope──→ scoped          (new scope from paused)
paused ──do+checkpoint──→ idle    (resumed, completed)
paused ──plan──→ idle             (re-consulted from pause)

user-pending ──checkpoint──→ idle     (USER tasks verified)
user-pending ──checkpoint──→ blocked  (USER task issue)

blocked ──plan──→ idle            (blocker resolved, re-consulted)
blocked ──scope──→ scoped         (blocker resolved, new scope)
```

## Document Update Matrix

| File | status | plan | scope | do | checkpoint |
|------|--------|------|-------|----|------------|
| state.md | — | ✓ | ✓ | — | ✓ |
| roadmap.md | — | ✓ | — | — | ✓ |
| decisions.md | — | ✓ | — | — | ✓ |
| project.md | — | ✓ (requirements) | — | — | ✓ (rare) |
| CLAUDE.md | — | — | — | — | ✓ (rare) |
| plan doc | — | — | ✓ (creates) | reads | ✓ (reads for routing) |
| investigations/ | — | — | — | ✓ | — |
| project files | — | — | — | ✓ | — |

**Key rules:**
- Do writes project files. Plan, scope, and checkpoint write scaffold files. Never the reverse.
- Scope is the only command that creates plan docs.
- Status writes nothing.

## CLAUDE.md Template

### Rules section

```markdown
## Rules
- Ask before making code changes — present your approach and get approval
- Consult .scaffold/decisions.md when making or revisiting design choices
- Ask before making architectural or structural changes
- If any scaffold file contradicts the codebase, trust the codebase. State the contradiction.
- If a session is getting long (context below 40%), suggest /scaffold:checkpoint
- If we made decisions or completed work, remind me to checkpoint before session ends
```

### Working section

```markdown
## Working
- If state.md references a plan doc, read it and follow its scope
- Out-of-scope discoveries get noted for checkpoint, not acted on now
```

### Session Protocol

```markdown
### Session Protocol
| User says | Action |
|-----------|--------|
| "status" | Run `/scaffold:status` |
| "plan" / "what's next" / "let's think" | Run `/scaffold:plan` |
| "scope this" / "write a plan" | Run `/scaffold:scope` |
| "do" / "execute the plan" | Run `/scaffold:do` |
| "go ahead" / "do it" | If plan doc exists, read it and execute per Working rules. If not, do what was discussed. |
| "checkpoint" / "save" / "pause" | Run `/scaffold:checkpoint` |
| "decision: [X]" | Log in `.scaffold/decisions.md` |
```

### Command Reference

```markdown
### Command Reference
| Command | Role |
|---------|------|
| `/scaffold:status` | Orient — read state, present options |
| `/scaffold:plan` | Consult — discuss direction, update roadmap |
| `/scaffold:scope` | Formalize — write a plan doc for complex/multi-actor work |
| `/scaffold:do` | Execute — formal scope-controlled execution from plan doc |
| `/scaffold:checkpoint` | Save — verify, update files, commit |
| `/scaffold:cleanup` | Migrate existing project to current format |
| `/scaffold:update` | Update scaffold commands to latest version |
| `/scaffold:graduate` | Exit scaffold to heavier framework |
```

## AI Instruction Strategy

### Principle 1: Commands inject fresh instructions at point of need

At 400k tokens deep, CLAUDE.md rules are far away. A slash command dumps precise instructions into context at the moment they're needed. This is why commands exist alongside CLAUDE.md rules — not redundancy, but reliability at depth.

### Principle 2: Don't tell Claude what it already knows

CLAUDE.md only instructs behaviors Claude wouldn't do by default:
- "Read the plan doc" — Claude wouldn't know to look for it
- "Note out-of-scope discoveries" — Claude would just fix things
- "Ask before making code changes" — this is a user preference, not a Claude default

Rules like "research code before changing it" or "work one task at a time" are dropped — Claude already does these.

### Principle 3: Explicit boundaries prevent bleeding

Each command states what it does NOT do:
- Plan: "Do NOT modify non-scaffold files. Do NOT write plan docs."
- Scope: "Do NOT execute. Do NOT modify non-scaffold files."
- Do: "Do NOT update scaffold files."
- Checkpoint: "Do NOT make code changes."

### Principle 4: Commands present options, not directives

Status says "you can do X or Y" not "run X now." Plan ends with options. The user controls what happens next.

### Principle 5: Gates prevent premature advancement

Interactive phases require explicit user response. "STOP. Wait for response." Not "proceed if obvious."

## Edge Cases

**Freeform work without any commands (except status/checkpoint):**
User talks to Claude, collaborates, builds things. Checkpoint handles it — reviews conversation, captures decisions, updates roadmap from what was done. No plan doc to route. Works.

**Scope invoked without prior plan:**
User knows what they want. Runs scope directly. Scope reads roadmap and conversation context, writes plan doc. Works.

**Plan invoked while scoped:**
Plan warns: "Existing scope will be cleared. Proceed?" If yes, plan clears scope pointer, consults, updates roadmap. State returns to idle. Old plan doc stays in `.scaffold/plans/` as history.

**Do without scope (user says "go ahead" instead):**
CLAUDE.md Working rules: "If plan doc exists, read it and follow its scope." Claude reads the doc and executes. Less reliable than do at depth, but works for most sessions. Do exists for when you want guaranteed reliability.

**Context crash mid-execution:**
State.md has plan doc pointer. Plan doc survives. Status detects scoped state, presents scope. User continues.

**Multi-actor plan in progress:**
Plan doc has USER and AI steps interleaved. Do executes AI steps, skips USER steps. Checkpoint notes pending USER items. User completes their steps. Checkpoint verifies on next run.

**Checkpoint with no commands run:**
User chatted, made decisions, never ran plan or scope or do. Checkpoint reviews conversation, captures decisions, updates state. Works.

**Deliverable takes multiple sessions:**
Roadmap item stays unchecked. Progress tracked in sub-bullets. Plan docs across sessions reference the same deliverable. When outcome is finally achieved, checkpoint marks it done.

**Requirements discovered mid-session:**
User says "that's a requirement" or it emerges from discussion. Plan adds it to project.md Requirements. Or checkpoint captures it during save. Either way, it lands in project.md.
