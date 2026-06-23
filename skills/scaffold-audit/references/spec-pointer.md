---
schema_version: 1
---

# Contract — `milestones/NN-slug/spec/`

**Purpose.** The contract that scoped a milestone, when it needed heavy scoping —
either the spec itself or a pointer to one that lives elsewhere.

**Band.** Execution — *live* (maintained in place) until the milestone closes, when
its enduring rules graduate to `knowledge/`.

**Owner(s).** Created by `scaffold-integrate` (absorb or pointer); moved/pointed by
`scaffold-cleanup`. Read by `scaffold-go`.

## Frontmatter

Pointer-file form only:

```yaml
---
type: spec-pointer
schema_version: 1
updated: YYYY-MM-DD
---
```

An embedded full spec keeps its own authoring convention (e.g. the `spec` skill's
STATE / SPEC / DELIVERABLES / DECISIONS layout) — scaffold imposes no frontmatter on it.

## Required structure

Optional folder; present only when the work warranted heavy scoping. Two forms:

- **The spec itself** — follows its own authoring convention; scaffold does not
  reshape it.
- **A pointer file** — a short markdown file naming and linking the external/shared
  spec, with one line on where it lives and why it's external.

## Rules

- A pointer'd or grandfathered spec's **internals are never cracked open or absorbed**
  into `.scaffold/`; it stays whole.
- A spec is *live*, not frozen, until its milestone closes (its `references/` are the
  active rulebook — see the `knowledge` contract).

## Anti-patterns

- Absorbing an external spec's internals into `.scaffold/`.
- Treating a spec as frozen history while its milestone is still active.
