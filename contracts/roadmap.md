---
schema_version: 2
---

# Contract — `roadmap.md`

**Purpose.** The program at 20k feet: the milestone index + the backlog.

**Band.** Living truth.

**Owner(s).** Created by `scaffold-setup`. Maintained by `scaffold-plan` (adds backlog
items; removes one on promotion to a milestone/phase), `scaffold-checkpoint` (flips a
line to `[done]` at close; removes a backlog item shipped that session),
`scaffold-cleanup` (builds the index). Read by `scaffold-status`; reality-checked by
`scaffold-audit` (flags items already built or stale).

## Required frontmatter

```yaml
---
type: roadmap
schema_version: 2
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
- [ ] <future feature, one line>
- [ ] <future feature, one line>
```

## Rules

- The milestone status token is exactly one of `[done] | [active] | [planned]` — the
  literal set is fixed so `scaffold-status` (reads) and `scaffold-checkpoint` (writes
  `[done]`) always agree.
- Program altitude only: the phases *inside* a milestone live in that milestone's
  `milestone.md`, never here.
- **Backlog membership — the one computable test.** Ask: *is this item tied to the
  active milestone — its scope, its code, or its goal?* **Not tied (or no milestone is
  active) → it's a backlog item** (it outlives any current milestone — typically a future
  feature/capability). **Tied → it is NOT a backlog item** → it routes to that milestone's
  `milestone.md` `## Deferred`. This tied-to-the-active-milestone test is the single
  discriminator between `## Backlog` and `## Deferred`; "altitude" is not the rule. A bug
  in code this milestone built is *tied* (→ Deferred); a standalone future capability is
  *not tied* (→ Backlog).
- **One line, hard.** Each item is a single terse line — a pointer/reminder, not a
  summary. No sub-bullets, no detail-bearing parentheticals, no multi-clause paragraphs.
  If it needs more than a line, it's a phase plan or an investigation, not a backlog
  entry.
- **`- [ ]`, never ticked.** Items are written as open checklist items and **leave by
  removal**, never by checking. An item is removed when it's promoted into a milestone/
  phase (by `scaffold-plan`) or shipped (by `scaffold-checkpoint`). A `- [x]` line is an
  error — a shipped feature is deleted, not ticked-and-kept.

## Anti-patterns

- Per-phase build detail (belongs in the milestone's `milestone.md`).
- Ground-level milestone debt — bugs, cleanups, residuals (belongs in `milestone.md`
  `## Deferred`).
- A multi-line / paragraph backlog item (one line only).
- A `someday / never` / rejected-idea entry (a rejected option is an ADR alternative or
  it's simply gone — the backlog is not a graveyard).
- A `- [x]` checked item, or a shipped feature still listed.
- A status token outside the fixed set.
- A milestone line whose folder pointer dangles.
