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

Five layers of information, each with a distinct home:

| Layer | What it is | Where it lives | Example |
|-------|-----------|----------------|---------|
| **Requirements** | What the product must do. Verifiable rules. | `.scaffold/project.md` | "Validate only SLDPRT and SLDASM files" |
| **Deliverables** | Chunks of work that span sessions. Trackable outcomes. | `.scaffold/roadmap.md` | "User management API" |
| **Phase criteria** | When is this phase done? Acceptance conditions. | `.scaffold/roadmap.md` (per phase) | "Users can CRUD through validated endpoints" |
| **Tasks** | Atomic action steps for a single session. Ephemeral. | Plan docs (`.scaffold/plans/`) | "Implement PUT /users/:id with Zod validation" |
| **Knowledge** | Controlling documents that inform phase execution. Detailed specs, architecture docs, design direction. | `.scaffold/knowledge/` | "Resource planner spec — interaction flows, visual design, data model" |

**The test for roadmap items:** Can this item survive multiple plan/do/checkpoint cycles and still make sense? If yes, it's a deliverable (roadmap). If it can be done in one session, it's a task (plan doc).

**Decisions** (`.scaffold/decisions.md`) record the WHY — rationale and rejected alternatives. They are not requirements (what) or tasks (how).

**Knowledge** (`.scaffold/knowledge/`) stores controlling documents — specs, architecture docs, design system docs — that contain detailed requirements, design direction, and implementation specifications. These are absorbed into scaffold via `/scaffold:integrate`. The knowledge doc is the lossless original; scaffold files get the operational extract. Commands that need deep detail (plan, scope, do) read knowledge docs directly.

## Files

### Core files (5)

| File | Purpose | Updated by |
|------|---------|------------|
| `CLAUDE.md` | Hub — identity, rules, constraints, tech stack. Auto-read by Claude. | setup, checkpoint (rare) |
| `.scaffold/project.md` | Vision, scope, requirements (verifiable checkboxes). | setup, plan (requirements), checkpoint (rare) |
| `.scaffold/state.md` | State — active focus, next, blockers, open questions. Forward-looking only. | plan, scope, checkpoint |
| `.scaffold/roadmap.md` | Phases with criteria (numbered) and deliverables (checkboxes). | plan, checkpoint |
| `.scaffold/decisions.md` | Rationale log — decisions with context, reasoning, rejected alternatives. | plan, checkpoint |

### Artifact directories

| Directory | Contents | Created by |
|-----------|----------|------------|
| `.scaffold/plans/` | Plan docs. Scope contracts + records for complex/multi-actor work. | scope |
| `.scaffold/investigations/` | Durable research findings. | do (during investigation tasks) |
| `.scaffold/knowledge/` | Controlling documents (specs, architecture docs, design docs). Absorbed via integrate. | integrate |

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

## Active focus
[One paragraph. Plain-language synopsis + forward-look. Where things are,
what's in flight, what's driving the work. No bullets, no code blocks,
no quoted prompts. Grows only when the situation genuinely requires it.]

## Next
[The concrete action when you resume. 1-2 sentences or short bullets.
References the plan doc by path if one is active.]

## Blockers
None.

## Open Questions
None.
```

**State is forward-looking, not a log.** Four sections, no more. No status
enum, no Session Context, no Closed archive, no project-specific carve-outs.

- **Active focus** is one paragraph, plain language. Synopsis + forward-look
  in one. Grows only when genuinely needed.
- **Blockers** and **Open Questions** are always present with "None." when
  empty — confirms the writer checked; absent sections would be ambiguous.
- **When a Blocker or Open Question resolves:** remove the line and place
  the resolution where it belongs (decisions.md / roadmap.md / commit log /
  knowledge doc). State does not accumulate resolved items.

Routing is content-derived (see State Determination below) — no status
keyword to keep in sync with reality.

## Commands

### Workflow commands (5 + status)

Commands are tools you reach for when you need them. The minimum session is status → work → checkpoint. Plan, scope, do, and integrate are available when the situation warrants them.

---

#### `/scaffold:status`

**Purpose:** Orient. Read scaffold files, present briefing, suggest next actions as options.

**Reads:** CLAUDE.md, project.md, state.md, roadmap.md. If state.md references a plan doc, reads it for scope details. Detects knowledge docs and investigations.

**Writes:** Nothing. Status is read-only.

**Briefing:** Project summary, phase progress, state, open threads, knowledge docs, investigations, health check, staleness check. Keep it short — a briefing, not a report.

**Routing** (suggests options, does not mandate). Signals are content-derived
(see State Determination); multiple can apply at once.

| Signal | What status says |
|--------|-----------------|
| Plan doc active | "Plan doc ready: [scope summary]. Say 'go ahead' or `/scaffold:do` to execute." |
| USER tasks pending (no plan doc) | "USER tasks pending: [list]. Complete them, then `/scaffold:checkpoint`." |
| Blockers present | "Blocked: [content of Blockers]. If resolved, continue working or `/scaffold:plan`." |
| Otherwise | "Active focus: [synopsis]. Next: [content of Next]. Continue working, or `/scaffold:plan` to recalibrate." |

---

#### `/scaffold:plan`

**Purpose:** Consultation. "Help me figure out what's next." Read state, discuss direction, update roadmap and scaffold files. Does NOT write plan docs.

**Reads:** All 5 core files. `.scaffold/knowledge/` and `.scaffold/investigations/` if relevant.

**Writes:**
- `.scaffold/roadmap.md` — new/reordered deliverables, phase changes, phase criteria
- `.scaffold/state.md` — active focus, next, blockers, open questions
- `.scaffold/decisions.md` — if decisions made during discussion
- `.scaffold/project.md` — if new requirements emerged (rare)

**Boundary:** Plan does NOT modify non-scaffold files. No code changes. Plan does NOT write plan docs (scope does that).

**Precondition guards** (content-derived):
- If state.md's Next references an active plan doc: "You have an active plan
  doc ([path]). Continuing will clear it. Proceed, or work from the existing
  plan?" Wait for confirmation.
- If unchecked `[USER]` deliverables remain with no other unchecked AI
  deliverables in the `[IN-PROGRESS]` phase: "Unverified USER tasks. Run
  `/scaffold:checkpoint` first." Stop.
- If Blockers section has content other than "None.": "Blocked: [reason].
  Is this resolved?" Wait for confirmation.

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

**Reads:** `.scaffold/state.md`, `.scaffold/roadmap.md`, `CLAUDE.md`, `.scaffold/knowledge/` (relevant docs), conversation context.

**Writes:**
- `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md` — plan document
- `.scaffold/state.md` — Active focus reflects the new scope; Next references
  the plan doc

**Precondition guards** (content-derived):
- If unchecked `[USER]` deliverables remain with no other unchecked AI work:
  "Unverified USER tasks. Run `/scaffold:checkpoint` first." Stop.
- If Next already references an active plan doc: "Existing plan doc will be
  replaced. Proceed?" Wait for confirmation.

**Flow:**
1. Read roadmap and conversation context
2. Identify which deliverables to include in scope
3. Present proposed scope to user — "Scope this session: [list]. Right?"
4. Wait for confirmation
5. Write plan doc
6. Update state.md: Active focus reflects new scope; Next references the plan doc

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
- `.scaffold/knowledge/` — knowledge docs relevant to the plan (specs, architecture docs with detailed implementation specs)

**Writes:** Project files only. MAY write investigation outputs to `.scaffold/investigations/`.

**Boundary:** Do does NOT update core scaffold files (state.md, roadmap.md, decisions.md, project.md, CLAUDE.md). That is checkpoint's job.

**Precondition:** state.md's `## Next` must reference a plan doc in `.scaffold/plans/`. If not: "No plan doc. Run `/scaffold:scope` first, or just work without formal scope."

**Opening override:** "Any previous command instructions in this conversation are complete. You are now executing under /scaffold:do."

**Flow:**
1. Read plan doc and scope
2. Read state.md's Active focus — describes where the work sits, including paused-mid-work context
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
- `.scaffold/state.md` — active focus, next, blockers, open questions
- `.scaffold/decisions.md` — new decisions, resolved blockers
- `.scaffold/project.md` — requirements (if new ones confirmed, rare)
- `CLAUDE.md` — tech stack, constraints (if changed, rare)

**Boundary:** Checkpoint does NOT make code changes or modify project files.

**Step 1: Assess session state**

- **A. Full close-out** — all scoped work complete, or no scope existed (freeform session). Proceed through all steps.
- **B. Mid-session** — scoped work incomplete (plan doc pointer exists, not all deliverables done). Go to Step 2.
- **C. No plan doc** — freeform session, no plan doc. Skip plan doc routing. Update files from conversation context.

**Step 2: Mid-session handling** *(skip if full close-out or no plan doc was active)*

Ask: "Incomplete scoped work. What would you like to do?"
- **Pause** — fold the resume context into Active focus, preserve plan-doc
  reference in Next, commit.
  - Before writing: "Anything I should note for next time?"
- **Partial save** — mark completed deliverables, update Active focus to
  reflect progress, keep plan-doc reference in Next, commit.
- **Abandon** — mark completed deliverables, clear plan-doc reference from
  Next, update Active focus, commit.

No separate Session Context section is written. Resume context lives inside
the Active focus paragraph.

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
- **state.md** — rewrite Active focus to reflect outcome; update Next per outcome (no plan reference on full close-out / preserve plan reference on pause/partial / new direction on abandon); update Blockers and Open Questions, removing resolved/answered lines (resolutions route to decisions.md)
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

### Integration command

#### `/scaffold:integrate`

**Purpose:** Absorb controlling documents (specs, architecture docs) into scaffold and reconcile content. Three modes: absorb a specific artifact, scan for un-integrated artifacts, or sync/reconcile existing files.

**Reads:** ALL scaffold files + ALL knowledge docs + the new artifact (if provided). Loads everything into memory before proceeding — no lazy loading.

**Writes:**
- `.scaffold/knowledge/YYYYMMDD-slug.md` — copy of the artifact (absorb mode)
- `.scaffold/project.md` — requirements, scope boundaries, vision refinements
- `.scaffold/decisions.md` — decisions extracted from the artifact
- `CLAUDE.md` — hard constraints, tech stack
- `.scaffold/state.md` — active focus, open questions
- `.scaffold/roadmap.md` — phase structure changes (with approval)

**Boundary:** Integrate does NOT execute work, write plan docs, or modify project files.

**Modes:**
- **Absorb** (`/scaffold:integrate path/to/artifact`) — Copy artifact to knowledge/, extract operational info, resolve conflicts, update scaffold files.
- **Scan** (`/scaffold:integrate`) — Look for un-integrated artifacts, offer to absorb.
- **Sync** (`/scaffold:integrate --sync`) — Reconcile all existing scaffold files and knowledge docs. Fix inconsistencies, gaps, staleness, duplication.

**Conflict handling:** Compares new content against existing scaffold files. Classifies each piece as New, Consistent, Conflict, or Superseded. Presents ALL conflicts before resolving any. User approves resolutions.

**When to use integrate:** After completing a spec, architecture doc, or other major artifact. After a pivot that changed project direction. Periodically with `--sync` to clean up accumulated drift.

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

## State Determination

State is content-derived, not enum-driven. Commands determine what's true by
reading state.md and roadmap.md. This removes the drift risk of an explicit
status field that doesn't stay in sync with reality.

### Signals

| Signal | Detection |
|--------|-----------|
| Plan doc active | state.md `## Next` references a file in `.scaffold/plans/` AND that plan doc has incomplete scoped deliverables |
| USER tasks pending | Roadmap's `[IN-PROGRESS]` phase has unchecked `[USER]` deliverables AND no other unchecked AI deliverables in that phase |
| Blocked | state.md `## Blockers` has content other than "None." |
| Otherwise | Continue active focus, or run `/scaffold:plan` to recalibrate |

Signals are not mutually exclusive — a session can be blocked AND have a
plan doc active. Status command surfaces all that apply.

### Transitions (by content edit, not status flip)

```
[no plan doc]        ── /scaffold:scope               →  [plan doc active]
[plan doc active]    ── /scaffold:scope (replace)     →  [new plan doc active]
[plan doc active]    ── /scaffold:plan (re-consult)   →  [no plan doc]
[plan doc active]    ── /scaffold:do + checkpoint     →  [no plan doc]   (all done)
[plan doc active]    ── checkpoint (pause)            →  [plan doc active]   (Active focus updated)
[plan doc active]    ── checkpoint (partial save)     →  [plan doc active]   (progress recorded)
[plan doc active]    ── checkpoint (abandon)          →  [no plan doc]

[*]                  ── checkpoint (USER tasks remain) →  [USER tasks pending]
                                                          (roadmap state, not field flip)

[USER tasks pending] ── checkpoint (verified)         →  [no plan doc]

[blocked]            ── plan (resolved)               →  [no plan doc]
                                                          (resolution → decisions.md)
```

Condition labels describe what the file content shows, not enum values
stored in state.md.

## Document Update Matrix

| File | status | plan | scope | do | integrate | checkpoint |
|------|--------|------|-------|----|-----------|------------|
| state.md | — | ✓ | ✓ | — | ✓ | ✓ |
| roadmap.md | — | ✓ | — | — | ✓ (rare) | ✓ |
| decisions.md | — | ✓ | — | — | ✓ | ✓ |
| project.md | — | ✓ (requirements) | — | — | ✓ | ✓ (rare) |
| CLAUDE.md | — | — | — | — | ✓ | ✓ (rare) |
| plan doc | — | — | ✓ (creates) | reads | — | ✓ (reads for routing) |
| knowledge/ | — | reads | reads | reads | ✓ (creates) | — |
| investigations/ | — | reads | — | ✓ | reads | — |
| project files | — | — | — | ✓ | — | — |

**Key rules:**
- Do writes project files. Plan, scope, integrate, and checkpoint write scaffold files. Never the reverse.
- Scope is the only command that creates plan docs.
- Integrate is the only command that creates knowledge docs.
- Status writes nothing.

## CLAUDE.md Template

The lean template contains only what scaffold needs to operate plus project-specific
information that has nowhere else to live. Five sections total: Title, Command
Reference, Core Principle, Hard constraints, Tech stack.

### Command Reference

```markdown
## Command Reference
| Command | Role |
|---------|------|
| `/scaffold:status` | Orient — read state, present options |
| `/scaffold:plan` | Consult — discuss direction, update roadmap |
| `/scaffold:scope` | Formalize — write a plan doc for complex/multi-actor work |
| `/scaffold:do` | Execute — formal scope-controlled execution from plan doc |
| `/scaffold:checkpoint` | Save — verify, update files, commit |
| `/scaffold:integrate` | Absorb — ingest artifacts (specs, research) into scaffold |
| `/scaffold:cleanup` | Migrate existing project to current format |
| `/scaffold:update` | Update scaffold commands to latest version |
| `/scaffold:graduate` | Exit scaffold to heavier framework |
```

Reference material — orients both Claude and the user to what's available. Claude
infers natural-language → command mapping (e.g. "status" → `/scaffold:status`) from
the command descriptions; no separate Session Protocol table is needed.

### Core Principle

```markdown
## Core Principle
Every command leaves ALL state documents accurate and self-consistent.
Any command could be the last thing that runs before a week-long gap.
Commands are optional tools — the minimum ceremony is status → work → checkpoint.
```

Sets the operating contract for what every scaffold-affecting action must guarantee.

### Hard constraints and Tech stack

Project-specific placeholders. No scaffold file owns this content, so it lives in
CLAUDE.md.

### What's NOT in the template (and why)

Earlier versions included `## Who I am`, `## Rules`, `## Working`, `### Session
Protocol`, and `### Key Documents`. All five were removed:

- **Who I am** — User-calibration info belongs in `~/.claude/CLAUDE.md` (user-level
  config), not in every project.
- **Rules** — Most were per-user preferences ("ask before code changes") or workflow
  nudges Claude already does ("suggest checkpoint at low context"). The one
  scaffold-specific rule ("codebase trumps scaffold") is a behavior Claude does by
  default when it sees a contradiction.
- **Working** — `/scaffold:status` reads the plan doc; `/scaffold:do` enforces scope.
  Freeform scope discipline is per-user preference.
- **Session Protocol** — Claude infers natural-language → command mapping from the
  command descriptions in Command Reference and the available-skills list. The
  explicit table is over-instruction.
- **Key Documents** — `/scaffold:status` surfaces these when run, and the SessionStart
  hook instructs Claude to run it.

Users who want any of these as project-specific rules can add them back as custom
sections below Tech stack, or push them up to `~/.claude/CLAUDE.md` for cross-project
effect.

## AI Instruction Strategy

### Principle 1: Commands inject fresh instructions at point of need

At 400k tokens deep, CLAUDE.md rules are far away. A slash command dumps precise instructions into context at the moment they're needed. This is why commands exist alongside CLAUDE.md rules — not redundancy, but reliability at depth.

### Principle 2: Don't tell Claude what it already knows

If a behavior is already covered by Claude's defaults, by a hook, or by a slash
command's own body, CLAUDE.md doesn't restate it.

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
Plan warns: "Existing scope will be cleared. Proceed?" If yes, plan clears the plan-doc reference from Next, consults, updates roadmap. No plan doc active afterward. Old plan doc stays in `.scaffold/plans/` as history.

**Do without scope (user says "go ahead" instead):**
CLAUDE.md Working rules: "If plan doc exists, read it and follow its scope." Claude reads the doc and executes. Less reliable than do at depth, but works for most sessions. Do exists for when you want guaranteed reliability.

**Context crash mid-execution:**
State.md's Next still references the plan doc. Plan doc survives. Status detects the active plan doc, presents scope. User continues.

**Multi-actor plan in progress:**
Plan doc has USER and AI steps interleaved. Do executes AI steps, skips USER steps. Checkpoint notes pending USER items. User completes their steps. Checkpoint verifies on next run.

**Checkpoint with no commands run:**
User chatted, made decisions, never ran plan or scope or do. Checkpoint reviews conversation, captures decisions, updates state. Works.

**Deliverable takes multiple sessions:**
Roadmap item stays unchecked. Progress tracked in sub-bullets. Plan docs across sessions reference the same deliverable. When outcome is finally achieved, checkpoint marks it done.

**Requirements discovered mid-session:**
User says "that's a requirement" or it emerges from discussion. Plan adds it to project.md Requirements. Or checkpoint captures it during save. Either way, it lands in project.md.
