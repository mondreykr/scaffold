---
schema_version: 2
---

# Contract — `milestones/NN-slug/phases/NN-slug.md` (phase plan)

**Purpose.** The atomic execution unit: one phase's scope, approach, and acceptance.
Authored by `scaffold-plan`, executed by `scaffold-go`, persists as the record.

**Band.** Execution — temporal; persists in place (may go stale; see Rules).

**Owner(s).** Created/updated by `scaffold-plan` (+ stale-sweep on pivot), executed by
`scaffold-go`, ticked complete by `scaffold-checkpoint`, moved by `scaffold-cleanup`
(preserving interstitials).

## Required frontmatter

```yaml
---
type: phase-plan
schema_version: 2
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# Phase NN — <slug>

## Objective
[What this phase delivers, in a sentence or two.]

## Scope
[What's in — the deliverables. `scaffold-go` reads THIS to bound execution.
Out-of-scope discoveries route to checkpoint, never silent expansion.]

## Approach
[How to build it.]

## Acceptance
[How we know the phase is done — an OBSERVABLE outcome the reader can verify
without reading code (a behavior, an output, a visible state), never "tests pass".]

## Targets   ← OPTIONAL; present only on a FINALIZED plan
_as of <sha>_
- `path/to/file` — [what this phase touches here]
- `interface / surface` — [ditto]
```

## Draft vs. final (the two plan states)

A plan has two states, **derived from content with grounding evidence** — never a
stored status enum (Principle 7). The `## Targets` section is the signal, and its
`as of <sha>` stamp is the evidence that makes the signal auditable:

- **no `## Targets`** → **draft** (code-blind; may be pre-written; not executable).
- **`## Targets` present, `<sha>` is HEAD** → **final & fresh** (validated against
  current code; `scaffold-go` may execute).
- **`## Targets` present, `<sha>` is NOT HEAD** → **stale** (code moved since
  validation; must be re-finalized before `go`).

`## Targets` lists the files/interfaces the phase touches; `scaffold-plan` writes it
during a **finalize** pass (`as of HEAD`) and `scaffold-go`'s deterministic `sha == HEAD?`
check reads it. A plan with no `## Targets` is a valid draft — existing plans are drafts,
no conformance break.

## Rules

- `## Scope` is load-bearing: `scaffold-go` executes exactly what it names. Keep it
  crisp.
- `NN` is the roadmap ordinal and admits interstitials (`09.1`); never renumber.
- **`## Targets` requires its `as of <sha>` stamp.** Bare section-presence is not a valid
  signal — the sha is the grounding evidence (audit checks it resolves to a real commit)
  *and* the staleness backstop (`go` compares it to HEAD). A `## Targets` without a sha is
  malformed.
- **Dirty working tree:** the `sha == HEAD?` check assumes committed state. If the tree
  has uncommitted edits touching any `## Targets` file, treat the plan as **stale** — the
  validation no longer describes what's on disk.
- **Staleness:** a pre-written downstream plan can go stale when a later decision/plan
  lands. `scaffold-plan` sweeps unexecuted plans (drafts included) on a pivot;
  `scaffold-checkpoint`'s coherence sweep also flags a *finalized* plan whose
  targets/approach conflict with a later decision.
- A plan is never authored on a not-yet-approved ADR (the ADR gate resolves first).

## Anti-patterns

- A plan premised on an unratified decision.
- A `## Targets` section with no `as of <sha>` stamp (unauditable, no staleness backstop).
- Renumbering interstitials on migration.
- Silent scope expansion during `go` instead of routing out-of-scope to checkpoint.
