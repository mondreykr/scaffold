# Essentials Scaffold

Lightweight context persistence for Claude Code. Markdown files, slash commands, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Essentials Scaffold gives it memory with five markdown files and a set of slash commands. No dependencies, no config, no build step. Works in any project with or without git.

## Install

**Prerequisite:** [Node.js](https://nodejs.org/) (for `npx`).

One-time setup (installs commands for all projects):

```bash
npx degit Mondreykr/essentials-scaffold/scaffold $HOME/.claude/commands/scaffold
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
npx degit Mondreykr/essentials-scaffold/scaffold $HOME/.claude/commands/scaffold --force
```

This is safe — it only replaces the command files in `~/.claude/commands/scaffold/`. Your project data in `.scaffold/` and `CLAUDE.md` is never touched.

After updating from an older version, run `/scaffold:cleanup` to migrate your scaffold files to the current format.

If you previously installed scaffold commands per-project (into `.claude/commands/scaffold/`), `/scaffold:update` detects and removes them. Or delete `.claude/commands/scaffold/` from the project manually — project-level commands shadow user-level ones.

## How it works

The scaffold is a state machine. Every command leaves all state documents accurate and self-consistent. Any command could be the last thing that runs before a week-long gap.

### The workflow

Every session starts with `status` and ends with `checkpoint`. In between, `plan` decides what to do and `do` does it.

```
status → plan → do → checkpoint
```

| Step | What happens |
|------|--------------|
| **Status** | `/scaffold:status` reads scaffold files and gives a session briefing. Run this at the start of every session. |
| **Plan** | `/scaffold:plan` triages state, consults you on direction, updates the roadmap, and writes a plan doc. |
| **Do** | `/scaffold:do` loads the plan, researches the codebase, presents an approach for approval, then executes. |
| **Checkpoint** | `/scaffold:checkpoint` verifies work, updates scaffold files, and commits. |

Not every session needs every step. There are four paths:

| Path | Flow | When |
|------|------|------|
| **Plan + Execute** | status → plan → do → checkpoint | New work needs scoping and executing |
| **Plan Only** | status → plan → checkpoint | Brainstorming, roadmap restructuring, no code changes |
| **Execute Only** | status → do → checkpoint | Resuming scoped work from a previous session |
| **Verify Only** | status → checkpoint | Confirming completed USER tasks |

Between any commands, you can `/clear` to free up context — run `status` to re-orient. The scaffold files carry all state.

### Quick fixes

Plan scales down for simple tasks. Pass a description inline:

```
/scaffold:plan fix the broken login redirect
```

This abbreviates the consultation — same path, same output, just faster.

### Pausing and resuming

Say "pause" or "I need to stop" at any point. Checkpoint captures your progress and session context. Next session, status detects the pause and routes you back.

### USER tasks

Mark tasks that require human action with `[USER]` in the roadmap. Checkpoint walks you through verifying them when you're ready.

## Commands

| Command | What it does | When to use it |
|---------|-------------|----------------|
| `/scaffold:setup` | Creates context files and a SessionStart hook. Pass `--deep` to scan the codebase (best for brownfield projects). | Once per project, at the start |
| `/scaffold:status` | Reads scaffold files, gives a session briefing with health checks. Detects paused sessions and pending work. | Every session start, or after `/clear` |
| `/scaffold:plan` | Triages state, consults you on direction, updates roadmap, scopes work, writes a plan doc. Pass a description inline for quick scoping. | Before substantial work sessions |
| `/scaffold:do` | Loads plan, researches codebase, proposes approach, gets approval, executes. | After plan, or when resuming scoped work |
| `/scaffold:checkpoint` | Verifies work, updates scaffold files, handles phase sign-off, commits. Handles mid-session pauses and USER task verification. Pass `--audit` to verify claims against code. | End of every work session |
| `/scaffold:cleanup` | Migrates existing scaffold files to current format. Handles old formats and v1→v2 migration. | After updating from an older version |
| `/scaffold:update` | Pulls latest scaffold commands to `~/.claude/commands/scaffold/`. Detects and removes legacy per-project installs. | When a new version is available |
| `/scaffold:graduate` | Consolidates into snapshot, archives commands, hands off. Pass `--thorough` to scan for breaking references. | When you outgrow the scaffold |

## Files

Five core files provide context persistence. Additional directories are created as you work.

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Hub — identity, rules, constraints, tech stack (auto-read by Claude) |
| `.scaffold/project.md` | Vision — what you're building, for whom, success criteria |
| `.scaffold/state.md` | Status — current position, next action pointer, blockers, open questions |
| `.scaffold/roadmap.md` | Progress — phase-grouped tasks with completion tracking |
| `.scaffold/decisions.md` | Record — decisions logged chronologically (newest first), with dates and reasoning |
| `.scaffold/plans/` | Plan documents — one per planning session, scope contracts for execution |
| `.scaffold/investigations/` | Investigation output — durable research findings |

All scaffold data lives in `.scaffold/` at project root (except `CLAUDE.md`, which lives at the root so Claude auto-reads it).

## Roadmap format

Tasks are tracked in phase-grouped sections:

```markdown
## Phase 1 — Setup [COMPLETE]
- [x] Project initialization (2026-03-01)
- [x] Auth integration (2026-03-02)

## Phase 2 — Core Features [IN-PROGRESS]
- [x] Data model design (2026-03-03)
- [ ] >> API endpoints
- [ ] Frontend components
- [ ] [USER] Deploy DLL to vault

## Phase 3 — Polish [PLANNED]
- [ ] Error handling improvements
- [ ] Performance optimization

## Backlog
- Mobile app
- Public API
```

- `[IN-PROGRESS]` / `[COMPLETE]` / `[PLANNED]` — phase status. Only ONE phase `[IN-PROGRESS]` at a time.
- `[x]` — completed task. `[ ]` — incomplete task. Plain sub-bullets are detail, not tasks.
- `>>` — marks the current active task (what's being worked on right now).
- `[USER]` — marks tasks that require human action (deploying, configuring, manual testing). Verified via checkpoint rather than executed by Claude.
- `Backlog` — unassigned ideas and future work, no checkboxes needed.
- Phase sign-off requires explicit user approval during checkpoint.

## Recovery

**Lost context mid-session:**
Run checkpoint to save progress before `/clear`. If you already cleared, run status — it reads from files and gets you oriented.

**Context rot mid-session:**
`/clear` then status to start fresh from files. Long conversations degrade Claude's attention — this resets it.

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert any file.

**Files contradict each other:**
Run status — the health check flags contradictions. Tell Claude which file is correct.

**Everything feels stale:**
Clear the contents of `state.md` and `roadmap.md` (keep the files with empty sections), then run checkpoint to regenerate from the codebase.

**Old format after update:**
Run `/scaffold:cleanup` to migrate files to the current format.

**Want to re-detect tech stack or pick up new context:**
Setup won't re-run if scaffold files already exist. Delete `.scaffold/` and re-run `/scaffold:setup`, or update the files manually.

## Limitations

**Context rot within a session.** Long conversations degrade Claude's attention. This scaffold solves between-session memory, not within-session degradation. Use `/clear` and status to reset.

**No enforcement.** The persistence chain depends on Claude following the SessionStart hook and CLAUDE.md rules. Nothing forces status to run — the hook and CLAUDE.md reinforce it, but can't enforce it.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.
