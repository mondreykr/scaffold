# Handoff — Conformance Auditing, Skills Migration, and Schema Hardening

**Date:** 2026-06-18 (updated — session 2)
**Status:** Decisions settled. Foundational reframe applied (see §0). Ready to execute
step 1 (reshape `ARCHITECTURE.md` + extract `contracts/`).
**Origin:** Adam asked whether scaffold has any mechanism to audit itself for
*format/structure conformance* against an enumerated standard, and if not, how to
build one cleanly. The conversation expanded into a schema-hardening +
commands→skills migration effort.

---

## 0. Foundational reframe (session 2 — read this first)

Everything below was written before this framing was made explicit, and it subtly
distorted some of it. The correction:

- **This repo is the factory, not the product.** Its only purpose is to *produce* the
  scaffold skills. Nothing here ships except the skills. `ARCHITECTURE.md`,
  `contracts/`, the self-check = factory equipment users never see. The repo's structure
  is **not sacred** — optimize it for building good skills, nothing else. Now captured in
  a new project `CLAUDE.md` (the missing keystone — its absence is why the framing kept
  needing re-explaining).
- **There are two different audits, not one** (the handoff fused them):
  1. **Product audit** = `/scaffold-audit` skill, ships to users. Grades *the user's*
     scaffold docs vs. the contracts AND vs. their code. A feature.
  2. **Factory QA** = the "self-check" / "meta-audit", never ships. Verifies the skills
     we're about to release are internally consistent (embedded contract copies ==
     masters == architecture). A release gate — closer to `make test`/lint than a skill.
  Keep them separate.

### Decisions resolved this session
- **§3c (where contracts live): R2+.** Contracts are standalone **build inputs** — one
  master file per doc type in `contracts/`. `ARCHITECTURE.md` shrinks to concepts/Laws/
  routing and *links* to them. Rationale: a standalone file is trivially copyable (into
  skills) and diffable (by the self-check); a section buried in a 35KB narrative must be
  parsed out every time. Repo-not-sacred makes this an easy call.
- **§2.4: drop `project.md` verifiable-checkbox Requirements — CONFIRMED.** `project.md`
  = identity + scope (incl. "what we're NOT building"). Invariants live where tested.
- **§3e frontmatter — CONFIRMED, minus `band`.** Minimal set: **`type` /
  `schema_version` / `updated`** (fold `Last updated` comment into `updated`).
  `band` dropped: it's a total function of `type` (state→living, decision→history,
  phase-brief→execution), so storing it = a derivable enum that can drift — a
  violation of Principle 7. Band stays a concept (Information Model, contract bodies),
  not a stored field. *(Applied the "simplify where possible" principle.)*
- **§7 open #4 (does audit always check reality?): audit ALWAYS does both, no asking.**
  The no-flags principle recurses — "audit asks whether to also check reality" is the
  same forgettable-friction one level down. Depth is already chosen by *which* command
  (`checkpoint` light/always vs `audit` deep/deliberate). Refinement: **conformance runs
  first and gates reality** — the reality pass must read the docs to know what's built,
  so malformed docs make it unreliable; if format is badly broken, report that and flag
  the reality pass as unreliable.

### Naming convention (new)
- Skills are a **flat, hyphenated family: `/scaffold-[skill]`** (e.g.
  `/scaffold-status`, `/scaffold-checkpoint`, `/scaffold-audit`) — NOT the
  plugin-namespaced `scaffold:checkpoint` form they currently surface as. Implies
  individually-installable self-contained skills, not one plugin bundle.
- **Distribution mechanism also changes:** today they install as *commands* (`npx degit
  mondreykr/scaffold/scaffold $HOME/.claude/commands/scaffold`). Target: self-contained
  skills. README + install model need updating (downstream of the skill build).

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

1. **[DONE]** **Perfect `ARCHITECTURE.md`** — reshaped: concepts kept, per-artifact
   format prose + CLAUDE.md template extracted out, Commands→Skills (9, `/scaffold-`
   naming), flags removed, two-tier audit model + frontmatter + Document Types index
   added. Contract shape settled: **Purpose · Band · Owner(s) · Required frontmatter ·
   Required structure · Rules · Anti-patterns** (don't-pad trivial types).
2. **[DONE]** **Produce the canonical per-doc-type contract files** — 11 in
   `contracts/` (claude-md, project, architecture, roadmap, state, knowledge, decision,
   investigation, milestone-plan, spec-pointer, phase-brief). Double as oracle +
   templates.
3. **[DONE]** **Resolve `project.md` Requirements + `CLAUDE.md`/`project.md` boundary**
   — checkboxes dropped, boundary pinned, "may be dropped for symmetry" license kept.
   - *Audit-after (2 independent agents) ran on steps 1–2: consistency CLEAN; recovered
     4 load-bearing items lost in extraction (ADR pruning rule, ID-convention rationale,
     project.md drop-license, knowledge "always a living home" invariant) — all
     restored.*
4. **[NEXT]** **Migrate commands → skills** via skill-creator; bundle the contract
   slices per §4. *(Delta: `scaffold/` still holds the 8 OLD command files; ARCHITECTURE
   now describes the 9-skill target incl. the not-yet-built `audit`.)*
5. **Build the dev-repo self-check** (skill copies == masters == architecture).
   Non-negotiable (§3c).
6. **Build `audit` skill** (deep conformance + reality + stranded-rules) and fold
   the **light conformance sweep into `checkpoint`**; remove all flags.
7. **Defer** the milestone-close distillation skill (§3f).

---

## 7. Open decisions for Adam — ALL RESOLVED (see §0)

- [x] §3c: **R2+** — contracts as standalone master files in `contracts/`; architecture
      links them.
- [x] §2.4: **drop** `project.md` verifiable-checkbox Requirements; `project.md` =
      identity + scope only.
- [x] Frontmatter field set (§3e) — minimal set confirmed (`type`/`band`/
      `schema_version`/`updated`).
- [x] `audit` reality-check: **always does both, conformance-gates-reality, no asking.**

---

## 8. Key files / pointers

- `~/dev/scaffold/ARCHITECTURE.md` — the master spec (controlling doc).
- `~/dev/scaffold/scaffold/*.md` — current 8 command files (to become skills).
- `~/dev/scaffold/wip/20260617-scaffold-restructure.md` — prior restructure notes.
- `~/dev/scaffold/README.md` — install model (`npx degit mondreykr/scaffold/...`).
- Distribution goal: public download → users get self-contained skills with
  everything bundled.
