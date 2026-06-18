# Scaffold

Lightweight context persistence for Claude Code. Markdown files, slash commands, nothing else.

## What this is

Claude Code loses context between sessions — every `/clear` or new conversation starts from zero. Scaffold gives it memory with a small set of markdown documents in `.scaffold/` and a set of slash commands that keep them accurate. No dependencies, no config, no build step. Works in any project with or without git.

The documents are organized in three bands, governed by two laws:

- **Living truth** — always current, overwritten in place: `project.md` (what it is), `architecture.md` (how it's built), `roadmap.md` (the program), `state.md` (where you are now), `knowledge/` (durable rules).
- **History** — frozen, written once, never the source of current truth: `decisions/` (ADRs) and `investigations/` (research records).
- **Execution** — temporal, retires when its chunk of work is done: `milestones/NN-slug/` holding a `plan.md`, optional `spec/`, and `phases/` briefs.

**Law 1 — truth and history never share a document.** **Law 2 — a document lives at the layer that owns its lifecycle and audience.** Everything routes from those two rules. The full model is in [`ARCHITECTURE.md`](ARCHITECTURE.md).

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

That's it. Setup creates your context files and walks you through filling them in. Commands are installed once at the user level and available in every project.

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
| `/scaffold:plan` | "Help me figure out what's next, and write it down." Discuss direction, then persist it — update the roadmap, author phase briefs, set the active cursor. | When you need to recalibrate, scope new work, or author the next chunk. |
| `/scaffold:go` | "Execute the active phase." Builds the phase brief that `state.md` Next points at. | When a brief is ready and you want scope-controlled execution. |
| `/scaffold:integrate` | "Absorb this artifact." Ingest a spec or doc into the scaffold. | After producing a spec, or to bring an external/shared spec under a milestone. |

These are independent tools. Use them in any combination:

```
Freeform:        status → work → checkpoint
Guided:          status → plan → work → checkpoint
Predetermined:   status → go → checkpoint   (repeat per phase)
With artifacts:  integrate → plan → go → checkpoint
Reconcile only:  checkpoint --reconcile
```

### Quick fixes

Just start working after status. No plan needed. Checkpoint saves whatever happened and reconciles the tree.

### Pausing and resuming

Say "pause" or "I need to stop" at any point. Checkpoint captures your progress and updates `state.md`'s Active focus to reflect where you left off. Next session, status reads `state.md` and tells you where to pick up.

### USER tasks

Mark deliverables that require human action with `[USER]` in a phase brief or the milestone `plan.md`. Checkpoint walks you through verifying them when you're ready.

## Commands

| Command | What it does | When to use it |
|---------|-------------|----------------|
| `/scaffold:setup` | Scaffolds the structure for a new project; on an existing codebase it automatically analyzes the code to seed the architecture doc. | Once per project |
| `/scaffold:status` | Reads scaffold files, gives a session briefing with health checks. Read-only. | Every session start, or after `/clear` |
| `/scaffold:plan` | Discusses direction and persists it — roadmap, phase briefs, milestone creation, active cursor. Proposes ADRs (you approve). | When you need to recalibrate or author the next chunk |
| `/scaffold:go` | Executes the active phase brief. Writes code (and optional research records); never scaffold docs. | When a brief is ready and Next points at it |
| `/scaffold:checkpoint` | Verifies work, updates scaffold docs, runs a coherence sweep, commits. Pass `--reconcile` to sweep without a work session; `--audit` to verify claims against code. | End of every session, or whenever you want to save |
| `/scaffold:integrate` | Absorbs an artifact (spec, doc) into the scaffold — to a milestone's `spec/` (copy or pointer) or `knowledge/`. Pure ingest. | After producing a spec or major artifact |
| `/scaffold:cleanup` | Migrates an older scaffold layout to the current structure. Cautious and interactive. | After updating from an older version |
| `/scaffold:update` | Pulls latest scaffold commands. | When a new version is available |

Two boundaries hold across the set: **`go` writes code, never scaffold docs** (all scaffold write-back is `plan`/`checkpoint`'s job), and **`decisions/` is propose-only** — a command may draft an ADR but stops for your approval before writing it.

## Files

| Path | Band | Purpose |
|------|------|---------|
| `CLAUDE.md` | — | Hub — orientation, working rules, a pointer into `.scaffold/` (auto-read by Claude) |
| `.scaffold/project.md` | living truth | What you're building, for whom, scope boundaries, requirements |
| `.scaffold/architecture.md` | living truth | How it's built — stack, data-access, auth, deployment, conventions |
| `.scaffold/roadmap.md` | living truth | The program — milestone index (`## Milestones`) + `## Backlog` |
| `.scaffold/state.md` | living truth | Where you are now — active focus, next, blockers, open questions |
| `.scaffold/knowledge/*.md` | living truth | Durable domain/behavioral rules (the residue of retired specs) |
| `.scaffold/decisions/NNNN-slug.md` | history | ADRs — load-bearing decisions + why (frozen, you gate every one) |
| `.scaffold/investigations/YYYYMMDD-slug.md` | history | Research and analysis records (frozen) |
| `.scaffold/milestones/NN-slug/` | execution | A chunk of work: `plan.md`, optional `spec/`, `phases/NN-slug.md` briefs |

All scaffold data lives in `.scaffold/` at project root (except `CLAUDE.md`, which lives at the root so Claude auto-reads it). Repo-level `docs/` holds only code-adjacent reference assets (e.g. a design-system bundle) — never project documentation.

## Milestone plans and the roadmap

Two altitudes, two documents:

- **`roadmap.md`** is the program index — *which* milestones exist and what's in the backlog. It never retires.

```markdown
## Milestones
- **01-rebuild** — [active] Rebuild the core on the new schema → `milestones/01-rebuild/`
- **02-multi-user** — [planned] Real auth + tenant isolation → `milestones/02-multi-user/`

## Backlog
- Mobile app
- Public API
```

- **`milestones/NN-slug/plan.md`** is the phase plan for *one* milestone — the phases inside it. It retires when the milestone closes.

```markdown
# Milestone 01 — Rebuild

## Objective
Rebuild the core on the new schema.

## Done when
1. All surfaces run on the new ledger; old code demolished.

## Phases
- [x] 01-foundation (2026-04-02)
- [x] 02-ledger-engine (2026-04-09)
- [ ] 03-reconciliation
```

The `## Phases` checklist (checkbox + completion date) is the disk-derivable "is it done?" signal — there is no status enum. `checkpoint` ticks it. Phase numbers admit interstitials (`09.1` for a surgical phase inserted after a frozen plan); they are never renumbered.

A phase brief (`phases/NN-slug.md`) carries one phase's Goal / Scope / Approach / Acceptance. Briefs are authored up front (predetermined milestone, from a spec) or just-in-time by `plan` (emergent milestone). `go` executes from a brief's `## Scope`.

## Integrating specs and other artifacts

When work produces a major artifact — a spec, architecture doc, design doc — `/scaffold:integrate` absorbs it:

```
/scaffold:integrate docs/my-spec/SPEC.md
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
Run status — the health check flags contradictions — or `/scaffold:checkpoint --reconcile` to sweep and repair the tree. Tell Claude which file is correct when judgment is needed.

**Everything feels stale:**
Clear the contents of `state.md`, then run checkpoint to regenerate from the codebase.

**Old format after update:**
Run `/scaffold:cleanup` to migrate files to the current format.

## Limitations

**Context rot within a session.** Long conversations degrade Claude's attention. This scaffold solves between-session memory, not within-session degradation. Use `/clear` and status to reset.

**No enforcement.** The persistence chain depends on you running `/scaffold:status` at the start of each session and Claude following CLAUDE.md rules. Nothing forces status to run — it's a manual first step, reinforced by CLAUDE.md but not enforced.

**Solo-only.** No multi-user conflict detection. Git handles merge conflicts at the file level.

**No session history.** Git commits serve as the session record. There's no built-in session log beyond what checkpoint commits capture.
