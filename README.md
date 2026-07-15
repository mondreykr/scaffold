# Scaffold

Lightweight context persistence for Claude Code. Markdown files, a family of skills, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Scaffold gives it memory with a small set of markdown documents in `.scaffold/` and a family of skills that keep them accurate. No dependencies, no config, no build step. Works in any project with or without git.

The documents are organized in three bands, governed by two laws:

- **Living truth** — always current, overwritten in place: `project.md` (what it is), `architecture.md` (how it's built), `roadmap.md` (the program), `state.md` (where you are now), `knowledge/` (durable rules).
- **History** — frozen, written once, never the source of current truth: `decisions/` (ADRs) and `investigations/` (research records).
- **Execution** — temporal, retires when its chunk of work is done: `milestones/NN-slug/` holding a `milestone.md`, optional `spec/`, and `phases/` plans.

**Law 1 — truth and history never share a document.** **Law 2 — a document lives at the layer that owns its lifecycle and audience.** Everything routes from those two rules. The full model is in [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Install

**Prerequisite:** [Node.js](https://nodejs.org/) (for `npx`).

One-time setup (installs the skills for all projects):

```bash
npx degit mondreykr/scaffold/skills $HOME/.claude/skills
```

This copies the `scaffold-*` skill folders into `~/.claude/skills/`, leaving any other skills you have untouched. Or copy the `skills/` folder's contents into `~/.claude/skills/` manually if you already have the repo.

Then, in any project:

1. Open Claude Code
2. Run `/scaffold-setup`

That's it. Setup creates your context files and walks you through filling them in. The skills are installed once at the user level and available in every project.

## Updating

Run `/scaffold-update` to pull the latest skills. It also detects and removes legacy command-era installs (scaffold used to ship as slash commands) that would otherwise shadow the skills.

Or manually:

```bash
npx degit mondreykr/scaffold/skills $HOME/.claude/skills --force
```

This is safe — it only replaces the `scaffold-*` skill folders in `~/.claude/skills/`. Your project data in `.scaffold/` and `CLAUDE.md` is never touched.

After updating from an older version, run `/scaffold-cleanup` to migrate your scaffold files to the current format.

## How it works

The scaffold is a state machine. Every skill leaves all state documents accurate and self-consistent. Any skill could be the last thing that runs before a week-long gap.

### Minimum ceremony

Every session starts with `status` and ends with `checkpoint`. Everything in between is up to you.

```
status → [work with Claude] → checkpoint
```

That's the whole system. The other skills are tools you reach for when you need them — not gates you pass through every time.

### When you need more structure

| Skill | What it's for | When to use it |
|-------|--------------|----------------|
| `/scaffold-plan` | "Help me figure out what's next, and write it down." Discuss direction, then persist it — update the roadmap, author phase plans, set the active cursor. Also **finalizes** a plan (`--final`): validates it against current code and confirms the approach with you. | When you need to recalibrate, scope new work, author the next chunk, or finalize a plan before executing it. |
| `/scaffold-go` | "Execute the active phase." Builds the phase plan that `state.md` Next points at. Runs only a **finalized, still-fresh** plan; refuses a draft or a stale one and routes you to finalize. | When a finalized plan is ready and you want scope-controlled execution. |
| `/scaffold-integrate` | "Absorb this artifact." Ingest a spec or doc into the scaffold. | After producing a spec, or to bring an external/shared spec under a milestone. |
| `/scaffold-audit` | "Check everything, hard." A deep, independent conformance + reality review. | Before a release, after a long gap, or after heavy hand-editing. |

These are independent tools. Use them in any combination:

```
Freeform:        status → work → checkpoint
Guided:          status → plan → work → checkpoint
Predetermined:   status → plan --final → go → checkpoint   (repeat per phase)
With artifacts:  integrate → plan → plan --final → go → checkpoint
Deep check:      audit
```

A phase plan has two states. A **draft** is high-level and code-blind (it can be written
ahead). Before you execute it, `/scaffold-plan --final` **finalizes** it — validating it
against the code as it is now, recording which files it touches, and confirming the
approach with you in plain terms. `/scaffold-go` then executes only a finalized, still-fresh
plan; if the code has moved since it was finalized, `go` stops and asks you to re-finalize.
This is what lets the thinking step and the building step happen separately and safely.

### Quick fixes

Just start working after status. No plan needed. Checkpoint saves whatever happened and reconciles the tree — it auto-detects when there's no work session and just runs its sweep.

### Pausing and resuming

Say "pause" or "I need to stop" at any point. Checkpoint captures your progress and updates `state.md`'s Active focus to reflect where you left off. Next session, status reads `state.md` and tells you where to pick up.

### USER tasks

Mark deliverables that require human action with `[USER]` in a phase plan or the milestone's `milestone.md`. Checkpoint walks you through verifying them when you're ready.

## Skills

| Skill | What it does | When to use it |
|-------|-------------|----------------|
| `/scaffold-setup` | Scaffolds the structure for a new project; on an existing codebase it automatically analyzes the code to seed the architecture doc. | Once per project |
| `/scaffold-status` | Reads scaffold files, gives a session briefing with health checks. Read-only. | Every session start, or after `/clear` |
| `/scaffold-plan` | Discusses direction and persists it — roadmap, phase plans, milestone creation, active cursor. Finalizes a plan against current code (`--final`). Proposes ADRs (you approve). | When you need to recalibrate, author the next chunk, or finalize a plan |
| `/scaffold-go` | Executes the active phase plan (finalized & fresh only — refuses a draft or stale plan). Writes code (and optional research records); never scaffold docs. | When a finalized plan is ready and Next points at it |
| `/scaffold-checkpoint` | Verifies work, updates scaffold docs, runs a light structural + coherence sweep, commits. Auto-detects a no-work run and just sweeps. | End of every session, or whenever you want to save |
| `/scaffold-audit` | Deep, independent review — grades every doc against its format and checks the docs against the real code. Read-only; reports drift, changes nothing. | Before a release, after a long gap, or after heavy hand-editing |
| `/scaffold-integrate` | Absorbs an artifact (spec, doc) into the scaffold — to a milestone's `spec/` (copy or pointer) or `knowledge/`. Pure ingest. | After producing a spec or major artifact |
| `/scaffold-cleanup` | Migrates an older scaffold layout to the current structure. Cautious and interactive. | After updating from an older version |
| `/scaffold-update` | Pulls latest scaffold skills. | When a new version is available |

Two boundaries hold across the set: **`go` writes code, never scaffold docs** (all scaffold write-back is `plan`/`checkpoint`'s job), and **`decisions/` is propose-only** — a skill may draft an ADR but stops for your approval before writing it.

**Two tiers of checking.** `checkpoint` runs a light structural + coherence sweep on every save, automatically — no flag. `audit` is the deep, independent version you run on demand: it is the sole grader of every doc hard against its format *and* verifies the docs against the actual code. You never have to remember a flag; the depth is chosen by which skill you run.

## Files

| Path | Band | Purpose |
|------|------|---------|
| `CLAUDE.md` | — | Hub — orientation, working rules, a pointer into `.scaffold/` (auto-read by Claude) |
| `.scaffold/project.md` | living truth | What you're building, for whom, why, scope boundaries |
| `.scaffold/architecture.md` | living truth | How it's built — stack, data-access, auth, deployment, conventions |
| `.scaffold/roadmap.md` | living truth | The program — milestone index (`## Milestones`) + `## Backlog` |
| `.scaffold/state.md` | living truth | Where you are now — active focus, next, blockers, open questions |
| `.scaffold/knowledge/*.md` | living truth | Durable domain/behavioral rules (the residue of retired specs) |
| `.scaffold/decisions/NNNN-slug.md` | history | ADRs — load-bearing decisions + why (frozen, you gate every one) |
| `.scaffold/investigations/YYYYMMDD-slug.md` | history | Research and analysis records (frozen) |
| `.scaffold/milestones/NN-slug/` | execution | A chunk of work: `milestone.md`, optional `spec/`, `phases/NN-slug.md` plans |

Every `.scaffold/` document carries minimal frontmatter — `type`, `schema_version`, `updated` — so the skills always know what a doc is and when it last changed. (`CLAUDE.md` is the one exception: a Claude Code special file with its own conventions.) All scaffold data lives in `.scaffold/` at project root (except `CLAUDE.md`, which lives at the root so Claude auto-reads it). Repo-level `docs/` holds only code-adjacent reference assets (e.g. a design-system bundle) — never project documentation.

## Milestone plans and the roadmap

Two altitudes, two documents:

- **`roadmap.md`** is the program index — *which* milestones exist and what's in the backlog. It never retires.

```markdown
## Milestones
- [active] 01-rebuild — Rebuild the core on the new schema → milestones/01-rebuild/
- [planned] 02-multi-user — Real auth + tenant isolation → milestones/02-multi-user/

## Backlog
- Mobile app
- Public API
```

The milestone status token is exactly one of `[done] | [active] | [planned]`.

- **`milestones/NN-slug/milestone.md`** is the plan for *one* milestone — the phases inside it, plus its objectives and done-contract. It retires when the milestone closes.

```markdown
# Milestone 01 — rebuild

## Objectives
Rebuild the core on the new schema.

## Phases
- [x] 01-foundation (2026-04-02)
- [x] 02-ledger-engine (2026-04-09)
- [ ] 03-reconciliation

## Done-contract
All surfaces run on the new ledger; old code demolished.
```

The `## Phases` checklist (checkbox + completion date) is the disk-derivable "is it done?" signal — there is no status enum. `checkpoint` ticks it. Phase numbers admit interstitials (`09.1` for a surgical phase inserted after a frozen plan); they are never renumbered.

A phase plan (`phases/NN-slug.md`) carries one phase's Objective / Scope / Approach / Acceptance. Plans are authored up front (predetermined milestone, from a spec) or just-in-time by `plan` (emergent milestone). A plan starts as a **draft**; `plan --final` finalizes it — adding a `## Targets` section (the files it touches, stamped `as of <sha>`) once it's validated against current code. `go` executes from a plan's `## Scope`, but only when the plan is finalized and the stamped commit is still HEAD.

## Integrating specs and other artifacts

When work produces a major artifact — a spec, architecture doc, design doc — `/scaffold-integrate` absorbs it:

```
/scaffold-integrate docs/my-spec/SPEC.md
```

It routes the artifact by what it is:

- **Scopes a milestone** → that milestone's `spec/` — either copied in, or left where it lives with a pointer file (for a shared or grandfathered spec). A pointer'd spec stays whole; its internals are never cracked open.
- **Cross-cutting durable knowledge** → `knowledge/`.

It also extracts operational facts into the truth docs (run/env → `architecture.md`). Integrate is pure ingest — it does not author plans, run coherence sweeps, or migrate old layouts.

While a milestone runs, its spec's `references/` are the *live* rulebook; at milestone close, the enduring rules graduate into `knowledge/` (via `checkpoint`).

## Recovery

**Lost context mid-session:**
Run checkpoint to save progress before `/clear`. If you already cleared, run status — it reads from files.

**Context rot mid-session:**
`/clear` then status to start fresh. Long conversations degrade Claude's attention.

**Checkpoint wrote bad state:**
`git diff .scaffold/` to see what changed. `git checkout -- .scaffold/<file>` to revert.

**Files contradict each other:**
Run status — the health check flags contradictions — or `/scaffold-checkpoint`, which sweeps and repairs the tree on every run. For a deep, independent check that also verifies the docs against the code, run `/scaffold-audit`. Tell Claude which file is correct when judgment is needed.

**Everything feels stale:**
Clear the contents of `state.md`, then run checkpoint to regenerate from the codebase.

**Old format after update:**
Run `/scaffold-cleanup` to migrate files to the current format.

## Limitations

**Context rot within a session.** Long conversations degrade Claude's attention. This scaffold solves between-session memory, not within-session degradation. Use `/clear` and status to reset.

**No enforcement.** The persistence chain depends on you running `/scaffold-status` at the start of each session and Claude following CLAUDE.md rules. Nothing forces status to run — it's a manual first step, reinforced by CLAUDE.md but not enforced.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.
