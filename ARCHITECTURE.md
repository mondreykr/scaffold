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
next by reading sections off disk (`## Next`, the `plan.md` checkbox, a brief's
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
| Milestone plan | The phases + objectives + acceptance + deferred work for one chunk | `.scaffold/milestones/NN-slug/plan.md` | temporal |
| Milestone contract | The spec, if the chunk needed heavy scoping | `.scaffold/milestones/NN-slug/spec/` | temporal |
| Phase brief | Atomic execution unit: one phase's scope/approach/acceptance | `.scaffold/milestones/NN-slug/phases/NN-slug.md` | temporal |

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
      plan.md                     this milestone's phase plan + objectives + acceptance + deferred work
      spec/                       OPTIONAL — the contract, if heavy scoping was needed
      phases/
        NN-slug.md                phase briefs

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
| `milestone-plan` | execution | `.scaffold/milestones/NN-slug/plan.md` | `contracts/milestone-plan.md` |
| `spec-pointer` | execution | `.scaffold/milestones/NN-slug/spec/` | `contracts/spec-pointer.md` |
| `phase-brief` | execution | `.scaffold/milestones/NN-slug/phases/NN-slug.md` | `contracts/phase-brief.md` |

### Execution model (cross-cutting)

A few concepts span the execution docs and don't belong to any single contract:

- **The mode question — dissolved (no flag).** Emergent vs predetermined is not a
  setting; it's an emergent property of how much was pre-written, derivable from disk:
  a **predetermined** milestone has a `spec/` (or pointer) and pre-written phase
  briefs; an **emergent** milestone has no spec and briefs written just-in-time. Same
  structure either way.
- **One artifact type — the phase brief.** A brief lives at
  `milestones/NN-slug/phases/NN-slug.md`, written up front (predetermined) or
  just-in-time by `plan` (emergent), executed by `go`, and persisting as the record.
  There is no standalone `plans/` folder.
- **Staleness obligation.** Because briefs *persist* instead of being thrown away, a
  pre-written downstream brief can go stale when a later decision or plan change lands
  (e.g. inserting a surgical Phase 9.1 stales the Phase 10 brief). Persistence buys
  durability at this cost, accepted explicitly. **Owner:** `plan`, on a pivot, sweeps
  all *unexecuted* briefs in the active milestone and flags/rewrites the stale ones;
  `checkpoint`'s coherence sweep also flags brief-vs-decision drift.
- **Milestone lifecycle.** Active = wherever `state.md` Next points (not folder
  order). On close, the folder rests in place (no archive move); durable rules graduate
  to `knowledge/` (reconciled, surfaced for Adam); `roadmap.md`'s milestone line flips
  to `[done]`. Any remaining `## Deferred` items are resolved, promoted, or dropped at
  close — they retire with the milestone, never silently graveyarded.
- **Deferred work (`plan.md` `## Deferred`).** Work *tied to* a milestone — surfaced
  inside it, in its scope or code, but not scheduled into a phase: a bug, a cleanup,
  deferred debt, a review residual. **The Backlog↔Deferred discriminator is one computable
  test — "is it tied to the active milestone?"** Tied → here (it's moot or owned elsewhere
  once the milestone closes); not tied, or no milestone is active → `roadmap.md`
  `## Backlog` (it outlives any current milestone). It is groomed **continuously, not only
  at close** (close is too rare to be the drain — milestones can run a long time): `plan`
  promotes an item into a phase brief (and removes the line) or leaves it; `checkpoint`
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
| Deferred work tied to the active milestone (a bug, cleanup, debt, residual in its scope/code) | that milestone's `plan.md` → `## Deferred` |
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
`01-<slug>/` (emergent default: `plan.md` seeded with a single Phase 1, no spec, no
pre-written briefs). The seed slug is rename-cheap (`01-main`); because the slug is a
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

Reads the truth docs + the active milestone's `plan.md` + the phase brief that
`state.md` Next points at. Derives all signals from disk; **active is per `state.md`
Next, not folder order.** Surfaces investigation filenames (cheap, no read) so a
resuming session sees them. Ends with options, not directives.

---

### `/scaffold-plan`

**Role:** Consult and author. The **single scaffold-authoring skill** (it absorbs the
old `scope`). The preceding conversation needs no skill; `plan` *persists* the agreed
plan into the right docs, routing by the model above.

It may: update `roadmap.md`, `state.md`, `architecture.md` (on a cross-cutting truth
shift), `project.md`; **create a new milestone**; **author one or more phase briefs** +
update the milestone `plan.md`; and set `state.md` Next. On a **pivot**, it sweeps
unexecuted briefs for staleness.

- **Ordering rule:** if a brief depends on a not-yet-approved ADR, `plan` resolves the
  ADR gate *first* — it never authors briefs premised on an unratified decision.
- May **propose** an ADR — present the draft, **stop for Adam's approval.**
- **Announces its intended write-set before writing.**
- **Boundary:** scaffold docs only, never code.

---

### `/scaffold-go`

**Role:** Execute. Run the phase brief referenced by `state.md` Next.

Writes project files and may write an `investigations/` record; **does NOT write
scaffold truth or execution docs** — that is `checkpoint`'s job. Reads its brief from
`milestones/NN/phases/` and executes exactly what its `## Scope` names. Presents its
approach and waits for approval before executing; works one deliverable at a time;
routes out-of-scope discoveries to checkpoint rather than expanding silently.

---

### `/scaffold-checkpoint`

**Role:** Save and reconcile. Verify work, update files, run the sweep, commit.

Updates the truth docs + the active milestone's `plan.md` (tick the phase checklist +
date) + `state.md` + `knowledge/` (when behavior changed).

- **Always runs a light, inline structural + coherence sweep** over *all* living docs
  (not just the touched ones), no flag:
  - *Structural* — each living doc well-formed at the stable, Law-level shape: required
    sections present and in order, frontmatter correct, no catch-all / no append-log, no
    `project.md` checkbox (Law 2). The deep per-contract rule grading is deferred to audit
    (the sole grader).
  - *Coherence* — cross-reference integrity (architecture ↔ decisions), Law-1/Law-2
    violations, duplication, brief-vs-decision staleness, `## Next` resolves, stale
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
briefs, or modify project files.

---

### `/scaffold-cleanup`

**Role:** Migrate. The cautious, interactive **migrator to this structure.**

It **proposes a migration plan and confirms every non-mechanical call with Adam** (which
doc is the plan, which decisions become ADRs, the milestone slug). It consults rather
than predicts — it does not assume a clean prior format. Detecting the old layout, it:

- **Splits the old `roadmap.md` by altitude** — its per-phase build plan →
  `milestones/01-*/plan.md` (preserving the checkbox + date checklist), while its
  `## Backlog` plus a freshly-authored `## Milestones` index remain in a repurposed
  program-altitude `roadmap.md`. A `phase-00`-style "plan authored" entry collapses into
  the `plan.md` checklist; it is **not** a phase brief.
- **Moves `plans/phase-*` into `phases/`, preserving interstitial numbers (`09.1`) —
  never renumber.**
- Stands up `architecture.md` from `CLAUDE.md`/decisions content + durable run/env
  facts (using the architecture-vs-knowledge tie-break).
- **Curates decisions — does not split them.** Most legacy `decisions.md` entries are
  build-records that don't clear the high ADR bar, so cleanup *detects* a monolithic
  file and hands to an interactive promote-the-few session — Adam gates which become
  ADRs; the rest retire to git. A grandfathered spec's own internal decisions file is
  **not** cracked open.
- **Stamps frontmatter** on migrated docs and records each doc's `schema_version`, so
  future format migrations are detectable.
- **Normalizes nonconformant names** (e.g. a hyphenated investigation date
  `2026-06-11-*` → `20260611-*`).
- **Before moving any file, runs a reference sweep** so no `state.md`/roadmap/brief
  pointer is left dangling.

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
| `architecture.md` | C (seed) | R | U (propose) | — | **U (primary)** | R | U | C (from old CLAUDE/decisions) |
| `knowledge/*.md` | C (dir) | R | C/U | R | **C/U (primary)** + graduate/retire-on-close | R | C/U (absorb) | — |
| `roadmap.md` | C | R | U (add/remove Backlog) | — | U (+ remove shipped) | R (flag stale) | R (classify) | U (build milestone index) |
| `state.md` | C | R | U | R | U + sweep | R | U | U |
| `decisions/NNNN-slug.md` | C (dir) | R (on ref) | **propose→gate** | — | **propose→gate** | R | — | migrate (Adam gates survivors) |
| `investigations/YYYYMMDD-slug.md` | C (dir) | R (lists) | R | C (opportunistic) | R | R | — | — |
| `milestones/NN-slug/` (container) | C (first) | R | **C** (new chunk) | — | × (close-in-place) | R | — | C (wrap existing roadmap) |
| `…/plan.md` | C (seed) | R | **U** (+ groom/promote Deferred) | R | U (tick + groom Deferred) | R (flag stale Deferred) | U | C (from old roadmap body) |
| `…/spec/` | — | R | — | R | — | R | **C** (absorb/pointer) | move or pointer |
| `…/phases/NN-slug.md` | — | R | **C/U** + stale-sweep | **execute** | × (tick complete) | R | — | C (move old `plans/`, keep `09.1`) |

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
briefs, setting `state.md` Next. Then you work and save.

### Predetermined milestone (execute from briefs)

```
status → go → checkpoint   (repeat per phase)
```

A spec has already been absorbed and phase briefs pre-written. `go` executes the brief
that Next points at; `checkpoint` ticks the `plan.md` checklist and reconciles. Repeat
until the milestone closes.

### Periodic deep check

```
audit
```

Run `/scaffold-audit` when you want an independent conformance + reality review — before
a release, after a long gap, or after heavy hand-editing. It reports drift; fixes go
back through the owning skill.

### Mix and match

Skills can be invoked at any point. Run `plan` deep into a session to recalibrate. Run
`go` whenever a brief is ready and Next points at it. Run `checkpoint` whenever you want
to save.

## State Determination

State is content-derived, not enum-driven. Skills determine what's true by reading
disk. This removes the drift risk of a status field that doesn't stay in sync with
reality.

| Signal | Detection |
|--------|-----------|
| Document type | frontmatter `type:` (authoritative); filename/location as fallback |
| Active milestone | `state.md` `## Next` names it (authority). Fallback hint only: highest `NN` folder, when Next is silent |
| Active phase | `state.md` `## Next` names the phase brief |
| Phase done? | the milestone `plan.md` checklist entry is checked (with a date) |
| Milestone ready to close? | `plan.md` fully checked AND its done-contract met (emergent: only when Adam says the chunk is done). The `roadmap.md` `[done]` flip is the *output* of closing, not a precondition |
| Milestone mode | derived: has `spec/` + pre-written briefs → predetermined; else emergent |
| Blocked | `state.md` `## Blockers` has content other than "None." |
| Deferred work parked | the active milestone's `plan.md` `## Deferred` is non-empty |

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

**A later phase insertion stales a downstream brief:**
`plan`, on the pivot, sweeps unexecuted briefs in the active milestone against the
change and flags/rewrites the stale one. If it slips through, the next `checkpoint`
sweep catches the brief-vs-decision drift.

**A brief depends on a not-yet-approved decision:**
`plan` resolves the ADR gate first — it presents the draft, stops for Adam's approval,
and only then authors the brief premised on it. It never writes a brief on an
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
`state.md` Next still points at the milestone + phase brief; the brief persists on disk.
`status` detects the active phase and resumes.

**Requirements discovered mid-session:**
`plan` captures the constraint in `project.md` (as plain truth) or routes a verifiable
invariant to where it's tested (a spec, phase acceptance, or a `knowledge/` doc) — never
as a checkbox in a truth doc.
