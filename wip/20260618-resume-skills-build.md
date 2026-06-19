# Resume — Scaffold skills build

**Date:** 2026-06-18 (session 2 → resume). **This is the authoritative resume doc.**
For full design history (decisions, audit findings, the schema fixes), see
`20260618-conformance-audit-and-skills-migration.md` — but its §3c/§4/§5 describe a
*bundling model we dropped*; trust THIS doc where they differ.

---

## 1. The model — settled, do not re-litigate

This cost four confused rounds; hold it firmly:

- **Factory vs product.** This repo is the **factory**. Only the **skills** ship. Nothing
  else here is visible in a user's repo.
- **The spec = `ARCHITECTURE.md` + `contracts/`.** `ARCHITECTURE.md` is the whole-system
  design (Laws, bands, routing, how the skills fit). `contracts/` are the per-document
  format rules. We **build skills FROM the spec.**
- **One-way:** the spec is the source; skills are derived from it. Change the design in
  the spec, then propagate to skills — never hack a skill and let the spec rot.
- **Contracts are factory-only.** Never bundled into a skill, never shipped, never read at
  runtime. The *only* link from a contract to a skill is "we read it while authoring the
  skill." **If you ever find yourself designing how a contract 'connects to' a skill at
  runtime — STOP. There is no runtime connection.** (That was the trap.)
- **A skill = a self-contained folder** = `SKILL.md` (+ its own `references/`/`scripts/`
  *only* if that one skill gets too long, ~>500 lines). Whatever format knowledge a skill
  needs is **written into the skill**, at the altitude that skill needs it.
- **Drift control** is authoring discipline + `/scaffold-audit` (the product-side
  conformance tool). There is **no** factory copy-compare gate (the deleted
  `sync_contracts.py` was a mistake born of the bundling model).

## 2. Built and verified

- **`CLAUDE.md`** — the keystone; states the model above.
- **`ARCHITECTURE.md`** — reshaped: concepts + a "Document Types" index pointing at the 11
  contracts; Commands→**Skills** (9, `/scaffold-[skill]` naming); `--reconcile`/`--audit`
  flags removed; two-tier audit model + frontmatter convention (`type`/`schema_version`/
  `updated`; band derived, not stored) + identifier convention added. Audited (2 agents):
  consistency clean; 4 load-bearing items lost in extraction were restored.
- **`contracts/`** — 11 format masters: `claude-md, project, architecture, roadmap, state,
  knowledge, decision, investigation, milestone-plan, spec-pointer, phase-brief`. Shape:
  Purpose · Band · Owner(s) · Required frontmatter · Required structure · Rules ·
  Anti-patterns (trivial types collapse unused sections — don't pad).
- **`skills/scaffold-checkpoint/SKILL.md`** — first skill, the shape-setter. 241 lines,
  self-contained, frontmatter-valid. **DONE.**

## 3. The skill shape (copy checkpoint's pattern)

- **Frontmatter:** `name` (kebab-case) + a deliberately "pushy" `description`. Only these
  keys are allowed: `name, description, license, allowed-tools, metadata, compatibility`.
- **Body:** the workflow (steps, gates, boundaries) + the format guidance the skill needs,
  written in. Altitude varies by skill: checkpoint *writes* docs so it carries concise
  per-doc shape; `audit` *grades* docs so it carries the full rules.
- **Self-contained:** no pointers to files that won't ship.
- **Validate:** frontmatter form — kebab `name`, `description` ≤1024 chars with no angle
  brackets, only allowed keys. (`quick_validate.py` in skill-creator needs `pyyaml`, which
  is absent in this env — use the inline python check instead; see session history.)

## 4. Next work — build the remaining 8 skills

Same pattern, authored from the spec. Sources: the existing `scaffold/*.md` command files
(for the 8 that already exist) + the relevant `ARCHITECTURE.md` skill section + the
contracts each skill reads.

**Which contracts inform each skill** (an *authoring* guide — what to read while writing
it; NOT bundled in):

| Skill | Contracts to author from |
|-------|--------------------------|
| `scaffold-setup` | all 11 (creates the structure) |
| `scaffold-status` | project, architecture, roadmap, state, knowledge, milestone-plan, phase-brief (reads to orient) |
| `scaffold-plan` | ~all (authors most truth + execution docs; proposes ADRs) |
| `scaffold-go` | phase-brief (reads `## Scope`), investigation (may write one) |
| `scaffold-audit` (NEW) | all 11 — it grades against them; carries grading criteria inlined |
| `scaffold-integrate` | project, architecture, roadmap, knowledge, milestone-plan, spec-pointer |
| `scaffold-cleanup` | all 11 (migrates everything; stamps frontmatter; normalizes names) |
| `scaffold-update` | none (pulls latest skills; touches no `.scaffold/`) |

**`scaffold-audit` is the one genuinely new skill.** Deep, independent, read-only, no
flags. Always does all three: **conformance** (grade every `.scaffold/` doc against the
rules — inlined into this skill — frontmatter `type` selects which rules), **reality**
(docs vs actual code: ticked phases built? architecture matches stack? ADRs match?), and
**stranded-rules** (no retired milestone holds an un-graduated durable rule). Conformance
runs first and **gates** reality (malformed docs → report reality as unreliable, don't
guess). The light version of conformance already lives in `checkpoint`'s Step 7.

Suggested order: do them in small batches, show 1–2 for a shape check before mass-
producing (the checkpoint pattern is proven, but altitude/length will vary).

## 5. After the skills

- **README + install model.** Today scaffold installs as **commands** (`npx degit
  mondreykr/scaffold/scaffold $HOME/.claude/commands/scaffold`). This must change to a
  **skills** install with `/scaffold-[skill]` naming. Update `README.md`. The old
  `scaffold/*.md` command files get retired once the skills replace them.
- **Deferred:** the milestone-close rule-distillation skill (old §3f) — still deferred.

## 6. State of the tree (the migration delta)

- `ARCHITECTURE.md` describes **9 skills** (the target).
- `skills/` has **1** (`scaffold-checkpoint`).
- `scaffold/` still has the **8 old command files** (`checkpoint, cleanup, go, integrate,
  plan, setup, status, update`) — to be retired as skills replace them. No `audit` command
  ever existed; `scaffold-audit` is net-new.
