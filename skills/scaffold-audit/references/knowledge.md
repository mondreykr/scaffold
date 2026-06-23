---
schema_version: 1
---

# Contract — `knowledge/*.md`

**Purpose.** Durable **cross-cutting behavioral invariants** — rules that are load-bearing
but that no single code location owns (they hold across several call sites, files, or
surfaces). Each entry states the invariant, *why* it matters, and *where the code enforces
it*. One file per coherent rule area.

**Band.** Living truth — maintained in place as code behavior changes.

**Owner(s).** `scaffold-checkpoint` is the **primary owner** — it graduates rules at
milestone close, reconciles the band, and keeps it coherent. `scaffold-plan` writes a rule
settled in discussion; `scaffold-integrate` places an externally-authored rulebook. Those
are the other two lifecycle moments a rule is written. `scaffold-audit` verifies the band
against the code (read-only). Read by `scaffold-go`.

## Required frontmatter

```yaml
---
type: knowledge
schema_version: 1
updated: YYYY-MM-DD
---
```

## Required structure

A prose rulebook, titled for its rule area. Each invariant is stated as three light parts —
kept short, because the point is to *point at* the code, not restate it:

- **The invariant** — one line, plainly.
- **Why** — the consequence if it's violated (so a reader, human or AI, understands intent
  and can generalize, not just obey).
- **Where it's enforced** — a pointer to the code site(s) that implement it (and, if one
  exists, the test / DB-constraint that guards it: "guarded by `test_x`"). If no automated
  guard exists, say so plainly — that invariant is higher-risk (it relies on everyone
  remembering), which is itself useful for a reader to know.

## The membership test (with its reasoning — carry the *why*, not just the rule)

A fact belongs here **iff it is load-bearing AND no single code location is its natural
home.** *Why:* a fact with a single code home is owned by the code; copying it into
knowledge creates a second, drifting source of truth. Knowledge is only for truth that is
real but *homeless* in the code — an invariant smeared across many sites that no one file
states.

So, before writing an entry, route it:
- A localized value / constant / enum / field name (a single code line is its home) →
  **stays in code.** Do not copy it here.
- A fact about *how it's built* that changes on re-platform → `architecture.md`.
- The *why* behind a load-bearing choice → a `decisions/` ADR.
- A cross-cutting invariant with no single code home → **here.**

## Rules

- **Living truth, not history:** maintained in place, never an append-log.
- **Point at code; stay brief.** An entry is concise and references the code rather than
  re-deriving it. A long entry is a smell that it has started restating what the code
  already owns — trim it back to the invariant + why + pointer.
- **Codify first when you can.** If an invariant can be enforced by a single test or DB
  constraint, prefer writing that — and then graduate *nothing* here; the test is the
  living source of truth. Knowledge is the home for invariants that genuinely resist
  codification (they span too many sites for one check).
- **Lifecycle:** during a predetermined milestone the rules may live in the active spec's
  `references/` and `knowledge/` may stay empty; at close, enduring rules graduate here —
  reconciled against existing docs, surfaced for Adam's confirmation. Emergent milestones
  accrue rules here directly.
- **Invariant:** a rule always has a *living* home — the active spec's `references/` during
  a milestone, `knowledge/` once it retires — never only a retired spec.

## Anti-patterns

- **Restating a code-homed value.** A localized constant / threshold / enum copied into
  prose here (e.g. "tolerance is ±0.01") — it belongs in code; the copy will drift.
- **A bloated or re-deriving entry** — one that restates code behavior step-by-step or has
  grown past a concise invariant + why + pointer (form-drift).
- A durable rule left **stranded** in a retired milestone's spec, never graduated.
- A fact that belongs in `architecture.md` (one that changes on re-platform).
- Dated log entries (Law 1).
