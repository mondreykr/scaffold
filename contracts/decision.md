---
schema_version: 1
---

# Contract — `decisions/NNNN-slug.md` (ADR)

**Purpose.** One load-bearing decision: the *why* you'd want in a year, plus the
rejected alternatives.

**Band.** History — frozen, written once. **Adam-gated.**

**Owner(s).** *Proposed* by `scaffold-plan` or `scaffold-checkpoint` (draft + stop);
created only on Adam's explicit approval. Migrated by `scaffold-cleanup` (Adam gates
which survive). Referenced by `architecture.md` when architectural.

## Required frontmatter

```yaml
---
type: decision
schema_version: 1
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# NNNN — <Decision title>

**Status:** Accepted | Superseded by [[NNNN-…]] | Proposed

## Context
## Decision
## Why
## Alternatives considered
## Consequences
```

## Rules

- **Write-gate (hard):** no ADR is created, superseded, or pruned without Adam's
  explicit approval. A command may *propose* — present the full draft — then stop.
- **Bar:** rare, architecturally-significant, cross-cutting choices (tenancy, auth, a
  foundational pivot) — not routine guardrails or build-records.
- **Numbering:** `NNNN-slug`, sequential, zero-padded to **4 digits** — deliberately
  distinct from the 2-digit `NN` of milestones/phases so the namespaces never read
  alike.
- **Supersession:** flip the `Status:` line and write a NEW file; never edit the
  ruling itself.
- **Pruning:** an ADR that guards nothing may be removed with approval (git retains
  it); architecturally-significant ones are kept with a `Superseded` status instead,
  because their *why-not* stays valuable.

## Anti-patterns

- An ADR written without explicit approval.
- Editing a frozen ruling instead of superseding it.
- Build-records / routine guardrails dressed up as ADRs.
- 2-digit numbering (collides with the milestone/phase namespace).
