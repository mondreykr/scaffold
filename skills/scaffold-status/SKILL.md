---
name: scaffold-status
description: Orient at the start of a scaffold session — read the .scaffold/ truth docs and the active milestone, derive current state from disk, and present where things stand plus what you can do next. Read-only; writes nothing. Use whenever you want a briefing, to resume after a gap, to pick up where you left off, or to see what's active, blocked, or next — even if the user only says "status", "where were we", "what's next", or "catch me up".
---

# scaffold-status

Brief the session: read the living truth, locate the active milestone and phase off
disk, surface open threads and history, and end with options — not directives. State is
**derived from what the docs say**, never from a status keyword.

**Precondition.** `CLAUDE.md` and the four `.scaffold/` truth docs (`project.md`,
`architecture.md`, `roadmap.md`, `state.md`) exist — a scaffold project always has all
four. If any is missing, stop: "Scaffold files missing or incomplete — run
/scaffold-setup first (or /scaffold-cleanup if this is an older layout)."

**Boundary.** Read-only. Status presents and orients; it writes nothing, decides
nothing, runs nothing. It tells you what's available.

---

## Step 1: Read the living truth

Read these in order — always-current truth, never a log:

1. `CLAUDE.md`
2. `.scaffold/project.md`
3. `.scaffold/architecture.md`
4. `.scaffold/state.md`
5. `.scaffold/roadmap.md`

A doc's `type` is its frontmatter `type:` (authoritative); filename/location is only a
fallback. Do **not** read `decisions/` files unless `state.md`, `roadmap.md`, or a brief
points at a specific ADR whose *why* you need. Do **not** read `knowledge/` files in
full — list them (Step 3).

## Step 2: Locate the active milestone + phase

**`state.md`'s `## Next` is the single authority for what's active** — both the milestone
and the current phase brief. Folder order is NOT the authority.

1. Read `## Next`. It points at the active milestone and phase brief (e.g.
   `milestones/01-rebuild/phases/09-categories.md`).
2. Read that milestone's `plan.md` and the phase brief `## Next` names.
3. **Fallback only if `## Next` is silent or stale:** the highest-`NN` milestone folder
   is a *hint*, not the authority — a later-numbered milestone can be pre-created while an
   earlier one still runs. If you fall back, say so, and flag that `## Next` should be set.

**Phase done-ness is read from the `plan.md` checklist** — each phase is a checkbox; a
checked box (with a date) means done. No status enum; count checked vs unchecked to see
how far the milestone has progressed.

## Step 3: Surface history filenames (cheap — list, do not read)

- **`knowledge/`** — if it has files, list filenames with a one-line description each.
  These are the durable rulebook for retired milestones. (During an active predetermined
  milestone the spec's `references/` are the live rulebook — `knowledge/` may legitimately
  be empty.)
- **`investigations/`** — if it has files, list the filenames so a resuming session knows
  what research exists. **Do not read them** — listing is enough.
- **`decisions/`** — list `NNNN-slug.md` filenames only if `state.md`, `roadmap.md`, or
  the active brief points at one whose context matters.

Ignore `.gitkeep` placeholders in any directory — they are not content.

## Step 4: Derive signals from disk

State is derived from what the documents say, not from status keywords. Compute:

- **Phase in flight?** The active `plan.md` has an unchecked phase and `## Next` points at
  its brief.
- **Milestone complete?** Every phase in the active `plan.md` is checked. For a
  **predetermined** milestone (has `spec/` + pre-written briefs) this means it's at its
  done-contract → close + graduate (`/scaffold-checkpoint`) or start a new milestone
  (`/scaffold-plan`). For an **emergent** milestone (no spec), all-phases-checked is the
  *normal* steady state between `plan` calls, **not** a close signal — the next move is
  author the next phase (`/scaffold-plan`); close only if the chunk is genuinely done.
- **Blocked?** `state.md`'s `## Blockers` has content other than "None."
- **Open questions?** `state.md`'s `## Open Questions` has content other than "None."
- **Operational note?** `state.md` has a `## Notes` section with transient state (dirty
  dev DB, temp env swap) — surface it; it affects how work resumes.

Signals are not mutually exclusive (you can be blocked AND mid-phase) — surface all that
apply. They drive routing in Step 6.

## Step 5: Present the briefing

Keep it short — a briefing, not a report:

1. **Project** — what this is, in one sentence (from `project.md`).
2. **Milestone + phase** — which milestone is active (per `## Next`), which phase brief is
   current, and how many phases in its `plan.md` are checked vs remaining.
3. **Active focus** — the one-paragraph synopsis from `state.md`.
4. **Open threads** — Blockers and Open Questions (skip if both "None."). Surface `##
   Notes` operational state if present.
5. **Knowledge** — `knowledge/` filenames + one-liners (Step 3). Skip if empty.
6. **Investigations** — `investigations/` filenames (Step 3). Skip if empty.
7. **Next action** — route per Step 6.
8. **Health check** — flag contradictions across docs:
   - `## Next` points at a phase brief or milestone folder that doesn't exist.
   - `## Next` is silent while a milestone has unchecked phases (active cursor lost).
   - A `plan.md` phase is checked but `roadmap.md` still shows the milestone planned, or
     every phase is checked but the roadmap line isn't flipped to done.
   - `project.md` scope boundaries contradict what the roadmap/active milestone builds.
   - An `architecture.md` statement references a decision (`decisions/NNNN-…`) that's
     missing.
   - If consistent, say so.

   (Brief-vs-decision staleness is NOT checked here — `status` deliberately doesn't read
   `decisions/` or downstream briefs. That detection is `checkpoint`'s coherence sweep and
   `plan`'s pivot sweep.)
9. **Staleness** — if any living-truth doc's frontmatter `updated:` date is more than 7
   days old while its content has clearly moved on, flag it.

## Step 6: Route to next step

Suggest, don't mandate. Surface multiple options if multiple signals apply.

**Phase in flight:**
> "Active: [milestone] / [phase brief] — [N] of [M] phases done. Run `/scaffold-go` to
> execute this phase, or `/scaffold-plan` to recalibrate."

**Milestone complete (all phases checked):**
> "[Milestone] is fully checked. If this chunk is genuinely done, run
> `/scaffold-checkpoint` to close it (graduate durable rules to `knowledge/`, flip the
> roadmap line). If it's an emergent milestone still accruing work, run `/scaffold-plan`
> to author the next phase — all-checked isn't a close signal on its own."

**Blocked:**
> "Blocked: [content of Blockers]. If resolved, continue or `/scaffold-plan` to discuss
> direction."

**Active cursor lost (`## Next` silent or dangling):**
> "`state.md ## Next` doesn't point at a live phase. I fell back to [milestone] by folder
> order. Run `/scaffold-plan` to set the active phase."

**Otherwise (early/empty):**
> "Active focus: [synopsis]. Next: [content of Next]. Continue working, or `/scaffold-plan`
> to figure out what's next."

---

## Boundaries

Status is **read-only**. It does NOT: write or mutate any scaffold doc (it presents and
orients only); make decisions (it surfaces state and options); or run other skills (it
tells you what's available). If everything is early or empty, say so plainly and ask what
the user wants to work on.
