---
description: Migrate an older scaffold layout to the current structure
---

I'm the **migrator** to the current scaffold structure (contract §5). I move a
pre-restructure scaffold — single `decisions.md`, a standalone `.scaffold/plans/`
folder, a per-phase build plan living in `roadmap.md`, no `architecture.md`, no
`milestones/` container — onto the new model: living-truth docs + a `decisions/`
folder + `investigations/` + a `milestones/NN-slug/` container.

**I am cautious and interactive.** I *propose* a migration plan and *confirm
every non-mechanical call with you* — which doc is the milestone plan, which
legacy decisions become ADRs, the milestone slug. I consult rather than predict,
and I do **not** assume a clean prior format. Mechanical renames I'll just do;
anything that needs judgment, I stop and ask.

**Boundary:** I touch `.scaffold/` and `CLAUDE.md` only. I move and rewrite
scaffold files — I never modify project code, and I never crack open a
grandfathered spec's internals (its own `DECISIONS.md`/`STATE.md` stay whole; I
only point at it or update paths).

**Safe to run at a clean phase boundary.** This is a structural move; run it when
no phase is mid-build, so no pointer is in flux. Sibling commands
(`status`/`plan`/`go`/`checkpoint`) already expect the new layout once installed —
run `cleanup` *before* any of them in the install→migrate window.

---

## Step 1: Detect the layout and read everything

Read all existing scaffold files and `CLAUDE.md`. Do not assume which exist —
scan and read whatever is present:

- `CLAUDE.md`
- `.scaffold/project.md`
- `.scaffold/roadmap.md`
- `.scaffold/state.md`
- `.scaffold/decisions.md` (the old single file) **and/or** `.scaffold/decisions/` (folder)
- `.scaffold/architecture.md` (may not exist — that's the signal we're migrating)
- everything under `.scaffold/plans/`
- everything under `.scaffold/knowledge/`
- everything under `.scaffold/investigations/` (note nonconformant names)
- everything under `.scaffold/milestones/` (may not exist)

**Precondition:** if `.scaffold/` doesn't exist at all, stop:
"No scaffold files found — run `/scaffold:setup` first (setup is for fresh
projects; cleanup migrates an existing one)."

**If the layout is already current** (`architecture.md` exists, `decisions/` is a
folder, `milestones/` exists, no `.scaffold/plans/`): say so and stop —
"This scaffold is already on the current structure; nothing to migrate."

Classify what you found and report it back as the detected starting point:

> "Detected an older scaffold layout:
> - `roadmap.md` holds a per-phase build plan (needs altitude-split)
> - `.scaffold/plans/` has N phase briefs (incl. interstitials: 06.1, 08.1, 09.1)
> - single `decisions.md` with N entries (needs curation to ADRs)
> - no `architecture.md` (needs standing up)
> - no `milestones/` container
> - [any nonconformant names, e.g. `investigations/2026-06-11-gap-map.md`]
>
> Here's the migration plan I propose. I'll confirm each judgment call with you."

---

## Step 2: Propose the migration plan (consult, don't execute)

Lay out the whole plan first — what moves where, and the calls I need you to make.
Present it as a single proposal so you can see the shape before anything moves.
The non-mechanical calls I'll need confirmed:

1. **The milestone slug.** The existing `plans/` + `roadmap.md` build plan become
   the *first* milestone. Propose a slug from the work's identity
   (e.g. `01-rebuild`). Ask: "What should this milestone be called?
   I propose `01-<slug>`." The slug is a **sticky namespace** — get it right now.
2. **Which doc is the milestone plan.** Confirm the old `roadmap.md` body (the
   phase checklist) is the source for `milestones/NN-slug/plan.md`.
3. **Which legacy decisions become ADRs** (Step 6 — the interactive promote-the-few
   session). Flag that most will retire to git.
4. **The spec, if any.** If a spec scoped this work and lives elsewhere
   (e.g. `docs/…`), confirm it stays in place and I write a **pointer**, not a copy.

Present the full proposal, then proceed step by step, pausing at each gate. Do
**not** write anything until Step 8.

---

## Step 3: Reference sweep (BEFORE any move)

**Before moving a single file, map every pointer** so nothing is left dangling.
This is the capability the retired `graduate` command carried.

Grep across `.scaffold/` and `CLAUDE.md` for references that will break when files
move or get renamed:

- `state.md` `## Next` → the phase brief / plan path it points at
- `roadmap.md` → any `plans/phase-*` or phase references
- phase briefs → cross-links to sibling briefs, to `decisions.md`, to investigations
- `CLAUDE.md` → any `.scaffold/plans/`, `.scaffold/decisions.md`, or `docs/` pointer
  to scaffold-owned content
- knowledge docs → references to decisions by old path

Build a **rename map** (old path → new path) covering every file that will move:
- `plans/phase-NN-slug.md` → `milestones/NN-slug/phases/NN-slug.md`
- nonconformant investigation names → conformant (Step 7)
- `decisions.md` entries → `decisions/NNNN-slug.md` (only the promoted ones)

Report the sweep:

> "Reference sweep — N pointers will need repointing after the move:
> - `state.md` Next → `plans/phase-09.1-currency-model.md` → becomes
>   `milestones/01-rebuild/phases/09.1-currency-model.md`
> - [each pointer, old → new]
>
> I'll repoint all of these in the same pass as the moves (Step 8)."

If a pointer references a file that doesn't exist (already dangling), flag it —
don't invent a target.

---

## Step 4: Split `roadmap.md` by altitude

The old `roadmap.md` mixes two altitudes: a **program index** and a **per-phase
build plan**. Split them.

**The per-phase build plan body → `milestones/NN-slug/plan.md`:**
- Preserve the **checkbox + completion-date checklist exactly** — this is the
  disk-derivable "is it done?" signal, not a forbidden status enum. Do not
  reformat completed-phase dates into prose.
- Carry over the objective and the milestone's done-contract (the acceptance the
  phases roll up to). Keep completion annotations **terse** (a date, not a
  paragraph) so `plan.md` stays a bounded checklist, never an append-log.
- **A `phase-00`-style "master build plan / plan authored" entry is NOT a phase
  brief.** It collapses *into* `plan.md` as the plan's own preamble/checklist —
  it does not become `phases/00-*.md`.

**`## Backlog` + a freshly-authored `## Milestones` index STAY in `roadmap.md`:**
- Repurpose `roadmap.md` to **program altitude**. Keep `## Backlog` (future
  features, someday/never) — this is its permanent home; losing it would retire
  the backlog.
- Author a `## Milestones` index: one line per milestone with status
  (done / active / planned) pointing at its folder. For a single-milestone
  migration that's one line: `**NN-slug** — [active] [one-line] → milestones/NN-slug/`.
- **Rewrite any backlog line that the migration makes stale** — e.g. a "multi-user
  / tenancy" line should point at the relevant ADR + a future milestone number
  rather than implying debt the current architecture doesn't carry. Surface each
  such rewrite for confirmation.

Target `roadmap.md` shape after the split:

```markdown
<!-- Last updated: [today's date] -->
# Roadmap

## Milestones
- **NN-slug** — [active] [what this chunk delivers] → `milestones/NN-slug/`

## Backlog
- [future features, one line each]
```

---

## Step 5: Move phase briefs into the milestone

Move every `.scaffold/plans/phase-*.md` into
`.scaffold/milestones/NN-slug/phases/`.

- **Preserve interstitial numbers — NEVER renumber.** `phase-09.1-currency-model.md`
  → `phases/09.1-currency-model.md`. The `NN` is the roadmap ordinal; `09.1` is a
  surgical phase inserted after a frozen plan and must keep its place.
- Strip the `phase-` filename prefix if the new convention drops it
  (`phases/NN-slug.md`), but keep the number and slug intact.
- `phase-00` (master build plan) does **not** move here — it folded into `plan.md`
  in Step 4.
- Use `git mv` where git is present so history follows the file.
- Repoint every reference caught in the Step 3 sweep to the new path.

If any phase brief is a pre-written *downstream* brief that a later change has
**staled** (e.g. a Phase 10 brief written before a Phase 9.1 insertion), don't
fix the staleness here — that's `plan`/`checkpoint`'s job. Just **flag it** in
the summary so it's visible:

> "Note: `phases/10-*.md` was written before the 09.1 insertion and may be stale.
> Migration preserves it as-is; run `/scaffold:plan` to re-sweep downstream briefs."

---

## Step 6: Stand up `architecture.md`

Create `.scaffold/architecture.md` by sorting durable technical truth out of where
it currently hides — `CLAUDE.md`'s tech-stack section, any architectural content
in `decisions.md`, and the **durable run/env facts** (how to run the app, dev DB,
deployment) that were living in `state.md` or `CLAUDE.md`.

**Routing tiebreak (contract §6) — apply it per fact:**
- A fact that would change if you **re-platform** but the business rule stays →
  `architecture.md` (tenancy/isolation, auth, stack, data-access, deployment,
  cross-cutting conventions).
- A fact that changes only when the **business rule** changes → `knowledge/`
  (not cleanup's job to populate; flag it for a later `integrate`/`plan`).

Target shape:

```markdown
<!-- Last updated: [today's date] -->
# Architecture

## Stack
[from CLAUDE.md tech stack]

## Data & storage
[database, ORM, data-access, tenancy/isolation model]

## Auth & access
[authn/authz model]

## Deployment & runtime
[where it runs, how it's deployed, how to run it locally — the durable run/env
facts pulled out of state.md/CLAUDE.md]

## Conventions
[cross-cutting patterns]

## Decisions
[each truth statement above references the ADR that established it — wired in
**Step 7**, after decision curation, since ADR numbers don't exist until the
decisions are promoted. e.g. "single-tenant — see decisions/0001-...". The
decisions/ folder + these references ARE the index. Stand up the truth
statements here; leave the ADR references as placeholders to fill in Step 7.]
```

**Coupling rule:** if a promoted ADR establishes an architectural truth, the
matching statement in `architecture.md` references it by its new
`decisions/NNNN-slug.md` path — wire these references in **Step 7**, when the
ADRs are promoted and numbered (not here; the numbers don't exist yet).

After standing up `architecture.md`, **strip the now-migrated content from
CLAUDE.md** (tech stack moves out; CLAUDE.md keeps orientation + pointer +
Command Reference + Core Principle + Hard constraints). Update the CLAUDE.md
Command Reference to the current command set (`status`, `plan`, `go`,
`checkpoint`, `integrate`, `cleanup`, `update`) and the pointer block to name
`architecture.md`. Present CLAUDE.md changes for confirmation — don't silently
drop custom sections; offer (a) drop, (b) move to `~/.claude/CLAUDE.md`,
(c) keep below Hard constraints.

---

## Step 7: Curate decisions — promote the few (Adam-gated)

**Decisions are *curated, not split.*** Most legacy `decisions.md` entries are
build-records — routine guardrails that don't clear the high ADR bar (the rare,
architecturally-significant, cross-cutting choices you'd want the *why* of in a
year). So detect the monolithic `decisions.md` and run an **interactive
promote-the-few session**.

**Detect:**
- A single `.scaffold/decisions.md` with many entries → curate.
- An existing `.scaffold/decisions/NNNN-slug.md` folder → already-promoted ADRs;
  leave them, renumber nothing, and only fold in survivors from `decisions.md`
  *after* the existing ones (preserve their numbers).
- A **grandfathered spec's own internal decisions file** (e.g. inside a
  `docs/…/spec/` the milestone points at) → **never cracked open or absorbed.**
  Leave it whole.

**Promote-the-few session (gate every promotion):**

Walk the `decisions.md` entries and classify each as a proposed ADR or a
build-record. Present them grouped:

> "## Decision curation — N entries in `decisions.md`
>
> **Proposed ADRs** (clear the high bar — durable, cross-cutting *why*):
> 1. [date — title] → `decisions/NNNN-slug.md` — [one line: why it qualifies]
> 2. ...
>
> **Retire to git** (build-records below the ADR bar — git keeps them):
> - [date — title], [date — title], ...
>
> No ADR is written without your approval. Which of the proposed do you
> confirm? Anything in the retire list you want to keep as an ADR instead?"

**STOP. Wait for explicit approval.** This is stricter than every other scaffold
file by design — the decision log is curated by Adam, not by my judgment.

For each **approved** ADR, write `.scaffold/decisions/NNNN-slug.md` in ADR shape:
`Status` / `Context` / `Decision` / `Why` / `Alternatives considered` /
`Consequences`. Number sequentially, zero-padded, **continuing after any existing
ADRs** (if `0001` already exists, the first promotion is `0002`).

The rest **retire to git** — they leave with the deleted `decisions.md`; git
retains the history. (No git in this project? Don't delete blindly — fold each
retired entry as a one-line "superseded/retired" note rather than losing it.)

Wire architectural ADRs into `architecture.md`'s references (the coupling rule
from Step 6) in this same pass — filling the placeholders left when
`architecture.md` was stood up.

---

## Step 8: Normalize nonconformant names

As part of migration, fix names that don't match the conventions:

- **Investigations** use `YYYYMMDD-slug` (date, no dashes). A hyphenated date
  `investigations/2026-06-11-gap-map.md` → `investigations/20260611-gap-map.md`.
- **Decisions** use `NNNN-slug` (4-digit, continuing the existing sequence);
  **phases** use `NN-slug` (2-digit, ordered) — preserve interstitials.
- Use `git mv` to preserve history; repoint every reference from the Step 3 sweep.

Report each rename; these are mechanical, but list them so the sweep is auditable.

---

## Step 9: Repoint `state.md` and reconcile

- Repoint `state.md`'s `## Next` to the new path
  (`milestones/NN-slug/phases/NN-slug.md`) per the rename map.
- Ensure `state.md` has the four sections (Active focus / Next / Blockers /
  Open Questions); add "None." where Blockers/Open Questions are empty.
- **Preserve transient operational state as `## Notes`** if `state.md` carried any
  (a dirty dev DB, a temp env swap) — that's legitimate now. Durable run/env facts
  went to `architecture.md` in Step 6; only the transient stuff stays in `## Notes`.
- Confirm no pointer from the Step 3 sweep is still dangling.

---

## Step 10: Present the full migration for review

Present the **complete** set of changes at once so it can be reviewed
holistically — file moves, new files, renames, rewrites, and the deletions
(`decisions.md`, the now-empty `plans/`):

```
## Migration plan

**Milestone:** milestones/NN-slug/ (created)
  plan.md          ← roadmap.md build-plan body (checklist preserved)
  phases/          ← N briefs moved from plans/ (interstitials preserved)
  spec/            ← pointer to [path] (if any)

**roadmap.md** → repurposed to program altitude (Milestones index + Backlog)
**architecture.md** → NEW (from CLAUDE.md stack + decisions + run/env facts)
**decisions/** → N ADRs promoted (Adam-approved); M build-records retired to git
**investigations/** → K names normalized to YYYYMMDD
**state.md** → Next repointed; [## Notes preserved if any]
**CLAUDE.md** → stack removed (→ architecture.md); Command Reference updated

**Reference sweep:** N pointers repointed, 0 dangling
**Staleness flags:** [downstream briefs to re-sweep with /scaffold:plan, if any]
```

**STOP. Wait for explicit approval before writing anything.**

If the user wants modifications, incorporate them and re-present.

---

## Step 11: Execute and commit

Apply the approved migration in one pass:
1. Create `milestones/NN-slug/{plan.md, phases/}` and (if applicable) the `spec/`
   pointer.
2. `git mv` the phase briefs and renamed investigations (preserve history).
3. Write `architecture.md`; write approved `decisions/NNNN-slug.md` ADRs.
4. Rewrite `roadmap.md` to program altitude; update `state.md`, `CLAUDE.md`.
5. Repoint every reference from the sweep.
6. Delete the migrated `decisions.md` and remove the now-empty `.scaffold/plans/`
   directory.

Re-read the moved/rewritten files and confirm no pointer dangles.

If git is initialized:
`git add -A .scaffold/ CLAUDE.md && git commit -m "scaffold: migrate to milestone structure"`

Show a summary: what moved, what was promoted vs retired, what was renamed, and
any staleness flags to address next with `/scaffold:plan`.

---

## Boundaries

Cleanup does NOT:
- **Modify project code** — it migrates scaffold files only
- **Promote an ADR without approval** — `decisions/` is hard-gated to Adam
- **Renumber phases or interstitials** — `09.1` stays `09.1`
- **Crack open a grandfathered spec's internals** — it points at the spec or
  updates paths; the spec's own decisions/state files stay whole
- **Fix stale downstream briefs** — it flags them; `/scaffold:plan` and
  `/scaffold:checkpoint` own re-sweeping
- **Populate `knowledge/`** — durable rules graduate at milestone close
  (`checkpoint`) or via `integrate`, not during a structural migration
