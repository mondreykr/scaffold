---
schema_version: 2
---

# Contract — `project.md`

**Purpose.** Product identity: what this is, who it's for, why it exists, and the
scope boundaries — including what it is explicitly NOT. Answers *what the product
is*; `architecture.md` answers *how it's built*.

**Band.** Living truth.

**Owner(s).** Created by `scaffold-setup`. Maintained by `scaffold-plan`,
`scaffold-checkpoint`, `scaffold-integrate`, `scaffold-cleanup`. Read by
`scaffold-status`.

## Required frontmatter

```yaml
---
type: project
schema_version: 2
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# <Product>

## What it is
[Plain statement of the product and the problem it solves.]

## Who it's for
[The user(s) / audience.]

## Why
[The motivating need.]

## Scope
[What's in scope.]

## Not building
[Explicit non-goals — the anti-drift boundary. What this product is NOT.]
```

## Rules

- Identity + scope only. Durable product constraints are stated as plain truth.
- **`CLAUDE.md`⇄`project.md` boundary:** `CLAUDE.md` = how to work here + a one-line
  "what this is"; `project.md` = the full what/who/why/scope. No duplicated
  orientation.
- Verifiable invariants are NOT kept here — they live where they're tested (a spec,
  phase acceptance, or a `knowledge/` invariants doc).
- **Mandatory:** one of the four living-truth docs every scaffold project always carries
  (`setup` creates it); never dropped, even when sparse. A missing `project.md` means an
  incomplete or pre-current-format scaffold, not a valid minimal one.

## Anti-patterns

- Requirements/acceptance **checkboxes** — task-tracking in a truth doc; removed by
  design.
- Restating *how it's built* (that's `architecture.md`).
- Duplicating `CLAUDE.md`'s orientation.
