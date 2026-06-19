# Resume — Scaffold skills build

**Date:** 2026-06-18 → updated 2026-06-19. **This is the authoritative resume doc.**
For full design history (decisions, audit findings, schema fixes), see
`20260618-conformance-audit-and-skills-migration.md` — but its §3c/§4/§5 describe a
*bundling model we dropped*; trust THIS doc where they differ.

**Status: the command→skill migration is essentially complete.** All 9 skills are built
and validated; README + install model updated to skills; old command files removed. What
remains is the adversarial review and one deferred skill (below).

---

## 1. The model — settled, do not re-litigate

This cost four confused rounds; hold it firmly:

- **Factory vs product.** This repo is the **factory**. Only the **skills** ship. Nothing
  else here is visible in a user's repo.
- **The spec = `ARCHITECTURE.md` + `contracts/`.** `ARCHITECTURE.md` is the whole-system
  design; `contracts/` are the per-document format rules. We **build skills FROM the spec.**
- **One-way:** the spec is the source; skills are derived. Change the design in the spec,
  then propagate to skills — never hack a skill and let the spec rot.
- **Contracts are factory-only.** Never bundled into a skill, never shipped, never read at
  runtime. The *only* link is "we read it while authoring the skill." **If you ever find
  yourself designing how a contract 'connects to' a skill at runtime — STOP. There is no
  runtime connection.** (That was the trap.)
- **A skill = a self-contained folder** = `SKILL.md` (+ its own `references/`/`scripts/`
  *only* if it gets too long, ~>500 lines — none did). Format knowledge a skill needs is
  **written into the skill**, at the altitude that skill needs it.
- **Drift control** is authoring discipline + `/scaffold-audit`. No factory copy-compare.

## 2. Built and verified

- **`CLAUDE.md`** — the keystone; states the model above.
- **`ARCHITECTURE.md`** — the reshaped spec (concepts + a Document Types index → 11
  contracts; 9-skill set; two-tier audit; frontmatter + identifier conventions). The two
  stale bundling lines that survived the reshape were fixed 2026-06-19.
- **`contracts/`** — 11 format masters (factory-only).
- **`skills/` — all 9 built and validated** (kebab `name`, `description` ≤1024 & no angle
  brackets, only allowed keys, folder==name, all <500 lines):
  - `scaffold-status` (148), `scaffold-go` (150) — read-only / execution; light.
  - `scaffold-setup` (323), `scaffold-plan` (243) — the heavy authoring/creating skills.
  - `scaffold-audit` (133) — **net-new**; 3-pass (conformance gates reality, then
    stranded-rules); carries a compact per-type conformance checklist inlined.
  - `scaffold-integrate` (158), `scaffold-cleanup` (298), `scaffold-update` (70).
  - `scaffold-checkpoint` (242) — the original shape-setter.
- **`README.md`** — rewritten for skills: `/scaffold-[skill]` naming, the skills install
  (`npx degit mondreykr/scaffold/skills $HOME/.claude/skills`), flags removed, `audit`
  added, examples updated to the current schema.
- **Old `scaffold/*.md` commands — removed** (`git rm`).

**Schema corrections folded in while authoring** (the old commands carried the *old*
schema; skills were authored from the contracts): frontmatter not `<!-- Last updated -->`;
`project.md` requirements → plain truth, never checkboxes; phase brief `## Objective` (not
Goal); ADR contract shape; `--reconcile`/`--audit` flags gone; `## Objectives` /
`## Done-contract`; roadmap `[token] NN-slug — … → path`; CLAUDE.md Skill Reference (9).

## 3. The skill shape (the proven pattern)

Frontmatter: `name` (kebab) + a "pushy" `description` listing plain-language triggers.
Body: the workflow (steps/gates/boundaries) + the format guidance the skill needs, written
in at its altitude (writers carry doc shapes; `audit` carries the full grading checklist;
read-only skills carry almost none). Self-contained; no pointers to non-shipping files.

## 4. Remaining work

1. **Adversarial review (next).** A red-team / independent check over all 9 skills + spec.
   **The #1 risk to probe: conformance drift** — skills were authored from the contracts,
   but the contracts don't ship, so a skill's inlined doc-shape could silently diverge
   from its `contracts/` master. Also check: cross-skill coherence (every doc has a
   creator + maintainer; routing/ownership boundaries agree; no contradictions), lost
   capability vs the old commands, gates/preconditions, naming.
2. **Deferred:** the milestone-close rule-distillation skill (old §3f) — still parked.

## 5. State of the tree

- `ARCHITECTURE.md` describes 9 skills; `skills/` has all 9; `scaffold/` (old commands)
  removed; `README.md` on the skills model. Migration delta closed.
- Install/update mechanism (confirmed): `npx degit mondreykr/scaffold/skills
  $HOME/.claude/skills` (+ `--force` to update); `scaffold-update` also retires
  command-era installs.
