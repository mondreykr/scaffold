# Handoff — audit grades against bundled contracts, one rule at a time

**Date:** 2026-06-23 · **Status:** Implemented in the source repo (skill + contracts copies
+ ARCHITECTURE + CLAUDE + sync script). **NOT yet propagated** to `~/.claude/skills` — see
Downstream.

## What prompted it

A real `/scaffold-audit` run (on the `mrr-automation` repo) passed a `roadmap.md` whose
`## Backlog` held two clear violations — a multi-line shipped-feature prose entry and a
"Someday/never:" placeholder. Adam challenged the clean verdict.

## The root-cause finding (the important part)

Two hypotheses were on the table; only one survived the evidence.

1. *"The audit skill truncated the contract rules, so it couldn't catch them."* — **False.**
   A line-by-line diff of all 11 contracts against the audit skill's inline Step-2 rules
   showed the three relevant roadmap anti-patterns ("multi-line item", "someday/never",
   "shipped feature still listed") were present **verbatim**. Nothing was lost for that case.
2. *The grader had the rule and didn't apply it.* — **True.** The conformance pass returned
   one holistic per-doc verdict ("conforms"), which let a present-but-ignored rule slide.
   The failure was grading discipline, not missing rules.

Secondary, real but not the cause: the inline paraphrase *did* drop the literal skeleton
templates and a little sharpness, and could rot vs. the contracts over time (nothing checked
it). So shipping the contracts is justified as drift hygiene — but on its own would not have
caught this miss.

## The fix (both problems, composed)

Shipping contracts AND keeping the inline paraphrase would have re-created the drift trap
(two copies of the rules). So instead, one oracle + forced application:

1. **Audit ships verbatim contract copies** in `skills/scaffold-audit/references/` (one per
   type). This is now the single explicit exception to "contracts never ship in a skill".
2. **Deleted the audit skill's inline per-type rules block.** Step 2 now: select the
   contract by `type`, walk its Required-structure / Rules / Anti-patterns **line by line**,
   emit a **per-rule pass/fail/n-a verdict with evidence**. The per-doc grade is *derived*
   (conforms only if every rule passed). Step 5 surfaces every failed rule, not a collapsed
   grade.
3. **`scripts/sync-contracts.sh`** copies `contracts/*` → the skill's `references/`;
   `--check` mode is the drift guard (run before commit). Direction one-way: master → copy.
4. **Scope: audit only.** `checkpoint`'s light inline sweep is left as-is — it's the fast
   sampler by design, not the authority; loading 11 contracts every checkpoint would fight
   the two-tier model.

## Files changed (source repo)

- `skills/scaffold-audit/SKILL.md` — Step 2 rewritten (load contract + per-rule grading),
  "Run it independently" + Step 5 updated.
- `skills/scaffold-audit/references/*.md` — NEW, 11 verbatim contract copies (generated).
- `scripts/sync-contracts.sh` — NEW, sync + `--check` drift guard.
- `ARCHITECTURE.md` — "Document Types" intro (factory-only → factory-authored masters +
  audit exception) and the audit conformance bullet (one-rule-at-a-time).
- `CLAUDE.md` — the skill-folder paragraph and the `contracts/` factory bullet (audit
  exception).

## Downstream (NOT done here)

- **Propagate:** run `/scaffold-update` (or `npx degit mondreykr/scaffold/skills $HOME/.claude/skills --force`)
  to ship the new audit skill + its `references/` into `~/.claude/skills/scaffold-audit/`.
- **Re-run** `/scaffold-audit` on `mrr-automation` in a fresh session; it should now flag the
  two `roadmap.md` `## Backlog` violations. (Those still need the `/scaffold-checkpoint` fix
  that was already pending — empty the Backlog.)
