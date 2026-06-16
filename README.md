# Essentials Scaffold

Lightweight context persistence for Claude Code. Markdown files, slash commands, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Essentials Scaffold gives it memory with five markdown files and a set of slash commands. No dependencies, no config, no build step. Works in any project with or without git.

## Install

**Prerequisite:** [Node.js](https://nodejs.org/) (for `npx`).

One-time setup (installs commands for all projects):

```bash
npx degit mondreykr/scaffold/scaffold $HOME/.claude/commands/scaffold
```

Or copy the `scaffold/` folder to `~/.claude/commands/scaffold/` manually if you already have the repo.

Then, in any project:

1. Open Claude Code
2. Run `/scaffold:setup`

That's it. The setup command creates your context files and walks you through filling them in. Commands are installed once at the user level and available in every project.

## Updating

Run `/scaffold:update` to pull the latest commands. This also detects and removes legacy per-project installs.

Or manually:

```bash
npx degit mondreykr/scaffold/scaffold $HOME/.claude/commands/scaffold --force
```

This is safe — it only replaces the command files in `~/.claude/commands/scaffold/`. Your project data in `.scaffold/` and `CLAUDE.md` is never touched.

After updating from an older version, run `/scaffold:cleanup` to migrate your scaffold files to the current format.

## How it works

The scaffold is a state machine. Every command leaves all state documents accurate and self-consistent. Any command could be the last thing that runs before a week-long gap.

### Minimum ceremony

Every session starts with `status` and ends with `checkpoint`. Everything in between is up to you.

```
status → [work with Claude] → checkpoint
```

That's the whole system. The other commands are tools you reach for when you need them — not gates you pass through every time.

### When you need more structure

| Command | What it's for | When to use it |
|---------|--------------|----------------|
| `/scaffold:plan` | "Help me figure out what's next." Discuss direction, update roadmap. | When you need to recalibrate or don't know what to work on. |
| `/scaffold:scope` | "Write up a formal plan." Create a scope contract for complex work. | When work involves multiple steps, multiple actors (you + Claude), or will span sessions. |
| `/scaffold:do` | "Execute the plan." Formal scope-controlled execution. | When a plan doc exists and you want reliable scope control. |
| `/scaffold:integrate` | "Absorb this spec." Ingest artifacts into scaffold. | After completing a spec, architecture doc, or other major artifact. Also `--sync` to reconcile files. |

These are independent tools. Use them in any combination:

```
Freeform:  status → work → checkpoint
Guided:    status → plan → work → checkpoint
Scoped:    status → plan → scope → do → checkpoint
With artifacts: integrate → plan → scope → do → checkpoint
```

### Quick fixes

Just start working after status. No plan or scope needed. Checkpoint saves whatever happened.

### Pausing and resuming

Say "pause" or "I need to stop" at any point. Checkpoint captures your progress and updates state.md's Active focus to reflect where you left off. Next session, status reads state.md and tells you where to pick up.

### USER tasks

Mark deliverables that require human action with `[USER]` in the roadmap. Checkpoint walks you through verifying them when you're ready.

## Commands

| Command | What it does | When to use it |
|---------|-------------|----------------|
| `/scaffold:setup` | Creates context files and a SessionStart hook. Pass `--deep` to scan the codebase. | Once per project |
| `/scaffold:status` | Reads scaffold files, gives a session briefing with health checks. | Every session start, or after `/clear` |
| `/scaffold:plan` | Discusses direction, updates roadmap and state, helps figure out what's next. | When you need to recalibrate |
| `/scaffold:scope` | Writes a plan doc — scope contract for complex or multi-actor work. | When you want a formal plan |
| `/scaffold:do` | Loads plan doc, proposes approach, executes with scope control. | When a plan doc exists and you want formal execution |
| `/scaffold:checkpoint` | Verifies work, updates scaffold files, commits. Handles pauses and USER task verification. Pass `--audit` to verify against code. | End of every session, or whenever you want to save |
| `/scaffold:integrate` | Absorbs an artifact (spec, architecture doc) into scaffold. Extracts requirements, decisions, constraints. Pass `--sync` to reconcile existing files without a new artifact. | After completing a spec or major artifact, or periodically to clean up drift |
| `/scaffold:cleanup` | Migrates scaffold files to current format. | After updating from an older version |
| `/scaffold:update` | Pulls latest scaffold commands. | When a new version is available |
| `/scaffold:graduate` | Consolidates into snapshot, archives, hands off. Pass `--thorough` to scan for references. | When you outgrow the scaffold |

## Files

Five core files provide context persistence.

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Hub — identity, rules, constraints, tech stack (auto-read by Claude) |
| `.scaffold/project.md` | Vision — what you're building, for whom, requirements (verifiable checkboxes) |
| `.scaffold/state.md` | State — active focus, next, blockers, open questions (forward-looking only) |
| `.scaffold/roadmap.md` | Progress — phases with acceptance criteria and deliverable tracking |
| `.scaffold/decisions.md` | Record — decisions logged chronologically with rationale |
| `.scaffold/plans/` | Plan documents — scope contracts for complex work (created by `/scaffold:scope`) |
| `.scaffold/investigations/` | Investigation output — durable research findings |
| `.scaffold/knowledge/` | Controlling documents — specs, architecture docs, design docs (created by `/scaffold:integrate`) |

All scaffold data lives in `.scaffold/` at project root (except `CLAUDE.md`, which lives at the root so Claude auto-reads it).

## Roadmap format

Phases have acceptance criteria (numbered) and deliverables (checkboxes):

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

- Phase criteria are **numbered** — evaluated as a set during phase sign-off.
- Deliverables are **checkboxes** — checked when the outcome is achieved (may span multiple sessions).
- Sub-bullets are **progress notes**, not tasks. Tasks live in plan docs.
- `[USER]` marks deliverables requiring human action.
- `Backlog` holds unassigned ideas. No checkboxes needed.
- Phase sign-off requires explicit user approval during checkpoint.

## Integrating specs and other artifacts

When a phase produces a major artifact — a spec, architecture doc, design system doc — that artifact contains requirements, decisions, and constraints that future phases need. The integrate command absorbs it into scaffold:

```
/scaffold:integrate docs/my-spec/SPEC.md
```

This does three things:
1. **Stores** a copy in `.scaffold/knowledge/` (scaffold's own knowledge base)
2. **Extracts** requirements, decisions, and constraints into scaffold files
3. **Resolves conflicts** between the artifact and existing scaffold content

Knowledge docs are then read by plan, scope, and do when working on related phases — so the spec's detailed flows, design direction, and implementation specs are available where they're needed.

Run `/scaffold:integrate --sync` periodically to reconcile all scaffold files without a new artifact — catches drift, duplication, and stale content.

## Recovery

**Lost context mid-session:**
Run checkpoint to save progress before `/clear`. If you already cleared, run status — it reads from files.

**Context rot mid-session:**
`/clear` then status to start fresh. Long conversations degrade Claude's attention.

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert.

**Files contradict each other:**
Run status — health check flags contradictions. Tell Claude which file is correct.

**Everything feels stale:**
Clear the contents of `state.md` and `roadmap.md`, then run checkpoint to regenerate from the codebase.

**Old format after update:**
Run `/scaffold:cleanup` to migrate files to the current format.

## Limitations

**Context rot within a session.** Long conversations degrade Claude's attention. This scaffold solves between-session memory, not within-session degradation. Use `/clear` and status to reset.

**No enforcement.** The persistence chain depends on Claude following the SessionStart hook and CLAUDE.md rules. Nothing forces status to run — the hook and CLAUDE.md reinforce it, but can't enforce it.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.
