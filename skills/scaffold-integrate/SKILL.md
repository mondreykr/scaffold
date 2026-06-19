---
name: scaffold-integrate
description: Absorb an external artifact (a spec, design doc, or research) into a scaffold project and route it to its one home — a milestone's spec/ (copy or pointer) or knowledge/ — then lift operational facts into the truth docs. Pure ingest; never authors plans, briefs, or ADRs, and never touches code. Use whenever the user wants to integrate, absorb, ingest, bring in, or pull in an external doc/spec/research — even if they only say "integrate this", "absorb that spec", or "add this doc to the scaffold". To migrate an old scaffold layout, use /scaffold-cleanup instead.
---

# scaffold-integrate

Pure ingest: absorb an external artifact, route it to its one home, and lift operational
facts into the truth docs. Nothing more — authoring, reconciling, and migrating belong to
other skills.

**Boundary.** Integrate does NOT: author plans or phase briefs (`scaffold-plan`); run a
coherence sweep or write back build results (`scaffold-checkpoint`); migrate an old-format
repo (`scaffold-cleanup`); create/supersede/prune a decision (`decisions/` is Adam-gated —
surface a ruling and hand to `plan`/`checkpoint`, never write one here); or change code.

**Precondition.** `CLAUDE.md`, `.scaffold/project.md`, `.scaffold/state.md`,
`.scaffold/roadmap.md` exist. If any is missing, stop: "Scaffold files missing — run
/scaffold-setup first."

**Frontmatter.** Any `.scaffold/` doc you create or touch carries `type` /
`schema_version: 1` / `updated:` (set to today). `CLAUDE.md` is exempt.

---

## Step 1: Locate the artifact

The artifact is named in the invocation (e.g. "integrate docs/20260326-import-spec/") —
a single file or a directory. **If none was named,** ask which artifact to absorb; do not
scan or guess. **If the path doesn't exist,** stop and report — don't try alternatives.

## Step 2: Read for routing

Read enough to classify — purpose, scope, shape:

1. The artifact itself (the file, or a directory's entry/index doc plus its structure —
   note any `references/`, `DECISIONS.md`, `STATE.md` it carries).
2. `roadmap.md` — does this scope an existing milestone, or a new one?
3. `architecture.md` (skip if absent) — to spot operational facts it carries that the
   truth docs lack.

Don't read all of `knowledge/` or every milestone — only what you need to place it.

## Step 3: Classify — spec or knowledge

Exactly one primary home:

- **Scopes a milestone** (a spec/contract/design doc defining a chunk of work — done,
  active, or about to start) → that milestone's **`spec/`** (Step 4a).
- **Cross-cutting durable knowledge** (a domain/behavioral rulebook that outlives any one
  milestone — "how the ledger replays", "reconciliation tolerances") → **`knowledge/`**
  (Step 4b).

Tiebreak: if its authority is *bounded by a milestone's lifecycle* (retires when that work
closes) → spec; if it's *durable truth that stays current as code changes* → knowledge. A
spec's enduring rules graduate to `knowledge/` later, but that graduation is
`checkpoint`'s milestone-close job, not integrate's. State the classification and
destination before writing.

## Step 4a: Route a milestone spec to `spec/`

Identify the target milestone from `roadmap.md` (confirm if ambiguous or the folder
doesn't exist yet). Then **copy vs. pointer** (ask if not obvious):

- **Copy in** — the artifact has no other home and belongs to scaffold. Place it at
  `.scaffold/milestones/NN-slug/spec/` (a file, or the directory contents). The original
  is **never modified or deleted** — copy, don't move, unless the user says to. An
  embedded full spec keeps its own authoring convention; scaffold imposes no frontmatter
  on it.
- **Pointer file** — the spec should stay where it lives (shared, owned by another tool,
  or grandfathered in `docs/`). Write a short pointer at
  `.scaffold/milestones/NN-slug/spec/POINTER.md`:

  ```markdown
  ---
  type: spec-pointer
  schema_version: 1
  updated: [today]
  ---

  # Spec pointer

  The spec for this milestone lives at: `[relative/path/to/spec]`

  It is maintained in place and is the **live rulebook** for this milestone until it
  closes; its `references/` (if any) are the active rules. Do not copy its content into
  `.scaffold/`. At milestone close, its enduring rules graduate to `knowledge/` (a
  `/scaffold-checkpoint` job).

  Why it lives outside scaffold: [shared / external tool owns it / grandfathered].
  ```

**Pointer'd-spec rule (hard):** its internals are **never cracked open or absorbed**. A
carried `DECISIONS.md` / `STATE.md` / `references/` stays whole inside it — do not split
into `.scaffold/decisions/`, `state.md`, or `knowledge/`. A spec is **live, not frozen**,
until its milestone closes; integrate only places it (or its pointer).

## Step 4b: Route durable knowledge to `knowledge/`

Place the artifact at `.scaffold/knowledge/<slug>.md` (slug from its subject —
`ledger-replay.md`, `reconciliation.md`); named by topic, not date. Stamp `type:
knowledge` frontmatter. **If a knowledge doc on the same topic exists,** don't silently
overwrite or blind-append — show the overlap and ask: (a) merge into the existing doc, (b)
save as a distinct doc, (c) replace. Reconciling *contradictions* across the whole set is
`checkpoint`'s sweep — integrate handles only the doc it's placing.

## Step 5: Extract operational facts into the truth docs

Beyond its primary home, lift operational facts — and only these:

- **Durable run/env facts** (how to run it, env vars, deployment shape, data-access) →
  `architecture.md`. If it doesn't exist and the facts are slim, propose creating it.
- **Transient operational state** (dirty dev DB, temp env swap) → `state.md` `## Notes`
  (add the section if absent).
- **A scope-boundary the artifact makes explicit** → `project.md`, as **plain truth** in
  `## Scope` or `## Not building` — **never a checkbox** (checkboxes are a `project.md`
  anti-pattern). A *verifiable invariant* the artifact states routes to where it's tested
  (the milestone done-contract, a brief's acceptance, or a `knowledge/` invariants doc),
  not a truth doc. Only what the artifact states plainly — don't invent.
- **A new milestone or backlog one-liner it implies** → flag for `roadmap.md`, but
  **propose, don't author** — milestone creation + phase planning are `plan`'s job.

Do **not** extract decisions into `decisions/` (Adam-gated — hand off) or author briefs /
a `plan.md` (`plan`). Present the extraction set before writing, and **STOP for
confirmation** if there's anything beyond the primary placement:

> "Extracting into truth docs:
> - architecture.md: [run/env facts]
> - state.md ## Notes: [transient state]
> - project.md: [scope boundary made explicit]
> Flagging for /scaffold-plan (not authored here): [implied milestone/backlog]."

Set `updated:` on every truth doc you touch.

## Step 6: Report + commit

> "## Integration summary
> **Artifact:** [path]
> **Routed to:** [`milestones/NN-slug/spec/` (copy | pointer)] or [`knowledge/<slug>.md`]
> **Truth docs touched:** [architecture.md / state.md / project.md — or none]
> **Handed off (not done here):** [ADR → plan/checkpoint; milestone → plan — or none]"

Run `git diff .scaffold/ CLAUDE.md` to show exact changes (the original artifact is
untouched and won't appear unless it lives under `.scaffold/`). **STOP for confirmation
before committing.** With git: `git add .scaffold/ CLAUDE.md && git commit -m "integrate:
[artifact]"`.

---

## Principles

**Ingest, then route — nothing more.** Get the artifact to its correct home and lift
operational facts; authoring/reconciling/migrating belong elsewhere. **Place; don't
dissect** — a pointer'd spec stays whole; a copied spec is placed as-is, not summarized.
**The original is never touched** — copy or point, don't move or modify the source unless
the user says so. **Hand off what you don't own** — a ruling is surfaced and routed to
`plan`/`checkpoint` for an Adam-gated ADR; an implied milestone is flagged for `plan`.
