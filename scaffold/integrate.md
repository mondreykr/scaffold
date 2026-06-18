---
description: Absorb an external artifact into scaffold and route it home
argument-hint: [path/to/artifact]
---

**Precondition:** Verify that CLAUDE.md, `.scaffold/project.md`,
`.scaffold/state.md`, and `.scaffold/roadmap.md` exist. If any are missing,
stop and say: "Scaffold files missing — run /scaffold:setup first."

**Boundary:** This command is **pure ingest**. It absorbs an external artifact
and routes it to its home, plus extracts operational facts into the truth docs.
It does NOT:
- **Author plans or phase briefs** — that's `/scaffold:plan`.
- **Run a coherence sweep or write back build results** — that's `/scaffold:checkpoint`.
- **Migrate an old-format repo** — that's `/scaffold:cleanup`.
- **Create, supersede, or prune a decision (ADR)** — `decisions/` is Adam-gated.
  If the artifact contains a load-bearing ruling, surface it and hand off to
  `/scaffold:plan` or `/scaffold:checkpoint` to propose the ADR — never write one here.
- **Change code or execute work.**

---

## Step 1: Locate the Artifact

The artifact path is given as the argument (e.g.
`/scaffold:integrate docs/20260326-import-spec/`). It may be a single file or a
directory.

**If no path was given:** ask which artifact to absorb. Do not scan or guess —
ingest acts on an artifact the user names.

**If the path doesn't exist:** stop and report. Don't try alternative paths.

---

## Step 2: Read for Routing

Read enough to classify the artifact — its purpose, scope, and shape:

1. The artifact itself (the file, or the directory's entry/index doc plus its
   structure — note any `references/`, `DECISIONS.md`, `STATE.md` it carries).
2. `.scaffold/roadmap.md` — the milestone index (does this artifact scope one of
   these milestones, or a new one?).
3. `.scaffold/architecture.md` (skip if absent) — to spot operational facts the
   artifact carries that the truth docs are missing.

Do NOT read all of `knowledge/` or every milestone — read only what you need to
decide where this artifact belongs.

---

## Step 3: Classify — Spec or Knowledge

An artifact routes to exactly one primary home:

- **It SCOPES a milestone** (a spec / contract / design doc that defines a chunk
  of work — done, active, or about to start) → the milestone's **`spec/`**
  (Step 4a).
- **It is cross-cutting DURABLE KNOWLEDGE** (a domain/behavioral rulebook, a
  reference that outlives any one milestone — "how the ledger replays,"
  "reconciliation tolerances") → **`knowledge/`** (Step 4b).

Tiebreak: if the artifact's authority is *bounded by a milestone's lifecycle*
(retires when that work closes), it's a spec; if it's *durable truth that stays
current as code changes*, it's knowledge. A milestone spec's enduring rules
graduate into `knowledge/` later — but that graduation is `checkpoint`'s
milestone-close job, not integrate's.

State the classification and the destination before writing:

> "This artifact scopes milestone `01-rebuild` → routing to its `spec/`."
> — or —
> "This is cross-cutting durable knowledge → routing to `knowledge/`."

---

## Step 4a: Route a Milestone Spec to `spec/`

Identify the target milestone from `roadmap.md` (confirm with the user if it's
ambiguous, or if the milestone folder doesn't exist yet). Then choose **copy vs.
pointer** — ask the user if it's not obvious:

- **Copy in** — the artifact has no other home and belongs to scaffold. Place it
  at `.scaffold/milestones/NN-slug/spec/` (a file, or the directory contents).
  The original is **never modified or deleted** — copy, don't move, unless the
  user says to move it.
- **Pointer file** — the spec should stay where it lives: a **shared** spec, a
  spec another tool owns, or one **grandfathered** in `docs/`. Write a small
  pointer at `.scaffold/milestones/NN-slug/spec/POINTER.md`:

  ```markdown
  <!-- Last updated: [today's date] -->
  # Spec pointer

  The spec for this milestone lives at: `[relative/path/to/spec]`

  It is maintained in place and is the **live rulebook** for this milestone
  until it closes. Its `references/` (if any) are the active rules. Do not copy
  its content into `.scaffold/`. At milestone close, its enduring rules graduate
  to `knowledge/` (a `/scaffold:checkpoint` job).

  Why it lives outside scaffold: [shared / external tool owns it / grandfathered].
  ```

**Pointer'd-spec rule (hard):** a pointer'd spec's **internals are never cracked
open or absorbed**. If it carries its own `DECISIONS.md` / `STATE.md` / `references/`,
those stay whole inside it — do not split them into `.scaffold/decisions/`,
`state.md`, or `knowledge/`. Only update paths if the spec is ever physically
moved.

A spec is a **live artifact, not frozen**, until its milestone closes. Integrate
does not freeze it or graduate its rules — it only places it (or its pointer).

---

## Step 4b: Route Durable Knowledge to `knowledge/`

Create `.scaffold/knowledge/` if it doesn't exist. Place the artifact at
`.scaffold/knowledge/<slug>.md` where `slug` is a descriptor derived from the
artifact's subject (e.g. `ledger-replay.md`, `reconciliation.md`). Knowledge
docs are named by topic, not date — they're living truth, maintained in place.

**If a knowledge doc on the same topic already exists:** do not silently
overwrite or blindly append. Show the user the overlap and ask whether to (a)
merge the new material into the existing doc, (b) save as a distinct doc, or (c)
replace it. Reconciling *contradictions* across the whole knowledge set is
`checkpoint`'s coherence sweep — integrate only handles the doc it's placing.

---

## Step 5: Extract Operational Facts Into the Truth Docs

Beyond its primary home, an artifact often carries operational facts that belong
in living truth. Extract these — and only these — applying the routing table:

- **Durable run/env facts** (how to run the app, required env vars, deployment
  shape, data-access patterns) → `.scaffold/architecture.md`. If architecture.md
  doesn't exist yet and the facts are slim, they may sit as a section; otherwise
  propose creating it.
- **Transient operational state** (dirty dev DB, a temporary env swap, "re-seed
  before verify") → `state.md` `## Notes` (add the section if absent).
- **A scope-boundary or requirement the artifact makes explicit** →
  `project.md` (scope boundaries / Requirements as `- [ ]` checkboxes, exact
  wording). Only what the artifact states plainly — don't invent.
- **A new milestone or backlog one-liner the artifact implies** → flag it for
  `roadmap.md`, but **propose, don't author the milestone** — milestone creation
  and phase planning are `/scaffold:plan`'s job.

**Do not** extract decisions into `decisions/` (Adam-gated — hand off, per the
boundary), and **do not** author phase briefs or a milestone `plan.md` (that's
`plan`). Keep extraction to operational truth only.

Present the extraction set before writing:

> "Extracting into truth docs:
> - architecture.md: [run/env facts]
> - state.md ## Notes: [transient state]
> - project.md: [scope/requirement made explicit]
> Flagging for `/scaffold:plan` (not authored here): [implied milestone/backlog]."

**STOP. Wait for confirmation** if there's anything beyond the primary placement.

Update `<!-- Last updated -->` on every truth doc you touch.

---

## Step 6: Report and Commit

Summarize the ingest:

> "## Integration Summary
> **Artifact:** [path]
> **Routed to:** [`milestones/NN-slug/spec/` (copy | pointer)] or [`knowledge/<slug>.md`]
> **Truth docs touched:** [architecture.md / state.md / project.md — or none]
> **Handed off (not done here):** [ADR proposal → checkpoint/plan; milestone → plan — or none]"

Run `git diff .scaffold/ CLAUDE.md` to show exact changes (the original artifact
is untouched and won't appear unless it lives under `.scaffold/`).

**STOP. Wait for confirmation before committing.**

If git is initialized:
`git add .scaffold/ CLAUDE.md && git commit -m "integrate: [artifact]"`

---

## Principles

**Ingest, then route — nothing more.** Integrate's whole job is getting an
external artifact to its correct home and lifting operational facts into the
truth docs. Authoring, reconciling, and migrating belong to other commands.

**Place; don't dissect.** A spec routed by pointer stays whole — its internals
are never cracked open. A spec copied in is placed as-is, not summarized into
scaffold files.

**The original is never touched.** Integrate copies or points; it does not move
or modify the source artifact unless the user explicitly says to.

**Hand off what you don't own.** A ruling the artifact contains is *surfaced* and
routed to `plan`/`checkpoint` for an Adam-gated ADR — integrate never writes
`decisions/`. An implied milestone is *flagged* for `plan` — integrate never
authors plans or briefs.
