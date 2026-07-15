# Handoff — Planning/Execution Redesign (v2, post-adversarial-review)

**Status:** **Part A IMPLEMENTED** (2026-07-14) — committed separately from Part B. Part B
(the rename) is being executed next per the user's instruction to complete everything;
B6's scope was resolved to the **full rename** (see the note at the top of Part B). This
doc is self-contained — it survives `/clear` and is the sole source for implementation.

> **Part A implementation notes.** All 8 files in A6 were changed: the `## Targets` +
> `as of <sha>` signal is in `contracts/phase-brief.md` (state-derivation + dirty-tree
> rules, `## Acceptance` now required user-verifiable, no `schema_version` bump); `plan`
> gained the Finalize pass + `--draft`/`--final` ask-if-absent; `go` is a thin executor
> with the deterministic `sha == HEAD?` + dirty-target check and draft/stale routing (old
> research/propose step removed); `status` surfaces draft/final&fresh/stale; `checkpoint`
> keeps the finalized-brief-vs-decision coherence flag; `audit` grades `## Targets` in its
> reality pass; `ARCHITECTURE.md` + `README.md` updated (execution model, flag
> justification, workflows, edge case). `sync-contracts.sh --check` passes. **A7 caveat:**
> the "verified live" acceptance item can't run in this factory repo (it isn't a
> scaffold-managed project); the git sha/dirty logic was verified in isolation instead.

**What changed from v1:** two independent adversarial reviews (different models) found v1
would (a) "resolve" scaffold's no-enums principle by hiding an enum in a section heading,
(b) delete staleness safety that's load-bearing, and (c) bundle a large rename into a small
functional change. This v2 fixes all three: the readiness signal now carries **grounding
evidence (a commit sha)**; the staleness sweeps are **narrowed, not deleted**; and the work
is **split** into a small functional core (Part A, ship first) and a deferred rename (Part B).

> **This repo is the factory.** Changes are to the *spec* (`ARCHITECTURE.md` + `contracts/`)
> and the *skills* (`skills/`). One-way: change the spec first, then derive the skills.

---

## 1. The problem (corrected)

`scaffold-go` does two jobs welded into one skill, one context, one model: **(A)** it
researches the current code and proposes a concrete approach (its Step 3), then **(B)** it
executes. Because A and B are fused you cannot run the reasoning-heavy part on one model and
execution on another, clear context between them, or slot an independent review in the middle.

Correcting v1's overstatement: it is **not** true that "briefs never name targets" or that
`plan` is "code-blind by design" — the phase-brief contract's own Scope example names a file,
and predetermined briefs from a spec are routinely concrete. The real gap is narrower and
still real: **there is no *mandated, separable* step that validates a brief against the code
as it is *now*, and the informal version of that step is fused into `go`'s execution context.**

**The user's working model (load-bearing).** He is an architect who does not read the brief
or the code. All oversight is front-loaded into the *dialogue* that sets intent; he does not
review documents afterward, and he does not watch execution. So (1) capture of intent must be
faithful, (2) the done-condition must be checkable by a non-coder, and (3) any approval step
must be a **plain-terms conversation**, not "read this document."

## 2. Design decisions (settled)

- A brief has two states: **draft** (high-level, code-blind, can be written ahead) and
  **final** (validated against current code, execution-ready).
- The state is **derived from content _with grounding evidence_**, never a stored status
  enum (scaffold Principle 7). A **final** brief has a **`## Targets`** section listing the
  files/interfaces the phase touches, stamped with the commit it was validated **`as of <sha>`**.
  A **draft** has no `## Targets`.
  - This is scaffold's own idiom: signals are *content + evidence* (the phase checkbox works
    because it is *checkbox + date*, groundable by audit). Bare section-presence was v1's
    mistake — unauditable by construction. The sha is the evidence that makes it auditable
    **and** is the staleness backstop (below).
- Depth is **fixed, not a per-task dial** — the user's oversight never varies, so every final
  brief hits the same floor: **targets, scope (in/out), and a done-condition the user can
  verify** (observable outcome, not "tests pass").

## 3. Two failure modes the design must defend (from the review)

1. **Finalize→execute drift.** A brief finalized `as of X`, then code moves before `go` runs
   (a `/clear`, a pause, the user's own external review step, a week-long gap — scaffold's
   whole reason to exist). Defended by a **deterministic** check in `go`: `sha == HEAD?`. This
   is *not* a "verify-lite" (it judges nothing; it compares two hashes) — it is exactly the
   deterministic check the design endorses. Mismatch → `go` refuses and routes to re-finalize.
2. **Plan-set drift.** Phases reordered or cut → draft briefs and their checklist lines become
   zombies; a draft premised on a since-superseded ADR still violates the ADR-gate rule
   *regardless of depth*. Defended by keeping `plan`'s pivot sweep (now cheaper — it sweeps
   drafts too) and `checkpoint`'s coherence flag for a *finalized* brief vs a later decision.

---

# PART A — Functional core (implement this first; no rename, no migration)

This delivers the whole functional benefit (model-split, clean-context execution, a
reviewable seam) with a small blast radius. It keeps the artifact named "brief" for now.

## A1. The signal — `## Targets` + `as of <sha>`

- Add an **optional** `## Targets` section to the phase-brief contract. Present only on a
  finalized brief. Each entry names a file/interface the phase touches; the section header (or
  each entry) carries the validated commit: `as of <sha>`.
- **Derivation (content-with-evidence, Principle-7-clean):**
  - no `## Targets` → **draft**
  - `## Targets` present, `sha == HEAD` → **final & fresh** (executable)
  - `## Targets` present, `sha != HEAD` → **stale** (must re-finalize)
- **Auditable:** `audit`'s reality pass grades a brief with `## Targets` — the named files
  exist in the code, and `<sha>` is a real commit. This closes v1's "unfalsifiable by
  construction" hole. `## Targets` is *not required* on a draft, so existing briefs (which
  have none) are valid drafts — no conformance break.
- **Edge — dirty working tree:** the sha check assumes committed state. If the tree has
  uncommitted edits touching the targets, treat as stale (re-finalize). Specify in the contract.

## A2. `plan` gains a finalize pass

- `plan` can **finalize** a brief: research the current code, write `## Targets` (with
  `as of HEAD`), tighten Scope/Approach, ensure `## Acceptance` is user-verifiable, and
  **present the approach in plain terms for the user to confirm in dialogue** (matching how he
  works — not "read the doc"). Finalize is where the code-aware, reasoning-heavy work lives.
- **Invocation:** default is **ask** ("draft or finalize?"); the argument **`--draft` /
  `--final`** is a shortcut; if omitted, it asks. The ask may name the likely option
  ("a draft exists for phase 7 — finalize it?") but never decides.
  - *Justify the flag in `ARCHITECTURE.md`* (scaffold is deliberately flagless elsewhere):
    this is a **user-intent shortcut, asked-if-absent, never stored** — it does not
    reintroduce a driftable mode enum, so it doesn't violate the no-flags stance.
- **Boundary intact:** finalize *reads* code but still writes only scaffold docs (the brief).
  Reading code to author a better brief does not cross `plan`'s "never writes code" boundary.

## A3. `go` becomes a thin executor + a deterministic check

- `go` reads the brief `state.md` Next points at and computes state (A1):
  - **draft** (no `## Targets`) → stop: "This brief isn't finalized. Run `/scaffold-plan
    --final` to validate it against current code — or just work freeform." (The "wing it"
    path is scaffold's existing **freeform** workflow — status → work → checkpoint — *not* a
    `go` override. This removes v1's self-contradiction: `go` no longer needs its own
    research/propose logic at all.)
  - **stale** (`sha != HEAD`) → stop: "Validated `as of <sha>`; code has moved. Re-finalize
    with `/scaffold-plan --final`."
  - **final & fresh** → execute, one scope item at a time.
- `go`'s old **Step 3 (research + propose approach) is removed** — that work is now `plan`'s
  finalize. The approach approval happened at finalize (in plain terms); `go` executes without
  re-approving, confirming start and working item-by-item.

## A4. Staleness — narrowed, not deleted

- **Keep** `plan`'s pivot sweep over unexecuted briefs — now including **drafts** (a draft on
  a superseded ADR still breaks the ADR-gate). Cheaper than before.
- **Keep** `checkpoint`'s coherence flag for a **finalized** brief whose targets/approach
  conflict with a later decision (reference-integrity shape, like the existing `## Next`-resolves
  check).
- **Add** the `go`-time `sha == HEAD?` check (A3). Together these cover both failure modes in §3.

## A5. `status` and `audit`

- `status` reads the active brief and **surfaces its state** — draft (finalize before go) /
  final & fresh (ready) / stale (re-finalize) — so a resuming session knows what to do.
- `audit` grades the new `## Targets` rule (files exist, sha valid) as part of its reality pass.

## A6. Change surface (Part A — small)

- **`contracts/phase-brief.md`**: add the optional `## Targets` (+ `as of <sha>`) section and
  its state-derivation + dirty-tree rules; require `## Acceptance` to be user-verifiable.
  **No `schema_version` bump, no file rename.**
- **`skills/scaffold-plan/SKILL.md`**: add the finalize pass + `--draft`/`--final` + plain-terms
  approval; keep (don't delete) the pivot sweep, now covering drafts.
- **`skills/scaffold-go/SKILL.md`**: remove Step 3 research/propose; add the state computation +
  deterministic `sha` check + the draft/stale routing.
- **`skills/scaffold-status/SKILL.md`**: surface draft/final/stale for the active brief.
- **`skills/scaffold-checkpoint/SKILL.md`**: keep the finalized-brief-vs-decision coherence flag;
  no other change.
- **`skills/scaffold-audit/SKILL.md`** + **`references/phase-brief.md`**: grade `## Targets`;
  regenerate the bundled copy via **`scripts/sync-contracts.sh`** (it globs `contracts/*.md`;
  run `--check` after — no STRAY issue here since nothing is renamed).
- **`ARCHITECTURE.md`**: update the Execution-model section (draft/final states, the sha signal),
  the `plan`/`go` skill descriptions, the State-Determination table (add the draft/final/stale
  signal), and add the `--draft`/`--final` flag justification. Rewrite (don't just rename) the
  Edge Case "A later phase insertion stales a downstream brief" to match the narrowed sweeps.
- **README.md**: note the finalize step in the workflow tables.

**Not touched in Part A:** no type renames, no `plan.md`→`milestone.md`, no `schema_version`
bump, no `cleanup` migration, no `scaffold-update` change. Existing repos keep working — their
briefs simply read as **drafts** and get a finalize pass before their next `go` (which is the
correct, safer behavior anyway).

## A7. Acceptance (measurable)

- `plan --final` produces a brief with `## Targets` carrying a valid `as of <sha>`; `plan
  --draft` produces one without; no arg → it asks.
- `go` executes only when `## Targets` present **and** `sha == HEAD`; refuses a draft (routes to
  finalize/freeform) and a stale brief (routes to re-finalize); its research/propose step is gone.
- `status` reports draft / final&fresh / stale for the active brief.
- `audit` flags a `## Targets` whose files don't exist or whose sha is invalid.
- `scripts/sync-contracts.sh --check` passes.
- A finalized brief left to go stale (HEAD advanced) is refused by `go` — verified live.

## A8. Known costs (surface, don't hide)

- **Predetermined milestones gain a per-phase finalize:** the `status → go → checkpoint` loop
  becomes `status → plan --final → go → checkpoint` per phase. This is the point (validation
  when it can be correct), but it is a real added step — call it out in `ARCHITECTURE.md`'s
  Workflows section.

---

# PART B — The rename (deferred; do NOT bundle with Part A)

Independently motivated ("brief" is the wrong word; free "plan" for the phase artifact). Larger
and riskier — it touches every installed repo. Documented here in full so it's not lost; ship
only after Part A is stable, and only if still wanted.

## B1. The renames
- Artifact `brief` → **`plan`**; `type: phase-brief` → `type: phase-plan`;
  `contracts/phase-brief.md` → `contracts/phase-plan.md`.
- Milestone `plan.md` → **`milestone.md`**; `type: milestone-plan` → `type: milestone`;
  `contracts/milestone-plan.md` → `contracts/milestone.md` (content unchanged).
- **Bump `schema_version: 1 → 2`** on the changed contracts.

## B2. The version-detection layer (REQUIRED before any rename ships — v1 omitted this)
- **`skills/scaffold-update/SKILL.md` Step 3:** add markers for a v1 repo — a `plan.md`
  present, `type: milestone-plan`/`type: phase-brief`, or `schema_version: 1`. Without this,
  update reports a v1 repo as "already current" and every skill then misreads it (the most
  dangerous window, by update's own words).
- **Per-skill v1 guard:** each skill's precondition routes a `schema_version: 1` repo to
  `cleanup` before doing anything.
- **`audit` on an unknown `type`:** define behavior when frontmatter `type` matches no bundled
  contract (a renamed type on an un-migrated repo) — report "unmigrated", don't guess.
- **Hardcoded `schema_version: 1` literals:** grep the skills and update every stamp
  (`scaffold-plan` frontmatter rule + brief template, `scaffold-setup`, `scaffold-integrate`,
  `scaffold-go`'s investigation stamp).

## B3. `cleanup` migration (safe)
- Migrate existing briefs to **draft** (rename file refs, rewrite `type:`), **not** auto-final:
  cleanup cannot judge "validated against current code" from prose, and must not fabricate a
  `## Targets`/sha for an event that never happened. Each active phase gets a real finalize pass
  before its next `go`. Ambiguous cases → STOP and surface (cleanup's own rule).
- Rename `plan.md` → `milestone.md`; update the mapping playbook's `plan.md`/brief names.

## B4. `sync-contracts.sh` after the rename
- The script globs `contracts/*.md` and copies to `references/`. After renaming a contract,
  the **old** `references/phase-brief.md` / `references/milestone-plan.md` copies remain (cp
  won't remove them) and `--check` reports them **STRAY**. Action: **delete** the stale copies,
  then re-sync and `--check`.

## B5. Full rename surface
All remaining `brief`/`phase-brief`/`plan.md`/`milestone-plan` references across
`ARCHITECTURE.md` (tables, Workflows, Edge Cases — *semantic rewrites, not find-and-replace*),
`README.md`, the shipped `CLAUDE.md` skill-reference, `contracts/*` cross-references, and every
skill. Acceptance must exclude the English word "brief"/"briefing" (e.g. status "session
briefing") from the "zero references" check — grep counts include those false positives.

## B6. Open question on the rename
The rename does not fully disambiguate "plan" — it still names the skill (`/scaffold-plan`),
the phase artifact, and Claude Code's native plan mode; and `type: milestone` names the
milestone's *plan*, not the milestone (the folder is). Decide whether the churn is worth it,
or whether renaming only the *file* (`plan.md`→`milestone.md`) while keeping `type: milestone-plan`
— or doing nothing — is enough. Put this on the table before starting Part B.

---

## Open decisions for the user
1. Part A `--draft`/`--final` flag: confirm the ask-if-omitted default and the
   `ARCHITECTURE.md` justification (A2).
2. Part A: confirm "wing it" = freeform (existing workflow), so `go` needs no override (A3).
3. Part B: confirmed deferred. Revisit scope (B6) if/when you pick it up.

## Audit trail (why this doc looks like this)
v1 was adversarially reviewed by two independent agents on different models. Confirmed findings
folded in: the readiness signal needs grounding evidence (sha), not bare section-presence;
staleness sweeps are load-bearing (narrowed, not deleted); the migration must default to draft;
the version-detection layer was missing; `go`'s draft paths were self-contradictory (resolved
via freeform); the problem statement misquoted the spec (corrected in §1); and the rename is
separable from the functional change (split into Part B).
