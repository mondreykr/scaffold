---
description: Initialize scaffold — context persistence for Claude Code
---

I'm setting up Scaffold for this project — a lightweight system of
markdown files that maintain context across sessions.

**Preflight checks:**
- Check if git is initialized. If not, warn: "This project has no git repo.
  The scaffold works without it, but git gives you undo for checkpoint. Consider
  running `git init` first."
- Scan for existing files:
  - **New-path scaffold files** (`.scaffold/project.md`,
    `.scaffold/architecture.md`, `.scaffold/roadmap.md`, `.scaffold/state.md`)
    are **collisions** — if any of these exist, tell me and stop, this project
    is already set up. **A root `CLAUDE.md` on its own is NOT a collision** — a
    project can have a hand-written `CLAUDE.md` and no `.scaffold/` yet; that's
    the adopt case (third bullet below), not "already set up." Only the presence
    of `.scaffold/` truth docs means already-set-up.
  - **Old-format scaffold files** (`.scaffold/decisions.md` as a single file,
    `.scaffold/plans/`, a per-phase `roadmap.md`, or `CLAUDE-*.md` in root) —
    this is a pre-restructure scaffold. Do NOT overwrite it. Tell me:
    "Found an older scaffold layout. Run `/scaffold:cleanup` to migrate it to
    the current structure — `setup` is for fresh projects only." Then stop.
  - **Existing CLAUDE.md without scaffold** — if `CLAUDE.md` exists in root but
    NO `.scaffold/` files exist, this is an existing Claude Code configuration:
    - Read its contents
    - Archive the original to `.scaffold/archive/CLAUDE.md.pre-scaffold`
    - When creating the scaffold CLAUDE.md, sort existing content as follows:
      - Existing **product/what-it-is** content → seed the CLAUDE.md orientation
        lines and `.scaffold/project.md`
      - Existing **tech stack, data-access, deployment, conventions** → seed
        `.scaffold/architecture.md` (NOT CLAUDE.md — architecture truth lives there now)
      - Existing **hard constraints / rules that govern how Claude works here**
        → keep as a `## Hard constraints` section in CLAUDE.md
      - **Other content (preferences, communication notes, "who I am" info, etc.)**
        does not map cleanly. Do NOT silently merge it. Present each non-empty
        section found and ask: "Found `## [section]` in the existing CLAUDE.md.
        Options: (a) drop — Claude defaults cover it, (b) move to
        `~/.claude/CLAUDE.md` (user-level config), (c) keep as a custom section in
        this project's CLAUDE.md." Wait for the user's choice per section.
    - Tell the user what was preserved, where it landed, and what was dropped or relocated
  - **Everything else** (`README.md`, `NOTES.md`, `CONTEXT.md`, `TODO.md`,
    `ARCHITECTURE.md`, etc.) is a **context source** — read for context. Most
    will be incorporated into scaffold files and archived (see Scope analysis).

**Scope analysis (existing projects only — skip for empty/new projects):**

If this project has existing code, do these three things before creating files:

1. **Auto-detect the tech stack** from dependency manifests and config files:
   `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`,
   `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, etc. Note framework
   choices, database references, deployment config, and major dependencies.

2. **Scan for context-bearing files:** Look for files that carry project context:
   `TODO.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `CONTRIBUTING.md`, `PROJECT.md`,
   `CHANGELOG.md`, `.cursor/rules`, `.github/CODEOWNERS`, etc. For each file found,
   report:
   - The filename
   - Which scaffold file its content maps to (e.g. `ARCHITECTURE.md` →
     `.scaffold/architecture.md`; `TODO.md` → `.scaffold/roadmap.md` Backlog).
     **A `DECISIONS.md` or decision-bearing doc is NOT curated here** — setup
     does not run the ADR-promotion gate (that is `cleanup`/`integrate`'s job,
     to keep the ADR-bar logic in one place). Note the file and recommend
     `/scaffold:integrate` after setup.
   - A one-line summary of what it contains
   - Whether it will be archived or left in place

3. **Incorporate and archive by default:** The scaffold supersedes these files:
   - Pull content into the appropriate scaffold file during creation
   - **If git is initialized**, move originals to `.scaffold/archive/`
     (e.g. `TODO.md` → `.scaffold/archive/TODO.md`) — git retains history, so
     the move is reversible. **If there is NO git repo**, do NOT move or delete:
     *copy* the content out and leave the originals in place (there is no undo
     point), and say so.
   - Log what was incorporated, where it went, and whether the original was
     archived or left in place
   - **Exception:** `README.md` stays in place (serves GitHub/npm/external purposes) — read for context only
   - Present scan results and tell the user what will happen. Don't wait for
     file-by-file confirmation. If the user objects to a specific file being
     archived, respect that.

---

**Create the file structure.**

The target layout (contract §5):

```
CLAUDE.md                  orientation + instructions + pointer into .scaffold/
.scaffold/
  project.md               what this product is & why (living)
  architecture.md          how it's built — tech truth (living)
  roadmap.md               the program: milestone index + backlog (living)
  state.md                 where we are now / next / blockers / questions (living)
  knowledge/               durable domain/behavioral rules (living) — starts empty
  decisions/               ADRs — load-bearing why (frozen, Adam-gated) — starts empty
  investigations/          research & analysis records (frozen) — starts empty
  milestones/
    01-<slug>/             the first chunk of work
      plan.md              phase plan + objectives + done-contract
      phases/              phase briefs — starts empty (emergent default)
```

Create the empty directories (`knowledge/`, `decisions/`, `investigations/`,
`milestones/01-<slug>/phases/`) — add a `.gitkeep` to each empty one so git
tracks it. Then create the files below. For existing projects, populate the
templates with information gathered during scope analysis (after confirmation).
For new projects, use the placeholder text as-is.

**The seed milestone slug.** Default to `01-main`. The slug is a **sticky
namespace** — phase briefs live at `milestones/01-main/phases/`, and `state.md`
Next, `roadmap.md`, and any briefs point at it by path. Pick something
rename-cheap and generic now; rename it later once the work has a real name
(see "Renaming the seed milestone" below). If the user already knows what the
first chunk of work is, ask for a slug and use `01-<that-slug>`.

1. **CLAUDE.md** — The hub. Claude reads this automatically. Lives in project root.
   It carries how-Claude-works-here instructions plus a short product orientation
   and a pointer into `.scaffold/`. It does **not** carry tech stack, data-access,
   or deployment — that is architecture truth and lives in `.scaffold/architecture.md`.

```markdown
# [Project Name]

[3–5 line product orientation: what this is, who it's for, and the single most
important thing to know before touching the code. Plain language. This is the
fast read; the durable detail lives in `.scaffold/`.]

For context: see `.scaffold/project.md` (what & why),
`.scaffold/architecture.md` (how it's built), `.scaffold/roadmap.md` (the
program), and `.scaffold/state.md` (where we are now). Run `/scaffold:status`
at the start of every session.

## Command Reference
| Command | Role |
|---------|------|
| `/scaffold:status` | Orient — read state, present options |
| `/scaffold:plan` | Author — discuss direction, persist into scaffold docs |
| `/scaffold:go` | Execute — build the phase brief Next points at |
| `/scaffold:checkpoint` | Save — verify, reconcile, update docs, commit |
| `/scaffold:integrate` | Absorb — ingest an external artifact (spec, research) |
| `/scaffold:cleanup` | Migrate an older scaffold layout to the current format |
| `/scaffold:update` | Update scaffold commands to latest version |

## Core Principle
Every command leaves ALL state documents accurate and self-consistent.
Any command could be the last thing that runs before a week-long gap.
Commands are optional tools — the minimum ceremony is status → work → checkpoint.

## Hard constraints
- [Things that must be true. Examples:]
- [Must work on mobile]
- [No paid APIs unless I approve]
- [Remove this section if none yet]
```

The template includes only what scaffold needs to operate (the orientation +
pointer so a cold read knows where everything lives; Command Reference; Core
Principle) plus how-Claude-works-here rules that have nowhere else to live (Hard
constraints). Generic preferences like "ask before code changes" belong in
`~/.claude/CLAUDE.md`, not in every project. Tech stack moved to
`architecture.md`. Natural-language → command mapping is left to Claude to infer
from command descriptions.

2. **`.scaffold/project.md`** — Product identity. What this is and why. (living)

```markdown
<!-- Last updated: [today's date] -->
# Project

## What is this?
[What are you building, or what problem are you solving? Vague is fine early:
"A tool that might help dog walkers manage their routes." Specific is fine too.
Write what's true right now.]

## Who is it for?
[Who would use this? Can be "just me" or a target audience.]

## What does success look like?
[How will you know it's working? The minimum thing that would make this feel
real. e.g. "I can add stops to a map and it saves them."]

## Scope boundaries
[What is this NOT? What are you explicitly choosing not to build, at least for
now? e.g. "Not a social network. Single user only for now."]

## Requirements
[Verifiable product rules. Add these as you discover them. Examples:]
- [ ] [Must work on mobile]
- [ ] [All inputs validated]
- [ ] [Remove this section if none yet]
```

`project.md` answers *what the product is* — not *how it's built* (that's
architecture.md). If it ever can't hold more than CLAUDE.md's orientation already
says, drop it rather than keep it for symmetry.

3. **`.scaffold/architecture.md`** — How it's built. Current technical truth. (living)

```markdown
<!-- Last updated: [today's date] -->
# Architecture

## Stack
[Languages, frameworks, key libraries. Empty is fine early on.]

## Data & storage
[Database, ORM, data-access patterns. Tenancy/isolation model if any.]

## Auth & access
[How users are authenticated and authorized, if applicable.]

## Deployment & runtime
[Where it runs, how it's deployed, how to run it locally.]

## Conventions
[Cross-cutting patterns worth stating once: naming, file organization, error
handling, etc. Empty is fine early on.]

## Decisions
[As architecturally-significant ADRs are approved in `.scaffold/decisions/`,
each durable truth statement above references the decision that established it
(e.g. "single-tenant — see decisions/0001-single-tenant.md"). The decisions/
folder plus these references ARE the index; there is no separate index file.]
```

Architecture is living truth, updated in place when the system changes
(`checkpoint` is its primary owner — it sees the diff). **Tiebreak vs
knowledge/:** if a fact would change when you *re-platform* but the business rule
stays → architecture.md; if it changes only when the *business rule* changes →
knowledge/. Small projects may keep these as sections until the file exceeds a
screen.

4. **`.scaffold/roadmap.md`** — The program at 20k feet. (living)

```markdown
<!-- Last updated: [today's date] -->
# Roadmap

## Milestones
- **01-main** — [active] [one line: what this chunk delivers] → `milestones/01-main/`

## Backlog
- [Future features and someday/never, one line each. This is the permanent home
  for a future-feature one-liner — it does not retire.]
```

`roadmap.md` is the program index, not a phase plan. `## Milestones` lists each
milestone as a one-liner with status (done / active / planned) pointing to its
folder. `## Backlog` holds future features. The phases *inside* the active
milestone live in that milestone's `plan.md`, not here.

5. **`.scaffold/state.md`** — Where we are NOW. Forward-looking. Changes every session.

```markdown
<!-- Last updated: [today's date] -->
# State

## Active focus
[One paragraph. Synopsis + forward-look. Where things are, what's in flight,
what's driving the work.

**ELI5 — explain it like the reader is five.** Plain words, short sentences,
no jargon shortcuts, no status-report officialese. If a five-year-old
wouldn't follow the gist, rewrite it.

No bullets, no code blocks, no quoted prompts. Grows only when the situation
genuinely requires it.]

## Next
Milestone `01-main`. [The concrete action when you resume. Names the active
milestone and the current phase brief by path once one exists, e.g.
`milestones/01-main/phases/01-<slug>.md`.]

## Blockers
None.

## Open Questions
None.
```

**`## Next` is the single authority for what's active** — which milestone, which
phase brief. Not folder order. State is forward-looking, not a log.

- **Active focus** is one paragraph, plain language.
- **Blockers** and **Open Questions** are always present with "None." when empty —
  confirms the writer checked.
- **When a Blocker or Open Question resolves:** remove the line and place the
  resolution where it belongs (a decision, the roadmap, the commit log). State
  does not accumulate resolved items.
- **Optional `## Notes`** — add this section only when there is *transient
  operational state* to record: "dev DB is dirty, re-seed before verify," a
  temporary env swap. This is neither truth, history, nor a next-action. Clear
  each note when it resolves. Durable run/env facts (how to run the app) belong
  in `architecture.md`, not here.

6. **`.scaffold/milestones/01-<slug>/plan.md`** — The first milestone's phase plan. (temporal)

   Seed it with a single Phase 1 (the **emergent default** — no spec, no
   pre-written briefs; briefs get authored just-in-time by `/scaffold:plan` as
   work is discovered):

```markdown
<!-- Last updated: [today's date] -->
# Milestone 01 — [name]

## Objective
[What this chunk of work delivers. One or two sentences.]

## Done when
1. [The milestone's done-contract — acceptance condition(s), evaluated as a set.]

## Phases
- [ ] **Phase 1 — [slug]** — [one line: what this phase does]
```

The `## Phases` checklist (each phase a checkbox + completion date when done) is
the disk-derivable "is it done?" signal — `checkpoint` ticks it. Keep completion
annotations **terse** (a date, not prose) so `plan.md` stays a bounded checklist,
never an append-log; verbose per-phase narrative belongs in git. There is **no
`spec/` and no `phases/*.md` brief yet** — those appear only if the work warrants
heavy scoping (a spec, via `/scaffold:integrate` or `/scaffold:plan`) or once
`/scaffold:plan` authors the first brief.

**Renaming the seed milestone (the slug is a sticky namespace):**
The slug appears in the folder path and is referenced from `state.md` Next,
`roadmap.md`, and any phase briefs. To rename `01-main` → `01-<newslug>`:
1. `git mv .scaffold/milestones/01-main .scaffold/milestones/01-<newslug>`
2. Update the milestone line in `roadmap.md`.
3. Update the path in `state.md` `## Next`.
4. Grep `.scaffold/` for `01-main` and fix any remaining references (brief
   front-matter, cross-links).
Do this early, before many briefs accrue — it gets more expensive the longer you wait.

7. **Verify companion commands** — confirm that `status.md`, `plan.md`, `go.md`,
   `checkpoint.md`, `integrate.md`, `cleanup.md`, and `update.md` exist as sibling
   files in this same folder. If any are missing, tell me — they should have been
   installed together.

**After creating everything:**
- If git is initialized: stage new files and any deletions from archiving, then
  commit: `git add CLAUDE.md .scaffold/ && git add -u && git commit -m "init: scaffold"`
- Give me a summary of what was set up, what content was incorporated (and from
  where), what was archived, and what I should fill in or verify — especially the
  seed milestone slug (rename it if the work has a real name).

**Existing-codebase deep analysis (automatic — no flag):**

If this project has an existing codebase (i.e. not an empty/new project), then
after creating the scaffold files, give the code the careful treatment it needs:
launch an Explore subagent (thoroughness: "very thorough") to:

1. Analyze code structure — top-level modules, key entry points, organization
2. Map architectural patterns — routing, state management, data flow, API layer
3. Surface conventions — naming, file organization, import style, test location
4. Identify undocumented dependencies — build tools, CI assumptions, env requirements

Feed subagent findings back into the scaffold files:
- Stack, patterns, conventions, data-access → `.scaffold/architecture.md`
- Module structure / what-it-is → `.scaffold/project.md` "What is this?"
- Known issues or TODOs found in code → `.scaffold/state.md`
