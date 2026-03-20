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

### Main workflow

```
status → plan → prime → execute → checkpoint
                ╰─ plan mode ─╯
```

| Step | What happens |
|------|--------------|
| **Status** | `/scaffold:status` reads scaffold files and gives a session briefing. Run this at the start of every session. |
| **Plan** | `/scaffold:plan` triages state, consults you on direction, updates the roadmap, and writes a plan doc. |
| **Prime** | Enter plan mode (`Shift+Tab`), then run `/scaffold:prime`. It loads the plan doc into context — Claude researches the codebase and presents an approach for approval. |
| **Execute** | After you approve, Claude executes within plan mode. This isn't a separate command — it's what plan mode does after prime loads the contract. |
| **Checkpoint** | `/scaffold:checkpoint` verifies work, marks tasks complete, handles phase sign-off, and commits. |

Between any commands, you can `/clear` to free up context — the scaffold files carry all state.

Not every session needs execution. `/scaffold:plan` determines the session type: some sessions produce codebase changes (execution), some are just roadmap restructuring or brainstorming (state-only), and some scope work that only you can do like deploying or manual testing (user-action). Plan tells you what comes next.

**User tasks:** Mark tasks that require human action with `[USER]` in the roadmap. After completing them, run `/scaffold:verify` to walk through each one and update state.

### Quick workflow

```
quick → quick-execute
```

For small fixes that don't warrant full planning. Quick tasks are tracked in `.scaffold/quick/` and don't disrupt the main workflow.

## Commands

| Command | What it does | When to use it |
|---------|-------------|----------------|
| `/scaffold:setup` | Creates context files and a SessionStart hook. Pass `--deep` to scan the codebase (best for brownfield projects). | Once per project, at the start |
| `/scaffold:status` | Reads scaffold files, gives a session briefing with health checks. Detects paused sessions and pending work. | Every session start, or after `/clear` |
| `/scaffold:plan` | Triages state, consults you on direction, updates roadmap, scopes work, writes a plan doc. | Before substantial work sessions |
| `/scaffold:prime` | Loads plan context into Claude's plan mode. Claude researches approach, gets approval, then executes. | After plan, in plan mode (`Shift+Tab`) |
| `/scaffold:checkpoint` | Verifies work, updates scaffold files, handles phase sign-off, commits. Pass `--audit` to verify claims against code. | End of every work session |
| `/scaffold:pause` | Captures full session context to a handoff file for seamless resumption. | When you need to stop mid-work and pick up later |
| `/scaffold:resume` | Restores context from a paused session and routes to next action. | Start of session when a pause file exists |
| `/scaffold:quick` | Plans a quick fix. Pass `--discuss` for a clarification phase. Pass a description inline (e.g., `/scaffold:quick fix the broken login redirect`). | Urgent fixes that don't warrant full planning |
| `/scaffold:quick-execute` | Executes a pending quick task — fix, verify, record, commit. | After `/scaffold:quick` plans a task |
| `/scaffold:verify` | Walks through pending `[USER]` tasks one at a time, verifies completion, updates roadmap and state. | After completing user tasks from a plan |
| `/scaffold:cleanup` | Migrates existing scaffold files to current format. Handles old checkbox/section conventions. | After updating from an older version |
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
| `.scaffold/plans/` | Plan documents — execution contracts produced by `/scaffold:plan` |
| `.scaffold/investigations/` | Investigation output — durable research findings from investigation tasks |
| `.scaffold/quick/` | Quick task plans and summaries — lightweight fixes tracked outside the main workflow |

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
- `[USER]` — marks tasks that require human action (deploying, configuring, manual testing). Verified via `/scaffold:verify` rather than executed by Claude.
- `Backlog` — unassigned ideas and future work, no checkboxes needed.
- Phase sign-off requires explicit user approval during checkpoint.

## Recovery

**Pausing and resuming:**
Use `/scaffold:pause` when you need to stop mid-work — it captures full session context to a handoff file. Next session, `/scaffold:status` detects the pause and routes you to `/scaffold:resume`.

**Lost context mid-session:**
Run `/scaffold:pause` before `/clear` to save context. If you already cleared, run `/scaffold:status` — it reads from files and gets you oriented.

**Context rot mid-session:**
`/clear` then `/scaffold:status` to start fresh from files. Long conversations degrade Claude's attention — this resets it.

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert any file.

**Files contradict each other:**
Run `/scaffold:status` — the health check flags contradictions. Tell Claude which file is correct.

**Everything feels stale:**
Clear the contents of `state.md` and `roadmap.md` (keep the files with empty sections), then run `/scaffold:checkpoint` to regenerate from the codebase.

**Old format after update:**
Run `/scaffold:cleanup` to migrate files to the current format.

**Want to re-detect tech stack or pick up new context:**
Setup won't re-run if scaffold files already exist. Delete `.scaffold/` and re-run `/scaffold:setup`, or update the files manually.

## Limitations

**Context rot within a session.** Long conversations degrade Claude's attention. This scaffold solves between-session memory, not within-session degradation. Use `/clear` and `/scaffold:status` to reset.

**No enforcement.** The persistence chain depends on Claude following the SessionStart hook and CLAUDE.md rules. Nothing forces `/scaffold:status` to run — the hook and CLAUDE.md reinforce it, but can't enforce it.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.
