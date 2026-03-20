---
description: Initialize essentials scaffold — context persistence for Claude Code
argument-hint: [--deep]
---

I'm setting up the essentials scaffold for this project — a lightweight system of
markdown files that maintain context across sessions.

**Preflight checks:**
- Check if git is initialized. If not, warn: "This project has no git repo.
  The scaffold works without it, but git gives you undo for checkpoint. Consider
  running `git init` first."
- Scan for existing files:
  - **New-path scaffold files** (`.scaffold/project.md`, `.scaffold/state.md`,
    `.scaffold/roadmap.md`, `.scaffold/decisions.md`, and `CLAUDE.md` in root)
    are **collisions** — if all five exist AND look like scaffold files, tell me and stop —
    this project is already set up.
  - **Existing CLAUDE.md without scaffold** — if `CLAUDE.md` exists in root but
    NO `.scaffold/` files exist, this is an existing Claude Code configuration:
    - Read its contents — preserve all existing rules, constraints, and tech stack
    - Archive the original to `.scaffold/archive/CLAUDE.md.pre-scaffold`
    - When creating the scaffold CLAUDE.md, merge the existing content:
      - Existing rules → add to "Rules" section (alongside scaffold rules)
      - Existing tech stack → populate "Tech stack" section
      - Existing constraints → populate "Hard constraints" section
      - Any other sections → preserve as-is below scaffold sections
    - Tell the user what was preserved and where it went
  - **Legacy scaffold files** (`CLAUDE-project.md`, `CLAUDE-state.md`, `CLAUDE-roadmap.md`,
    `CLAUDE-decisions.md` in project root) — archive them to `.scaffold/archive/`
    before creating fresh scaffold files. Log what was archived and why.
  - **Everything else** (`README.md`, `NOTES.md`, `CONTEXT.md`, `TODO.md`,
    `ARCHITECTURE.md`, etc.) is a **context source** — read for context. Most
    will be incorporated into scaffold files and archived (see Scope analysis).

**Scope analysis (existing projects only — skip for empty/new projects):**

If this project has existing code, do these three things before creating files:

1. **Auto-detect the tech stack** from dependency manifests and config files:
   `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`,
   `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, etc. Note framework
   choices, database references, and major dependencies.

2. **Scan for context-bearing files:** Look for files that carry project context:
   `TODO.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `CONTRIBUTING.md`, `PROJECT.md`,
   `CHANGELOG.md`, `.cursor/rules`, `.github/CODEOWNERS`, etc. For each file found,
   report:
   - The filename
   - Which scaffold file its content maps to (e.g., `TODO.md` → parking lot in
     `.scaffold/state.md`, `ARCHITECTURE.md` → `.scaffold/decisions.md`)
   - A one-line summary of what it contains
   - Whether it will be archived or left in place

3. **Incorporate and archive by default:** The scaffold supersedes these files:
   - Pull content into the appropriate scaffold file during creation
   - Move originals to `.scaffold/archive/` (e.g. `TODO.md` → `.scaffold/archive/TODO.md`)
   - Log what was incorporated, where it went, and that the original was archived
   - **Exception:** `README.md` stays in place (serves GitHub/npm/external purposes) — read for context only
   - Present scan results and tell the user what will happen. Don't wait for file-by-file confirmation. If the user objects to a specific file being archived, respect that.

**Create the file structure:**

Create all five files using the templates below. For existing projects, populate
the templates with information gathered during scope analysis (after confirmation).
For new projects, use the placeholder text as-is.

1. **CLAUDE.md** — The hub. Claude reads this automatically. Lives in project root.

```markdown
# [Project Name]

## Who I am
- Comfortable with: [e.g. "terminal, git basics, reading code"]
- Less familiar with: [e.g. "databases, deployment, CSS"]
- Communication: [e.g. "Explain the why, skip the how unless I ask"]

## Rules
- Consult .scaffold/decisions.md when making or revisiting technology/architecture/design choices
- Ask before making architectural or structural changes
- If any scaffold file contradicts what you observe in the codebase, trust the codebase. State the contradiction to me explicitly and await my approval before proceeding.
- If a session is getting long and available context is less than 40%, pause the work and suggest /scaffold:checkpoint for completed work before continuing
- If we made decisions, found bugs, discussed scope changes, or planned future work and I haven't said "checkpoint" — remind me before the session ends

## Working
- Before making code changes: research the relevant code, present your approach, get approval
- One task at a time. Verify each works before starting the next.
- Only work on tasks in the current scope (see state.md Next Action)
- Out-of-scope discoveries get noted for checkpoint, not acted on now

### Session Protocol
| User says | Action |
|-----------|--------|
| "status" | Run `/scaffold:status` |
| "plan" / "let's think" | Run `/scaffold:plan` |
| "do it" / "go ahead" / "execute" | Run `/scaffold:do` — always invoke the command, do not begin execution without it |
| "checkpoint" / "save" | Run `/scaffold:checkpoint` |
| "pause" / "I need to stop" | Run `/scaffold:checkpoint` (mid-session) |
| "decision: [X]" | Log in `.scaffold/decisions.md` |

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

### Core Principle
Every command leaves ALL state documents accurate and self-consistent.
Any command could be the last thing that runs before a week-long gap.
Plan updates scaffold files directly — user approves roadmap changes before they're written.

### Key Documents
- `.scaffold/roadmap.md` — Phase plan and task tracking
- `.scaffold/state.md` — Current status and next action pointer
- `.scaffold/decisions.md` — Design and architecture decisions
- `.scaffold/project.md` — Project definition and scope
- `.scaffold/plans/` — Plan documents (execution contracts)
- `.scaffold/investigations/` — Investigation output (durable research findings)

## Hard constraints
- [Things that must be true. Examples:]
- [Must work on mobile]
- [Budget under $X/month for services]
- [No paid APIs unless I approve]
- [Remove this section if none yet]

## Tech stack
- [e.g. "Next.js with App Router, Tailwind CSS, Supabase"]
- [Empty is fine early on]
```

2. **`.scaffold/project.md`** — The vision. What this project is and where it's going.

```markdown
<!-- Last updated: [today's date] -->
# Project Vision

## What is this?
[What are you building, or what problem are you trying to solve?
It's fine to be vague: "A tool that might help dog walkers manage their routes."
It's fine to be specific: "A SaaS platform for freelance dog walkers to plan
optimized multi-stop routes, manage client scheduling, and track walk history."
Write what's true right now.]

## Who is it for?
[Who would use this? Can be "just me" or a target audience.]

## What does success look like?
[How will you know it's working? What's the minimum thing that would make
this feel real? e.g. "I can add stops to a map and it saves them."]

## Scope boundaries
[What is this NOT? What are you explicitly choosing not to build, at least for now?
e.g. "Not a social network. No sharing features yet. Single user only for now."]
```

3. **`.scaffold/state.md`** — Where we are NOW. Changes every session.

```markdown
<!-- Last updated: [today's date] -->
# State

## Status
[idle / scoped / user-pending / paused / blocked]

## Current Position
[Synopsis of the active phase, recent completions, and project health.
1-3 sentences that orient someone picking this up cold.]

## Next Action
[What's queued for next execute — summary of scoped tasks.
Plan: `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`
If nothing queued: "Run /scaffold:plan to determine next steps."]

## Blockers
- [Things preventing progress]

## Open Questions
- [Unknowns that need answers]

```

4. **`.scaffold/roadmap.md`** — The plan. Phase-grouped progress tracking.

```markdown
<!-- Last updated: [today's date] -->
# Roadmap

## Phase 1 — Exploration [IN-PROGRESS]
- [ ] [First task or deliverable]

## Backlog
- [Ideas not yet assigned to a phase]
```

For existing projects with known phases, create appropriate phase structure
instead of the default "Exploration" phase. Use information from scope analysis
to populate phases and tasks.

Phase rules:
- Only ONE phase may be `[IN-PROGRESS]` at a time
- Completed phases are marked `[COMPLETE]` — only with explicit user sign-off (during checkpoint)
- ALL phases use checkboxes for tasks (including `[PLANNED]` phases)
- Plain sub-bullets are for clarification or detail, not tasks
- `Backlog` absorbs future ideas and unassigned work

Task conventions:
- `- [x] Completed task (YYYY-MM-DD)` — done, with completion date
- `- [ ] >> Active task being worked on` — in progress
- `- [ ] Upcoming task` — in any phase (including PLANNED and Backlog)
  - Plain sub-bullet for detail or clarification

5. **`.scaffold/decisions.md`** — The record. Why things are the way they are.

Decisions are logged chronologically, newest first. Each entry carries a `Category:` field for filtering.

```markdown
<!-- Last updated: [today's date] -->
# Decisions

### [Date] — [What was decided]
**Category:** Tech | Architecture | Design | Scope | Resolved Blocker
**Context:** [What prompted this choice]
**Decision:** [What was chosen]
**Why:** [The reasoning — even if informal]
**Status:** Active | Revisiting | Reversed

---

[Example:]

### 2026-02-27 — Supabase for database and auth
**Category:** Architecture
**Context:** Need a database and user authentication. Don't want to manage infrastructure.
**Decision:** Supabase (PostgreSQL + built-in auth)
**Why:** Free tier covers prototyping. Auth is built in so I don't have to wire it up
separately. Claude has strong familiarity with the SDK.
**Status:** Active

---

### 2026-02-27 — Next.js with App Router
**Category:** Tech
**Context:** Needed to pick a framework. No strong preference.
**Decision:** Next.js with App Router and Tailwind CSS
**Why:** Claude recommended it as the most straightforward full-stack option
for a solo builder. Good defaults, large community, easy Vercel deployment.
**Status:** Active

---

## Archived
[Reversed or superseded decisions. Kept for historical context.]
```

6. **Verify companion commands** — confirm that `status.md`, `plan.md`,
   `do.md`, `checkpoint.md`, `cleanup.md`, `graduate.md`, and `update.md`
   exist as sibling files in this same folder. If any are missing, tell me —
   they should have been installed together.

7. **Create or update `.claude/hooks.json`** — SessionStart hook for automatic
   scaffold context loading.

   If `.claude/hooks.json` does not exist, create it:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "type": "command",
           "command": "test -f .scaffold/state.md && echo '{\"additionalContext\": \"[SCAFFOLD] This project uses essentials-scaffold for context persistence. Scaffold files are at .scaffold/. Run /scaffold:status to orient before starting work. Do not skip this step even if the task seems simple.\"}' || true"
         }
       ]
     }
   }
   ```

   If `.claude/hooks.json` already exists, add the SessionStart hook entry
   to the existing hooks without overwriting other hooks. If a SessionStart
   hook already exists, append to the array.

**After creating everything:**
- If git is initialized: stage new files and any deletions from archiving, then commit: `git add CLAUDE.md .scaffold/ && git add -u && git commit -m "init: essentials scaffold"`
- Give me a summary of what was set up, what content was incorporated (and from where), what was archived, and what I should fill in or verify.

**Enhanced mode (`/scaffold:setup --deep`):**

If "--deep" appears in the arguments, do everything above AND launch an Explore
subagent (thoroughness: "very thorough") after creating scaffold files to:

1. Analyze code structure — identify top-level modules, key entry points,
   and how the codebase is organized
2. Map architectural patterns — routing approach, state management, data flow,
   API layer structure
3. Surface conventions — naming patterns, file organization rules, import style,
   test location conventions
4. Identify undocumented dependencies — things that aren't in manifests but
   matter (build tools, CI assumptions, environment requirements)

Feed subagent findings back into the scaffold files:
- Architectural patterns → .scaffold/decisions.md (as discovered conventions, not decisions)
- Module structure → .scaffold/project.md "What is this?" section
- Known issues or TODOs found in code → .scaffold/state.md
