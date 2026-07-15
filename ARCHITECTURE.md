# Scaffold — Architecture

This is the controlling document for the **scaffold system** (the product): how it
works and where everything goes when scaffold is applied to a user's repo. All skills
and file behaviors derive from what's defined here. It is the timeless human+AI
reference, not a changelog.

It defines *concepts*. The exact **format** of each document type lives in its
canonical contract under `contracts/` (see [Document Types](#document-types)); those
contracts are the single master of each format and the oracle the audit grades
against. (This doc lives in the dev repo — the factory — and does not ship; the
shipped artifacts are the self-contained `/scaffold-[skill]` skills.)

Scaffold is a solo-developer context-persistence system: a set of living and
historical markdown documents in a repo's `.scaffold/` directory, plus Claude Code
skills that maintain them so a session can resume after a week-long gap with full
context intact.

## Design Principles

**Scaffold runs like code.** It is a deterministic state machine whose *data is the
document structure itself*: skills compute what's active, what's done, and what to do
next by reading sections off disk (`## Next`, the `milestone.md` checkbox, a plan's
`## Scope`). That is the load-bearing invariant behind every principle below, and it has
one sharp consequence — **every piece of information must have exactly one *computable*
home, so a catch-all or open-ended section is forbidden.** A soft bucket is a
non-deterministic home: the place ambiguous data silently piles up, which is how the
machine starts misreading its own state (and how the docs bloat). When you change
Scaffold, preserve determinism — a new kind of datum gets a section with a membership
rule a skill can apply, never a dumping ground.

1. **State machine.** Every skill leaves all state documents accurate and
   self-consistent. Any skill could be the last thing that runs before a long gap.
2. **Skills are optional tools, not mandatory gates.** The minimum ceremony is
   status → work → checkpoint. Everything else is available when you need it.
3. **No plan mode dependency.** All skills run in normal mode. Shift+Tab plan mode is
   a complementary tool, not a requirement.
4. **Ceremony scales with the user.** You decide how much structure you want per
   session. The system supports freeform collaboration and formal scoped execution
   equally.
5. **A place for everything — and it's computable.** Every piece of information has
   exactly one canonical home, decidable by a rule a skill can apply. Documents don't
   duplicate each other, and no section is a catch-all.
6. **Don't tell Claude what it already knows.** Skills and rules only instruct
   behaviors Claude wouldn't do by default.
7. **Content-derived state, no enums.** What's active, what's done, and what mode a
   milestone is in are all read off disk, never stored as a status flag that can drift
   from reality.

## The Two Governing Laws

Everything below derives from two laws. They are the test for where any artifact
lives.

**Law 1 — Truth and history never share a document.** A document is *either* **living
truth** (one of it; always current; updated in place; never reconstructed by replaying
a log) *or* **frozen history** (dated; written once; never the source of current
truth). The failure mode to design out is a single append-only document that tries to
be both — it smears current truth across N entries and bloats by construction. A
living-truth document is overwritten in place; a history document is written once and
never edited as the source of present truth.

**Law 2 — A document lives at the layer that owns its lifecycle and audience.**
Work-tracking belongs to Scaffold's execution layer. System truth (architecture,
durable rules) belongs to Scaffold's truth layer. Strategy and cross-project thinking
belong to an external knowledge base (e.g. cortex). Scaffold *points outward*; it does
not absorb what another layer owns. Within the repo, `.scaffold/` is the single
governed home for project documentation; repo-level `docs/` holds only
**code-adjacent reference assets** (e.g. a design-system upload bundle), never project
documentation.

These two laws are the tie-breaker for every routing question. If a placement would
violate one, the placement is wrong — not the law.

## Information Model

Each layer has exactly one home and a defined mutability. Living layers are
overwritten in place; history layers are written once; execution layers are temporal
and retire with their milestone.

| Layer | What it is | Home | Mutability |
|-------|-----------|------|------------|
| Orientation + instructions | How Claude should work here + a one-line "what this is" | `CLAUDE.md` (auto-read) | living |
| Product identity | What this is, who for, why, scope boundaries | `.scaffold/project.md` | living |
| **Architecture truth** | How it's built — tenancy, auth, stack, data-access, deployment, conventions | `.scaffold/architecture.md` | living |
| Domain/behavioral truth | Durable cross-cutting invariants (each: the rule + why + a pointer to where code enforces it) | `.scaffold/knowledge/*.md` | living |
| Program | Milestones (done/active/planned) + backlog | `.scaffold/roadmap.md` | living |
| Active state | Where we are now / next / blockers / open questions | `.scaffold/state.md` | living (churns) |
| Decisions | Load-bearing *why* + rejected alternatives (ADRs) | `.scaffold/decisions/NNNN-slug.md` | frozen; **Adam-gated** |
| Research | Investigations / analyses produced while working | `.scaffold/investigations/YYYYMMDD-slug.md` | frozen |
| Milestone plan | The phases + objectives + acceptance + deferred work for one chunk | `.scaffold/milestones/NN-slug/milestone.md` | temporal |
| Milestone contract | The spec, if the chunk needed heavy scoping | `.scaffold/milestones/NN-slug/spec/` | temporal |
| Phase plan | Atomic execution unit: one phase's scope/approach/acceptance | `.scaffold/milestones/NN-slug/phases/NN-slug.md` | temporal |

The model has three bands: **living truth** (overwritten in place, always current),
**history** (frozen, written once), and **execution** (temporal, retires with its
milestone).

## Files & Folders

```
CLAUDE.md                         orientation + instructions + pointer into .scaffold/

.scaffold/
  # ── LIVING TRUTH (overwritten in place; never reconstructed from a log) ──
  project.md                      what this product is & why (identity/scope)
  architecture.md                 how it's built (tech truth)
  roadmap.md                      the program: milestone index + backlog
  state.md                        where we are now / next / blockers / open questions
  knowledge/
    *.md                          durable domain/behavioral truth (living)

  # ── HISTORY (frozen; written once; never the source of truth) ──
  decisions/
    NNNN-slug.md                  ADRs — load-bearing why + alternatives + status line
  investigations/
    YYYYMMDD-slug.md              research & analysis records

  # ── EXECUTION (temporal; retires with its milestone) ──
  milestones/
    NN-slug/
      milestone.md                     this milestone's phases + objectives + acceptance + deferred work
      spec/                       OPTIONAL — the contract, if heavy scoping was needed
      phases/
        NN-slug.md                phase plans

docs/                             code-adjacent reference assets ONLY (e.g. design-system bundle)
```

**No `archive/`.** Retired milestones rest in place in `milestones/`. **What's active
is whatever `state.md`'s `## Next` points at — not folder order.** "Highest `NN`" is
only a fallback hint when `state.md` is silent: a later-numbered milestone can be
pre-created while an earlier one is still active, so folder order cannot be the
authority. (`setup`/`cleanup` may write a `.scaffold/archive/` holding pre-scaffold
snapshots — an overwritten `CLAUDE.md`, superseded context files. It holds only
superseded originals, is read by no skill, and is not part of the live model. Retired
*milestones* never go there — they rest in place in `milestones/`.)

**What happened (history)** lives in git. There is no `log.md`.

## Document Types

Every document type has one canonical **format contract** in `contracts/`. This doc
defines the *concepts*; the contract defines the *exact form* (required sections,
skeleton, rules, anti-patterns) and is the oracle `/scaffold-audit` grades against. The
format detail lives in the contract, not here — so there is one master per format, not
two. **Contracts are factory-authored masters.** We write each skill's format guidance
*from* them, at the altitude that skill needs — for most skills that guidance is an inline
paraphrase, never the contract itself. **One exception:** `/scaffold-audit` grades docs
against the *exact* contract, so it ships a verbatim copy of every contract in its own
`references/` — the single place a contract is bundled into a skill. Those copies are
**derived**: `scripts/sync-contracts.sh` regenerates them from `contracts/` and its
`--check` mode guards the drift, so the direction stays one-way (master → copy). No other
skill bundles a contract.

**Frontmatter convention.** Every `.scaffold/` document carries minimal YAML
frontmatter: **`type` · `schema_version` · `updated`**. `type` is authoritative for
what a doc is — the auditor reads it, never infers. **Band is *derived* from `type`,
never stored** (a stored band would be a driftable enum — Principle 7). `CLAUDE.md` is
the one exception: a Claude Code special file with its own conventions, no frontmatter.

**Identifier convention.** An ordered, zero-padded number marks things referenced as a
sequence — milestones and phases at 2 digits (`NN`), decisions at 4 (`NNNN`,
deliberately distinct so the two namespaces never read alike). A `YYYYMMDD` date marks
a point-in-time capture (investigations). A new doc type picks its scheme by this rule.

| Type | Band | Home | Contract |
|------|------|------|----------|
| `claude-md` | living | `CLAUDE.md` | `contracts/claude-md.md` |
| `project` | living | `.scaffold/project.md` | `contracts/project.md` |
| `architecture` | living | `.scaffold/architecture.md` | `contracts/architecture.md` |
| `roadmap` | living | `.scaffold/roadmap.md` | `contracts/roadmap.md` |
| `state` | living | `.scaffold/state.md` | `contracts/state.md` |
| `knowledge` | living | `.scaffold/knowledge/*.md` | `contracts/knowledge.md` |
| `decision` | history | `.scaffold/decisions/NNNN-slug.md` | `contracts/decision.md` |
| `investigation` | history | `.scaffold/investigations/YYYYMMDD-slug.md` | `contracts/investigation.md` |
| `milestone` | execution | `.scaffold/milestones/NN-slug/milestone.md` | `contracts/milestone.md` |
| `spec-pointer` | execution | `.scaffold/milestones/NN-slug/spec/` | `contracts/spec-pointer.md` |
| `phase-plan` | execution | `.scaffold/milestones/NN-slug/phases/NN-slug.md` | `contracts/phase-plan.md` |

### Execution model (cross-cutting)

A few concepts span the execution docs and don't belong to any single contract:

- **The mode question — dissolved (no flag).** Emergent vs predetermined is not a
  setting; it's an emergent property of how much was pre-written, derivable from disk:
  a **predetermined** milestone has a `spec/` (or pointer) and pre-written phase
  plans; an **emergent** milestone has no spec and plans written just-in-time. Same
  structure either way.
- **One artifact type — the phase plan.** A plan lives at
  `milestones/NN-slug/phases/NN-slug.md`, written up front (predetermined) or
  just-in-time by `plan` (emergent), executed by `go`, and persisting as the record.
  There is no standalone `plans/` folder.
- **Draft vs. final — a plan has two states, derived from content + evidence (no
  enum).** A **draft** is code-blind: high-level, may be pre-written, not executable. A
  **final** plan has been validated against the code *as it is now* and carries a
  `## Targets` section — the files/interfaces the phase touches — stamped `as of <sha>`.
  The state is read off disk: no `## Targets` → draft; `## Targets` with the sha at HEAD →
  final & fresh; `## Targets` with the sha behind HEAD (or a dirty target file) → stale.
  This is scaffold's own idiom — a signal is *content + evidence*, like the phase checkbox
  is *checkbox + date* — so it is auditable by construction (the sha must resolve to a real
  commit and the named files must exist). **Finalizing is where the code-aware,
  reasoning-heavy work lives** (`plan`'s finalize pass); `go` is then a thin executor
  behind a deterministic `sha == HEAD?` gate. This split is what lets the reasoning step
  and the execution step run on different models / clean contexts, with a reviewable seam
  between them.
- **`--draft` / `--final` is a user-intent shortcut, not a mode enum.** `plan` asks
  "draft or finalize?" when the argument is absent; the flag only skips the ask. It is
  **never stored** anywhere on disk — the plan's state is still derived from `## Targets`
  + sha — so it does not reintroduce a driftable status flag. This is the one place
  scaffold takes an argument, and it is justified precisely because it selects an intent
  for *this* invocation rather than recording state.
- **Staleness obligation.** Because plans *persist* instead of being thrown away, they
  can go stale two ways, and each has a defense:
  - **Finalize→execute drift** — a plan finalized `as of X`, then code moves before `go`
    runs (a `/clear`, a pause, a week-long gap — scaffold's whole reason to exist).
    Defended by `go`'s **deterministic** `sha == HEAD?` check (it judges nothing — it
    compares two hashes); mismatch → `go` refuses and routes to re-finalize.
  - **Plan-set drift** — phases reordered/cut, or a plan premised on a since-superseded
    decision. Defended by `plan`'s pivot sweep over all *unexecuted* plans (**drafts
    included** — a draft on a superseded ADR still breaks the ADR gate) and
    `checkpoint`'s coherence sweep flagging a *finalized* plan vs a later decision.
  Persistence buys durability at this cost, accepted explicitly.
- **Milestone lifecycle.** Active = wherever `state.md` Next points (not folder
  order). On close, the folder rests in place (no archive move); durable rules graduate
  to `knowledge/` (reconciled, surfaced for Adam); `roadmap.md`'s milestone line flips
  to `[done]`. Any remaining `## Deferred` items are resolved, promoted, or dropped at
  close — they retire with the milestone, never silently graveyarded.
- **Deferred work (`milestone.md` `## Deferred`).** Work *tied to* a milestone — surfaced
  inside it, in its scope or code, but not scheduled into a phase: a bug, a cleanup,
  deferred debt, a review residual. **The Backlog↔Deferred discriminator is one computable
  test — "is it tied to the active milestone?"** Tied → here (it's moot or owned elsewhere
  once the milestone closes); not tied, or no milestone is active → `roadmap.md`
  `## Backlog` (it outlives any current milestone). It is groomed **continuously, not only
  at close** (close is too rare to be the drain — milestones can run a long time): `plan`
  promotes an item into a phase plan (and removes the line) or leaves it; `checkpoint`
  removes items shipped that session **and, on its always-on sweep, surfaces a nudge to run
  `/scaffold-audit` once the list grows large or hasn't been groomed in a while**; `audit`'s
  reality pass does the expensive "already built / no longer applies" determination and
  flags items for removal. Accumulation of one-liners is tolerable *because* the sweep
  nudges grooming before it bloats — the discipline is one line per item plus prompted
  grooming, not a guaranteed-empty list, and not a drain you must remember to run unprompted.

## Routing — "Where Does This Go?"

Deterministic. Resolve by the two laws when in doubt.

| The thing | Home |
|-----------|------|
| Future work NOT tied to the active milestone (a feature/capability that outlives it; or anything surfaced while no milestone is active) | `roadmap.md` → `## Backlog` |
| Deferred work tied to the active milestone (a bug, cleanup, debt, residual in its scope/code) | that milestone's `milestone.md` → `## Deferred` |
| A significant, durable choice + its why | `decisions/NNNN-slug.md` (+ reference it from `architecture.md` if architectural) |
| Research / analysis output | `investigations/YYYYMMDD-slug.md` |
| Current technical truth (how it's built, incl. durable run/env) | `architecture.md` |
| A durable business/behavioral rule | `knowledge/*.md` |
| How to build phase X of the active milestone | `milestones/NN-active/phases/X-slug.md` |
| The contract that scoped a milestone | `milestones/NN-slug/spec/` (the spec, or a pointer to a shared/external one) |
| Where we are right now | `state.md` (`## Next` is the active-cursor authority) |
| Transient operational state (dirty DB, temp env) | resolve it; else route — a resume precondition → `state.md` `## Next`; a durable run/env condition → `architecture.md`; a blocker → `## Blockers`. **No catch-all section.** |
| What the product is / scope boundaries | `project.md` |
| A code-adjacent reference asset (design bundle) | repo `docs/` |
| What happened (history) | git (no `log.md`) |

## Skills

The skill set is **9**: `setup`, `status`, `plan`, `go`, `checkpoint`, `audit`,
`integrate`, `cleanup`, and the `update` utility — each named `/scaffold-[skill]` and
each a self-contained artifact that carries the format guidance it needs, written in. Skills are
tools you reach for when you need them; the minimum session is status → work →
checkpoint.

Two structural boundaries hold across the set:

- **`go` writes code (and optional investigations); never scaffold truth or execution
  docs.** All *runtime* scaffold write-back is owned by `plan` and `checkpoint`; `setup`
  creates the initial set and `cleanup` migrates it. Never the reverse — truth-writing
  skills never touch project code.
- **`decisions/` is propose-only.** Skills may draft an ADR and stop; **Adam approves**
  before anything is written.

### The two-tier audit model (no flags)

A safety check you must remember to invoke isn't a safety net, so there are no audit
flags. Instead, two tiers:

- **`checkpoint` always runs a light, inline structural + coherence sweep** over the
  living docs — automatically, every time, no flag. It checks the *stable* structural
  invariants (frontmatter present, required sections present, no catch-all / no
  append-log) and cross-doc coherence, then **defers the deep per-rule grading to audit**.
  Fast enough to run at every session end.
- **`audit` is the deep, independent review** — on demand, spins up fresh agents. It is
  the **sole grader of per-contract format rules** (it owns the bundled contract copies in
  its `references/` — the one drift-guarded place those rules live), checks docs against
  actual code, and verifies no durable rule is stranded. It always does all three (see
  below).

  *Why the split:* the detailed per-contract format rules change as contracts evolve, so
  keeping them in exactly one drift-guarded place (audit's bundled copies) is what stops
  the rules from being hand-copied into multiple skills and silently rotting. Checkpoint's
  always-on net stays cheap by checking only the Law-level structural invariants, which
  don't drift.

---

### `/scaffold-setup`

**Role:** Initialize. Scaffold the structure for a new project.

Creates the living-truth docs (`project`, `architecture`, `roadmap`, `state`), empty
`knowledge/`, `decisions/`, `investigations/`, and `milestones/` with an initial
`01-<slug>/` (emergent default: `milestone.md` seeded with a single Phase 1, no spec, no
pre-written plans). The seed slug is rename-cheap (`01-main`); because the slug is a
sticky namespace, setup documents the rename procedure. Writes `CLAUDE.md` per the
`claude-md` contract (orientation + pointer; nothing that belongs in `architecture.md`).
**Stamps frontmatter** on every doc it creates. On an **existing codebase**, setup
automatically gives it careful treatment — a thorough Explore pass seeds
`architecture.md`/`project.md` from the real code (no flag). It does **not** curate
decisions into ADRs — a legacy monolith is `cleanup`'s migration job; a stray decisions
doc is surfaced and proposed via `plan`/`checkpoint` (Adam-gated). `integrate` is
pure-ingest and never writes decisions.

---

### `/scaffold-status`

**Role:** Orient. Read state, present options. Read-only — writes nothing.

Reads the truth docs + the active milestone's `milestone.md` + the phase plan that
`state.md` Next points at. Derives all signals from disk; **active is per `state.md`
Next, not folder order.** Surfaces investigation filenames (cheap, no read) so a
resuming session sees them. Ends with options, not directives.

---

### `/scaffold-plan`

**Role:** Consult and author. The **single scaffold-authoring skill** (it absorbs the
old `scope`). The preceding conversation needs no skill; `plan` *persists* the agreed
plan into the right docs, routing by the model above.

It may: update `roadmap.md`, `state.md`, `architecture.md` (on a cross-cutting truth
shift), `project.md`; **create a new milestone**; **author one or more phase plans** +
update the milestone's `milestone.md`; **finalize** a plan; and set `state.md` Next. On a
**pivot**, it sweeps unexecuted plans (drafts included) for staleness.

- **Finalize pass.** `plan` turns a draft plan into a final one: it researches the
  current code, writes `## Targets` (stamped `as of HEAD`), tightens Scope/Approach,
  ensures `## Acceptance` is user-verifiable, and **presents the approach in plain terms
  for the user to confirm in dialogue** (not "read the doc"). This is where the
  code-aware, reasoning-heavy work lives — the step `go` no longer does. It reads code but
  still writes only the plan (the "never code" boundary holds). Invocation is
  ask-if-absent, `--draft`/`--final` as a shortcut.
- **Ordering rule:** if a plan depends on a not-yet-approved ADR, `plan` resolves the
  ADR gate *first* — it never authors plans premised on an unratified decision.
- May **propose** an ADR — present the draft, **stop for Adam's approval.**
- **Announces its intended write-set before writing.**
- **Boundary:** scaffold docs only, never code.

---

### `/scaffold-go`

**Role:** Execute. A thin executor of the phase plan referenced by `state.md` Next.

Writes project files and may write an `investigations/` record; **does NOT write
scaffold truth or execution docs** — that is `checkpoint`'s job. Reads its plan from
`milestones/NN/phases/` and **computes its state** (draft / final&fresh / stale) from
`## Targets` + the `sha == HEAD?` check:

- **draft** (no `## Targets`) → stop: finalize it with `/scaffold-plan --final`, or work
  freeform (status → work → checkpoint). `go` has no research/propose step of its own — a
  draft is not for `go` to figure out.
- **stale** (sha behind HEAD, or a dirty target) → stop: re-finalize with
  `/scaffold-plan --final`.
- **final & fresh** → execute exactly what `## Scope` names, one deliverable at a time.
  The approach was already approved in plain terms at finalize, so `go` confirms the
  start and works item-by-item — it does not re-propose. Out-of-scope discoveries route
  to checkpoint rather than expanding silently.

---

### `/scaffold-checkpoint`

**Role:** Save and reconcile. Verify work, update files, run the sweep, commit.

Updates the truth docs + the active milestone's `milestone.md` (tick the phase checklist +
date) + `state.md` + `knowledge/` (when behavior changed).

- **Always runs a light, inline structural + coherence sweep** over *all* living docs
  (not just the touched ones), no flag:
  - *Structural* — each living doc well-formed at the stable, Law-level shape: required
    sections present and in order, frontmatter correct, no catch-all / no append-log, no
    `project.md` checkbox (Law 2). The deep per-contract rule grading is deferred to audit
    (the sole grader).
  - *Coherence* — cross-reference integrity (architecture ↔ decisions), Law-1/Law-2
    violations, duplication, plan-vs-decision staleness, `## Next` resolves, stale
    dates.
- **Auto-detects "no work to save → just sweep"** — run it after hand-edits or to
  tidy. (This replaces the old standalone reconcile pass; there is no flag.)
- May **propose** an ADR (gated).
- **Milestone-close motion:** graduate durable rules to `knowledge/` (reconciling +
  retiring contradicted docs, **surfaced for Adam's confirmation**), flip the
  `roadmap.md` line to done, leave the folder in place.
- **Primary owner of `architecture.md`** — it sees the diff and updates the technical
  truth when the build changed how it's built.
- The inline sweep *flags*; the **deep** grading (hard conformance + docs-vs-code) is
  `/scaffold-audit`. Git is the history; no log file. Commits `CLAUDE.md` + `.scaffold/`.

---

### `/scaffold-audit`

**Role:** Deep, independent review. On demand. Read-only — reports drift, changes
nothing.

Spins up fresh read-only agents to do thoroughly what `checkpoint`'s inline sweep only
samples. **It always does all three, no asking** — depth is already chosen by invoking
`audit` at all:

- **Conformance (runs first, gates the rest):** grade every `.scaffold/` doc against its
  contract — the audit skill bundles a verbatim copy of each in `references/` — and grade
  **one rule at a time**: every Required-structure item, Rule, and Anti-pattern gets an
  explicit pass/fail/n-a verdict with evidence, so a present-but-ignored rule can't be
  waved through by a holistic glance. The per-doc grade is derived (conforms only if every
  rule passed). Frontmatter `type` selects the contract.
- **Reality:** verify scaffold claims against actual code — ticked phases really built,
  `architecture.md` matches the real stack, ADRs match reality.
- **Stranded-rules check:** no retired milestone holds an un-graduated durable rule.

**Conformance gates reality:** if a doc is malformed enough that its state can't be
read reliably (e.g. `## Next` doesn't resolve), the reality pass for that area is
reported as *unreliable* rather than guessed. Findings are returned prioritized; fixes
go through the owning skill (audit never edits).

---

### `/scaffold-integrate`

**Role:** Absorb. Pure ingest of an external artifact.

Absorbs a spec or doc: if it scopes a milestone → that milestone's `spec/` (the
artifact itself or a pointer); if it is cross-cutting durable knowledge → `knowledge/`.
Extracts operational info into the truth docs. Does not execute work, author phase
plans, or modify project files.

---

### `/scaffold-cleanup`

**Role:** Migrate. The cautious, interactive **migrator to this structure.**

**Cleanup is the one skill whose input is unknown by design.** Every other skill assumes a
conformant repo and computes from it; cleanup faces an old format, a half-finished
migration, a hand-edited mess, or something unfamiliar — and you cannot write fixed steps
for unknown input. So cleanup is **objective-driven, not shape-driven**: it fixes the
*target end-state* (what `setup` produces + the contracts), reads whatever is on disk
**without assuming a shape**, and works with Adam to map what it finds onto that target.
The flexibility is bounded by two *fixed* ends — the known objective, and a structural
self-check at the end that proves the result reached it. It **migrates the gap, not a
presumed whole**, so it is safe to re-run and safe on a partially-migrated repo.

Its flow: **inventory** (read everything, assume nothing; hard-stop if there's no
`.scaffold/` → `setup`, or if it's already fully conformant → nothing to do) → **triage**
every gap into *mechanical* (just do), *judgment* (gate with Adam — the milestone slug,
which decisions become ADRs, which doc is the plan), or **ambiguous / partial /
contradictory → STOP and surface, never guess** (this is the safety valve for the unknown
repo) → **propose the full plan** → **reference sweep before any move** → **map** what the
inventory found → **execute in one pass** → **verify against the target**.

The mapping playbook (applied only to patterns the inventory actually turns up): splits an
old per-phase `roadmap.md` by altitude (build plan → `milestones/NN-*/milestone.md` with the
checkbox+date checklist preserved; `## Backlog` + a fresh `## Milestones` index stay at
program altitude; a `phase-00` "plan authored" entry folds into `milestone.md`, not a plan);
moves `plans/phase-*` into `phases/` **preserving interstitials (`09.1`) — never renumber**;
stands up `architecture.md` from `CLAUDE.md`/decisions + run/env (architecture-vs-knowledge
tiebreak); **curates decisions — does not split them** (a monolithic `decisions.md` → an
Adam-gated promote-the-few session; the rest retire to git; a grandfathered spec's internal
decisions file is never cracked open); normalizes nonconformant names
(`2026-06-11-*` → `20260611-*`); drains a legacy `state.md` `## Notes` to each item's real
home; and **stamps frontmatter** (`schema_version`) so future format migrations are
detectable.

**Verify + hand-off (the fixed back end):** before committing, cleanup runs the *same
light structural + coherence self-check `checkpoint` runs* — proving the mechanical result
is well-formed and no pointer dangles. It does **not** grade docs rule-by-rule against the
contracts; that is `audit`'s sole job, and duplicating those rules here would re-create the
drift the system prevents. After committing, it **recommends `/scaffold-audit`** for the
independent deep conformance + reality pass.

---

### `/scaffold-update` (utility)

**Role:** Pull the latest skills. Touches no `.scaffold/` content.

---

### Skill × Artifact Coverage

Every artifact has a skill that **creates** it and a skill that **maintains** it
(updates, or retires/freezes). No orphan files, no orphan operations. `R` = reads,
`C` = creates, `U` = updates, `×` = retires/freezes/closes.

**"Single owner per band" means single owner of *maintenance*, not single writer.** A band
may be *written* at several distinct lifecycle moments (e.g. `knowledge/` is written at
ingest by `integrate`, at discussion-settle by `plan`, and at milestone-close by
`checkpoint`) — that is correct, not a smell, because each write is owned by the skill
that owns *that moment*. What must be single is the skill accountable for the band staying
coherent over time; that owner is marked **(primary)** below.

| Artifact | setup | status | plan | go | checkpoint | audit | integrate | cleanup |
|----------|-------|--------|------|----|------------|-------|-----------|---------|
| `CLAUDE.md` | C | R | U (rare) | — | U (rare) | R | — | U (migrate) |
| `project.md` | C | R | U | — | U (rare) | R | U | U |
| `architecture.md` | C (seed) | R | U (propose) | R | **U (primary)** | R | U | C (from old CLAUDE/decisions) |
| `knowledge/*.md` | C (dir) | R | C/U | R | **C/U (primary)** + graduate/retire-on-close | R | C/U (absorb) | — |
| `roadmap.md` | C | R | U (add/remove Backlog) | — | U (+ remove shipped) | R (flag stale) | R (classify) | U (build milestone index) |
| `state.md` | C | R | U | R | U + sweep | R | — | U |
| `decisions/NNNN-slug.md` | C (dir) | R (on ref) | **propose→gate** | — | **propose→gate** | R | — | migrate (Adam gates survivors) |
| `investigations/YYYYMMDD-slug.md` | C (dir) | R (lists) | R | C (opportunistic) | R | R | — | U (rename + stamp) |
| `milestones/NN-slug/` (container) | C (first) | R | **C** (new chunk) | — | × (close-in-place) | R | — | C (wrap existing roadmap) |
| `…/milestone.md` | C (seed) | R | **U** (+ groom/promote Deferred) | R | U (tick + groom Deferred) | R (flag stale Deferred) | — | C (from old roadmap body) |
| `…/spec/` | — | R | — | R | — | R | **C** (absorb/pointer) | move or pointer |
| `…/phases/NN-slug.md` | — | R (state) | **C/U** + finalize + stale-sweep | **execute (final&fresh only)** | × (done; tick lands in `milestone.md`) | R (grade `## Targets`) | — | C (move old `plans/`, keep `09.1`) |

`update` is omitted — it pulls skill files and touches no `.scaffold/` content. `audit`
is read-only — it grades and reports across every artifact, never writes. The coherence
reconcile is `checkpoint`'s job — every checkpoint, auto-detecting the no-work case.

## Workflows

Skills are optional. These are common patterns, not mandatory sequences.

### Freeform (minimum ceremony)

```
status → work with Claude → checkpoint
```

No plan, no go. Just collaborate and save. Checkpoint captures everything from
conversation context and runs its light structural + coherence sweep.

### Guided (consultation + authoring)

```
status → plan → work with Claude → checkpoint
```

Plan figures out what to do and persists it — updating the roadmap, authoring phase
plans, setting `state.md` Next. Then you work and save.

### Predetermined milestone (execute from plans)

```
status → plan --final → go → checkpoint   (repeat per phase)
```

A spec has already been absorbed and phase plans pre-written **as drafts**. Each phase
gets a **finalize** pass first — `plan --final` validates the draft against the code as it
is now (writing `## Targets` + `as of HEAD`, confirming the approach in plain terms) — then
`go` executes the final & fresh plan and `checkpoint` ticks the `milestone.md` checklist and
reconciles. Repeat until the milestone closes.

**This is a real added step, called out honestly:** the old `status → go → checkpoint` loop
gains `plan --final` per phase. That is the point of the redesign — validation happens
*when it can be correct* (against current code), not when the plan was written ahead of
it — but it is extra ceremony on a predetermined run, accepted deliberately.

### Periodic deep check

```
audit
```

Run `/scaffold-audit` when you want an independent conformance + reality review — before
a release, after a long gap, or after heavy hand-editing. It reports drift; fixes go
back through the owning skill.

### Mix and match

Skills can be invoked at any point. Run `plan` deep into a session to recalibrate. Run
`go` whenever a plan is ready and Next points at it. Run `checkpoint` whenever you want
to save.

## State Determination

State is content-derived, not enum-driven. Skills determine what's true by reading
disk. This removes the drift risk of a status field that doesn't stay in sync with
reality.

| Signal | Detection |
|--------|-----------|
| Document type | frontmatter `type:` (authoritative); filename/location as fallback |
| Active milestone | `state.md` `## Next` names it (authority). Fallback hint only: highest `NN` folder, when Next is silent |
| Active phase | `state.md` `## Next` names the phase plan |
| Plan state | no `## Targets` → **draft**; `## Targets` + `as of <sha>` at HEAD → **final & fresh**; sha behind HEAD or a dirty target file → **stale**. `go` executes only final & fresh |
| Phase done? | the milestone's `milestone.md` checklist entry is checked (with a date) |
| Milestone ready to close? | `milestone.md` fully checked AND its done-contract met (emergent: only when Adam says the chunk is done). The `roadmap.md` `[done]` flip is the *output* of closing, not a precondition |
| Milestone mode | derived: has `spec/` + pre-written plans → predetermined; else emergent |
| Blocked | `state.md` `## Blockers` has content other than "None." |
| Deferred work parked | the active milestone's `milestone.md` `## Deferred` is non-empty |

Signals are not mutually exclusive — a session can be blocked AND have an active phase.
`status` surfaces all that apply. No status keyword is stored anywhere; every signal is
read off disk.

## AI Instruction Strategy

### Skills inject fresh instructions at point of need

At 400k tokens deep, `CLAUDE.md` rules are far away. A skill dumps precise instructions
into context at the moment they're needed. This is why skills exist alongside
`CLAUDE.md` rules — not redundancy, but reliability at depth.

### Don't tell Claude what it already knows

If a behavior is already covered by Claude's defaults, by a hook, or by a skill's own
body, `CLAUDE.md` doesn't restate it.

### Explicit boundaries prevent bleeding

Each skill states what it does NOT do:

- `plan`: scaffold docs only — never code.
- `go`: project files (and optional investigations) only — never scaffold
  truth/execution docs.
- `checkpoint`: scaffold write-back + commit — never code changes.
- `audit`: read-only — grades and reports, never writes.
- `integrate`: ingest only — never executes work or writes project files.

`integrate` is the thinnest skill, and that is deliberate: it owns the *ingest-vs-author*
boundary. A thin skill that holds a clean boundary is worth more than folding its job into
an authoring skill — placing an external artifact as-is (and never cracking a pointer'd
spec open) is the opposite instinct from `plan`, whose job is to dissect and compose. The
thinness reads as intentional, not vestigial.

### Skills present options, not directives

`status` says "you can do X or Y," not "run X now." `plan` ends with options. The user
controls what happens next.

### Gates prevent premature advancement

Interactive phases require explicit user response. ADR writes are the hardest gate of
all: a skill may *propose* a decision but must **stop for Adam's approval** before
writing, superseding, or pruning anything in `decisions/`.

## Edge Cases

**Freeform work without any skills (except status/checkpoint):**
Collaborate and build. Checkpoint reviews the conversation, captures decisions
(proposing ADRs through the gate), updates the roadmap and state, and runs its
light structural + coherence sweep. Works.

**A later phase insertion stales a downstream plan:**
`plan`, on the pivot, sweeps all unexecuted plans (drafts included) in the active
milestone against the change and flags/rewrites the stale one. That is the *plan-set*
defense. Separately, a plan that was *finalized* and then left while code moved is
caught deterministically at execution time by `go`'s `sha == HEAD?` check — it refuses
and routes to re-finalize. `checkpoint`'s coherence sweep is the backstop for a finalized
plan whose targets/approach conflict with a later decision.

**A plan depends on a not-yet-approved decision:**
`plan` resolves the ADR gate first — it presents the draft, stops for Adam's approval,
and only then authors the plan premised on it. It never writes a plan on an
unratified decision.

**A later-numbered milestone is pre-created while an earlier one runs:**
Folder order is not the authority — `state.md` `## Next` is. `status` reads the active
milestone off Next, not off the highest `NN`.

**A milestone closes:**
`checkpoint` graduates the spec's enduring rules into `knowledge/` (reconciling and
retiring contradicted docs, surfaced for Adam), flips the `roadmap.md` line to done, and
leaves the folder in place. No archive move.

**A spec lives outside `.scaffold/` (shared or grandfathered):**
The milestone's `spec/` is a pointer, not a copy. The external spec stays whole and is
maintained in place until the milestone closes; its internals are never cracked open or
absorbed.

**Context crash mid-execution:**
`state.md` Next still points at the milestone + phase plan; the plan persists on disk.
`status` detects the active phase and resumes.

**Requirements discovered mid-session:**
`plan` captures the constraint in `project.md` (as plain truth) or routes a verifiable
invariant to where it's tested (a spec, phase acceptance, or a `knowledge/` doc) — never
as a checkbox in a truth doc.
