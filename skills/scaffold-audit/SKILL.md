---
name: scaffold-audit
description: Deep, independent, read-only review of a scaffold project — grade every .scaffold/ doc hard against its format, verify the docs against the actual code, and check no durable rule is stranded in a retired milestone. Spins up fresh agents; always does all three (conformance gates the rest); changes nothing. Use whenever the user wants a thorough audit, a deep check, a conformance or reality review, or to validate the scaffold before a release, after a long gap, or after heavy hand-editing — even if they only say "audit", "check the scaffold", or "is everything consistent". The light always-on version is built into /scaffold-checkpoint.
---

# scaffold-audit

The deep, independent review. Where `checkpoint`'s inline sweep *samples*, audit grades
the whole tree hard and checks it against reality. It is **read-only** — it reports drift
and never edits. Depth is already chosen by invoking audit at all, so it **always does all
three passes, no asking**: conformance, then reality, then stranded-rules.

**Boundary.** Read-only. Audit grades and reports; it writes nothing. Every fix routes
back through the skill that owns the doc (`plan`/`checkpoint`/`integrate`/`cleanup`) —
audit never edits, proposes ADRs, or touches code.

**Run it independently.** To grade without the bias of the working session's context,
dispatch **fresh read-only subagents** (Explore / general-purpose) rather than judging
from memory: one (or more) for the conformance pass over the doc tree, and — only after
conformance clears — one or more for the reality pass against the code. Synthesize their
findings here. Each agent is told it is grading, not fixing, and grades against the
**bundled contracts** (Step 2), not from recollection.

**Precondition.** `.scaffold/` exists with truth docs. If not: "No scaffold here — run
/scaffold-setup (fresh) or /scaffold-cleanup (migrate an old layout)."

---

## Step 1: Inventory

List every doc in scope: `CLAUDE.md`, the four `.scaffold/` truth docs, all of
`knowledge/`, `decisions/`, `investigations/`, and every `milestones/NN-slug/`
(`plan.md`, `spec/`, `phases/*`). Read each doc's frontmatter `type:` — that is
authoritative and selects which conformance rules apply (filename/location is only a
fallback). Ignore `.gitkeep` placeholders.

**Two gates before grading.** (1) If the tree *wholesale* lacks `type`/`schema_version`
frontmatter (a pre-current-format / un-migrated layout), stop and report: "This scaffold
predates the current format — run /scaffold-cleanup to migrate, then re-audit," rather
than flooding per-doc 'missing frontmatter' findings. (2) A *missing* mandatory truth doc
(`project` / `architecture` / `roadmap` / `state`) is itself a conformance finding — the
four are always present in a current scaffold.

## Step 2: Conformance pass (runs FIRST — gates the rest)

Grade each doc **against its contract.** This skill bundles a verbatim copy of every
format contract in `references/` — one file per `type` (`references/roadmap.md`,
`references/state.md`, `references/claude-md.md`, …). The contract is the oracle: grade
against the file, never from memory or a remembered paraphrase. (The copies are kept
identical to the factory masters by `scripts/sync-contracts.sh`; they are the authority
here.)

**Grade one rule at a time — never a holistic verdict.** A whole-doc "this looks fine"
judgment is exactly how a real violation slips through: the grader skims, the doc reads
clean, and a present-but-ignored rule is never checked. To prevent that, for each doc:

1. **Select the contract** from the doc's frontmatter `type:` (authoritative;
   filename/location is only a fallback). `CLAUDE.md` → `references/claude-md.md`.
2. **Walk the contract line by line** — every item in its **Required structure**, every
   bullet in **Rules**, and every entry in **Anti-patterns**. For *each* one, emit an
   explicit verdict — **pass / fail / n-a** — with the evidence (the doc line or section
   that satisfies or violates it). Every anti-pattern is checked **by name**; you may not
   drop one because the doc "seems clean." This per-rule table is the deliverable.
3. **Also check** frontmatter (`type` / `schema_version` / `updated`; `CLAUDE.md` exempt)
   and brevity (no bloat that signals a Law-1 append-log). For `knowledge/` specifically,
   flag **form-drift**: an entry that restates code (a value/constant with a single code
   home) or has grown past a concise *invariant + why + pointer*.

Dispatch the fresh grading subagent(s) with the absolute path to this skill's
`references/` directory and the instructions above, so they grade against the bundled
contracts rather than recalling rules. A doc's overall grade — **conforms / minor /
malformed** — is *derived* from its table: **conforms only if every rule passed.** A
contract whose `type` doesn't apply to a given file (e.g. an embedded full spec, which
keeps its own authoring convention) is marked n-a, not force-graded.

## Step 3: Reality pass (gated by conformance)

Verify the scaffold's claims against the actual code:

- **Ticked phases really built** — for each `[x]` phase in an active/closed `plan.md`,
  the deliverables exist in the code.
- **Architecture matches the real stack** — `architecture.md`'s Stack / Data access /
  Deployment reflect the manifests and code, not an aspiration.
- **ADRs match reality** — an `Accepted` ADR's ruling is actually what the code does (a
  contradiction means the ADR is stale or silently violated).
- **Knowledge invariants hold in the code** — for each `knowledge/` entry, the code
  site(s) it points to exist and still implement the invariant. Flag a pointer that no
  longer resolves, or a rule the code now violates (route to `checkpoint`). This is the
  payoff of the pointer form and the backstop for a thin milestone-close graduation.
- **Standing blockers are real** — each `state.md` Blocker is corroborated by the code /
  state, not stale or already resolved.
- **Deferred / backlog items aren't already done** — this is the deliberate, expensive
  check the lighter skills can't do: for each `plan.md` `## Deferred` and `roadmap.md`
  `## Backlog` item, verify against the actual code whether it's already built or no longer
  applies. Flag every item that looks shipped or stale for removal (route to
  `checkpoint`/`plan`) — audit reports, never deletes. This is the housekeeping pass that
  keeps the lists from silently accreting done work.
- **In-flight / uncommitted work** — flag uncommitted changes or recent edits the docs
  don't yet reflect (a checkpoint may be overdue).

**The gate (hard):** if a doc is malformed enough that its state can't be read reliably
(e.g. `## Next` doesn't resolve, a `plan.md` checklist is unparseable), report the reality
of that area as **unreliable — fix conformance first**, rather than guessing. Don't infer
through a broken doc.

## Step 4: Stranded-rules check

Confirm no retired milestone holds an **un-graduated durable rule** — a rule that should
have graduated to `knowledge/` at close but still lives only in a retired milestone's
`spec/references/`. The invariant: a durable rule always has a *living* home
(`knowledge/`), never only a retired spec. Flag any orphan for a `checkpoint`
graduation pass.

## Step 5: Report

Return findings **prioritized** (malformed/blocking first, then reality contradictions,
then minor conformance). Conformance findings come straight from the Step 2 per-rule
tables — surface **every failed rule** (doc → the exact contract rule → evidence); do not
collapse them into a single per-doc grade. Each finding names the doc, the specific rule,
and **which skill owns the fix**:

- format / section / frontmatter drift → `scaffold-checkpoint` (sweep) or
  `scaffold-cleanup` (structural)
- a truth/identity/brief change → `scaffold-plan`
- a stranded rule / milestone-close graduation → `scaffold-checkpoint`
- an absorbed-artifact issue → `scaffold-integrate`
- an ADR that should change → propose via `scaffold-plan`/`scaffold-checkpoint`
  (Adam-gated)

End by stating audit changed nothing, and what to run next.

## Boundaries

Audit does NOT: write or edit any doc (read-only — it routes fixes to the owning skill);
propose or write ADRs (it flags; the gated proposal is plan/checkpoint's); touch code; or
skip a pass (all three always run — conformance first, gating reality).
