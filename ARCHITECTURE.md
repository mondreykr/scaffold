# Scaffold — Architecture

This is the controlling document. All commands, workflows, and file behaviors
derive from what's defined here. It describes how Scaffold works and where
everything goes — the timeless human+AI reference, not a changelog of how the
system got here.

Scaffold is a solo-developer context-persistence system: a set of living and
historical markdown documents in a repo's `.scaffold/` directory, plus Claude
Code slash commands that maintain them so a session can resume after a
week-long gap with full context intact.

## Design Principles

1. **State machine.** Every command leaves all state documents accurate and
   self-consistent. Any command could be the last thing that runs before a
   long gap.
2. **Commands are optional tools, not mandatory gates.** The minimum ceremony
   is status → work → checkpoint. Everything else is available when you need
   it.
3. **No plan mode dependency.** All commands run in normal mode. Shift+Tab plan
   mode is a complementary tool, not a requirement.
4. **Ceremony scales with the user.** You decide how much structure you want
   per session. The system supports freeform collaboration and formal scoped
   execution equally.
5. **A place for everything.** Every piece of information has exactly one
   canonical home. Documents don't duplicate each other.
6. **Don't tell Claude what it already knows.** Commands and rules only
   instruct behaviors Claude wouldn't do by default.
7. **Content-derived state, no enums.** What's active, what's done, and what
   mode a milestone is in are all read off disk, never stored as a status flag
   that can drift from reality.

## The Two Governing Laws

Everything below derives from two laws. They are the test for where any
artifact lives.

**Law 1 — Truth and history never share a document.** A document is *either*
**living truth** (one of it; always current; updated in place; never
reconstructed by replaying a log) *or* **frozen history** (dated; written
once; never the source of current truth). The failure mode to design out is a
single append-only document that tries to be both — it smears current truth
across N entries and bloats by construction. A living-truth document is
overwritten in place; a history document is written once and never edited as
the source of present truth.

**Law 2 — A document lives at the layer that owns its lifecycle and audience.**
Work-tracking belongs to Scaffold's execution layer. System truth
(architecture, durable rules) belongs to Scaffold's truth layer. Strategy and
cross-project thinking belong to an external knowledge base (e.g. cortex).
Scaffold *points outward*; it does not absorb what another layer owns. Within
the repo, `.scaffold/` is the single governed home for project documentation;
repo-level `docs/` holds only **code-adjacent reference assets** (e.g. a
design-system upload bundle), never project documentation.

These two laws are the tie-breaker for every routing question. If a placement
would violate one, the placement is wrong — not the law.

## Information Model

Each layer has exactly one home and a defined mutability. Living layers are
overwritten in place; history layers are written once; execution layers are
temporal and retire with their milestone.

| Layer | What it is | Home | Mutability |
|-------|-----------|------|------------|
| Orientation + instructions | How Claude should work here + a 3–5 line product orientation | `CLAUDE.md` (auto-read) | living |
| Product identity | What this is, who for, why, scope boundaries, requirements | `.scaffold/project.md` | living |
| **Architecture truth** | How it's built — tenancy, auth, stack, data-access, deployment, conventions | `.scaffold/architecture.md` | living |
| Domain/behavioral truth | How the rules work — the durable residue of specs | `.scaffold/knowledge/*.md` | living |
| Program | Milestones (done/active/planned) + backlog | `.scaffold/roadmap.md` | living |
| Active state | Where we are now / next / blockers / open questions | `.scaffold/state.md` | living (churns) |
| Decisions | Load-bearing *why* + rejected alternatives (ADRs) | `.scaffold/decisions/NNNN-slug.md` | frozen; **Adam-gated** |
| Research | Investigations / analyses produced while working | `.scaffold/investigations/YYYYMMDD-slug.md` | frozen |
| Milestone plan | The phases + objectives + acceptance for one chunk | `.scaffold/milestones/NN-slug/plan.md` | temporal |
| Milestone contract | The spec, if the chunk needed heavy scoping | `.scaffold/milestones/NN-slug/spec/` | temporal |
| Phase brief | Atomic execution unit: one phase's scope/approach/acceptance | `.scaffold/milestones/NN-slug/phases/NN-slug.md` | temporal |

The model has three bands: **living truth** (overwritten in place, always
current), **history** (frozen, written once), and **execution** (temporal,
retires with its milestone).

## Files & Folders

```
CLAUDE.md                         orientation + instructions + pointer into .scaffold/

.scaffold/
  # ── LIVING TRUTH (overwritten in place; never reconstructed from a log) ──
  project.md                      what this product is & why (identity/scope/requirements)
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
      plan.md                     this milestone's phase plan + objectives + acceptance
      spec/                       OPTIONAL — the contract, if heavy scoping was needed
      phases/
        NN-slug.md                phase briefs

docs/                             code-adjacent reference assets ONLY (e.g. design-system bundle)
```

**No `archive/`.** Retired milestones rest in place in `milestones/`. **What's
active is whatever `state.md`'s `## Next` points at — not folder order.**
"Highest `NN`" is only a fallback hint when `state.md` is silent: a
later-numbered milestone can be pre-created while an earlier one is still
active, so folder order cannot be the authority. (`setup`/`cleanup` may write a
`.scaffold/archive/` holding pre-scaffold snapshots — an overwritten `CLAUDE.md`,
superseded context files. It holds only superseded originals, is read by no
command, and is not part of the live model. Retired *milestones* never go there
— they rest in place in `milestones/`.)

**What happened (history)** lives in git. There is no `log.md`.

## Per-Artifact Specifications

### `project.md` (living)

Product identity: what / who / why / scope boundaries / requirements
(verifiable checkboxes). **Does not merge with `architecture.md`** — project
answers *what the product is*; architecture answers *how it's built*.
`CLAUDE.md` carries a 3–5 line orientation plus a pointer here. If `project.md`
ever can't hold more than `CLAUDE.md` already says, drop it rather than keep it
for symmetry.

Requirements format (unchanged from the source convention):

```markdown
## Requirements
- [ ] Validate only SLDPRT and SLDASM files
- [ ] All validation rules are blockers (no warnings)
- [ ] PreState performance: < 2 seconds, fail-open
```

Requirements are verifiable product rules — checked by `checkpoint` when
evidence confirms they're met. They are stable (set early, refined rarely) and
are NOT deliverables, phases, or tasks.

### `architecture.md` (living)

The defining technical truth, kept current: tenancy/isolation model, auth,
stack, data-access patterns, deployment, cross-cutting conventions, and durable
run/env facts (how to run the app). Updated in place when the system changes.

- **Primary owner: `checkpoint`** — it sees the diff and updates architecture
  when the build changed *how it's built*. `plan` updates it when a
  cross-cutting truth shifts in discussion. `setup` seeds it;
  `integrate`/`cleanup` populate it.
- **Indexes the architecturally-significant decisions** in `decisions/`. Each
  truth statement references the ADR that established it — the folder plus
  these inline references *are* the index. There is no separate index file (it
  would drift).
- **Coupling rule:** approving or superseding an architectural ADR must update
  its referencing statement in `architecture.md` in the *same* command turn, or
  the index silently breaks.
- **Architecture-vs-knowledge tie-break:** if a fact would change when you
  *re-platform* but the business rule stays → `architecture.md`; if it changes
  only when the *business rule* changes → `knowledge/`.

Small projects may keep architecture as sections until it exceeds a screen.

### `knowledge/*.md` (living)

Durable domain/behavioral truth — how the rules actually work ("the ledger
replays thus; reconciliation tolerance is ±X"). Living truth, maintained in
place as code behavior changes. Lifecycle:

- **While a predetermined milestone runs, the milestone's spec — especially its
  `references/` docs — *is* the living rulebook,** maintained in place as the
  build proceeds. `knowledge/` may stay empty until then. So "how does Claude
  know the rules?" → from the active spec's references during a milestone, then
  from `knowledge/` once it retires. The rules always have a *living* home,
  never only a retired spec.
- **At milestone close,** enduring rules graduate into `knowledge/`, and
  `checkpoint` **reconciles them against existing knowledge docs, retiring or
  superseding any they contradict.** Graduation is **surfaced for Adam's
  confirmation**, not silently curated.
- **Emergent milestones** (no spec) accrue rules directly into `knowledge/` as
  they are discovered.

### `roadmap.md` (living)

The program at 20k feet. Two sections:

- `## Milestones` — each milestone as a one-liner with a status token
  `[done] | [active] | [planned]`, pointing to its folder. (`checkpoint` writes
  `[done]` at close; `status` reads these tokens — the literal set is fixed so
  the two agree.)
- `## Backlog` — future features and someday/never items as one-liners.

**This is the permanent home for a future-feature one-liner** — it does not
retire, unlike a milestone's `plan.md`. Distinct from a milestone `plan.md`:
roadmap = which milestones + what's next at program altitude; plan = the
phases inside the active milestone.

### `state.md` (living, churns)

Forward-looking, not a log. The four core sections — **Active focus** (one ELI5
paragraph) / **Next** / **Blockers** / **Open Questions** — plus one optional
addition:

- **`## Next` is the single authority for what's active** (milestone + current
  phase brief). Not folder order, not a status enum.
- **`## Notes` (optional)** — transient *operational* state: "the dev DB is
  dirty, re-seed before verify," a temporary env swap. This is neither truth,
  history, nor a next-action; it is legitimized here rather than force-fit
  elsewhere. Durable run/env facts belong in `architecture.md`; only
  *transient* state lives in `## Notes`, cleared when it resolves.

```markdown
<!-- Last updated: YYYY-MM-DD -->
# State

## Active focus
[One paragraph. Synopsis + forward-look. ELI5 — plain words, short sentences.
No bullets, no code blocks, no quoted prompts. Grows only when genuinely needed.]

## Next
[The concrete action when you resume — milestone + phase brief by path.
1-2 sentences or short bullets.]

## Blockers
None.

## Open Questions
None.

## Notes
[Optional. Transient operational state only. Omit the section when empty.]
```

- **Blockers** and **Open Questions** are always present with "None." when
  empty — confirms the writer checked.
- **When a Blocker or Open Question resolves,** remove the line and place the
  resolution where it belongs (a decision, the roadmap, the commit log, a
  knowledge doc). State does not accumulate resolved items.

### `decisions/NNNN-slug.md` (frozen, Adam-gated)

One file per load-bearing decision (an ADR — Architecture Decision Record).

- **Bar:** the rare, architecturally-significant, cross-cutting choices you'd
  want the *why* of in a year (tenancy, auth, a foundational pivot) — not
  routine guardrails or build-records.
- **Write-gate (hard rule):** **no ADR is created, superseded, or pruned
  without Adam's explicit approval.** A command (`plan` or `checkpoint`) may
  *propose* one — present the full draft — but must stop and get approval
  before writing. This is stricter than every other scaffold file, by design:
  the decision log is curated by Adam, not by a command's judgment.
- **Format (ADR-shaped):** Status line / Context / Decision / Why /
  Alternatives considered / Consequences.
- **Numbering:** `NNNN-slug`, sequential and zero-padded to **4 digits** — a
  stable reference id ("decision 0001"). The 4-digit width is deliberately
  distinct from milestones'/phases' 2-digit `NN`, so the two namespaces never
  read alike. The convention: an ordered number = things you reference as a
  sequence (phases/milestones 2-digit, decisions 4-digit); `YYYYMMDD` =
  point-in-time captures (investigations).
- **Supersession:** flip the `Status:` line (`Superseded by [[NNNN-…]]`) and
  write a new file; never edit the ruling itself.
- **Pruning:** a decision that guards nothing may be removed with approval (git
  retains it); architecturally-significant ones are kept with a `Superseded`
  status because their *why-not* stays valuable.

### `investigations/YYYYMMDD-slug.md` (frozen)

Research and analysis produced while working — gap maps, spikes, security
investigations. Dated, immutable. Distinct from `decisions/` (research vs
ruling) and from external/cortex investigations (repo-specific and tactical vs
strategic and cross-project). Creation is **opportunistic** — any work may drop
a record when warranted; nothing is obligated to create one. When a record
yields a ruling, the analysis stays here and the ruling is *proposed* as an ADR
at the next checkpoint.

### `milestones/NN-slug/` (temporal)

The first-class container for a durable, multi-phase chunk of work that retires
when done. `NN` is a milestone counter **disambiguated from product version**
(`01-rebuild`, `02-multi-user`). Contents:

- **`plan.md`** — the milestone's phase plan: the **phase checklist** (each
  phase a checkbox + completion date — *this* is the disk-derivable "is it
  done?" signal, not a status enum), the objectives, and the milestone's
  done-contract. Keep completion annotations **terse** (a date, not prose) so
  `plan.md` stays a bounded checklist, never an append-log (Law 1). Verbose
  per-phase narrative belongs in git.
- **`spec/`** — OPTIONAL. The contract that scoped this milestone, **either the
  spec itself or a pointer file to a spec that lives elsewhere** (a shared
  spec, or one grandfathered in `docs/`). Present only when the work warranted
  heavy scoping. **A spec is a *live* artifact, not frozen, until its milestone
  closes** — maintained in place as the build proceeds (its `references/` are
  the active rulebook; see `knowledge/`). At close, its enduring rules graduate
  to `knowledge/`. A pointer'd spec's **internals are never cracked open or
  absorbed** into `.scaffold/`; a grandfathered spec carrying its own
  `DECISIONS.md`/`STATE.md` stays whole.
- **`phases/NN-slug.md`** — phase briefs (the single execution-unit artifact;
  authored by `plan`, executed by `go`). Phase numbers reset per milestone; the
  slug namespaces them. **`NN` is the roadmap ordinal and admits interstitials**
  (`09.1` for a surgical phase inserted after a frozen plan); migration
  preserves these and never renumbers.

**Lifecycle:** active = wherever `state.md` Next points (not folder order). On
close, the folder rests in place (no archive move); durable rules graduate to
`knowledge/`; `roadmap.md`'s milestone line flips to done.

### The mode question — dissolved (no flag)

Emergent vs predetermined is **not a setting**; it's an emergent property of
how much was pre-written, derivable from disk:

- **Predetermined milestone:** has a `spec/` (or pointer) and pre-written phase
  briefs.
- **Emergent milestone:** no spec; phase briefs written just-in-time as work is
  discovered.

Same structure either way.

**One artifact type — the phase brief.** The source's transient scope docs and
durable phase briefs are merged into one: a brief lives at
`milestones/NN-active/phases/NN-slug.md`, written up front (predetermined) or
just-in-time by `plan` (emergent), executed by `go`, persisting as the record.
There is no standalone `plans/` folder.

**Staleness obligation.** Because briefs now *persist* instead of being thrown
away, a pre-written downstream brief can go **stale** when a later decision or
plan change lands (e.g. inserting a surgical Phase 9.1 stales the Phase 10
brief). Persistence buys durability at this cost, and we accept it explicitly.
**Owner:** when `plan` pivots (a decision reverses, phases reorder), it sweeps
all *unexecuted* briefs in the active milestone against the change and
flags/rewrites the stale ones; `checkpoint`'s coherence sweep also flags
brief-vs-decision drift.

## Routing — "Where Does This Go?"

Deterministic. Resolve by the two laws when in doubt.

| The thing | Home |
|-----------|------|
| A new feature idea, one line | `roadmap.md` → Backlog |
| A significant, durable choice + its why | `decisions/NNNN-slug.md` (+ reference it from `architecture.md` if architectural) |
| Research / analysis output | `investigations/YYYYMMDD-slug.md` |
| Current technical truth (how it's built) | `architecture.md` |
| A durable business/behavioral rule | `knowledge/*.md` |
| How to build phase X of the active milestone | `milestones/NN-active/phases/X-slug.md` |
| The contract that scoped a milestone | `milestones/NN-slug/spec/` (the spec, or a pointer to a shared/external one) |
| Where we are right now | `state.md` (`## Next` is the active-cursor authority) |
| Transient operational state (dirty DB, temp env) | `state.md` → `## Notes` |
| What the product is / scope boundaries | `project.md` |
| A code-adjacent reference asset (design bundle) | repo `docs/` |
| What happened (history) | git (no `log.md`) |

## Commands

The command set is **8**: `setup`, `status`, `plan`, `go`, `checkpoint`,
`integrate`, `cleanup`, and the `update` utility. Commands are tools you reach
for when you need them; the minimum session is status → work → checkpoint.

Two structural boundaries hold across the set:

- **`go` writes code (and optional investigations); never scaffold truth or
  execution docs.** All scaffold write-back is owned by `plan` and
  `checkpoint`. Never the reverse — truth-writing commands never touch project
  files.
- **`decisions/` is propose-only.** Commands may draft an ADR and stop;
  **Adam approves** before anything is written.

---

### `/scaffold:setup`

**Role:** Initialize. Scaffold the structure for a new project.

Creates the four living-truth docs (`project`, `architecture`, `roadmap`,
`state`), empty `knowledge/`, `decisions/`, `investigations/`, and `milestones/`
with an initial `01-<slug>/` (emergent default: `plan.md` seeded with a single
Phase 1, no spec, no pre-written briefs). The seed slug is rename-cheap (e.g.
`01-main`); because the slug is a sticky namespace, setup documents the rename
procedure. The `CLAUDE.md` template gains the orientation + pointer and loses
anything that now belongs in `architecture.md`. On an **existing codebase**,
setup automatically gives it careful treatment — a thorough Explore pass seeds
`architecture.md`/`project.md` from the real code (no flag). It does **not**
curate decisions into ADRs (that is `cleanup`/`integrate`'s job).

---

### `/scaffold:status`

**Role:** Orient. Read state, present options. Read-only — writes nothing.

Reads the truth docs + the active milestone's `plan.md` + the phase brief that
`state.md` Next points at. Derives all signals from disk; **active is per
`state.md` Next, not folder order.** Surfaces investigation filenames (cheap,
no read) so a resuming session sees them. Ends with options, not directives.

---

### `/scaffold:plan`

**Role:** Consult and author. The **single scaffold-authoring command** (it
absorbs the old `scope`). The preceding conversation needs no command; `plan`
*persists* the agreed plan into the right docs, routing by the model above.

It may: update `roadmap.md`, `state.md`, `architecture.md` (on a cross-cutting
truth shift), `project.md` (requirements); **create a new milestone**; **author
one or more phase briefs** + update the milestone `plan.md`; and set `state.md`
Next. On a **pivot**, it sweeps unexecuted briefs for staleness.

- **Ordering rule:** if a brief depends on a not-yet-approved ADR, `plan`
  resolves the ADR gate *first* — it never authors briefs premised on an
  unratified decision.
- May **propose** an ADR — present the draft, **stop for Adam's approval.**
- **Announces its intended write-set before writing.**
- **Boundary:** scaffold docs only, never code.

---

### `/scaffold:go`

**Role:** Execute. Run the phase brief referenced by `state.md` Next (the old
`do`, renamed).

Writes project files and may write an `investigations/` record; **does NOT
write scaffold truth or execution docs** — that is `checkpoint`'s job. Reads
its brief from `milestones/NN/phases/`. Presents its approach and waits for
approval before executing; works one deliverable at a time; routes
out-of-scope discoveries to checkpoint rather than expanding silently.

---

### `/scaffold:checkpoint`

**Role:** Save and reconcile. Verify work, update files, run the coherence
sweep, commit. (Reconcile-capable — it absorbs the job that a separate `sync`
would have owned.)

Updates the truth docs + the active milestone's `plan.md` (tick the phase
checklist + date) + `state.md` + `knowledge/` (when behavior changed).

- **Every checkpoint runs a comprehensive coherence sweep** over *all* living
  docs (not just the touched ones): cross-reference integrity
  (architecture ↔ decisions), Law-1/Law-2 violations, duplication, and
  **brief-vs-decision staleness.**
- **On-demand `checkpoint --reconcile`** runs that sweep with no work session
  (after hand-edits, or to tidy).
- **On-demand `checkpoint --audit`** spawns a read-only Explore sub-agent to
  verify scaffold claims against the actual code — ticked phases really built,
  `architecture.md` matches the real stack, ADRs match reality. Reports drift;
  changes nothing.
- May **propose** an ADR (gated).
- **Milestone-close motion:** graduate durable rules to `knowledge/`
  (reconciling + retiring contradicted docs, **surfaced for Adam's
  confirmation**), flip the `roadmap.md` line to done, leave the folder in
  place.
- **Primary owner of `architecture.md`** — it sees the diff and updates the
  technical truth when the build changed how it's built.
- Git is the history; no log file. Commits `CLAUDE.md` + `.scaffold/`.

*(If real use shows `checkpoint` can't keep the tree coherent, the sweep is
promoted to a standalone `sync`. Not the case today.)*

---

### `/scaffold:integrate`

**Role:** Absorb. Pure ingest of an external artifact.

Absorbs a spec or doc: if it scopes a milestone → that milestone's `spec/` (the
artifact itself or a pointer); if it is cross-cutting durable knowledge →
`knowledge/`. Extracts operational info into the truth docs. Does not execute
work, author phase briefs, or modify project files.

---

### `/scaffold:cleanup`

**Role:** Migrate. The cautious, interactive **migrator to this structure**.

It **proposes a migration plan and confirms every non-mechanical call with
Adam** (which doc is the plan, which decisions become ADRs, the milestone
slug). It consults rather than predicts — it does not assume a clean prior
format. Detecting the old layout, it:

- **Splits the old `roadmap.md` by altitude** — its per-phase build plan →
  `milestones/01-*/plan.md` (preserving the checkbox + date checklist), while
  its `## Backlog` plus a freshly-authored `## Milestones` index remain in a
  repurposed program-altitude `roadmap.md`. A `phase-00`-style "plan authored"
  entry collapses into the `plan.md` checklist; it is **not** a phase brief.
- **Moves `plans/phase-*` into `phases/`, preserving interstitial numbers
  (`09.1`) — never renumber.**
- Stands up `architecture.md` from `CLAUDE.md`/decisions content + durable
  run/env facts (using the architecture-vs-knowledge tie-break).
- **Curates decisions — does not split them.** Most legacy `decisions.md`
  entries are build-records that don't clear the high ADR bar, so cleanup
  *detects* a monolithic file and hands to an interactive promote-the-few
  session — Adam gates which become ADRs; the rest retire to git. A
  grandfathered spec's own internal decisions file is **not** cracked open.
- **Normalizes nonconformant names** (e.g. a hyphenated investigation date
  `2026-06-11-*` → `20260611-*`).
- **Before moving any file, runs a reference sweep** so no
  `state.md`/roadmap/brief pointer is left dangling.

---

### `/scaffold:update` (utility)

**Role:** Pull the latest command files. Touches no `.scaffold/` content.

---

### Command × Artifact Coverage

Every artifact has a command that **creates** it and a command that
**maintains** it (updates, or retires/freezes). No orphan files, no orphan
operations. `R` = reads, `C` = creates, `U` = updates, `×` =
retires/freezes/closes.

| Artifact | setup | status | plan | go | checkpoint | integrate | cleanup |
|----------|-------|--------|------|----|------------|-----------|---------|
| `CLAUDE.md` | C | R | U (rare) | — | U (rare) | — | U (migrate) |
| `project.md` | C | R | U | — | U (rare) | U | U |
| `architecture.md` | C (seed) | R | U (propose) | — | **U (primary)** | U | C (from old CLAUDE/decisions) |
| `knowledge/*.md` | C (dir) | R | U | R | U + **graduate/retire-on-close** | C/U (absorb) | — |
| `roadmap.md` | C | R | U | — | U | U (rare) | U (build milestone index) |
| `state.md` | C | R | U | R | U + reconcile | U | U |
| `decisions/NNNN-slug.md` | — | R (on ref) | **propose→gate** | — | **propose→gate** | — | migrate (Adam gates survivors) |
| `investigations/YYYYMMDD-slug.md` | C (dir) | R (lists) | R | C (opportunistic) | R | — | — |
| `milestones/NN-slug/` (container) | C (first) | R | **C** (new chunk) | — | × (close-in-place) | — | C (wrap existing roadmap) |
| `…/plan.md` | C (seed) | R | **U** | R | U (tick checklist + sign-off) | U | C (from old roadmap body) |
| `…/spec/` | — | R | — | R | — | **C** (absorb/pointer) | move or pointer |
| `…/phases/NN-slug.md` | — | R | **C/U** + stale-sweep | **execute** | × (tick complete) | — | C (move old `plans/`, keep `09.1`) |

`update` is omitted — it pulls command files and touches no `.scaffold/`
content. The coherence reconcile is `checkpoint`'s job — every checkpoint plus
on-demand `--reconcile`.

## Workflows

Commands are optional. These are common patterns, not mandatory sequences.

### Freeform (minimum ceremony)

```
status → work with Claude → checkpoint
```

No plan, no go. Just collaborate and save. Checkpoint captures everything from
conversation context and runs its coherence sweep.

### Guided (consultation + authoring)

```
status → plan → work with Claude → checkpoint
```

Plan figures out what to do and persists it — updating the roadmap, authoring
phase briefs, setting `state.md` Next. Then you work and save.

### Predetermined milestone (execute from briefs)

```
status → go → checkpoint   (repeat per phase)
```

A spec has already been absorbed and phase briefs pre-written. `go` executes
the brief that Next points at; `checkpoint` ticks the `plan.md` checklist and
reconciles. Repeat until the milestone closes.

### Reconcile only (after hand-edits)

```
checkpoint --reconcile
```

Runs the coherence sweep with no work session — tidies the tree after manual
edits.

### Mix and match

Commands can be invoked at any point. Run `plan` deep into a session to
recalibrate. Run `go` whenever a brief is ready and Next points at it. Run
`checkpoint` whenever you want to save.

## State Determination

State is content-derived, not enum-driven. Commands determine what's true by
reading disk. This removes the drift risk of a status field that doesn't stay
in sync with reality.

| Signal | Detection |
|--------|-----------|
| Active milestone | `state.md` `## Next` names it (authority). Fallback hint only: highest `NN` folder, when Next is silent |
| Active phase | `state.md` `## Next` names the phase brief |
| Phase done? | the milestone `plan.md` checklist entry is checked (with a date) |
| Milestone done? | `roadmap.md`'s `## Milestones` line reads done AND `plan.md` is fully checked |
| Milestone mode | derived: has `spec/` + pre-written briefs → predetermined; else emergent |
| Blocked | `state.md` `## Blockers` has content other than "None." |
| Transient op-state present | `state.md` `## Notes` is non-empty |

Signals are not mutually exclusive — a session can be blocked AND have an
active phase. `status` surfaces all that apply. No status keyword is stored
anywhere; every signal is read off disk.

## AI Instruction Strategy

### Commands inject fresh instructions at point of need

At 400k tokens deep, `CLAUDE.md` rules are far away. A slash command dumps
precise instructions into context at the moment they're needed. This is why
commands exist alongside `CLAUDE.md` rules — not redundancy, but reliability at
depth.

### Don't tell Claude what it already knows

If a behavior is already covered by Claude's defaults, by a hook, or by a slash
command's own body, `CLAUDE.md` doesn't restate it.

### Explicit boundaries prevent bleeding

Each command states what it does NOT do:

- `plan`: scaffold docs only — never code.
- `go`: project files (and optional investigations) only — never scaffold
  truth/execution docs.
- `checkpoint`: scaffold write-back + commit — never code changes.
- `integrate`: ingest only — never executes work or writes project files.

### Commands present options, not directives

`status` says "you can do X or Y," not "run X now." `plan` ends with options.
The user controls what happens next.

### Gates prevent premature advancement

Interactive phases require explicit user response. ADR writes are the hardest
gate of all: a command may *propose* a decision but must **stop for Adam's
approval** before writing, superseding, or pruning anything in `decisions/`.

## CLAUDE.md Template

The lean template contains only what scaffold needs to operate plus
project-specific information that has nowhere else to live: Title, Command
Reference, Core Principle, a 3–5 line product orientation + pointer into
`.scaffold/`, and project-specific Hard constraints. Durable tech-stack and
run/env facts now live in `architecture.md`, not here.

### Command Reference

```markdown
## Command Reference
| Command | Role |
|---------|------|
| `/scaffold:setup` | Initialize — scaffold the structure for a new project |
| `/scaffold:status` | Orient — read state, present options |
| `/scaffold:plan` | Consult + author — discuss direction, persist into the right docs |
| `/scaffold:go` | Execute — run the active phase brief |
| `/scaffold:checkpoint` | Save + reconcile — verify, update files, sweep, commit |
| `/scaffold:integrate` | Absorb — ingest an artifact (spec, research) into scaffold |
| `/scaffold:cleanup` | Migrate an existing project to this structure |
| `/scaffold:update` | Update scaffold commands to the latest version |
```

Claude infers natural-language → command mapping (e.g. "status" →
`/scaffold:status`) from the command descriptions; no separate Session Protocol
table is needed.

### Core Principle

```markdown
## Core Principle
Every command leaves ALL state documents accurate and self-consistent.
Any command could be the last thing that runs before a week-long gap.
Commands are optional tools — the minimum ceremony is status → work → checkpoint.
```

### Orientation + pointer, Hard constraints

A 3–5 line product orientation and a pointer into `.scaffold/` (so a cold read
knows where truth lives), plus project-specific hard constraints that no
scaffold file owns. Everything about *how it's built* — tech stack, data
access, run/env — belongs in `architecture.md`, referenced from here, not
duplicated.

### What's NOT in the template (and why)

- **Who I am / user calibration** — belongs in `~/.claude/CLAUDE.md`
  (user-level config), not every project.
- **Tech stack / run instructions** — now `architecture.md`'s job (living
  technical truth), referenced from `CLAUDE.md`.
- **Rules / Working / Session Protocol** — mostly per-user preferences or
  behaviors Claude does by default; Claude infers command mapping from the
  Command Reference.
- **Key Documents** — `/scaffold:status` surfaces these on every session start.

Users who want any of these as project-specific rules can add them as custom
sections, or push them up to `~/.claude/CLAUDE.md` for cross-project effect.

## Edge Cases

**Freeform work without any commands (except status/checkpoint):**
Collaborate and build. Checkpoint reviews the conversation, captures decisions
(proposing ADRs through the gate), updates the roadmap and state, and runs its
coherence sweep. Works.

**A later phase insertion stales a downstream brief:**
`plan`, on the pivot, sweeps unexecuted briefs in the active milestone against
the change and flags/rewrites the stale one. If it slips through, the next
`checkpoint` coherence sweep catches the brief-vs-decision drift.

**A brief depends on a not-yet-approved decision:**
`plan` resolves the ADR gate first — it presents the draft, stops for Adam's
approval, and only then authors the brief premised on it. It never writes a
brief on an unratified decision.

**A later-numbered milestone is pre-created while an earlier one runs:**
Folder order is not the authority — `state.md` `## Next` is. `status` reads the
active milestone off Next, not off the highest `NN`.

**A milestone closes:**
`checkpoint` graduates the spec's enduring rules into `knowledge/` (reconciling
and retiring contradicted docs, surfaced for Adam), flips the `roadmap.md` line
to done, and leaves the folder in place. No archive move.

**A spec lives outside `.scaffold/` (shared or grandfathered):**
The milestone's `spec/` is a pointer, not a copy. The external spec stays whole
and is maintained in place until the milestone closes; its internals are never
cracked open or absorbed.

**Context crash mid-execution:**
`state.md` Next still points at the milestone + phase brief; the brief
persists on disk. `status` detects the active phase and resumes.

**Requirements discovered mid-session:**
`plan` adds them to `project.md` Requirements, or `checkpoint` captures them
during save. Either way they land in `project.md`.
