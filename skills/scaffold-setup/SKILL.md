---
name: scaffold-setup
description: Initialize Scaffold in a project — create CLAUDE.md plus the .scaffold/ truth docs (project, architecture, roadmap, state), the empty knowledge/decisions/investigations folders, and a seed milestone, all with conformant frontmatter. Handles fresh projects, existing codebases (auto-explores to seed architecture from real code), and adopting a hand-written CLAUDE.md. Use whenever the user wants to set up scaffold, initialize it, start using it here, or bootstrap context persistence — even if they only say "set up scaffold" or "init scaffold". For an older scaffold layout, route to /scaffold-cleanup instead.
---

# scaffold-setup

Initialize Scaffold: a small set of living markdown docs in `.scaffold/` plus a
`CLAUDE.md` hub, so a session can resume after a long gap with full context. This skill
*creates the structure*; the other skills maintain it. Every doc it writes is conformant
from birth — correct sections, correct frontmatter.

**Boundary.** Setup creates the scaffold structure and commits it. It does not author
phase plans (that's `scaffold-plan`), execute work (`scaffold-go`), or curate decisions
into ADRs (`scaffold-integrate`/`scaffold-cleanup` own the ADR-promotion gate).

---

## Step 1: Preflight checks

- **Git.** If git isn't initialized, warn: "No git repo. Scaffold works without it, but
  git gives you undo for checkpoint. Consider `git init` first." Don't block on it.
- **Already present → conformant, or route to cleanup.** If any `.scaffold/` *truth doc*
  exists (`project.md`, `architecture.md`, `roadmap.md`, `state.md`), this is **not** a
  fresh project — decide by conformance, and **never overwrite:**
  - **Fully conformant** (all four truth docs present, `decisions/`/`investigations/` as
    folders, a `milestones/` container, no `plans/`, and every doc stamped with
    `type`/`schema_version` frontmatter) → stop: "Already set up — run /scaffold-status."
  - **Anything else** — an older layout *or* a partial/hand-edited/ambiguous state (signs:
    a single-file `.scaffold/decisions.md`, a `.scaffold/plans/` folder, a per-phase
    `roadmap.md`, `CLAUDE-*.md` files in root, docs lacking frontmatter, or any mix that
    isn't cleanly current) → stop and route: "Found an existing scaffold that isn't fully
    current. Run /scaffold-cleanup — it inventories whatever's there and migrates any prior
    or partial state (and no-ops if it turns out current). Setup is for fresh projects
    only." Don't try to judge which legacy shape it is — that's cleanup's job.

  A root `CLAUDE.md` on its own (no `.scaffold/`) is **not** a collision — that's the adopt
  case below.
- **Adopt an existing `CLAUDE.md`** (exists in root, no `.scaffold/`): read it, archive
  the original to `.scaffold/archive/CLAUDE.md.pre-scaffold`, then sort its content:
  - product / what-it-is → the new `CLAUDE.md` "About this project" + `project.md`
  - tech stack, data access, deployment, conventions → `architecture.md` (NOT
    `CLAUDE.md` — that's architecture truth now)
  - hard constraints that govern how Claude works here → `CLAUDE.md` `## Hard constraints`
  - **anything else** (preferences, "who I am", communication notes) does not map
    cleanly — do NOT silently merge. Present each section and ask: "(a) drop — Claude
    defaults cover it, (b) move to `~/.claude/CLAUDE.md` (user-level — read it first and
    *append*, never overwrite; it's shared across every project), (c) keep as a custom
    section here." Wait for the choice per section.
  Then report what was preserved, where it landed, and what was dropped or relocated.
- **Other context-bearing files** (`README.md`, `TODO.md`, `ARCHITECTURE.md`,
  `NOTES.md`, …) are context sources — read in Step 2.

## Step 2: Scope analysis (existing projects only — skip for empty/new)

If the project has existing code, do these before creating files:

1. **Auto-detect the stack** from manifests/config (`package.json`, `Cargo.toml`,
   `go.mod`, `pyproject.toml`, `requirements.txt`, `Gemfile`, `pom.xml`,
   `build.gradle`, `composer.json`, …) — frameworks, database, deployment, major deps.
2. **Scan for context-bearing files** (`TODO.md`, `ARCHITECTURE.md`, `DECISIONS.md`,
   `CONTRIBUTING.md`, `CHANGELOG.md`, `.cursor/rules`, …). For each, report: filename,
   which scaffold doc its content maps to, a one-line summary, and whether it'll be
   archived or left in place. **A `DECISIONS.md` is NOT curated here** — note it and surface
   its rulings via `/scaffold-plan`, which proposes them as ADRs (Adam-gated). (`cleanup`'s
   promote-the-few handles a legacy monolith during old-layout migration; `integrate` is
   pure-ingest and never writes decisions.)
3. **Incorporate and archive by default.** Pull content into the right scaffold doc.
   **With git:** move originals to `.scaffold/archive/` (git retains history — reversible).
   **No git:** *copy* content out and leave originals in place (no undo point); say so.
   `README.md` always stays in place (it serves GitHub/npm) — read for context only.
   Present the scan and what will happen; don't wait for file-by-file confirmation, but
   respect any objection to a specific file being archived.

## Step 3: Create the structure

Create the directories (add a `.gitkeep` to each empty one so git tracks it):

```
CLAUDE.md
.scaffold/
  project.md        architecture.md        roadmap.md        state.md
  knowledge/        (empty)
  decisions/        (empty)
  investigations/   (empty)
  milestones/
    01-<slug>/
      milestone.md
      phases/       (empty)
```

**The seed milestone slug.** Default `01-main`. The slug is a **sticky namespace** —
`state.md` Next, `roadmap.md`, and plans reference it by path. Pick something
rename-cheap now; if the user already knows the first chunk, ask for a slug and use
`01-<that>`. Rename procedure is in Step 5.

**Frontmatter (every `.scaffold/` doc).** YAML frontmatter `type` / `schema_version: 2`
/ `updated: <today>` on every doc below. `CLAUDE.md` is the one exception — a Claude Code
special file, no frontmatter. For existing projects, fill templates from Step 2 findings
(after confirmation); for new projects, use the placeholder prose as-is.

### CLAUDE.md (the hub — no frontmatter; lives in project root)

```markdown
# [Project Name]

## Skill Reference
| Skill | Role |
|-------|------|
| `/scaffold-setup` | Initialize — scaffold the structure for a new project |
| `/scaffold-status` | Orient — read state, present options |
| `/scaffold-plan` | Consult + author — discuss direction, persist into the right docs |
| `/scaffold-go` | Execute — run the active phase plan |
| `/scaffold-checkpoint` | Save + reconcile — verify, update files, sweep, commit |
| `/scaffold-audit` | Audit — deep conformance + reality check (on demand) |
| `/scaffold-integrate` | Absorb — ingest an artifact (spec, research) into scaffold |
| `/scaffold-cleanup` | Migrate an existing project to this structure |
| `/scaffold-update` | Update scaffold skills to the latest version |

## Core Principle
Every skill leaves ALL state documents accurate and self-consistent.
Any skill could be the last thing that runs before a week-long gap.
Skills are optional tools — the minimum ceremony is status → work → checkpoint.
Scaffold works like a state machine: every piece of information has exactly one home a
skill can compute — so never add a catch-all / open-ended / "misc" section to any doc;
that's where dumping and drift start. New information routes to its existing home.

## About this project
[3–5 line product orientation: what this is, who it's for, and the one thing to know
before touching the code. Plain language — this is the fast read. For detail: see
`.scaffold/project.md` (what & why), `.scaffold/architecture.md` (how it's built),
`.scaffold/roadmap.md` (the program), `.scaffold/state.md` (where we are). Run
`/scaffold-status` at the start of every session.]

## Hard constraints
[Project-specific constraints no scaffold file owns — e.g. "must work offline", "no paid
APIs without approval". Optional; remove this section if none. Generic preferences like
"ask before code changes" belong in `~/.claude/CLAUDE.md`, not here.]
```

Tech stack, data access, and run/env do **not** go here — that's `architecture.md`.

### .scaffold/project.md — product identity (living)

```markdown
---
type: project
schema_version: 2
updated: [today]
---

# [Product]

## What it is
[Plain statement of the product and the problem it solves. Vague is fine early.]

## Who it's for
[The user(s) / audience. "Just me" is a valid answer.]

## Why
[The motivating need.]

## Scope
[What's in scope.]

## Not building
[Explicit non-goals — the anti-drift boundary. What this is NOT.]
```

Answers *what the product is* — not *how it's built* (`architecture.md`). No
requirements/acceptance checkboxes — verifiable invariants live where they're tested.
Always created (one of the four mandatory truth docs), even when sparse.

### .scaffold/architecture.md — how it's built (living)

```markdown
---
type: architecture
schema_version: 2
updated: [today]
---

# Architecture

## Stack
[Languages, frameworks, key libraries. Empty is fine early.]

## Tenancy / isolation
[Multi-tenant model, if any.]

## Auth
[How users are authenticated/authorized, if applicable.]

## Data access
[Database, ORM, data-access patterns.]

## Deployment
[Where and how it's deployed.]

## Conventions
[Cross-cutting patterns worth stating once: naming, file organization, error handling.]

## Run / env
[How to run the app locally + durable run/env facts.]
```

Cover the sections that apply; small projects keep them plan until architecture exceeds
a screen. As architectural ADRs get approved later, each truth statement references the
ADR that established it (`[[NNNN-…]]`) — those inline references *are* the decision index;
there is no separate index file. **Tiebreak vs `knowledge/`:** a fact that changes when
you *re-platform* (business rule unchanged) → here; a fact that changes only when the
*business rule* changes → `knowledge/`.

### .scaffold/roadmap.md — the program at 20k feet (living)

```markdown
---
type: roadmap
schema_version: 2
updated: [today]
---

# Roadmap

## Milestones
- [active] 01-<slug> — [one line: what this chunk delivers] → milestones/01-<slug>/

## Backlog
- [ ] [Future feature — program-altitude, one terse line]
```

Program altitude only. The status token is exactly one of `[done] | [active] |
[planned]`. The phases *inside* a milestone live in its `milestone.md`, never here. `## Backlog`
holds future work **not tied to the active milestone** (typically features), one `- [ ]`
line each (never ticked — an item leaves by removal when promoted into a milestone or
shipped); work **tied to** an active milestone (a bug/cleanup/residual in its code) goes to
that milestone's `milestone.md` `## Deferred`, not here. The test is tied-ness, not altitude.

### .scaffold/state.md — where we are NOW (living, churns)

```markdown
---
type: state
schema_version: 2
updated: [today]
---

# State

## Active focus
[One paragraph. Synopsis + forward-look. ELI5 — plain words, short sentences, no jargon,
no status-report officialese. No bullets, code blocks, or quoted prompts.]

## Next
Milestone `01-<slug>`. [The concrete action when you resume. Names the active milestone
and the current phase plan by path once one exists.]

## Blockers
None.

## Open Questions
None.
```

`## Next` is the single authority for what's active — not folder order, not a status enum.
`Blockers`/`Open Questions` always present with literal `None.` when empty. These four
headings are the whole document — **there is no `## Notes` section.** Transient operational
state routes to its real home: a precondition on resuming (reseed the DB first) rides in
`## Next`; a durable run/env condition goes to `architecture.md`; a blocker to
`## Blockers`.

### .scaffold/milestones/01-<slug>/milestone.md — the first milestone's phase plan (temporal)

Seed it with a single Phase 1 (the **emergent default** — no spec, no pre-written plans;
plans get authored just-in-time by `/scaffold-plan` as work is discovered):

```markdown
---
type: milestone
schema_version: 2
updated: [today]
---

# Milestone 01 — <slug>

## Objectives
[What this chunk of work delivers. One or two sentences.]

## Phases
- [ ] 01-<slug> — [one line: what this phase does]

## Done-contract
[The acceptance condition(s) for the milestone, evaluated as a set.]
```

The `## Phases` checklist (each phase a checkbox + a completion date when done) is the
disk-derivable "is it done?" signal — `checkpoint` ticks it. Keep annotations terse (a
date, not prose) so it stays a bounded checklist, never an append-log. An optional
`## Deferred` section (ground-level work surfaced inside the milestone but not yet
scheduled — bugs, cleanups, debt) is added by `plan`/`checkpoint` when there's something to
park; the seed omits it while empty. No `spec/` and no `phases/*.md` plan yet — those
appear only if the work warrants heavy scoping (via `/scaffold-integrate` or
`/scaffold-plan`) or once `plan` authors the first plan.

## Step 4: Existing-codebase deep analysis (automatic — no flag)

If the project has an existing codebase, after creating the files give the code careful
treatment: launch an **Explore** subagent (thoroughness "very thorough") to map code
structure + entry points, architectural patterns (routing, state, data flow, API layer),
conventions (naming, organization, test location), and undocumented dependencies (build
tools, CI assumptions, env requirements). Feed findings back:

- stack, patterns, conventions, data access → `architecture.md`
- module structure / what-it-is → `project.md` "What it is"
- known issues or code TODOs → `state.md`

## Step 5: Renaming the seed milestone (the slug is a sticky namespace)

The slug is in the folder path and referenced from `state.md` Next, `roadmap.md`, and any
plans. To rename `01-main` → `01-<newslug>` (do it early, before plans accrue):

1. `git mv .scaffold/milestones/01-main .scaffold/milestones/01-<newslug>`
2. Update the milestone line in `roadmap.md`.
3. Update the path in `state.md` `## Next`.
4. Grep `.scaffold/` for `01-main` and fix any remaining references.

## Step 6: Commit + summary

- With git: stage new files and any archive moves, then commit:
  `git add CLAUDE.md .scaffold/ && git add -u && git commit -m "init: scaffold"`.
- Summarize what was set up, what content was incorporated (and from where), what was
  archived, and what the user should fill in or verify — especially the seed milestone
  slug (rename it now if the work has a real name). Then route forward: "Run
  /scaffold-status to orient, or /scaffold-plan to scope the first milestone."

---

## Boundaries

Setup does NOT: author phase plans or set up a full milestone plan beyond the seed
(`scaffold-plan`); execute any work or write project code (`scaffold-go`); curate a
legacy `DECISIONS.md` into ADRs (that's `cleanup`'s migration job, or surface via `plan`
for an Adam-gated proposal); or overwrite an existing scaffold (fully
conformant → stop; anything else already present → route to `scaffold-cleanup`).
