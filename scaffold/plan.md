---
description: Consultation — discuss direction, update roadmap, figure out what's next
argument-hint: [description]
---

**Precondition:** Verify that all five scaffold files exist: CLAUDE.md,
`.scaffold/project.md`, `.scaffold/state.md`, `.scaffold/roadmap.md`,
`.scaffold/decisions.md`. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

**Boundary:** This command does NOT modify non-scaffold files. No code changes.
This command does NOT write plan docs — `/scaffold:scope` does that.

---

## Precondition Guards

Read `.scaffold/state.md` and `.scaffold/roadmap.md` before proceeding.

**If state.md's `## Next` references an existing plan doc in
`.scaffold/plans/`:**
> "You have an active plan doc ([path]). Continuing will clear that
> scope. Proceed, or work from the existing plan?"

Wait for explicit confirmation. If the user wants to keep the existing
scope, stop. If confirmed, clear the plan-doc reference from state.md's
Next during Phase 3 and proceed.

**If unchecked `[USER]` deliverables exist in the `[IN-PROGRESS]` phase
with no other unchecked AI deliverables:**
> "Unverified USER tasks from prior work. Run `/scaffold:checkpoint`
> first to handle them, then re-plan."

Stop. Do not proceed.

**If state.md's `## Blockers` section has content other than "None.":**
> "State shows blockers: [reason from Blockers section]. Is this resolved?
> If yes, we'll plan forward. If not, let's address the blocker first."

Wait for confirmation.

---

## Behavioral Principle: User Comprehension

When the user expresses uncertainty — "I don't understand", "help me understand",
"I'm not sure" — that becomes the top priority before planning continues.

Use AskUserQuestion to offer 2-4 concrete aspects they might be uncertain about.
Let them point to what needs clarification rather than articulating from scratch.

Do NOT probe for hidden uncertainty. If the user gives a clear affirmative,
move forward. Don't second-guess clear signals.

---

## Check for Inline Description

If the user provided a description with the command (e.g.,
`/scaffold:plan fix the redirect`), this is the **inline shortcut**:

1. Treat the description as the user's direction
2. Run Phase 1 (triage) silently to read all files
3. Assess complexity: more than 3 deliverables, architectural decisions, or
   multi-system changes?
   - If yes: "This is bigger than a quick consult — [reason]. Let me walk
     through the full flow." Proceed to Phase 2.
   - If no: skip Phase 2, proceed to Phase 3 with the description as direction.

---

## Phase 1: Triage (silent)

Read in this order. Do not present findings yet — absorb context:
1. .scaffold/state.md — Active focus, Next, Blockers, Open Questions
2. .scaffold/roadmap.md — phases, deliverables, criteria, completion state
3. .scaffold/project.md — vision, scope boundaries, requirements
4. .scaffold/decisions.md — recent active decisions only
5. CLAUDE.md — constraints and tech stack

Scan `.scaffold/knowledge/` — read knowledge docs relevant to the current phase.
These are controlling documents (specs, architecture docs) that contain detailed
requirements, design direction, and implementation specifications. When planning
a build phase, knowledge docs are often the most important input.

Scan `.scaffold/investigations/` — read any that look relevant by filename.

Assess internally:
- Which phase is `[IN-PROGRESS]`? What deliverables are done vs remaining?
- Are there blockers or open questions to resolve first?
- Are any scaffold files stale (>7 days)?
- Are there knowledge docs (specs, architecture docs) for the current phase?
- Are there investigation files that inform the current phase?

---

## Phase 2: Consult (interactive — WAIT for user)

**Skip if inline shortcut is active.**

Present a brief assessment:

- **Where we are:** 1-2 sentences on current state
- **What the docs suggest:** what roadmap/state point to as next work
- **Flags:** blockers, stale files, contradictions, open questions
- **Knowledge docs:** specs or architecture docs relevant to the current phase
- **Prior research:** investigation files if relevant

Then ask:

> "That's what I see in the scaffold files. What are you thinking?
> Direction, concerns, ideas?"

**CRITICAL — Do NOT skip this step. Do NOT propose changes yet.**

The user may have context not in the files, concerns about the approach,
or a completely different direction. Wait for their response.

---

## Phase 3: Discuss and Update (interactive)

After the user shares direction (or from inline description), restate it:

> "So the direction is [one-sentence restatement]. Right?"

Wait for confirmation. User's direction overrides scaffold files.

**Propose roadmap changes:**
- New deliverables to add (and which phase)
- Deliverables to reorder or move between phases
- Items to move to Backlog
- New phases to create
- Phase criteria to add or update
- Phase status changes

For human-owned deliverables, use the `[USER]` marker.

**Wait for approval before writing to roadmap.md.**

**If new requirements emerged:** Add to project.md's Requirements section.

**Update state.md:**
- **Active focus** — reflect the discussion and roadmap changes.
  **ELI5 — explain it like the reader is five.** Plain words, short
  sentences, no jargon shortcuts, no status-report officialese. If a
  five-year-old wouldn't follow the gist, rewrite it.
- **Next** — brief note of what to work on. If the prior Next referenced a
  cleared plan doc, replace with the new direction.
- **Blockers** — update if resolved or new. Resolved blockers: remove the
  line; the resolution lives in decisions.md (Category: Resolved Blocker)
  per Step 5c-equivalent below.
- **Open Questions** — update if answered or new. Answered questions:
  remove the line; the answer lives wherever it was captured.

**Update decisions.md** if decisions were made (add at TOP, newest first).

Update `<!-- Last updated -->` dates on all modified files.

---

## Phase 4: Summary

Present what was updated and where:
- Roadmap changes
- State updates
- Any decisions logged

End with options:

> "[Summary of what changed]. Ready to work — just start, or
> `/scaffold:scope` if you want a formal plan for this."

---

## Edge Cases

- **User wants something not on the roadmap:** User's direction wins. Add to
  roadmap during Phase 3.
- **User doesn't know what to work on:** Present options from roadmap, help
  them choose. Stay in Phase 2 until they have direction.
- **Files are stale:** Flag in Phase 2, suggest checkpoint --audit or updating
  files during this session.
- **Mid-discussion pivot:** If direction changes, restart Phase 3 with the
  new direction. Don't carry stale proposals.

---

## Boundaries

Plan does NOT:
- **Modify non-scaffold files** — no code, no project files
- **Write plan docs** — that is /scaffold:scope
- **Use plan mode** — all work happens in normal mode
- **Skip user consultation** — inline shortcut is the only exception
