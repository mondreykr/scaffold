---
schema_version: 1
---

# Contract — `milestones/NN-slug/phases/NN-slug.md` (phase brief)

**Purpose.** The atomic execution unit: one phase's scope, approach, and acceptance.
Authored by `scaffold-plan`, executed by `scaffold-go`, persists as the record.

**Band.** Execution — temporal; persists in place (may go stale; see Rules).

**Owner(s).** Created/updated by `scaffold-plan` (+ stale-sweep on pivot), executed by
`scaffold-go`, ticked complete by `scaffold-checkpoint`, moved by `scaffold-cleanup`
(preserving interstitials).

## Required frontmatter

```yaml
---
type: phase-brief
schema_version: 1
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
[How we know the phase is done.]
```

## Rules

- `## Scope` is load-bearing: `scaffold-go` executes exactly what it names. Keep it
  crisp.
- `NN` is the roadmap ordinal and admits interstitials (`09.1`); never renumber.
- **Staleness:** a pre-written downstream brief can go stale when a later decision/plan
  lands. `scaffold-plan` sweeps unexecuted briefs on a pivot; `scaffold-checkpoint`'s
  coherence sweep also flags brief-vs-decision drift.
- A brief is never authored on a not-yet-approved ADR (the ADR gate resolves first).

## Anti-patterns

- A brief premised on an unratified decision.
- Renumbering interstitials on migration.
- Silent scope expansion during `go` instead of routing out-of-scope to checkpoint.
