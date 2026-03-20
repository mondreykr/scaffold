---
description: Migrate scaffold files to current format
---

**Precondition:** Verify that `.scaffold/` directory exists with at least
`state.md` and `roadmap.md`. If not, stop and say:
"No scaffold files found — run /scaffold:setup first."

This command migrates existing scaffold files to the current format. It handles
both the old flat-section format and any intermediate formats.

---

## Step 1: Read All Existing Files

Read all scaffold files and CLAUDE.md:
- `.scaffold/state.md`
- `.scaffold/roadmap.md`
- `.scaffold/project.md`
- `.scaffold/decisions.md`
- `CLAUDE.md`

---

## Step 1.5: Scratch Migration

Check if `.scaffold/scratch/` exists:

1. If it does, read each file in the directory
2. Present each file: "Found `.scaffold/scratch/[filename]` — [one-line summary of contents]"
3. Propose migration: move files to `.scaffold/investigations/`, rename to match
   `YYYYMMDD-NN-slug.md` convention (date without dashes, zero-padded counter, brief slug)
4. For each file, propose the new name based on content and creation date
5. Wait for user approval
6. Create `.scaffold/investigations/` if needed and move files with new names
7. Remove the empty `.scaffold/scratch/` directory

If `.scaffold/scratch/` does not exist, skip this step.

---

## Step 1.6: v1 Artifact Cleanup

**Check for `.scaffold/quick/`:** If it exists, these are v1 quick task records.
- Present each directory: "Found quick task [NNN]: [description from plan.md]"
- Propose: archive to `.scaffold/archive/quick/` to preserve history
- Wait for user approval, then move

**Check for `.scaffold/continue-here.md`:** If it exists, this is a v1 pause file.
- Read it and present the context
- Propose: incorporate relevant context into state.md Session Context section,
  then delete the file
- Wait for user approval

If neither exists, skip this step.

---

## Step 2: Identify Format Differences

Check each file against the current format:

**roadmap.md — check for:**
- Old flat sections: "Done", "In progress", "Up next", "Later", "Current phase"
- Old checkbox convention: `- v Item` (should be `- [x] Item`)
- Old in-progress convention: `- >> Item` (should be `- [ ] >> Item`)
- Missing phase grouping (should be `## Phase N — Title [STATUS]`)
- Old status format: `[IN PROGRESS]` (should be `[IN-PROGRESS]`)
- Plain bullets in `[PLANNED]` phases (should be `- [ ]` checkboxes; plain sub-bullets for detail only)
- Missing `Backlog` section

**state.md — check for:**
- Old sections: "What's not working", "What's working well", "Parking lot",
  "Next session"
- Missing new sections: "Status", "Current Position", "Next Action",
  "Blockers"

**decisions.md — check for:**
- Old category-grouped format (## Tech, ## Architecture, etc. as organizing headers)
  - Should be flat chronological with `**Category:**` field per entry

**state.md — check for v1→v2 status values:**
- `planning` → `idle` (planning is a transient state, not persisted)
- `executing` → `scoped` (execution scope is set, awaiting /scaffold:do)
- Missing `scoped`, `user-pending`, `paused` as recognized values

**CLAUDE.md — check for:**
- Missing or outdated "Working" section — current version has only 2 rules:
  - If state.md references a plan doc, read it and follow its scope
  - Out-of-scope discoveries get noted for checkpoint, not acted on now
- Over-imposing Working rules from v2: "research the relevant code", "one task
  at a time", "only work on tasks in current scope" — remove (Claude already
  does these; don't tell Claude what it already knows)
- "Ask before making code changes" should be in Rules, not Working
- Missing or outdated Session Protocol — current version includes: status, plan,
  scope, do, go ahead, checkpoint/save/pause, decision
- Missing or outdated Command Reference — current commands: status, plan, scope,
  do, checkpoint, cleanup, update, graduate
- Old command references: `/scaffold:prime`, `/scaffold:pause`, `/scaffold:resume`,
  `/scaffold:quick`, `/scaffold:quick-execute`, `/scaffold:verify` — all removed
- v2 Core Principle should say "Commands are optional tools" not "Plan updates
  scaffold files directly"
- `.scaffold/quick/` in Key Documents — remove
- Redundant rules that duplicate SessionStart hook and command logic:
  - "Run /scaffold:status at the start of every session..." — handled by hook
  - "If /scaffold:status wasn't run, read ..." — handled by hook
  - "Before checkpoint: verify claims with evidence..." — handled by checkpoint
  - "When I say 'checkpoint' — run /scaffold:checkpoint" — self-evident
  - If found, replace with the current lean Rules block:
    - Ask before making code changes — present your approach and get approval
    - Consult .scaffold/decisions.md when making or revisiting design choices
    - Ask before making architectural or structural changes
    - If any scaffold file contradicts the codebase, trust the codebase
    - If context below 40%, suggest checkpoint
    - If decisions or work completed, remind to checkpoint before session ends

**roadmap.md — check for v2→v3 format:**
- Missing phase criteria (numbered acceptance conditions per phase)
- `>>` markers — remove (state.md is the controller, not roadmap markers)
- Items that are tasks (session-level) rather than deliverables (span sessions) —
  flag for consolidation
- Missing `[USER]` markers on human-owned deliverables

**project.md — check for:**
- Missing "Requirements" section — add with verifiable checkboxes
- Requirements hiding in decisions.md — flag for migration to project.md

---

## Step 3: Propose Restructured Content

For each file that needs changes, build the new content by mapping old → new:

**roadmap.md migration:**
- "Current phase" text → becomes the title of the `[IN-PROGRESS]` phase
- "Done" items → become `[x]` tasks in completed phases or Phase 1
  - If items suggest natural phase boundaries, group into separate phases
  - Otherwise, group all into "Phase 1 — [inferred title] [COMPLETE]"
- "In progress" items → become `[ ]` deliverables in the `[IN-PROGRESS]` phase
- "Up next" items → become `[ ]` deliverables in the `[IN-PROGRESS]` or next `[PLANNED]` phase
- "Later" items → move to `Backlog` (as `[ ]` checkbox items)
- Old `- v Item` → `- [x] Item`
- Old `- >> Item` → `- [ ] Item` (drop `>>` — state.md is the controller)
- Add phase criteria if missing: `Phase complete when:` with numbered conditions
- Consolidate granular tasks into deliverables (items that span sessions)

**state.md migration:**
- "What's not working" → "Blockers"
- "Open questions" → "Open Questions" (unchanged)
- "What's working well" → Drop (preferences route to CLAUDE.md)
- "Parking lot" / "Future Ideas" → move to roadmap.md Backlog
- "Next session" → "Next Action" (rewrite as action pointer, not vague intentions)
- Add "Status" section (infer from current state: idle / scoped / blocked)
- Add "Current Position" section (synthesize from existing content)

**decisions.md migration:**
- Extract entries from category sections (## Tech, ## Architecture, ## Design, ## Scope)
- Add `**Category:** [section name]` field to each entry
- Flatten into single chronological list, newest first (sort by date in ### header)
- Keep `## Archived` section at bottom

**CLAUDE.md migration:**
- Add/update "Working" section to current format (2 rules only)
- Move "ask before making code changes" to Rules if it's in Working
- Add/update Session Protocol to current format (status, plan, scope, do,
  go ahead, checkpoint, decision)
- Add/update Command Reference to current format (status, plan, scope, do,
  checkpoint, cleanup, update, graduate)
- Update Core Principle: "Commands are optional tools — minimum ceremony is
  status → work → checkpoint."
- Add Key Documents if missing, remove `.scaffold/quick/` if present
- Remove old command references (prime, pause, resume, quick, quick-execute)

**project.md migration:**
- Add "Requirements" section if missing
- Scan decisions.md for entries that are requirements (product rules, not
  design choices with rejected alternatives) — flag for migration to project.md
- Present each candidate: "[decision entry] looks like a requirement. Move to
  project.md Requirements?"

**roadmap.md migration:**
- Add phase criteria if missing
- Remove `>>` markers
- Consolidate granular tasks into deliverables where appropriate
- Add `[USER]` markers to human-owned items if missing

---

## Step 4: Present Changes for Review

For EACH file that needs changes, show before/after:

```
### [filename]

**Current format issues:** [list what's wrong]

**Proposed new content:**
[full new content]
```

Present ALL proposed changes at once so the user can review holistically.

**Wait for explicit approval before writing any changes.**

If the user wants modifications, incorporate them and re-present.

---

## Step 5: Write Approved Changes

Write all approved changes to their respective files.

---

## Step 6: Commit

If git is initialized:
`git add CLAUDE.md .scaffold/ && git commit -m "scaffold: migrate to v2 format"`

Show a summary of what was migrated.
