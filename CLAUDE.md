# Scaffold — development repo

**This repo is the factory, not the product.** Its only purpose is to *produce* the
scaffold skills — self-contained artifacts that users download and apply to their own
coding repos. Nothing in this repo ships except the skills.

Two consequences, and they override any instinct to the contrary:

1. **Don't treat this repo's structure as sacred.** `ARCHITECTURE.md`, `contracts/`,
   the self-check — all of it is factory equipment. Users never see it. Optimize
   everything here for one thing: building good skills. If a different structure builds
   better skills, change the structure.
2. **This repo is not itself a scaffold-managed project.** Don't expect (or create) the
   living docs scaffold maintains in a *user's* repo. The thing under development here is
   the system; the system is not applied to its own factory.

## The product (what ships)

Scaffold is a context-persistence system for Claude Code: a family of skills that
maintain a small set of living docs in a user's repo so work survives across sessions.

**The essence — hold this while editing anything here.** The product is a *deterministic
state machine, and its data is the document structure itself.* Skills compute state by
reading sections off disk (`## Next` = what's active, the `plan.md` checkbox = what's
done, a brief's `## Scope` = what to build). The whole thing works only because **every
piece of information has exactly one *computable* home.** The corollary is a hard
guardrail on every change you make: **never add an open-ended or catch-all section.** A
soft bucket is a non-deterministic home — ambiguous data piles up there, the docs bloat,
and the machine starts misreading its own state. A new kind of datum earns a section with
a membership rule a skill can apply, or it routes to an existing home — never a dumping
ground. (Full statement: `ARCHITECTURE.md` → Design Principles.)
Skills are named in a flat, hyphenated family — **`/scaffold-[skill]`** (e.g.
`/scaffold-status`, `/scaffold-checkpoint`, `/scaffold-audit`). A skill is a folder
(`SKILL.md`, plus its own `references/`/`scripts/` only when that skill is big enough to
warrant splitting — a per-skill pragmatic call). Whatever a skill needs to do its job is
written *into the skill*. The factory `contracts/` are **never** bundled into or shipped
with a skill.

## The factory (this repo)

The **spec** is `ARCHITECTURE.md` + `contracts/`. We build the skills from it.

- `ARCHITECTURE.md` — the whole-system design: the two Laws, the bands
  (truth/history/execution), routing, and how the skills fit together. The single
  coherent view that **no individual skill holds** (each skill knows only its slice).
  This is why it earns its place and never becomes a double-up. Doesn't ship.
- `contracts/` — the per-document-type format specs. **Factory-only**: we author skills
  *from* them, and `/scaffold-audit` is built to check a user's files *against* them.
  Never bundled into a skill, never shipped, never read at runtime — the connection to a
  skill is "we read it while building the skill," nothing more. A contract earns its
  place when a format is needed by more than one skill (or by audit); a format used by a
  single skill just lives in that skill.
- `skills/` — the skill sources that ship as `/scaffold-[skill]` (being built during the
  migration). `scaffold/` holds the old command files still being migrated.
- `wip/` — design notes and handoffs. Doesn't ship.

**Direction is one-way: the spec is the source; skills are derived from it.** Change the
design in the spec, then propagate to the skills — never hack a skill and let the spec
rot into stale parallel notes. `/scaffold-audit` is the backstop that catches drift.

## Active work

A migration is in flight: commands → self-contained skills, schema hardening, and a new
`/scaffold-audit`. The current authoritative handoff is the newest file under `wip/`.
Read it before building on the design.
