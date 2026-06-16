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
    - Read its contents
    - Archive the original to `.scaffold/archive/CLAUDE.md.pre-scaffold`
    - When creating the scaffold CLAUDE.md, merge existing content as follows:
      - Existing tech stack → populate "Tech stack" section
      - Existing hard constraints → populate "Hard constraints" section
      - **Other content (rules, preferences, communication notes, "who I am" info, etc.)**
        does not map cleanly to the lean template. Do NOT silently merge it. Present
        each non-empty section found to the user and ask: "Found `## [section]` in the
        existing CLAUDE.md. Options: (a) drop — Claude defaults cover it, (b) move to
        `~/.claude/CLAUDE.md` (user-level config), (c) keep as a custom section in this
        project's CLAUDE.md." Wait for the user's choice per section before merging.
    - Tell the user what was preserved, dropped, or relocated
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
   - Which scaffold file its content maps to (e.g., `TODO.md` → `.scaffold/roadmap.md`
     Backlog, `ARCHITECTURE.md` → `.scaffold/decisions.md`)
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

## Core Principle
Every command leaves ALL state documents accurate and self-consistent.
Any command could be the last thing that runs before a week-long gap.
Commands are optional tools — the minimum ceremony is status → work → checkpoint.

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

The lean template includes only what scaffold needs to operate (Command Reference as
reference material for the available commands; Core Principle as the operating
contract) plus project-specific information that has nowhere else to live (Hard
constraints, Tech stack). Generic rules like "ask before code changes" or "note
out-of-scope discoveries" are intentionally omitted — they're per-user preferences
that belong in `~/.claude/CLAUDE.md`, not in every project. Natural-language → command
mapping (e.g. "status" → `/scaffold:status`) is left to Claude to infer from command
descriptions. Orientation comes from the SessionStart hook (Step 7) which directs
Claude to run `/scaffold:status`.

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

## Requirements
[Verifiable product rules. Add these as you discover them. Examples:]
- [ ] [Must work on mobile]
- [ ] [All inputs validated]
- [ ] [Performance under 2 seconds]
- [ ] [Remove this section if none yet]
```

3. **`.scaffold/state.md`** — Where we are NOW. Forward-looking. Changes every session.

```markdown
<!-- Last updated: [today's date] -->
# State

## Active focus
[One paragraph. Synopsis + forward-look. Where things are, what's in flight,
what's driving the work.

**ELI5 — explain it like the reader is five.** Plain words, short sentences,
no jargon shortcuts, no status-report officialese. If a five-year-old
wouldn't follow the gist, rewrite it.

No bullets, no code blocks, no quoted prompts. Grows only when the
situation genuinely requires it.]

## Next
[The concrete action when you resume. 1-2 sentences or short bullets.
References the plan doc by path if one is active.]

## Blockers
None.

## Open Questions
None.
```

**State is forward-looking, not a log.** Four sections. No status enum,
no Session Context, no Closed archive, no project-specific carve-outs.

- **Active focus** is one paragraph, plain language. Captures synopsis +
  forward-look in one. Grows only when genuinely needed.
- **Blockers** and **Open Questions** are always present with "None." when
  empty — confirms the writer checked; absent sections would be ambiguous.
- **When a Blocker or Open Question resolves:** remove the line and place
  the resolution where it belongs (decisions.md / roadmap.md / commit log).
  State does not accumulate resolved items.

4. **`.scaffold/roadmap.md`** — The plan. Phase-grouped progress tracking.

```markdown
<!-- Last updated: [today's date] -->
# Roadmap

## Phase 1 — Exploration [IN-PROGRESS]
Phase complete when:
1. [Acceptance condition for this phase]

- [ ] [First deliverable]

## Backlog
- [Ideas not yet assigned to a phase]
```

For existing projects with known phases, create appropriate phase structure
instead of the default "Exploration" phase. Use information from scope analysis
to populate phases and deliverables.

Phase rules:
- Only ONE phase may be `[IN-PROGRESS]` at a time
- Completed phases are marked `[COMPLETE]` — only with explicit user sign-off (during checkpoint)
- Phase criteria are numbered (not checkboxes) — evaluated as a set during sign-off
- Deliverables are checkboxes — checked when the outcome is achieved
- Sub-bullets under deliverables are progress notes, not tasks
- `[USER]` marks deliverables requiring human action
- `Backlog` absorbs future ideas and unassigned work

Deliverable conventions:
- `- [x] Completed deliverable (YYYY-MM-DD)` — done, with completion date
- `- [ ] In-progress deliverable` — not yet complete
  - Sub-bullet for progress notes or clarification
- `- [ ] [USER] Human-owned deliverable` — requires user action

5. **`.scaffold/decisions.md`** — The record. The load-bearing *why* behind
   choices you could otherwise reverse and regret.

Logged chronologically, newest first. Each entry carries a `Category:` field for filtering.

- **Logging bar — selective, not a journal.** Log a decision only if future-you,
  looking at only `project.md` and the code, could undo it and regret it —
  because the reasoning isn't visible there (non-obvious choice, tempting
  rejected alternative, costly to reverse blind). Skip what's self-evident,
  trivially reversible, or already plain in the code.
- **Curated, not append-only — git is the history.** Edit an entry in place
  when its decision is refined. Prune an entry (delete it) when it no longer
  guards anything — the alternative is now impossible, the choice has become
  self-evident, or it was replaced. There is no `Status` field and no
  `## Archived` graveyard: a reversed decision is removed, not flagged. `git log`
  / `git blame` this file for how a decision was reached or unwound. (No git in
  this project? Replace the entry with a one-line "superseded by …" note in
  place of deleting.)

```markdown
<!-- Last updated: [today's date] -->
# Decisions

### [Date] — [What was decided]
**Category:** Tech | Architecture | Design | Scope | Resolved Blocker
**Context:** [What prompted this choice]
**Decision:** [What was chosen]
**Why:** [The reasoning — even if informal. If a tempting alternative was rejected, name it and why; that's the guardrail.]

---

[Example:]

### 2026-02-27 — Supabase for database and auth
**Category:** Architecture
**Context:** Need a database and user authentication. Don't want to manage infrastructure.
**Decision:** Supabase (PostgreSQL + built-in auth)
**Why:** Free tier covers prototyping. Auth is built in so I don't wire it up
separately. Rejected raw Postgres + a custom auth layer — more control, but
weeks of work this prototype doesn't need.

---

### 2026-02-27 — Next.js with App Router
**Category:** Tech
**Context:** Needed to pick a framework. No strong preference.
**Decision:** Next.js with App Router and Tailwind CSS
**Why:** Most straightforward full-stack option for a solo builder. Good
defaults, large community, easy Vercel deployment.
```

6. **Verify companion commands** — confirm that `status.md`, `plan.md`,
   `scope.md`, `do.md`, `checkpoint.md`, `integrate.md`, `cleanup.md`,
   `graduate.md`, and `update.md` exist as sibling files in this same
   folder. If any are missing, tell me — they should have been installed
   together.

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
