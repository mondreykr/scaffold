# Scaffold Restructure — Requirements & Design Contract

**Date:** 2026-06-17 · **Type:** Design contract (drives implementation; auditable) · **Status:** v3 — ratified + adversarial-panel fixes + real-inventory dry-run refinements folded in. `sync` dropped (folded into a reconcile-capable `checkpoint`); architecture/knowledge kept separate; decisions + milestone folders kept; `do`→`go`; `scope`→`plan`; `graduate` removed. **Rollout is source-first** (the migrator is a sourced slash command — see §10). Not yet implemented.

---

## 1. Purpose & how to use this document

This is the contract for a structural upgrade to Scaffold. Its job is to define the **target information model and file structure**, the **rules that govern routing**, and the **per-command changes** needed to support them — precisely enough that (a) the clarifi reference implementation can be built from it by hand, (b) the `~/dev/scaffold/` source commands + `ARCHITECTURE.md` can be updated to match, and (c) a fresh agent can audit the source against it.

It is deliberately heavy on *why* and on *invariants*, lighter on prescriptive command-body wording (that's the implementation step). Treat §3–§7 as the settled model, §8 as the explicit delta from today, and §9 as command requirements. All decision points are ratified as of v2 (see §11); the adversarial-panel findings are folded into the relevant sections rather than left as open callouts.

**General-model-first.** This contract defines the *general* Scaffold system. clarifi is the first instance and the reference implementation — it is not the definition. Anything clarifi-specific is marked as an example, not a rule.

## 2. Motivation

Scaffold today is a mode-agnostic persistence spine (5 core files + artifact dirs + commands) with an emergent-default posture. Two gaps surfaced in real use:

1. **No first-class milestone/epoch.** A settled spec can decompose a whole target into many durable phase briefs (clarifi: 16). Scaffold has `plans/` for *transient* per-session scope docs but no container for a *durable, multi-phase chunk of work that retires when done*. The milestone name becomes load-bearing the moment a second spec's `phase-01` would collide with the first's. (Established in `cortex projects/clarifi/investigations/20260611-scaffold-emergent-vs-predetermined-modes`.)
2. **No home for cross-cutting system truth that outlives a spec.** A feature spec is temporal — built, then retired. But the *durable behavioral rules* it established (how the ledger replays, reconciliation tolerances) and the *architecture* it assumes (tenancy, auth, stack) are permanent truth that must stay current as code changes. Today these have no living home; they rot inside the retired spec or live only in code + memory.

This restructure adds the milestone container and a living system-truth layer, dissolves the emergent-vs-predetermined distinction into one structure, and tightens "a place for everything."

## 3. The two governing laws

Everything below derives from two laws. They are the test for where any artifact lives.

**Law 1 — Truth and history never share a document.** A document is *either* **living truth** (one of it; always current; updated in place; never reconstructed by replaying a log) *or* **frozen history** (dated; written once; never the source of current truth). The failure mode to design out is a single append-only document that tries to be both — it smears current truth across N entries and bloats by construction.

**Law 2 — A document lives at the layer that owns its lifecycle and audience.** Work-tracking → scaffold's execution layer. System truth (architecture, durable rules) → scaffold's truth layer. Strategy / cross-project thinking → cortex (external). Scaffold *points outward*; it does not absorb what another layer owns. Within the repo, `.scaffold/` is the single governed home for project documentation; `docs/` holds only **code-adjacent reference assets** (e.g. a design-system upload bundle), not project documentation.

## 4. Target information model

Extends the source's five-layer model. Each layer has exactly one home and a defined mutability.

| Layer | What it is | Home | Mutability |
|---|---|---|---|
| Orientation + instructions | How Claude should work here + a 3–5 line product orientation | `CLAUDE.md` (auto-read) | living |
| Product identity | What this is, who for, why, scope boundaries, requirements | `.scaffold/project.md` | living |
| **Architecture truth** *(NEW)* | How it's built — tenancy, auth, stack, data-access, deployment, conventions | `.scaffold/architecture.md` | living |
| Domain/behavioral truth | How the rules work — the durable residue of specs | `.scaffold/knowledge/*.md` | living *(refined — see §6)* |
| Program | Milestones (done/active/planned) + backlog/future-features | `.scaffold/roadmap.md` | living |
| Active state | Where we are now / next / blockers / open questions | `.scaffold/state.md` | living (churns) |
| Decisions | Load-bearing *why* + rejected alternatives | `.scaffold/decisions/NNNN-slug.md` *(was `decisions.md`)* | frozen; **Adam-gated**; supersede via status line |
| Research | Investigations / analyses produced while working | `.scaffold/investigations/YYYYMMDD-slug.md` | frozen |
| Milestone plan | The phases + objectives + acceptance for one chunk | `.scaffold/milestones/NN-slug/plan.md` | temporal (retires with milestone) |
| Milestone contract | The spec, if the chunk needed heavy scoping | `.scaffold/milestones/NN-slug/spec/` | temporal |
| Phase brief | Atomic execution unit: one phase's scope/approach/acceptance | `.scaffold/milestones/NN-slug/phases/NN-slug.md` | temporal |

## 5. Target file & folder structure

```
CLAUDE.md                         orientation + instructions + pointer into .scaffold/

.scaffold/
  # ── LIVING TRUTH (overwritten in place; never reconstructed from a log) ──
  project.md                      what this product is & why (identity/scope/requirements)
  architecture.md                 how it's built (tech truth) — NEW
  roadmap.md                      the program: milestone index + backlog/future
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

**Removed vs today:** `.scaffold/log.md` (never existed in source core — confirmed; no change), the single `.scaffold/decisions.md` (becomes the `decisions/` folder), the standalone `.scaffold/plans/` folder (phase briefs move under milestones).

**No `archive/`.** Retired milestones rest in place in `milestones/`. **What's active is whatever `state.md`'s `## Next` points at — not folder order.** "Highest `NN`" is only a fallback hint when `state.md` is silent (a later-numbered milestone can be pre-created while an earlier one is still active — so folder order cannot be the authority). *(clarifi's existing `.scaffold/archive/` for a pre-scaffold CLAUDE.md snapshot is incidental and may stay.)*

## 6. Per-artifact specifications

### project.md (living)
Product identity: what / who / why / scope boundaries / requirements (verifiable checkboxes, as today). **Does not merge with architecture.md** — project answers *what the product is*; architecture answers *how it's built*. CLAUDE.md carries a 3–5 line orientation + a pointer here. If `project.md` ever can't hold more than CLAUDE.md already says, it should be dropped rather than kept for symmetry.

### architecture.md (living) — NEW
The defining technical truth, current: tenancy/isolation model, auth, stack, data-access patterns, deployment, cross-cutting conventions. Updated in place when the system changes. **Primary owner: `checkpoint`** (it sees the diff and updates architecture when the build changed *how it's built*); `plan` updates it when a cross-cutting truth shifts in discussion. **Indexes the architecturally-significant decisions** in `decisions/` (each truth statement references the decision that established it — the folder + these references *are* the index; no separate index file, which would drift). **Coupling rule:** approving or superseding an architectural ADR must update its referencing statement in `architecture.md` in the *same* command turn, or the index silently breaks. **Architecture-vs-knowledge tiebreak (the panel's routing fix):** if a fact would change when you *re-platform* but the business rule stays → `architecture.md`; if it changes only when the *business rule* changes → `knowledge/`. Small projects may keep architecture as sections until it exceeds a screen.

### knowledge/*.md (living) — REFINED
Durable domain/behavioral truth — how the rules actually work ("the ledger replays thus; reconciliation tolerance is ±X"). Living truth, maintained in place as code behavior changes (same discipline as the design-system sync rule). **Lifecycle (resolved against the reviewers' "empty knowledge/ / no retire-owner" findings):**
- **While a predetermined milestone runs, the milestone's spec — especially its `references/` docs — *is* the living rulebook**, maintained in place as the build proceeds (clarifi already does this: Phase 9.1 amends `schema.md`/`reconciliation-engine.md`). `knowledge/` may stay empty until then. So "how does Claude know the rules?" → from the active spec's references during a milestone, then from `knowledge/` once it retires. The rules always have a *living* home, never only a retired spec.
- **At milestone close**, enduring rules graduate into `.scaffold/knowledge/`, and `checkpoint` **reconciles them against existing knowledge docs, retiring/superseding any they contradict** (the missing retire-owner the panel flagged). Graduation is **surfaced for Adam's confirmation**, not silently curated.
- **Emergent milestones** (no spec) accrue rules directly into `knowledge/` as discovered.

### roadmap.md (living)
The program at 20k feet. Two sections: `## Milestones` (each milestone as a one-liner with status — done/active/planned — pointing to its folder) and `## Backlog` (future features and someday/never as one-liners). **This is the permanent home for a future-feature one-liner** (it does not retire, unlike a milestone's `plan.md`). Distinct from a milestone `plan.md`: roadmap = which milestones + what's next at program altitude; plan = the phases inside the active milestone.

### state.md (living, churns)
Source four sections — Active focus (one ELI5 paragraph) / Next / Blockers / Open Questions — forward-looking, not a log. **`## Next` is the single authority for what's active** (milestone + current phase brief). **One sanctioned addition (the panel's catch):** an optional **`## Notes` section for transient *operational* state** — "the dev DB is dirty, re-seed before verify," a temporary env swap. That's neither truth, history, nor a next-action, and clarifi was already (correctly) keeping it; legitimize it rather than force-fit or drop it. Durable run/env facts (how to run the app) belong in `architecture.md`; only the *transient* state lives in `## Notes`, cleared when it resolves.

### decisions/NNNN-slug.md (frozen, Adam-gated)
One file per load-bearing decision (ADR — Architecture Decision Record). **Bar:** higher than the source's `decisions.md` — these are the rare, architecturally-significant, cross-cutting choices you'd want the *why* of in a year (tenancy, auth, a foundational pivot), not routine guardrails. **Write-gate (hard rule):** **no ADR is created, superseded, or pruned without Adam's explicit approval.** A command (plan/checkpoint) may *propose* one — present the full draft — but must stop and get approval before writing. This is stricter than every other scaffold file, by design: the decision log is curated by Adam, not by a command's judgment. **Format (ADR-shaped):** Status line / Context / Decision / Why / Alternatives considered / Consequences. **Numbering:** `NNNN-slug` (sequential, zero-padded to **4 digits** — e.g. `0001`, matching clarifi's existing ADR file; the 4-digit width is visually distinct from milestones'/phases' 2-digit `NN`, so the two namespaces never read alike) — a stable reference id ("decision 0001"), a deliberate contrast with `investigations/`'s dates (rule: an ordered number = things you reference as a sequence — phases/milestones 2-digit, decisions 4-digit; `YYYYMMDD` = point-in-time captures). **Supersession:** flip the `Status:` line (`Superseded by [[NNNN-...]]`) and write a new file; never edit the ruling. **Pruning:** a decision that guards nothing may be removed with approval (git retains it); architecturally-significant ones are kept with a `Superseded` status because their *why-not* stays valuable.

### investigations/YYYYMMDD-slug.md (frozen)
Research/analysis produced while working (gap maps, spikes, security investigations). Dated, immutable. Distinct from `decisions/` (research vs ruling) and from cortex investigations (repo-specific/tactical vs strategic/cross-project).

### milestones/NN-slug/ (temporal)
The first-class container for a chunk of work. `NN` is a milestone counter **disambiguated from product version** (`01-rebuild`, `02-multi-user`). Contents:
- `plan.md` — the milestone's phase plan: the **phase checklist** (each phase a checkbox + completion date — *this* is the disk-derivable "is it done?" signal, the source's existing convention, not a forbidden status enum), objectives, and the milestone's done-contract. Keep completion annotations **terse** (a date, not prose) so `plan.md` stays a bounded checklist, never an append-log (Law 1). Verbose per-phase narrative belongs in git.
- `spec/` — OPTIONAL. The contract that scoped this milestone — **either the spec itself or a pointer file to a spec that lives elsewhere** (a shared spec, or one grandfathered in `docs/`). Present only when the work warranted heavy scoping. **A spec is a *live* artifact, not frozen, until its milestone closes** — it's maintained in place as the build proceeds (its `references/` are the active rulebook — see knowledge/ lifecycle). At milestone close its enduring rules graduate to `knowledge/`. A pointer'd spec's **internals are never cracked open or absorbed** into `.scaffold/` (e.g. a grandfathered spec carrying its own `DECISIONS.md`/`STATE.md` stays whole; only paths update if it's ever physically ingested).
- `phases/NN-slug.md` — phase briefs (the single execution-unit artifact; authored by `plan`, executed by `go`). Phase numbers reset per milestone; the slug namespaces them. **`NN` is the roadmap ordinal and admits interstitials** (`09.1` for a surgical phase inserted after a frozen plan — clarifi's proven pattern); migration preserves these, never renumbers.

**Lifecycle:** active = wherever `state.md` Next points (not folder order). On close, the folder rests in place (no archive move); durable rules graduate to `knowledge/`; `roadmap.md`'s milestone line flips to done.

### The mode question — dissolved (no flag)
Emergent vs predetermined is **not a setting**; it's an emergent property of how much was pre-written:
- **Predetermined milestone:** has a `spec/` (or pointer) and pre-written phase briefs (clarifi rebuild).
- **Emergent milestone:** no spec; phase briefs written just-in-time as work is discovered.

Same structure either way; mode is derivable from disk (no enum).

**One artifact type — the phase brief** (ratified). The source's transient scope docs and durable phase briefs are **merged**: a brief lives at `milestones/NN-active/phases/NN-slug.md`, written up front (predetermined) or just-in-time by `plan` (emergent), executed by `go`, persisting as the record. The standalone `plans/` folder is gone.

**Staleness obligation (the panel's blocker — owned here).** Because briefs now *persist* (instead of being thrown away), a pre-written downstream brief can go **stale** when a later decision or plan change lands — live example: clarifi's Phase 9.1 insertion staled the Phase 10 brief. The throwaway model avoided this by writing just-in-time; persistence buys durability at this cost, and we accept it explicitly. **Owner:** when `plan` pivots (a decision reverses, phases reorder), it sweeps all *unexecuted* briefs in the active milestone against the change and flags/rewrites the stale ones; `checkpoint`'s coherence sweep also flags brief-vs-decision drift.

## 7. Routing — "where does this go?" (deterministic)

| The thing | Home |
|---|---|
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

## 8. Explicit delta from today's scaffold

**Added:** `architecture.md` (living architecture truth); `milestones/` container with `plan.md` + optional `spec/` + `phases/`; `decisions/` folder; a sanctioned `state.md` `## Notes` for transient operational state.
**Refined:** `knowledge/` reframed as living maintained truth with an explicit graduation/retire lifecycle (active spec's references are the rulebook until close); `roadmap.md` rises to program altitude; per-milestone phase plan moves into `milestones/NN/plan.md`; `integrate` becomes pure ingest; **`checkpoint` becomes reconcile-capable** (absorbs the coherence-sweep job — see §9).
**Removed/merged:** single `decisions.md` → `decisions/` folder (Adam-gated); standalone `plans/` → phase briefs under milestones (one artifact type); `scope` → merged into `plan`; `graduate` → removed; **`sync` → not a separate command** (folded into `checkpoint`; revisitable per Adam's condition).
**Renamed:** the `do` command → **`go`**.
**Unchanged:** `project.md`, `state.md` four-section core, `CLAUDE.md` lean-hub role, content-derived state (no enums/flags), minimum-ceremony ethos, "a place for everything", git-is-history.

## 9. Command requirements (drives the source edits)

Stated as requirements, not final command-body text.

Command set: **`setup`, `status`, `plan`, `go`, `checkpoint`, `integrate`, `cleanup`** + `update` utility. (`scope` merged into `plan`; `graduate` and `sync` removed.)

- **setup** — Scaffolds the new structure: the four living-truth docs (`project`, `architecture`, `roadmap`, `state`), empty `knowledge/`, `decisions/`, `investigations/`, and `milestones/` with an initial `01-<slug>/` (emergent default: `plan.md` seeded with a single Phase 1, no spec, no pre-written briefs). Seed slug is rename-cheap (e.g. `01-main`); document the rename procedure since the slug is a sticky namespace. CLAUDE.md template gains the orientation+pointer; loses anything that now belongs in `architecture.md`.
- **status** — Reads the truth docs + active milestone's `plan.md` + the phase brief `state.md` Next points at. Derives signals from disk; **active is per `state.md` Next, not folder order.** Surfaces investigation filenames (cheap, no read) so a resuming session sees them.
- **plan** *(absorbs `scope`)* — **The single scaffold-authoring command.** The preceding conversation needs no command; `plan` *persists* the agreed plan into the right docs, routing by the coverage matrix. It may: update `roadmap.md`, `state.md`, `architecture.md` (cross-cutting truth shift), `project.md` (requirements); **create a new milestone**; **author one or more phase briefs** + update the milestone `plan.md`; set `state.md` Next. On a **pivot**, it sweeps unexecuted briefs for staleness (§6). **Ordering rule:** if a brief depends on a not-yet-approved ADR, `plan` resolves the ADR gate *first* — it never authors briefs premised on an unratified decision. May **propose** an ADR — present the draft, **stop for Adam's approval**. **Announces its intended write-set before writing.** Boundary: scaffold docs only, never code.
- **go** *(was `do`)* — Executes the phase brief referenced by `state.md` Next. Writes project files + may write `investigations/`; does NOT write scaffold truth/execution docs. Path: `milestones/NN/phases/`.
- **checkpoint** *(now reconcile-capable — absorbs the `sync` job)* — Updates truth docs + the active milestone's `plan.md` (tick the phase checklist + date) + `state.md` + `knowledge/` (when behavior changed). **Every checkpoint runs a comprehensive coherence sweep** over all living docs (not just touched ones): cross-reference integrity (architecture↔decisions), Law-1/Law-2 violations, duplication, and **brief-vs-decision staleness**. **On-demand `checkpoint --reconcile`** runs that sweep with no work session (after hand-edits, or to tidy). May **propose** an ADR (gated). **Milestone-close motion:** graduate durable rules to `knowledge/` (reconciling + retiring contradicted docs, **surfaced for Adam's confirmation**), flip the `roadmap.md` line to done, leave the folder in place. Git is the history; no log file.
  - *Judgment recorded (Adam's condition):* `sync` is **not** a separate command. `checkpoint` is the natural coherence owner — it already owns write-back + the commit, and a reconcile is the same sweep whether run at save-time or on demand. If real use shows checkpoint *can't* keep the tree coherent, promote the sweep to a standalone `sync`.
- **integrate** — **Pure ingest of an external artifact.** Absorbs a spec/doc: if it scopes a milestone → that milestone's `spec/` (the artifact or a pointer); if cross-cutting durable knowledge → `knowledge/`. Extracts operational info into the truth docs.
- **cleanup** — The **migrator to this structure**, cautious + interactive: it **proposes a migration plan and confirms every non-mechanical call with Adam** (which doc is the plan, which decisions become ADRs, the milestone slug). It consults rather than predicts — it does not assume a clean prior format. Detects the old layout and migrates:
  - **Splits the old `roadmap.md` by altitude** — its per-phase build plan → `milestones/01-*/plan.md` (preserving the checkbox+date checklist), while its `## Backlog` + a freshly-authored `## Milestones` index remain in a repurposed program-altitude `roadmap.md`. A `phase-00`-style "plan authored" entry collapses into the `plan.md` checklist; it is **not** a phase brief.
  - **Moves `plans/phase-*` into `phases/`, preserving interstitial numbers (`09.1`) — never renumber.**
  - Stands up `architecture.md` by sorting CLAUDE.md/decisions content + durable run/env facts (using the architecture-vs-knowledge tiebreak).
  - **Decisions are *curated, not split*:** most legacy `decisions.md` entries are build-records that don't clear the high ADR bar, so `cleanup` *detects* a monolithic file and hands to an interactive promote-the-few session — Adam gates which become ADRs; the rest retire to git (the ADR folder ends up small). A grandfathered spec's own internal decisions file is **not** cracked open.
  - **Normalizes nonconformant names** as part of migration (e.g. a hyphenated investigation date `2026-06-11-*` → `20260611-*`).
  - **Before moving files, runs a reference sweep** (the capability the killed `graduate` had) so no `state.md`/roadmap/brief pointer is left dangling.
- **update** — Unaffected. Pulls the latest command files.

### Command × file coverage (completeness check)

Every artifact must have a command that **creates** it and a command that **maintains** it (updates or retires/freezes). No orphan files (a file no command owns) and no orphan operations (a needed operation no command performs). `R` = reads, `C` = creates, `U` = updates, `×` = retires/freezes/closes.

| Artifact | setup | status | plan | go | checkpoint | integrate | cleanup |
|---|---|---|---|---|---|---|---|
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

(`update` omitted — pulls command files, touches no `.scaffold/` content. Coherence reconcile is `checkpoint`'s job — every checkpoint + on-demand `--reconcile`.)

**Gaps the matrix caught (now assigned):**
1. **`architecture.md` ongoing ownership** — living truth must stay current. **Primary owner `checkpoint`** (sees the diff); `plan` proposes on a truth shift; `setup` seeds; `integrate`/`cleanup` populate. Approving an architectural ADR updates its `architecture.md` back-reference in the same turn.
2. **`knowledge/` graduation + retire** — at milestone close, `checkpoint` graduates durable rules in and **retires/supersedes contradicted docs** (surfaced for Adam). Closes the panel's "no retire owner" hole.
3. **Milestone creation** — **plan** (direction-and-authoring act); **setup** the first.
4. **ADR gating** — `decisions/` is propose-only for commands: **plan**/**checkpoint** propose, **Adam approves**; `cleanup` curates legacy entries with Adam gating.
5. **`go` writes no scaffold docs** — code + (optional) `investigations/` only; `checkpoint` owns write-back.
6. **`investigations/` is opportunistic, not owned** — `go` (or any work) drops a record when warranted; `status` *lists* them on resume; nothing is obligated to create one. A research record that yields a ruling: the analysis stays here, the ruling is *proposed* as an ADR at the next checkpoint.
7. **Phase-completion signal** — the `plan.md` phase checklist (checkbox + date) is the disk-derivable "done?" signal; `checkpoint` ticks it. No status enum needed.
8. **Stale downstream briefs** — `plan` (on pivot) + `checkpoint` (coherence sweep) own detecting/rewriting briefs staled by a later change.

## 10. Rollout sequence

**Source-first — settled.** The migration is *performed by* `/scaffold:cleanup`, a sourced slash command that does not exist until the source is updated, pushed, and pulled via `/scaffold:update`. "Migrate clarifi by hand first" was never mechanically coherent: there would be no command to run, and a hand-migration validates neither the model nor the commands. The mechanism: `~/dev/scaffold/` *is* the system → push to GitHub → `/scaffold:update` installs the command bodies into `~/.claude/commands/scaffold/` → the installed slash commands govern and act. The **design** is proven from first principles against clarifi's real artifacts (done — see §11 / the dry-run); the **commands** are proven by running `cleanup` on clarifi, which can only happen after install.

1. **This contract (v3)** — ratified; adversarial-panel fixes + real-inventory dry-run refinements folded in.
2. **Source update — FIRST, all commands in lockstep.** Encode the proven structure into `~/dev/scaffold/`: `ARCHITECTURE.md` + **every** command body per §9 — not just `cleanup`. After migration clarifi's structure changes (`milestones/`, `decisions/`, no `plans/`), so `status`/`plan`/`go`/`checkpoint` must *already* expect the new layout or they break the moment cleanup finishes. A fresh agent audits the source against this contract. Then push to GitHub and run `/scaffold:update` to install the new command set.
3. **clarifi reference migration — run `/scaffold:cleanup`.** clarifi is *between* phases (Phase 9.1 planned, **not started** — nothing built), so migrating now is safe. **Run order:** source updated + pushed + `/scaffold:update` done → **then** `/scaffold:cleanup` (do **not** run `status`/`plan`/`go`/`checkpoint` in the window between install and cleanup — cleanup detects the old layout and goes first). cleanup proposes a plan and confirms each non-mechanical call with Adam. The concrete clarifi migration:
   - **Split `roadmap.md`:** the 16-phase build plan body → `milestones/01-rebuild/plan.md` (already in checkbox+date form); `## Backlog` + a freshly-authored `## Milestones` index stay in a program-altitude `roadmap.md` (thin but permanent — losing it would retire the backlog at cutover). `phase-00` collapses into the plan checklist, not a brief.
   - **Rewrite the stale backlog line** (`Multi-user / real auth (schema stays user_id-aware…)`) to point at ADR 0001 / milestone `02` — the app is single-tenant, no tenancy debt to unwind.
   - `architecture.md` from ADR 0001 + current truth (CLAUDE.md tech stack + clarifi's `state.md` durable run/env facts).
   - `milestones/01-rebuild/{plan.md, phases/}` preserving `06.1/08.1/09.1` — never renumber.
   - `milestones/01-rebuild/spec/` = a **pointer** to the live `docs/20260326-…` spec (stays in place, maintained until milestone close; then its `references/` graduate to `knowledge/`). Internals not cracked open.
   - Curate `decisions.md` → `decisions/` (promote the few real ADRs with Adam; retire build-records to git).
   - Normalize the hyphenated investigation date → `YYYYMMDD`; repoint `state.md` Next; preserve transient operational state as `## Notes`.
4. **cleanup becomes repeatable.** clarifi (clean, predetermined) is a *weak* generalization test; a messier emergent repo is the real proving ground later.

## 11. Out of scope / open items

- Multi-repo rollout beyond clarifi — later.
- Whether `knowledge/` needs sub-structure for large rule sets — decide during the clarifi migration if it bites.
- The clarifi spec stays in `docs/`, referenced by a `spec/` pointer — now a **first-class pattern** (a milestone's spec may live external/shared), not an exception.
- **`sync` condition (Adam):** dropped in favor of a reconcile-capable `checkpoint`. Revisit only if checkpoint proves unable to keep the tree coherent in practice.
- All prior ratifications (ADR folder, phase-brief merge, scope→plan, graduate kill, `do`→`go`, architecture/knowledge separate) + the six adversarial must-fixes + four majors + the v3 dry-run refinements (roadmap altitude-split, `YYYYMMDD` conformance enforced by cleanup, spec live-until-close, source-first command-driven rollout) folded in as of **v3**.
- **Post-audit hardening (after the 4-lens adversarial review of the written source).** Source-level fixes — the model is unchanged: setup's collision dead-end fixed (only `.scaffold/` truth docs mean already-set-up; a lone `CLAUDE.md` is the adopt case); `go` checks whether deliverables already exist in code, not just the checkbox (handles the executed-but-unticked gap); `plan`'s executed-but-unrecorded guard reframed as a conversation-context signal (not disk-derivable — `status`/`checkpoint` own cold-resume detection); milestone-close gated on the done-contract, and **emergent milestones never auto-close** on all-ticked; `cleanup` wires architecture↔ADR references in Step 7 *after* curation (numbers don't exist before); `status` drops the staleness check it structurally can't perform; `update` hard-guards the install→cleanup window; `checkpoint`'s sweep narrowed (cross-doc content moves surfaced, not auto-fixed). Decisions: **`--deep` folded into automatic existing-codebase analysis** (no flag); **`--audit` kept and documented** as a read-only sub-agent verifier; setup's decision-curation duplication trimmed (routes to `cleanup`/`integrate`); integrate's unimplemented matrix cells (`R` investigations, `U` CLAUDE.md) dropped to `—`.
