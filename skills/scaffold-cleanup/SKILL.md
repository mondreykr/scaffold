---
name: scaffold-cleanup
description: Migrate an older scaffold layout to the current structure — split a per-phase roadmap by altitude, move plans/ into milestones/NN-slug/phases/ (preserving interstitials), stand up architecture.md, curate a legacy decisions.md into the few real ADRs (Adam-gated), normalize nonconformant names, and stamp conformant frontmatter on everything. Cautious and interactive; confirms every judgment call. Use whenever the user has an old/pre-restructure scaffold and wants to migrate, upgrade, or convert it to the current format — even if they only say "migrate the scaffold", "clean this up", or "upgrade the layout". For a fresh project, use /scaffold-setup instead.
---

# scaffold-cleanup

The **migrator** to the current scaffold structure. It moves a pre-restructure scaffold —
single `decisions.md`, a standalone `.scaffold/plans/` folder, a per-phase build plan
living in `roadmap.md`, no `architecture.md`, no `milestones/` container, docs lacking
frontmatter — onto the current model: living-truth docs + `decisions/` + `investigations/`
+ a `milestones/NN-slug/` container, every doc stamped with conformant frontmatter.

**Cautious and interactive.** It *proposes* a migration plan and *confirms every
non-mechanical call* — which doc is the milestone plan, which legacy decisions become ADRs,
the milestone slug. It consults rather than predicts; it does not assume a clean prior
format. Mechanical renames it just does; anything needing judgment, it stops and asks.

**Boundary.** Touches `.scaffold/` and `CLAUDE.md` only — never project code, and never
cracks open a grandfathered spec's internals (its own `DECISIONS.md`/`STATE.md` stay
whole; cleanup only points at it or updates paths).

**Run at a clean phase boundary** — this is a structural move; run it when no phase is
mid-build, so no pointer is in flux. Other skills already expect the current layout, so run
cleanup *before* them in the install→migrate window.

---

## Step 1: Detect the layout and read everything

Read all existing scaffold files and `CLAUDE.md` — scan, don't assume which exist:
`CLAUDE.md`, `.scaffold/project.md`, `roadmap.md`, `state.md`, `.scaffold/decisions.md`
(old single file) and/or `decisions/` (folder), `architecture.md` (may be absent — the
migrate signal), everything under `plans/`, `knowledge/`, `investigations/` (note
nonconformant names), `milestones/` (may be absent).

- **If `.scaffold/` doesn't exist at all,** stop: "No scaffold files found — run
  /scaffold-setup first (setup is for fresh projects; cleanup migrates an existing one)."
- **If the layout is already current** (`architecture.md` exists, `decisions/` is a
  folder, `milestones/` exists, no `plans/`, docs carry `type`/`schema_version`
  frontmatter), say so and stop: "Already on the current structure; nothing to migrate."

Classify and report the detected starting point:

> "Detected an older scaffold layout:
> - `roadmap.md` holds a per-phase build plan (needs altitude-split)
> - `plans/` has N phase briefs (incl. interstitials 06.1, 08.1, 09.1)
> - single `decisions.md`, N entries (needs curation to ADRs)
> - no `architecture.md` (needs standing up)
> - no `milestones/` container; docs lack frontmatter
> - [nonconformant names, e.g. `investigations/2026-06-11-gap-map.md`]
>
> Here's the migration plan I propose. I'll confirm each judgment call."

## Step 2: Propose the migration plan (consult, don't execute)

Lay out the whole plan first, as a single proposal. The non-mechanical calls to confirm:

1. **The milestone slug.** The existing `plans/` + roadmap build plan become the *first*
   milestone. Propose a slug from the work's identity (`01-rebuild`). It's a **sticky
   namespace** — get it right now.
2. **Which doc is the milestone plan** — confirm the old `roadmap.md` body (the phase
   checklist) is the source for `milestones/NN-slug/plan.md`.
3. **Which legacy decisions become ADRs** (Step 7 — the promote-the-few session); flag
   that most retire to git.
4. **The spec, if any** — if a spec scoped this work and lives elsewhere, confirm it stays
   in place and you write a **pointer**, not a copy.

Present the full proposal, then proceed gate by gate. Write **nothing** until Step 10.

## Step 3: Reference sweep (BEFORE any move)

Map every pointer first, so nothing dangles. Grep `.scaffold/` and `CLAUDE.md` for
references that break on move/rename:

- `state.md` `## Next` → the brief/plan path it points at
- `roadmap.md` → any `plans/phase-*` references
- phase briefs → cross-links to siblings, to `decisions.md`, to investigations
- `CLAUDE.md` → any `plans/`, `decisions.md`, or `docs/` pointer to scaffold content
- knowledge docs → references to decisions by old path

Build a **rename map** (old → new) covering every moving file:
`plans/phase-NN-slug.md` → `milestones/NN-slug/phases/NN-slug.md`; nonconformant
investigation names → conformant (Step 8); `decisions.md` entries → `decisions/NNNN-slug.md`
(promoted ones only). Report it; repoint all in the Step 10 pass. If a pointer already
dangles, flag it — don't invent a target.

## Step 4: Split `roadmap.md` by altitude

The old `roadmap.md` mixes a **program index** and a **per-phase build plan** — split them.

**Build-plan body → `milestones/NN-slug/plan.md`:** preserve the **checkbox + completion-
date checklist exactly** (the disk-derivable done-signal, not a forbidden enum — don't
reformat dates into prose); carry over the objective and the milestone's done-contract;
keep annotations terse. A `phase-00`-style "master build plan / plan authored" entry is
**not** a phase brief — it collapses *into* `plan.md` as the plan's own preamble, not into
`phases/00-*.md`. Target shape (stamp frontmatter):

```markdown
---
type: milestone-plan
schema_version: 1
updated: [today]
---

# Milestone NN — <slug>

## Objectives
[from the old build plan's objective]

## Phases
- [x] NN-slug — one-liner (YYYY-MM-DD)
- [ ] NN-slug — one-liner

## Done-contract
[the acceptance the phases roll up to]
```

**`## Backlog` + a freshly-authored `## Milestones` index STAY in `roadmap.md`:**
repurpose it to program altitude; keep `## Backlog` (its permanent home — losing it
retires the backlog); author a `## Milestones` index, one line per milestone with a
`[done] | [active] | [planned]` token + folder pointer. **Rewrite any backlog line the
migration makes stale** (e.g. a "multi-user/tenancy" line should point at the relevant ADR
+ a future milestone number rather than imply debt the current architecture doesn't carry)
— surface each rewrite. Target shape (stamp frontmatter):

```markdown
---
type: roadmap
schema_version: 1
updated: [today]
---

# Roadmap

## Milestones
- [active] NN-slug — [what this chunk delivers] → milestones/NN-slug/

## Backlog
- [future features, one line each]
```

## Step 5: Move phase briefs into the milestone

Move every `.scaffold/plans/phase-*.md` into `milestones/NN-slug/phases/`:

- **Preserve interstitials — NEVER renumber.** `phase-09.1-currency-model.md` →
  `phases/09.1-currency-model.md`. `NN` is the roadmap ordinal; `09.1` is a surgical
  insertion that must keep its place.
- Strip the `phase-` prefix (new convention is `phases/NN-slug.md`); keep number + slug.
- `phase-00` does **not** move here — it folded into `plan.md` (Step 4).
- **Stamp `type: phase-brief` frontmatter** and, where the old brief used `## Goal`,
  rename to `## Objective` to match the current shape (`# Phase NN — <slug>` / Objective /
  Scope / Approach / Acceptance).
- Use `git mv` where git is present; repoint every reference from the Step 3 sweep.

If a pre-written *downstream* brief has been **staled** by a later change (e.g. a Phase 10
brief written before a Phase 9.1 insertion), don't fix it here — just **flag it**:
> "Note: `phases/10-*.md` predates the 09.1 insertion and may be stale. Migration keeps it
> as-is; run /scaffold-plan to re-sweep downstream briefs."

## Step 6: Stand up `architecture.md`

Create it by sorting durable technical truth out of where it hides — `CLAUDE.md`'s
tech-stack section, architectural content in `decisions.md`, and the durable run/env facts
living in `state.md`/`CLAUDE.md`. **Tiebreak per fact:** changes on *re-platform* (business
rule stays) → `architecture.md`; changes only when the *business rule* changes →
`knowledge/` (not cleanup's job to populate — flag for a later `integrate`/`plan`). Target
shape (stamp frontmatter; use the current section set):

```markdown
---
type: architecture
schema_version: 1
updated: [today]
---

# Architecture

## Stack
## Tenancy / isolation
## Auth
## Data access
## Deployment
## Conventions
## Run / env
```

There is **no `## Decisions` section** — each truth statement references the ADR that set
it inline (`[[NNNN-…]]`); the `decisions/` folder + these references *are* the index.
Stand up the truth statements now; **wire the ADR references in Step 7**, once the ADRs are
promoted and numbered (the numbers don't exist yet).

After standing it up, **strip the migrated content from `CLAUDE.md`** (tech stack moves
out; `CLAUDE.md` keeps the Skill Reference + Core Principle + About-this-project pointer +
Hard constraints). **Replace the old Command Reference with the current `## Skill
Reference` table** — embed it verbatim (the same 9 rows `setup` writes):

```markdown
## Skill Reference
| Skill | Role |
|-------|------|
| `/scaffold-setup` | Initialize — scaffold the structure for a new project |
| `/scaffold-status` | Orient — read state, present options |
| `/scaffold-plan` | Consult + author — discuss direction, persist into the right docs |
| `/scaffold-go` | Execute — run the active phase brief |
| `/scaffold-checkpoint` | Save + reconcile — verify, update files, sweep, commit |
| `/scaffold-audit` | Audit — deep conformance + reality check (on demand) |
| `/scaffold-integrate` | Absorb — ingest an artifact (spec, research) into scaffold |
| `/scaffold-cleanup` | Migrate an existing project to this structure |
| `/scaffold-update` | Update scaffold skills to the latest version |
```

Point the orientation block at `architecture.md`. Present `CLAUDE.md` changes for
confirmation — don't silently drop a
custom section; offer (a) drop, (b) move to `~/.claude/CLAUDE.md`, (c) keep below Hard
constraints.

## Step 7: Curate decisions — promote the few (Adam-gated)

**Decisions are *curated, not split.*** Most legacy `decisions.md` entries are
build-records that don't clear the high ADR bar (rare, architecturally-significant,
cross-cutting choices you'd want the *why* of in a year). Detect and run an interactive
promote-the-few session:

- A single `decisions.md` with many entries → curate.
- An existing `decisions/NNNN-slug.md` folder → already-promoted ADRs; leave them, renumber
  nothing, fold in survivors *after* the existing numbers.
- A grandfathered spec's own internal decisions file → **never cracked open.** Leave whole.

Walk the entries, classify each as a proposed ADR or a build-record, present grouped:

> "## Decision curation — N entries in `decisions.md`
> **Proposed ADRs** (clear the bar — durable, cross-cutting *why*):
> 1. [date — title] → `decisions/NNNN-slug.md` — [why it qualifies]
> **Retire to git** (build-records below the bar — git keeps them):
> - [date — title], …
> No ADR is written without your approval. Which do you confirm? Anything to keep as an
> ADR instead?"

**STOP. Wait for explicit approval** — stricter than every other file by design. For each
approved ADR write `.scaffold/decisions/NNNN-slug.md` (stamp `type: decision` frontmatter;
`# NNNN — <title>`; `**Status:** Accepted`; Context / Decision / Why / Alternatives
considered / Consequences). Number sequentially, **4-digit, zero-padded, continuing after
any existing ADRs**. The rest **retire to git** (they leave with the deleted
`decisions.md`; git keeps the history — no git? fold each as a one-line "retired" note
rather than losing it). Wire architectural ADRs into `architecture.md`'s references in this
same pass (the coupling rule — filling the Step 6 placeholders).

## Step 8: Normalize nonconformant names

- **Investigations** use `YYYYMMDD-slug` (date, no dashes): `2026-06-11-gap-map.md` →
  `20260611-gap-map.md`. Stamp `type: investigation` frontmatter.
- **Decisions** `NNNN-slug` (4-digit, continuing the sequence); **phases** `NN-slug`
  (2-digit) — preserve interstitials.
- `git mv` to preserve history; repoint every reference from the Step 3 sweep. Report each
  rename (mechanical, but list them so the sweep is auditable).

## Step 9: Repoint `state.md` and reconcile

Stamp `type: state` frontmatter. Repoint `## Next` to the new path per the rename map.
Ensure the four sections exist in order (Active focus / Next / Blockers / Open Questions),
with literal `None.` where Blockers/Open Questions are empty. **Preserve transient
operational state as `## Notes`** if `state.md` carried any (durable run/env facts went to
`architecture.md` in Step 6 — only transient stuff stays). Stamp `type: project` on
`project.md` and any `knowledge/*.md` (`type: knowledge`) it carries. Confirm no swept
pointer still dangles.

## Step 10: Present the full migration, then execute

Present the **complete** change set at once — moves, new files, renames, rewrites,
deletions (`decisions.md`, the now-empty `plans/`):

```
## Migration plan
**Milestone:** milestones/NN-slug/ (created)
  plan.md   ← roadmap build-plan body (checklist preserved)
  phases/   ← N briefs moved from plans/ (interstitials preserved)
  spec/     ← pointer to [path] (if any)
**roadmap.md** → program altitude (Milestones index + Backlog); frontmatter stamped
**architecture.md** → NEW (from CLAUDE.md stack + decisions + run/env)
**decisions/** → N ADRs promoted (Adam-approved); M build-records retired to git
**investigations/** → K names normalized to YYYYMMDD; frontmatter stamped
**state.md / project.md / knowledge/** → frontmatter stamped; Next repointed; [## Notes kept]
**CLAUDE.md** → stack removed (→ architecture.md); Skill Reference table updated
**Reference sweep:** N pointers repointed, 0 dangling
**Staleness flags:** [downstream briefs to re-sweep with /scaffold-plan, if any]
```

**STOP. Wait for explicit approval before writing anything.** Incorporate any
modifications and re-present. On approval, apply in one pass:
1. Create `milestones/NN-slug/{plan.md, phases/}` and the `spec/` pointer if applicable.
2. `git mv` the briefs and renamed investigations (preserve history).
3. Write `architecture.md`; write approved `decisions/NNNN-slug.md` ADRs.
4. Rewrite `roadmap.md`; update `state.md`, `project.md`, `CLAUDE.md`; stamp all
   frontmatter.
5. Repoint every reference from the sweep.
6. Delete the migrated `decisions.md` and the now-empty `plans/`.

Re-read the moved/rewritten files; confirm no pointer dangles. With git:
`git add -A .scaffold/ CLAUDE.md && git commit -m "scaffold: migrate to milestone structure"`.
Summarize what moved, what was promoted vs retired, what was renamed, and any staleness
flags to address next with `/scaffold-plan`.

---

## Boundaries

Cleanup does NOT: modify project code (migrates scaffold files only); promote an ADR
without approval (`decisions/` is hard-gated); renumber phases or interstitials (`09.1`
stays `09.1`); crack open a grandfathered spec's internals (points/updates paths only);
fix stale downstream briefs (flags them — `plan`/`checkpoint` own re-sweeping); or populate
`knowledge/` (durable rules graduate at milestone close via `checkpoint`, or via
`integrate`, not during a structural migration).
