---
name: scaffold-checkpoint
description: Save session progress in a scaffold project — verify work, update the .scaffold/ truth and execution docs, run the light structural + coherence sweep, and commit. Use whenever the user wants to checkpoint, save progress, wrap up or pause a session, record what was done, reconcile or tidy the scaffold docs after hand-edits, or close out a milestone — even if they only say "save", "commit my work", "let's stop here", or "wrap up". Runs the light always-on sweep; for the deep independent review use /scaffold-audit.
---

# scaffold-checkpoint

Save and reconcile a work session: verify what was actually done, update the
`.scaffold/` truth + execution docs, run the light structural + coherence sweep, and commit.
Any checkpoint could be the last thing that runs before a long gap, so it leaves the
whole tree accurate and self-consistent.

**Precondition.** `CLAUDE.md` and the four `.scaffold/` truth docs (`project.md`,
`architecture.md`, `roadmap.md`, `state.md`) exist. If any is missing, stop: "Scaffold
files missing or incomplete — run /scaffold-setup first."

**Boundary.** No code changes, no project files. Checkpoint updates `.scaffold/` (+
`CLAUDE.md`) and commits. Code is `scaffold-go`'s job; strategy and authoring are
`scaffold-plan`'s.

**Active milestone.** Resolve it from `state.md`'s `## Next` (the active-cursor
authority) before doing anything else. Folder order ("highest `NN`") is only a fallback
hint when Next is silent.

**Frontmatter.** Every `.scaffold/` doc carries `type` / `schema_version` / `updated`
YAML frontmatter; whenever you write a doc, set `updated:` to today and ensure `type`
and `schema_version` are present. `CLAUDE.md` is exempt (no frontmatter).

**Nothing to save?** When there's no session work to record — after hand-edits, after an
`integrate`, or just to tidy a drifted tree — skip Steps 1–6 and run **only** the sweep
(Step 7), then review (Step 8) and commit (Step 9) whatever it changed. If the sweep
finds nothing, say so and do not commit an empty change. (This absorbs the old reconcile
pass — there is no flag; detect the no-work case and do the right thing.)

---

## Step 1: Assess session state

Read `state.md`, `roadmap.md`, `CLAUDE.md`, and the active milestone's `plan.md`
(resolved from `## Next`). If `## Next` references a phase brief, read it for
verification and routing. Determine the checkpoint kind:

- **A. Full close-out** — the active phase brief's work is complete, or it was a
  freeform session with no active brief. Proceed through all steps.
- **B. Mid-session** — a brief is active and its work is incomplete. Go to Step 2.
- **C. No active brief** — freeform session. Skip the phase-checklist tick (5a); update
  truth docs from conversation context, then sweep.

## Step 2: Mid-session handling

*Skip unless case B.* Ask:
> "Incomplete phase work. What would you like to do?
> - **Pause** — save current state, continue next session
> - **Partial save** — record what's done, keep the phase active
> - **Abandon** — done with this phase for now"

Wait for the response.

- **Pause:** ask "Anything to note for next time? (context, gotchas, where you left off
  — or 'no')." Then fold it into `state.md` Active focus (one paragraph) and set Next to
  the concrete resume action preserving the milestone + brief reference. A precondition on
  resuming (e.g. "reseed the dev DB first") rides in `## Next`; a durable run/env condition
  goes to `architecture.md` — there is no `## Notes` section. Skip Steps 3–6; go to Step 7.
- **Partial save:** do NOT tick the phase. Update Active focus to reflect progress;
  preserve milestone + brief in Next. Skip Step 3; go to Step 5.
- **Abandon:** do NOT tick the phase. Clear the brief reference in Next, replace with a
  pointer to the new direction (or "Run /scaffold-plan"). Update Active focus with what
  was abandoned and why. Go to Step 5.

## Step 3: USER task check

*Skip on pause/partial.* Scan the active brief and `plan.md` objectives for unchecked
human-owned (`[USER]`) tasks. For each, one at a time: present what was expected; if
criteria name file paths, report Found/Missing; ask "Did you complete this? What
happened?"; then route — **Pass** (note for the tick), **Issue** (ask blocker vs
follow-up, route accordingly), **Not done** (leave it; phase can't be ticked).
**GATE: resolve each USER task before the next.**

## Step 4: Verify AI work

*Skip if no code changed.* Before updating any scaffold doc, verify claims:
1. **Run build/lint/tests** if they exist. On failure, report — do NOT tick a phase
   complete on failing verification; the user decides fix-now vs checkpoint-with-issues.
2. **Evidence-based updates.** A `[x]`, or removing a blocker, requires evidence (test
   output, observed behavior, user confirmation). "It should work" is not evidence.
3. **If verification isn't possible**, say so: "Completed X — not yet verified (no
   tests)."

## Step 5: Update truth + execution docs

Route every change by where it belongs — a place for everything; touch only what this
session changed. The shape each doc must keep:

- **5a `milestones/NN-slug/plan.md`** — tick the phase checklist for any phase completed
  this session: `- [x] NN-slug (YYYY-MM-DD)`. The checkbox + date IS the "done?" signal
  (no status enum). Keep annotations terse — a date, not prose; verbose narrative goes to
  git, never accreting here. **Groom `## Deferred`** (add the section if the milestone
  needs it): add a terse `- [ ]` line for any work tied to this milestone that this session
  surfaced but deferred (a bug, cleanup, debt, residual), and **remove any `## Deferred`
  item this session actually shipped** (you have the diff — that's your evidence). Items are removed,
  never ticked `- [x]`. If a *plan* shifted (phases reordered/scope changed), that's
  `scaffold-plan`'s job — note and route.
- **5b `state.md` (always)** — exactly four sections (Active focus / Next / Blockers /
  Open Questions), no others:
  - **Active focus** — one paragraph, rewritten to reflect this session's outcome.
    Forward-looking, ELI5 (plain words, short sentences); no bullets, code blocks, or
    quoted prompts.
  - **Next** — the concrete next action + the active cursor (milestone + phase brief by
    path).
  - **Blockers** / **Open Questions** — always present; literal `None.` when empty. When
    one resolves, remove the line and route the resolution to its home (a decision, the
    roadmap, a commit, a knowledge doc) — state never accumulates resolved items.
  - **No `## Notes` section** — `state.md` has only the four headings above. Transient
    operational state routes to its real home: a resume precondition → `## Next`; a durable
    run/env condition → `architecture.md`; a blocker → `## Blockers`. If a `## Notes` (or
    any catch-all) section exists from an older tree, drain it this checkpoint — re-home
    each line, then delete the section.
- **5c `knowledge/*.md` (PRIMARY OWNER)** — checkpoint owns the knowledge band: keep it
  coherent, reconcile, and graduate at close (Step 6b). Write here only if the build
  changed how a durable *cross-cutting* invariant works — one with no single code home.
  State it in the contract's form: **the invariant + why + a pointer to where the code
  enforces it** (and the test/constraint that guards it, if any). Stay brief — point at
  code, don't restate it; a localized value/constant belongs in code, not here. Living
  truth, maintained in place, never a log. During a predetermined milestone the spec's
  `references/` are the living rulebook; emergent milestones accrue rules here directly.
- **5d `architecture.md` (PRIMARY OWNER)** — you see the diff, so you keep technical
  truth current. Update *in place* when *how it's built* changed (tenancy, auth, stack,
  data-access, deployment, conventions, durable run/env). It **indexes the
  architecturally-significant ADRs**: each statement references the `decisions/NNNN-slug`
  that established it (`[[NNNN-…]]`) — the references *are* the index, no separate index
  file. **Coupling rule:** if you ratify/supersede an architectural ADR in Step 6, update
  its referencing statement here in the *same* turn. (Tiebreak: a fact that changes only
  when the *business rule* changes belongs in `knowledge/`, not here.)
- **5e `project.md`** — only if scope/identity evolved. Identity + scope boundaries only
  (including "what we're NOT building"); state durable constraints as plain truth — **no
  checkboxes.** A verifiable invariant routes to where it's tested (a phase brief's
  `## Acceptance`, the milestone done-contract, or a `knowledge/` doc), not here.
- **5f `roadmap.md`** — add a surfaced future-work one-liner to `## Backlog` as a terse
  `- [ ]` **only if it's not tied to the active milestone** (work tied to the active
  milestone — its scope/code — goes to `plan.md` `## Deferred`, not here; the test is
  tied-ness, not altitude). **Remove any `## Backlog` item this session shipped** (removed,
  never ticked `- [x]`). `## Milestones` lines use the fixed tokens `[done] | [active] | [planned]`; the
  status flip to `[done]` happens in Step 6b.
- **5g `CLAUDE.md` (rare)** — only if orientation/working instructions genuinely changed;
  durable technical truth goes to `architecture.md`, not here.

## Step 6: Decisions + milestone close

### 6a. Propose an ADR (Adam-gated — present draft, STOP)

`decisions/` is the curated log of rare, architecturally-significant choices you'd want
the *why* of in a year — not routine guardrails or build-records. **Write-gate (hard):
no ADR is created, superseded, or pruned without Adam's explicit approval; checkpoint
may only propose.** If the session produced a decision that clears the bar:
1. Draft the full ADR — `**Status:**` line + Context / Decision / Why / Alternatives
   considered / Consequences — filename `decisions/NNNN-slug.md` (next sequential,
   zero-padded to 4 digits, distinct from the 2-digit milestone/phase `NN`).
2. **Present the complete draft and STOP.** Write nothing until Adam approves.
3. On approval: write it; if architectural, apply the coupling rule (5d) in the same
   turn.
4. **Supersession:** flip the prior ADR's `Status:` line (`Superseded by [[NNNN-…]]`) and
   write a NEW file — never edit the ruling; update the `architecture.md` back-reference
   in the same turn.

A research record that yielded a ruling stays in `investigations/`; only the ruling is
proposed here.

### 6b. Milestone-close motion

*Only when the active milestone is genuinely done — its done-contract is met.* For a
**predetermined** milestone, a fully-ticked `plan.md` + met done-contract is the close
signal. For an **emergent** milestone, all-phases-ticked is the normal steady state, NOT
a close signal — close only when Adam explicitly says the chunk is done. When the
condition holds, confirm: "Milestone `NN-slug` — done-contract met. Close it?" On
confirmation:
1. **Graduate durable rules into `knowledge/`** — lift enduring *cross-cutting invariants*
   from the retiring milestone's spec `references/` (or accrued emergent rules) and write
   each in the contract's form: invariant + why + a pointer to where the code enforces it.
   First triage each candidate: a single-code-home value (constant/enum) → leave it in
   code, graduate nothing; an invariant a single test/constraint could enforce → prefer
   writing that, graduate nothing; only a genuinely homeless cross-cutting invariant
   graduates. **Reconcile against existing knowledge docs** (retire/supersede contradicted
   ones). **Surface the graduation + retire set for Adam's confirmation; don't curate
   silently.** After graduating, tell the user: *"graduated N rules into `knowledge/` — run
   `/scaffold-audit` to verify them against the code."*
2. **Resolve the `## Deferred` list (backstop).** No milestone closes with un-handled
   deferred items: for each, confirm shipped (remove it), promote it (surface for
   `scaffold-plan` to re-home into the next milestone's `plan.md` `## Deferred` or
   `roadmap.md` `## Backlog`), or drop it with Adam's nod. The list retires with the
   folder — it must not graveyard.
3. **Flip the roadmap line** to `[done]` in `roadmap.md`'s `## Milestones`.
4. **Leave the folder in place** — no archive move; git is the history.
5. A pointer'd/external spec is **not cracked open** — only its enduring rules graduate.

## Step 7: Structural + coherence sweep (EVERY checkpoint)

Runs on every checkpoint, and is the *whole* job when there's no work to save. Sweep
**all living docs**, not just the touched ones.

**Structural (the deep per-rule grade is `/scaffold-audit`'s).** Check each living doc is
well-formed at the *stable, Law-level* shape. The detailed per-contract format rules live
in exactly one drift-guarded place — audit's bundled contract copies — so **don't
re-enumerate them here; route them to audit.** Check only:
1. Required sections present, correctly named, and in order (per the shapes in Step 5).
2. Frontmatter present and valid (`type` / `schema_version` / `updated`; `CLAUDE.md`
   exempt).
3. No Law violations — an append-log / dated entries in a living-truth doc (Law 1); a
   `## Notes` / any catch-all / open-ended section (the one-home rule); or a checkbox in
   `project.md` (Law 2 — a truth doc never carries work-tracking). Fix these on sight. The
   genuinely driftable per-contract details (e.g. investigation date format, status-token
   set, `## Backlog`↔`## Deferred` item shape) are audit's deep pass — flag for
   `/scaffold-audit`, don't grade them here.

**Coherence** — read across `project.md`, `architecture.md`, `roadmap.md`, `state.md`,
`knowledge/*.md`, the active `plan.md` + briefs, and `decisions/`:
1. **Cross-reference integrity (architecture ↔ decisions)** — every cited ADR exists and
   isn't silently superseded; every architecturally-significant ADR is reflected by a
   current statement. No dangling/stale back-references (the coupling rule, audited).
2. **Law 1** — no living-truth doc has grown an append-log; fold current truth back into
   place, history belongs in git.
3. **Law 2** — no work-tracking in truth docs; no durable truth, deferred work, or to-do
   list stranded where it doesn't belong (durable run/env → `architecture.md`; deferred
   work → `plan.md` `## Deferred` / `roadmap.md` `## Backlog`; an undecided question →
   `## Open Questions`); no strategy that belongs in cortex; no project docs drifted into
   `docs/`.
4. **Duplication** — the same fact in two living docs; collapse to the single owner per
   the routing tiebreak.
5. **Brief-vs-decision staleness** — any unexecuted brief premised on a changed or
   un-ratified decision. Flag and route to `scaffold-plan`; do NOT rewrite a brief here.
6. **Active-cursor sanity** — `state.md`'s `## Next` points at a milestone + brief that
   exist; the named phase is consistent with `plan.md`'s checklist.
7. **Stale dates** — any living doc whose `updated:` is over a week old while its content
   clearly moved.
8. **Deferred/Backlog grooming nudge** — staleness removal (is an item already built or
   moot?) needs the code, so it's `audit`'s job, not this sweep's — but a discretionary
   check nobody's reminded to run isn't a safety net. So the always-on sweep *surfaces the
   signal*: if the active milestone's `## Deferred` (or `roadmap.md` `## Backlog`) has grown
   large (rule of thumb: >~12 items) or clearly hasn't been groomed in a long while, flag
   it — "`## Deferred` is at N items; run `/scaffold-audit` to do the deep already-built/
   stale check, then `/scaffold-plan` to act on the flags." Checkpoint nudges; audit
   determines. This keeps a long-lived milestone's list from silently accreting.

Fix what's **mechanical and unambiguous** (a broken back-reference path, a stray dated
entry folded back into truth, a shipped `## Backlog`/`## Deferred` item removed, a
leftover `## Notes` section drained and removed, a missing/refreshable frontmatter field)
and note it in Step 8. **Surface** anything needing judgment (a brief
needing a real rewrite, a two-way contradiction, an ADR that should change, collapsing a
duplicate / re-homing content between `architecture.md` and `knowledge/`, or a requirement
checkbox in `project.md` — the `[ ]` syntax is the anti-pattern, but its *content* is a
requirement to re-home to where it's tested, so surface it, never silently delete the
content) and route — do not guess. Moving durable content between truth docs is an authoring call
(`scaffold-plan`/`scaffold-integrate`), not a sweep fix.

The inline sweep *samples*; for the deep, independent grading — hard conformance over the
whole tree, docs vs. actual code, and the stranded-rules check — run `/scaffold-audit`.

## Step 8: Review before committing

- Re-read every file you changed; flag any remaining contradiction.
- `git diff .scaffold/ CLAUDE.md` for the full change set.
- Show, per file, what changed — and **call out separately**: any proposed ADR (and
  Adam's decision), any knowledge graduation/retire at close, any sweep fixes, and
  anything the sweep surfaced for follow-up.
- Ask: "Checkpoint changes ready. Anything to adjust?" Wait for confirmation; commit only
  after approval.

## Step 9: Commit

If git is initialized: `git add CLAUDE.md .scaffold/ && git commit -m "checkpoint: [brief
summary]"` (use `reconcile: [summary]` when this was a sweep-only run). If the commit
fails, show the error and stop. List loose threads for next session, then **route to
next** based on the resulting state:
- Phase paused/partial: "Next session `/scaffold-status` picks up, or `/scaffold-go` to
  resume now."
- Phase done, more remain: "Next phase: [brief path]. `/scaffold-status` then
  `/scaffold-go`, or `/scaffold-plan` to recalibrate."
- Milestone closed: "Milestone `NN-slug` done. `/scaffold-plan` for the next."
- USER tasks pending: "Complete your tasks, then checkpoint again."
- Blockers present: "Resolve [blocker], then `/scaffold-plan`."
- Otherwise: "Run `/scaffold-plan`, start working, or done for now."

## Boundaries

Checkpoint does NOT: make code changes (`scaffold-go` builds); make strategic decisions
or rewrite plans (`scaffold-plan` does — checkpoint *surfaces* brief staleness); write an
ADR without approval (propose, present, STOP); graduate/retire knowledge silently
(surface the set, wait); archive a closed milestone (it rests in place); or guess at
outcomes (evidence or user confirmation required).
