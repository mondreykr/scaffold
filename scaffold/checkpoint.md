---
description: Save session progress — verify work, reconcile scaffold truth, commit
argument-hint: [--reconcile] [--audit]
---

**Precondition:** Verify that CLAUDE.md, `.scaffold/state.md`, and
`.scaffold/roadmap.md` exist. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

**Boundary:** This command does NOT make code changes or modify project files.
It updates `.scaffold/` truth + execution docs, runs the coherence sweep, and
commits. Code is `go`'s job; strategy is `plan`'s.

**Active milestone:** `state.md`'s `## Next` is the active-cursor authority —
it names the active milestone (`milestones/NN-slug/`) and the current phase
brief. Folder order ("highest `NN`") is only a fallback hint when Next is
silent. Resolve the active milestone from Next before doing anything else.

---

## `--reconcile` mode (sweep only, no work session)

If invoked as `/scaffold:checkpoint --reconcile`, there is **no work session to
record**. Skip Steps 1–6 entirely. Run **only** Step 7 (the coherence sweep),
then Step 8 (review) and Step 9 (commit) for whatever the sweep changed. Use
this after hand-edits, after an `integrate`, or to tidy a tree that drifted.

If the sweep finds nothing to fix, say so and do not commit an empty change.

Otherwise proceed through all steps in order.

---

## Step 1: Assess Session State

Read `.scaffold/state.md`, `.scaffold/roadmap.md`, CLAUDE.md, and the active
milestone's `plan.md` (resolved from `## Next`). If `## Next` references a phase
brief in `milestones/NN-slug/phases/`, read that brief for verification and
routing.

Determine what kind of checkpoint this is:

**A. Full close-out** — All work for the active phase brief is complete, or it
was a freeform session with no active brief. Proceed through all steps.

**B. Mid-session** — A phase brief is active and its work is incomplete
(`## Next` references a brief; its phase is not yet ticked in `plan.md`). Go to
Step 2.

**C. No active brief** — Freeform session. Skip phase-checklist routing
(Step 5b's tick). Update truth docs from conversation context, then sweep.

---

## Step 2: Mid-Session Handling

*Skip if full close-out or no active brief.*

Ask:
> "Incomplete phase work. What would you like to do?
> - **Pause** — Save current state, continue next session
> - **Partial save** — Record what's done, keep the phase active
> - **Abandon** — Done with this phase for now"

Wait for response.

**If Pause:**
Ask: "Anything I should note for next time? (Context, gotchas, where you left
off mentally — or just 'no'.)"

Wait for response. Then:
- Update state.md's **Active focus** to reflect the paused situation — fold the
  user's response into the paragraph (progress / where their head was / what to
  pick up). One paragraph; no separate session-context section.
- Update state.md's **Next** with the concrete resume action, preserving the
  milestone + phase-brief reference.
- If the pause is caused by transient operational state (dirty dev DB, a temp
  env swap), record that in state.md's optional **`## Notes`** — not in Active
  focus, and not as truth. Clear it when it resolves.
- Skip Steps 3–6. Go to Step 7 (sweep), Step 8 (review), Step 9 (commit).

**If Partial save:**
- Do NOT tick the phase in `plan.md` (the phase isn't done).
- Update state.md's Active focus to reflect progress; preserve the milestone +
  phase-brief reference in Next.
- Skip Step 3. Proceed to Step 5 (partial updates), then Steps 7–9.

**If Abandon:**
- Do NOT tick the phase in `plan.md`.
- Update state.md's Next: clear the phase-brief reference; replace with a brief
  pointer to the new direction (or "Run /scaffold:plan to determine next steps.").
- Update Active focus to reflect that the phase was abandoned and why.
- Proceed to Step 5, then Steps 7–9.

---

## Step 3: USER Task Check

*Skip if mid-session pause or partial save.*

Scan the active phase brief (and `plan.md`'s objectives) for unchecked
human-owned (`[USER]`) tasks.

If none exist, skip to Step 4.

If unchecked `[USER]` tasks exist, walk through each one at a time:

1. Present what was expected (from the brief's acceptance criteria, or the
   `plan.md` objective).
2. If criteria reference specific file paths, check whether they exist.
   Report: "Found: [path]" or "Missing: [path]".
3. Ask: "Task: [title]. Did you complete this? What happened?"
4. Process the response:
   - **Pass** — user confirms, consistent with criteria. Note it for the tick.
   - **Issue** — completed but something went wrong. Ask: "Blocker, or a
     follow-up task?" Route accordingly (blocker → state.md; follow-up →
     `plan` later, or a new brief).
   - **Not done** — leave it; the phase cannot be ticked complete.

**GATE: Resolve each USER task before moving to the next.**

---

## Step 4: Verify AI Work

*Skip if no code changes were made this session.*

Before updating any scaffold doc, verify claims:

1. **Run build/lint/tests** if they exist (package.json scripts, Makefile,
   pytest, etc.). If they fail, report. Do NOT tick a phase complete on failing
   verification — the user decides: fix now, or checkpoint with issues noted.
2. **Evidence-based updates.** A `[x]` requires evidence (test output, observed
   behavior, user confirmation). Removing a blocker requires evidence it's
   resolved. "It should work" is NOT evidence.
3. **If verification isn't possible**, note it honestly: "Completed X — not yet
   verified (no tests)."

---

## Step 5: Update Truth + Execution Docs

Route every change by the contract's coverage matrix — **a place for
everything.** Touch only what this session actually changed.

### 5a. `milestones/NN-slug/plan.md` (the active milestone)

- **Tick the phase checklist** for any phase completed this session:
  `- [x] NN-slug (YYYY-MM-DD)`. The checkbox + date IS the disk-derivable
  "done?" signal — there is no status enum.
- Keep completion annotations **terse** — a date, not prose. Verbose per-phase
  narrative belongs in git, never in `plan.md` (Law 1: `plan.md` is a bounded
  checklist, not an append-log).
- Update objectives or the done-contract only if they genuinely shifted; if a
  *plan* shifted (phases reordered, scope changed), that's `plan`'s job, not
  checkpoint's — note it and route to `plan`.

### 5b. `.scaffold/state.md` (always)

Forward-looking. Four core sections — Active focus / Next / Blockers / Open
Questions — plus an optional `## Notes`.

- **Active focus** — one paragraph; rewrite to reflect this session's outcome.
  Forward-looking, not a journal. **ELI5 — explain it like the reader is five.**
  Plain words, short sentences, no officialese. If a five-year-old wouldn't get
  the gist, rewrite it.
- **Next** — the concrete next action and the active-cursor:
  - Full close-out, phase done, more phases remain: point Next at the next
    phase brief in the active milestone.
  - Full close-out, milestone done: see Step 6 (close motion), then point Next
    forward ("Run /scaffold:plan" or the next milestone).
  - Pause / partial: preserve the milestone + phase-brief reference and name the
    concrete resume step.
  - USER tasks pending: "USER tasks pending: [list]. Complete, then
    `/scaffold:checkpoint`. Phase: [brief path]".
  - Abandon: brief pointer to the new direction.
- **Blockers** — add new; remove resolved (no "Closed" archive). If a resolved
  blocker carries a durable *why* worth keeping, propose it as an ADR in Step 6
  (gated) rather than smearing it across state. If none, write "None."
- **Open Questions** — add new, remove answered (the answer lives in the
  artifact/decision/conversation that resolved it). If none, write "None."
- **`## Notes`** (optional) — transient *operational* state only (dirty dev DB,
  a temp env swap). Clear lines that resolved this session. Durable run/env
  facts (how to run the app) are NOT notes — they belong in `architecture.md`
  (route them there in Step 5d).
- Update `<!-- Last updated -->`.

### 5c. `.scaffold/knowledge/*.md` (if durable behavior changed)

- While a predetermined milestone runs, its **spec's `references/` are the
  living rulebook** — maintain rules there in place as the build proceeds, not
  in `knowledge/`. For an emergent milestone (no spec), accrue discovered rules
  directly into `knowledge/`.
- Either way, when the *build changed how a durable domain/behavioral rule
  actually works* (the ledger replays thus; reconciliation tolerance is ±X),
  update the owning doc in place. This is living truth, not a log.
- **Routing tiebreak:** a fact that changes only when the *business rule*
  changes → `knowledge/`. A fact that would change if you *re-platform* →
  `architecture.md` (Step 5d). Don't double-home it.
- Milestone-spanning graduation/retire of rules happens at **close** — Step 6.

### 5d. `.scaffold/architecture.md` (checkpoint is the PRIMARY OWNER)

You see the diff — so you own keeping architecture truth current.

- If the build changed **how the system is built** — tenancy/isolation, auth,
  stack, data-access patterns, deployment, a cross-cutting convention, or a
  durable run/env fact — update the relevant statement **in place**. Living
  truth, overwritten, never appended.
- `architecture.md` **indexes the architecturally-significant ADRs**: each
  truth statement references the `decisions/NNNN-slug.md` that established it.
  There is no separate index file — the references *are* the index.
- **Coupling rule (hard):** if you approve a new architectural ADR or supersede
  an existing one in Step 6, update its referencing statement in
  `architecture.md` **in this same checkpoint turn** — never leave the index
  pointing at a stale or missing decision.
- Don't migrate a fact here that only the business rule would change — that's
  `knowledge/` (the tiebreak in 5c).

### 5e. `.scaffold/project.md` (if requirements confirmed or scope evolved)

- Update the Requirements section if new requirements were confirmed
  (verifiable checkboxes). Update scope boundaries if they shifted.
- Update `<!-- Last updated -->`.

### 5f. `.scaffold/roadmap.md` (if the program moved)

- Add a future-feature one-liner to `## Backlog` if one surfaced (this is its
  permanent home — it does not retire with a milestone).
- The milestone-line status flip lives in Step 6 (close motion).
- Update `<!-- Last updated -->`.

### 5g. CLAUDE.md (rare — only if orientation/instructions changed)

- Update the orientation lines or working instructions if they genuinely
  changed. Durable *technical* truth goes to `architecture.md` (Step 5d), not
  here — CLAUDE.md is the lean hub + pointer.

---

## Step 6: Decisions + Milestone Close

### 6a. Propose an ADR (Adam-gated — present draft, STOP)

`decisions/` is the curated log of rare, architecturally-significant,
cross-cutting choices you'd want the *why* of in a year (tenancy, auth, a
foundational pivot) — NOT routine guardrails or build-records.

**Write-gate (hard rule): no ADR is created, superseded, or pruned without
Adam's explicit approval.** Checkpoint may only *propose*.

If this session produced a decision that clears that bar:
1. Draft the full ADR — Status / Context / Decision / Why / Alternatives
   considered / Consequences — filename `decisions/NNNN-slug.md` (next sequential
   `NNNN`, zero-padded to 4 digits).
2. **Present the complete draft and STOP.** Do not write the file until Adam
   approves.
3. On approval: write it. **If it is architectural, apply the coupling rule
   (5d) now** — update or add its referencing statement in `architecture.md` in
   this same turn.
4. **Supersession:** flip the prior ADR's `Status:` line
   (`Superseded by [[NNNN-slug]]`) and write the new file — never edit the
   ruling. Update the `architecture.md` back-reference in the same turn.

A research record that yielded a ruling stays in `investigations/`; only the
ruling is proposed here.

### 6b. Milestone-close motion

*Only when the active milestone is genuinely done — its done-contract is met.*
For a **predetermined** milestone (fixed phase set from a spec), a fully-ticked
`plan.md` plus a met done-contract is the close signal. For an **emergent**
milestone (no spec), all-phases-ticked is the *normal steady state* between
`plan` calls and is **not** a close signal on its own — do NOT auto-propose
close; close only when Adam explicitly says the chunk is done.

When the close condition holds, confirm with Adam: "Milestone `NN-slug` —
done-contract met. Close it?" On confirmation:

1. **Graduate durable rules into `knowledge/`.** Lift the enduring
   domain/behavioral rules out of the retiring milestone's spec
   `references/` (or accrued emergent rules) into `knowledge/*.md`.
   **Reconcile against existing knowledge docs** — where a graduating rule
   contradicts or refines an existing doc, retire/supersede the old one. This is
   **surfaced for Adam's confirmation, not silently curated** — present the
   graduation set and any retire/supersede actions, and wait.
2. **Flip the roadmap line.** In `roadmap.md`'s `## Milestones`, change the
   `NN-slug` line's status to done.
3. **Leave the milestone folder in place** — no archive move. Git is the
   history. The retired folder rests in `milestones/`; what's active is whatever
   `state.md`'s Next points at next, never folder order.
4. A pointer'd/external spec is **not cracked open** — only its enduring rules
   graduate; the spec itself stays whole where it lives.

---

## Step 7: Comprehensive Coherence Sweep (EVERY checkpoint)

This runs on **every** checkpoint, and is the *only* thing `--reconcile` runs.
Sweep **all living docs**, not just the ones touched this session — the job is
to leave the whole tree self-consistent, because any checkpoint could be the
last thing that runs before a long gap.

Read across `project.md`, `architecture.md`, `roadmap.md`, `state.md`,
`knowledge/*.md`, the active milestone's `plan.md` + phase briefs, and
`decisions/`. Check for:

1. **Cross-reference integrity (architecture ↔ decisions).** Every
   `architecture.md` statement that cites an ADR points at a file that exists
   and is not silently superseded; every architecturally-significant ADR is
   reflected by a current statement in `architecture.md`. No dangling or stale
   back-references (the coupling rule, audited).
2. **Law 1 — truth and history never share a document.** No living-truth doc
   has grown an append-log (dated entries piling up, "changelog" sections,
   `plan.md` accreting prose). Flag and fold the current truth back into place;
   history belongs in git.
3. **Law 2 — each doc lives at the layer that owns it.** No work-tracking in
   truth docs; no durable truth stranded in a phase brief or `## Notes`; no
   strategy that belongs in cortex; no project documentation that drifted into
   `docs/` (which holds only code-adjacent reference assets). Re-home
   misplaced content.
4. **Duplication.** The same fact stated in two living docs (e.g. a rule in both
   `architecture.md` and `knowledge/`). Collapse to the single owner per the
   routing tiebreak; the other points to it.
5. **Brief-vs-decision staleness.** Any **unexecuted** phase brief in the active
   milestone premised on a decision that has since changed, or on an ADR that
   was superseded/never ratified. Flag it. Rewriting a staled brief is `plan`'s
   job — surface the drift and route to `plan`; do not silently rewrite a brief
   here.
6. **Active-cursor sanity.** `state.md`'s `## Next` points at a milestone +
   phase brief that exist; the named phase is consistent with `plan.md`'s
   checklist (not already ticked, unless Next has moved on).
7. **Stale dates.** Any living doc whose `<!-- Last updated -->` is more than a
   week old while its content clearly moved — flag it.

For anything the sweep can fix **mechanically and unambiguously** — repair a
broken back-reference path, fold a stray dated entry back into living truth,
clear a `## Notes` line that resolved, re-home a line whose correct home is
unambiguous — **fix it** and note it in the Step 8 summary. For anything
requiring **judgment** — a brief needing a real rewrite, a contradiction with
two plausible resolutions, an ADR that should change, or **collapsing a
duplicate / re-homing content between `architecture.md` and `knowledge/`**
(which invokes the re-platform-vs-business-rule tiebreak) — **surface it** and
route; do not guess. Moving durable content between truth docs is an authoring
call (`plan`/`integrate`), not a mechanical sweep fix.

---

## Step 8: Review Before Committing

- Re-read every file you changed. Flag any remaining contradiction.
- Run `git diff .scaffold/ CLAUDE.md` to see the full change set.
- Show, per file, what was added / removed / reworded — and **call out
  separately**: any proposed ADR (and Adam's decision), any knowledge
  graduation/retire at close, any sweep fixes, and anything the sweep surfaced
  for follow-up.
- Ask: "Checkpoint changes ready. Anything to adjust?"
- Wait for confirmation. Only commit after approval.

---

## Step 9: Commit

If git is initialized:
`git add CLAUDE.md .scaffold/ && git commit -m "checkpoint: [brief summary]"`

(`--reconcile`: use `reconcile: [brief summary]` as the message.)

If the commit fails, show the error and stop.

List open questions or loose threads for next session.

**Route to next:** Present options based on the resulting state.
- Phase still active (paused/partial): "Next session, `/scaffold:status` picks
  up. Or `/scaffold:go` to resume now."
- Phase done, more remain: "Next phase: [brief path]. `/scaffold:status` then
  `/scaffold:go`, or `/scaffold:plan` to recalibrate."
- Milestone closed: "Milestone `NN-slug` is done. `/scaffold:plan` for the next
  one."
- USER tasks pending: "Complete your tasks, then checkpoint again."
- Blockers present: "Resolve [blocker summary], then `/scaffold:plan`."
- Otherwise: "Run `/scaffold:plan`, start working, or done for now."

---

## `--audit` mode (`/scaffold:checkpoint --audit`)

After the standard checkpoint completes (including commit), launch an Explore
subagent (thoroughness: "very thorough") to verify scaffold claims against
reality — read-only, report only:

1. Ticked phases — does the work exist in the code?
2. In-flight items — recent changes or uncommitted work?
3. Blockers — evidence in the code?
4. `architecture.md` — matches actual stack/dependencies/data-access?
5. ADRs — do the code and current `architecture.md` match the rulings?

Report discrepancies. Do NOT modify files.

---

## Boundaries

Checkpoint does NOT:
- **Make code changes** — it verifies and records, not implements (`go` builds).
- **Make strategic decisions or rewrite plans** — `plan` does that. Checkpoint
  *surfaces* brief staleness; it does not author or re-author briefs.
- **Write an ADR without approval** — propose, present, STOP. Adam gates
  `decisions/`.
- **Graduate/retire knowledge silently** — surface the set, wait for Adam.
- **Archive a closed milestone** — it rests in place; git is the history.
- **Guess at outcomes** — evidence or user confirmation required.
