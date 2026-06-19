# Handoff — Conformance Auditing, Skills Migration, and Schema Hardening

**Date:** 2026-06-18
**Status:** Design discussion — decisions mostly settled, ready to execute next session.
**Origin:** Adam asked whether scaffold has any mechanism to audit itself for
*format/structure conformance* against an enumerated standard, and if not, how to
build one cleanly. The conversation expanded into a schema-hardening +
commands→skills migration effort.

---

## 1. The problem that started this

Adam's question: does scaffold (or any command) sweep the scaffold files for
**correctness of format** — right sections, right content, brevity, conformity —
against an enumerated standard the way a spec lets you audit an implementation?

**Findings (from reading the scaffold repo: `ARCHITECTURE.md`, `README.md`,
`scaffold/checkpoint.md`):**

- Two audit-shaped mechanisms exist today, and they check **different** things:
  - **Coherence sweep** (checkpoint Step 7, every checkpoint + `--reconcile`):
    *relational* consistency — cross-refs resolve, no Law-1 append-logs, no
    duplication, `## Next` resolves, stale dates. Docs vs **each other** + the
    two Laws.
  - **`--audit` flag** (on-demand): docs vs **reality/code** — ticked phases
    really built, architecture matches real stack, ADRs match code.
- **Neither does format-conformance**: grade each file against its enumerated
  per-artifact format spec (required sections, ADR's 6 parts, filename padding,
  brevity, etc.). This is the real gap.
- **The standard IS authored** — `ARCHITECTURE.md` is explicitly the controlling
  doc and has a "Per-Artifact Specifications" section. But it's **prose with a
  few inline examples**, not a checkable enumeration, and **no command consumes
  it as an audit oracle.**
- **Why this matters (not cosmetic):** scaffold's core principle is
  *content-derived state, no enums* — "phase done?" reads a checkbox; "active?"
  reads `state.md` `## Next`; `go` reads the brief's `## Scope`. **The structure
  IS the state machine's data.** Silent format drift → silently misread state.
- **Sharpest gap:** nothing verifies the scaffold's **own command files** against
  `ARCHITECTURE.md`, the doc that claims "all commands derive from what's defined
  here." A drift-prevention system with no drift-check on itself.

---

## 2. Schema audit of ARCHITECTURE.md (the master spec)

Overall verdict: **concepts are sound** (bands: truth/history/execution; the two
Laws; routing table). The problems are **under-specification of format**, not
wrong concepts — which is precisely why a clean checklist can't be extracted yet.
Plus a couple of real smells.

1. **Most doc types lack a canonical skeleton (the core gap).** Only `state.md`
   gets a real template. `plan.md`/`roadmap.md` get examples. Phase briefs, ADRs,
   knowledge docs, investigations, `project.md`, and `architecture.md` itself are
   described in prose. Load-bearing headings (`## Next`, `## Scope`, the `plan.md`
   checklist) must become **required, named structures**, not prose guidance.

2. **The spec wears two hats; rules can get stranded (operational risk, not a Law
   violation).** During a predetermined milestone, domain rules live in the
   spec's `references/` and `knowledge/` stays empty until close, when rules
   "graduate." Defensible (a rule still being shaped belongs to the milestone),
   but if graduation is skipped at close, a durable rule dies in a retired folder.
   **Fix: an explicit "no retired milestone contains un-graduated rules" check.**

3. **`CLAUDE.md` ⇄ `project.md` boundary is blurry (self-admitted** — the doc says
   "if project.md can't hold more than CLAUDE.md, drop it"). **Fix:** pin it —
   `CLAUDE.md` = how to work here + one-line "what this is"; `project.md` = full
   what/who/why/scope. No duplicated orientation.

4. **`project.md` Requirements section — recommend DROPPING the verifiable-checkbox
   mechanism** (Adam's explicit question #3). It overlaps phase-acceptance
   criteria, the milestone done-contract, and `knowledge/` rules, and a checked
   list in a truth doc reads like task-tracking (Law-2 smell). **Keep `project.md`
   for identity + scope boundaries** (incl. "what we're NOT building" — a real
   anti-drift tool); state durable product constraints as plain truth, not
   checkboxes. Verifiable invariants belong where they're tested (spec/acceptance/
   a knowledge doc of invariants). *Adam leaning yes to this; confirm and apply.*

---

## 3. The architecture of the solution (decisions)

### 3a. CONFIRMED — Two-tier audit, no flags
Adam strongly endorsed this. Kill `--reconcile` / `--audit` flags entirely —
*a safety check you must remember to invoke isn't a safety net*, and the flags
don't autocomplete / are forgettable.

- **`checkpoint`** stays lean and fast (run anytime, every session end). Always
  runs a **light, inline conformance + coherence sweep** automatically. No flags.
  Auto-detects "no work to save → just sweep" (absorbs old `--reconcile`).
- **`audit`** = NEW, its own discoverable command/skill (shows in the slash menu).
  Does the **deep, independent review** — spins up fresh agents to grade
  conformance hard AND check docs vs actual code/reality (absorbs old `--audit`).
  Include the **stranded-rules check** (§2.2) here now.

### 3b. CONFIRMED — Migrate commands → skills
Adam wants skills, not commands. Rationale is sound: the distribution model
requires each unit to bundle its own reference content, and **commands can't
cleanly bundle reference files; skills can.** The dev repo (`~/dev/scaffold`) is
the factory; the published package is a set of **self-contained skills** users
install via the link and that each have everything they need.

### 3c. KEY DECISION — where the format contracts physically live
Adam's stance: **`ARCHITECTURE.md` is the master spec, always, comprehensive no
matter what.** He accepts duplication IF managed by master-copies copy-pasted
into skill references at build time (his point #4).

**Claude's recommendation (push-back to refine, not reject):**
- Contracts live as **one canonical reference file per document type** (per
  *document type*, NOT per command). These are the single physical master of each
  format AND the exact-form templates the auditor diffs against.
- `ARCHITECTURE.md` remains the master **authority** — defines concepts/laws/
  routing and **indexes/links** the canonical contracts rather than physically
  restating them. "Comprehensive" = comprehensive authority + concepts, not a
  monolith. (Keeps the already-35KB doc readable and removes one drift layer.)
- Each skill copies into its own `references/` folder **only the contract slices
  it touches** (see §4 map). Self-contained for distribution.
- **NON-NEGOTIABLE: the dev repo must have an automated self-check** that verifies
  (a) every skill's embedded reference == its canonical master, and (b) masters
  are consistent with `ARCHITECTURE.md`. Without this, self-contained-copies =
  a drift machine, violating the project's entire purpose. This IS the meta-audit
  (auditing scaffold against its own spec) flagged at the start.

*Open tension to resolve with Adam:* he said "architecture contains everything";
Claude recommends "architecture is authority + indexes; contracts are their own
master files." Both honor "architecture is the master spec." Pick one — it
determines whether contracts are sections of ARCHITECTURE.md (R1, more in-repo
drift layers) or standalone master files architecture points to (R2, fewer
layers, Claude's recommendation).

### 3d. CONFIRMED — skill-creator governs skill construction
Use `/skill-creator:skill-creator` to build/validate each skill is well-formed,
self-contained, and accomplishes its scope. *Verify what skill-creator actually
supports re: bundled reference folders + consistency enforcement — don't assume.*

### 3e. CONFIRMED — frontmatter on every scaffold doc (Adam's point #4)
Add minimal YAML frontmatter to each scaffold document type:
- `type:` (state | project | architecture | roadmap | knowledge | decision |
  investigation | plan | phase-brief | spec-pointer …) — makes the audit
  **deterministic** (auditor reads the type instead of inferring it).
- `band:` (living | history | execution).
- `schema_version:` — makes future format migrations **detectable** when scaffold
  ships new public versions (cleanup/migration knows what version a file is).
- Possibly fold the existing `<!-- Last updated -->` into `updated:`.
Keep it minimal; don't over-spec.

### 3f. DEFERRED — milestone-close rule distillation (Adam's point #2)
Distilling a closing spec's content into `knowledge/` is a big, possibly
interactive, multi-agent exercise — potentially its own skill, with guidance on
the end-state it must reach. **Deferred.** But the *stranded-rules check* lives in
`audit` now (§3a), so the risk is caught even before the close-skill exists.

---

## 4. Which skills need which contracts (answers Adam's "which commands deserve
their own spec documents")

Contracts are per **document type**; each skill carries the slices for the docs it
touches.

| Skill | Reference content needed |
|-------|--------------------------|
| `setup` | Full contract set (creation/template subset for all initial docs) |
| `status` | Light — compact "expected sections per doc" map; read-only |
| `plan` | Contracts for docs it authors: phase-brief, roadmap, state, project, milestone plan |
| `go` | Phase-brief contract only (reads `## Scope`) |
| `checkpoint` | **Full** contract set (light conformance sweep over all living docs) |
| `audit` (new) | **Full** contract set + reality-check guidance + stranded-rules check |
| `integrate` | spec/ + knowledge + architecture contracts |
| `cleanup` | **Full** contract set + version/migration info |
| `update` | None (pulls package; touches no `.scaffold/` content) |

Full set is needed by setup / checkpoint / audit / cleanup; subsets by plan / go /
integrate. This is the master-copy distribution map.

---

## 5. Attempts to break the design (and mitigations)

1. **Drift machine** — N self-contained copies of contracts. *Mitigation:*
   mandatory dev-repo self-check (§3c). Critical, non-optional.
2. **Duplication bloat** — ~7 skills touch doc formats; embedding full contracts
   in each bloats SKILL.md. *Mitigation:* modular per-doc-type contracts; skills
   carry only needed slices (§4).
3. **skill-creator capability unknown** — don't assume it validates bundled
   reference folders / enforces consistency. *Action:* verify before relying on it.
4. **Invocation/discoverability parity** — Adam's original gripe was forgettable
   flags. Converting commands→skills must NOT regress slash-menu discoverability.
   *Action:* verify skills appear and slash-invoke at least as well as commands.
   (Note: scaffold commands already surface as `scaffold:*` skills in the env, so
   likely fine — but confirm.)
5. **Architecture bloat** — "comprehensive no matter what" must not mean
   monolithic/unreadable. *Mitigation:* R2 (authority + index) per §3c.

---

## 6. Sequence of work (do in this order — checklist derives from the schema)

1. **Perfect `ARCHITECTURE.md`** — apply §2 fixes; regularize every artifact into
   a uniform contract shape: **Purpose · Band · Owner(s) · Required structure
   (skeleton, incl. frontmatter) · Rules · Anti-patterns.** Resolve §3c R1-vs-R2.
2. **Produce the canonical per-doc-type contract reference files** (these double
   as the conformance oracle / exact-form templates).
3. **Resolve `project.md` Requirements** (§2.4) and `CLAUDE.md`/`project.md`
   boundary (§2.3).
4. **Migrate commands → skills** via skill-creator; bundle the contract slices per
   §4.
5. **Build the dev-repo self-check** (skill copies == masters == architecture).
   Non-negotiable (§3c).
6. **Build `audit` skill** (deep conformance + reality + stranded-rules) and fold
   the **light conformance sweep into `checkpoint`**; remove all flags.
7. **Defer** the milestone-close distillation skill (§3f).

---

## 7. Open decisions for Adam (next session)

- [ ] §3c: R1 (contracts inside ARCHITECTURE.md) vs **R2 (contracts as standalone
      master files, architecture indexes them — Claude's rec).**
- [ ] §2.4: confirm dropping `project.md` verifiable-checkbox Requirements;
      decide what `project.md` should contain (identity + scope only?).
- [ ] Frontmatter field set (§3e) — minimal set confirmation.
- [ ] Whether `audit` runs reality-vs-code every time it's invoked, or that stays
      a heavier sub-mode (no flags — maybe audit always does both, or audit asks).

---

## 8. Key files / pointers

- `~/dev/scaffold/ARCHITECTURE.md` — the master spec (controlling doc).
- `~/dev/scaffold/scaffold/*.md` — current 8 command files (to become skills).
- `~/dev/scaffold/wip/20260617-scaffold-restructure.md` — prior restructure notes.
- `~/dev/scaffold/README.md` — install model (`npx degit mondreykr/scaffold/...`).
- Distribution goal: public download → users get self-contained skills with
  everything bundled.
