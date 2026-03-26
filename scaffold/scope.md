---
description: Write a plan doc — formalize scope for complex or multi-actor work
---

**Precondition:** Verify that `.scaffold/state.md` and `.scaffold/roadmap.md`
exist. If missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

**Boundary:** This command writes a plan doc and updates state.md. It does NOT
modify non-scaffold files, does NOT execute work, and does NOT update roadmap.md
(plan and checkpoint do that).

---

## Precondition Guards

Read `.scaffold/state.md` Status field.

**If status is `user-pending`:**
> "Unverified USER tasks from the current plan. Run `/scaffold:checkpoint`
> first to handle them."

Stop. Do not proceed.

**If status is `scoped`:**
> "A plan doc already exists. Replace it with a new one?"

Wait for confirmation. If declined, stop.

---

## Step 1: Gather Scope

Read:
1. `.scaffold/roadmap.md` — current deliverables and phase state
2. `.scaffold/state.md` — current position and context
3. `CLAUDE.md` — constraints and tech stack
4. `.scaffold/context/` — context docs relevant to deliverables being scoped
   (specs, architecture docs with detailed requirements and design direction)
5. Conversation context — what has been discussed this session

Identify which deliverables should be in scope. Consider:
- What did the user ask for or what did plan identify?
- Which deliverables from the `[IN-PROGRESS]` phase are relevant?
- Are there `[USER]` deliverables that interleave with AI deliverables?

---

## Step 2: Propose Scope

Present the proposed scope to the user:

> "Scope for this plan:
> 1. [Deliverable] — [done-when condition]
> 2. [Deliverable] — [done-when condition]
> 3. [USER] [Deliverable] — [done-when condition]
>
> Approach: [brief strategy]
>
> Right? Anything to add, remove, or change?"

**STOP. Wait for user confirmation.**

If the user adjusts, incorporate and re-present if needed.

---

## Step 3: Write Plan Doc

Write to `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`
(create the directory if needed).

**Naming convention:**
- `YYYYMMDD` — date without dashes
- `NN` — zero-padded sequence counter (scan existing files for today's date)
- `phase-N` — primary phase number
- `slug` — brief descriptor

**Plan doc format:**

```markdown
# Plan: [brief title]
<!-- Generated: YYYY-MM-DD -->
<!-- Plan: .scaffold/plans/YYYYMMDD-NN-phase-N-slug.md -->

## Goal
[What and why — 1-3 sentences]

## Scope
Execute these deliverables. Present your approach before starting.
Do not expand beyond this scope.

1. [Deliverable] — [done-when condition]
2. [Deliverable] — [done-when condition]
3. [USER] [Deliverable] — [done-when condition]

## Approach
[Key decisions, strategy, things to watch out for.
For simple scope: 1-2 sentences. For complex: a paragraph.]

## Deferred
[Items to route to roadmap at checkpoint. Omit section if none.]

## Decisions
[Decisions to log to decisions.md at checkpoint. Omit section if none.]
```

For investigation deliverables, add to the entry:
`Output: .scaffold/investigations/YYYYMMDD-slug.md`

---

## Step 4: Update State

Update `.scaffold/state.md`:
- Status → `scoped`
- Next Action → "Plan doc: `.scaffold/plans/YYYYMMDD-NN-phase-N-slug.md`.
  Say 'go ahead' or run `/scaffold:do` to execute."
- Clear Session Context if present (it's from a previous pause and is now stale)
- Update the `<!-- Last updated -->` date

---

## Step 5: Confirm

> "Plan doc written: `.scaffold/plans/[filename]`
> [N] deliverables scoped. Say 'go ahead' or `/scaffold:do` to execute."

---

## Boundaries

Scope does NOT:
- **Execute work** — that is do or freeform collaboration
- **Update roadmap** — that is plan or checkpoint
- **Modify non-scaffold files** — scope only writes the plan doc and state.md
- **Require prior plan command** — scope works from conversation context alone
