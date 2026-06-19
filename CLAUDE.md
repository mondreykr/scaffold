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
Skills are named in a flat, hyphenated family — **`/scaffold-[skill]`** (e.g.
`/scaffold-status`, `/scaffold-checkpoint`, `/scaffold-audit`) — and each is
**self-contained**: it bundles every reference file it needs, so it works on its own once
installed.

## The factory (this repo)

- `ARCHITECTURE.md` — the design doc. Concepts, the two Laws, the bands
  (truth/history/execution), the routing model. Human-readable authority for *why* the
  system is shaped as it is. Does not ship; links to the contracts rather than restating
  them.
- `contracts/` — the canonical per-document-type format specs (one master per doc type).
  **Build inputs**: copied into each skill's own reference folder at build time, used as
  the conformance oracle by `/scaffold-audit`, and verified by the self-check. *(Target
  structure — being established during the current migration; see `wip/`.)*
- `scaffold/` — the skill sources that get published as `/scaffold-[skill]`.
- `wip/` — design notes and handoffs. Does not ship.
- **self-check** — factory QA (a release gate, not a skill) that verifies every skill's
  embedded contract copy matches its master in `contracts/`, and that masters stay
  consistent with `ARCHITECTURE.md`. Self-contained copies are a drift machine without
  it.

## Active work

A migration is in flight: commands → self-contained skills, schema hardening, and a new
`/scaffold-audit`. The current authoritative handoff is the newest file under `wip/`.
Read it before building on the design.
