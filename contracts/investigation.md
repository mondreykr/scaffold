---
schema_version: 1
---

# Contract — `investigations/YYYYMMDD-slug.md`

**Purpose.** A dated record of research/analysis produced while working — gap maps,
spikes, security investigations.

**Band.** History — dated, immutable, written once.

**Owner(s).** Created opportunistically by `scaffold-go` (and any work that warrants a
record). Read by `scaffold-status` (lists filenames) and `scaffold-plan`.

## Required frontmatter

```yaml
---
type: investigation
schema_version: 1
updated: YYYY-MM-DD
---
```

## Required structure

No fixed skeleton — a titled, dated analysis. Records its question, what was found,
and any recommendation.

## Rules

- Filename is `YYYYMMDD-slug` (point-in-time capture; **no hyphens in the date**).
- Immutable: written once, never the source of current truth.
- When a record yields a ruling, the analysis **stays here** and the ruling is
  *proposed* as an ADR at the next checkpoint (it does not become truth by itself).
- Repo-specific and tactical — strategic/cross-project research belongs in an external
  knowledge base (cortex), not here (Law 2).

## Anti-patterns

- A hyphenated date (`2026-06-11-*` → normalize to `20260611-*`).
- Editing it later as if it were living truth.
- Strategic cross-project analysis (belongs outside the repo).
