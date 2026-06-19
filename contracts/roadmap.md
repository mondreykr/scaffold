---
schema_version: 1
---

# Contract — `roadmap.md`

**Purpose.** The program at 20k feet: the milestone index + the backlog.

**Band.** Living truth.

**Owner(s).** Created by `scaffold-setup`. Maintained by `scaffold-plan`,
`scaffold-checkpoint` (flips a line to `[done]` at close), `scaffold-cleanup` (builds
the index). Read by `scaffold-status`.

## Required frontmatter

```yaml
---
type: roadmap
schema_version: 1
updated: YYYY-MM-DD
---
```

## Required structure

```markdown
# Roadmap

## Milestones
- [active] 01-<slug> — one-liner → milestones/01-<slug>/
- [planned] 02-<slug> — one-liner → milestones/02-<slug>/

## Backlog
- <future feature, one line>
- <someday / never item>
```

## Rules

- The milestone status token is exactly one of `[done] | [active] | [planned]` — the
  literal set is fixed so `scaffold-status` (reads) and `scaffold-checkpoint` (writes
  `[done]`) always agree.
- Program altitude only: the phases *inside* a milestone live in that milestone's
  `plan.md`, never here.
- The permanent home for a future-feature one-liner; the backlog does not retire
  (unlike a milestone's `plan.md`).

## Anti-patterns

- Per-phase build detail (belongs in the milestone `plan.md`).
- A status token outside the fixed set.
- A milestone line whose folder pointer dangles.
