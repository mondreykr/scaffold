---
schema_version: 1
---

# Contract — `architecture.md`

**Purpose.** The defining technical truth, kept current: how it's built.

**Band.** Living truth — updated in place when the system changes.

**Owner(s).** Primary: `scaffold-checkpoint` (sees the diff). Also `scaffold-plan`
(cross-cutting truth shifts), `scaffold-setup` (seeds), `scaffold-integrate` /
`scaffold-cleanup` (populate / stand up). Read by `scaffold-status`, `scaffold-go`.

## Required frontmatter

```yaml
---
type: architecture
schema_version: 1
updated: YYYY-MM-DD
---
```

## Required structure

Topic sections, kept current; cover those that apply. Small projects may keep these
as sections until architecture exceeds a screen.

```markdown
# Architecture

## Stack
## Tenancy / isolation
## Auth
## Data access
## Deployment
## Conventions
## Run / env
[How to run the app + durable run/env facts.]
```

## Rules

- **Indexes the architecturally-significant decisions:** each truth statement
  references the ADR that established it (`[[NNNN-…]]`). The folder + these inline
  references *are* the index — there is no separate index file (it would drift).
- **Coupling rule:** approving or superseding an architectural ADR must update its
  referencing statement here in the *same* command turn, or the index breaks.
- **Architecture-vs-knowledge tie-break:** a fact that changes when you *re-platform*
  (but the business rule stays) → here; a fact that changes only when the *business
  rule* changes → `knowledge/`.

## Anti-patterns

- A separate ADR index file (drifts).
- Business/behavioral rules that belong in `knowledge/`.
- Run/env facts parked in `state.md` — durable run/env truth lives **here**; `state.md`
  has no transient-state section (a resume precondition rides in its `## Next`).
