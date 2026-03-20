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
- Missing "Working" section (v2 addition — execution behavior rules)
- Missing "Session Protocol" table
- Missing "Command Reference" table
- Missing "Core Principle" section
- Missing "Key Documents" section
- Old v1 command references: `/scaffold:prime`, `/scaffold:pause`,
  `/scaffold:resume`, `/scaffold:quick`, `/scaffold:quick-execute`,
  `/scaffold:verify` — replace with v2 commands (`/scaffold:do`)
- Old session protocol entries: "prime" / "execute" → "do it" / "go ahead";
  "pause" → checkpoint mid-session; remove "resume", "quick fix" rows
- `.scaffold/quick/` in Key Documents — remove (v2 dropped quick workflow)
- Redundant rules that duplicate SessionStart hook and command logic:
  - "Run /scaffold:status at the start of every session..." — handled by SessionStart hook
  - "If /scaffold:status wasn't run, read ..." — handled by SessionStart hook
  - "Before checkpoint: verify claims with evidence..." — handled by checkpoint command
  - "When I say 'checkpoint' — run /scaffold:checkpoint" — self-evident
  - "Ask before making major architectural..." — simplify to "Ask before making architectural..."
  - If found, replace the full rules block with:
    - Consult .scaffold/decisions.md when making or revisiting technology/architecture/design choices
    - Ask before making architectural or structural changes
    - If any scaffold file contradicts what you observe in the codebase, trust the codebase. State the contradiction to me explicitly and await my approval before proceeding.
    - If a session is getting long and available context is less than 40%, pause the work and suggest /scaffold:checkpoint for completed work before continuing
    - If we made decisions, found bugs, discussed scope changes, or planned future work and I haven't said "checkpoint" — remind me before the session ends

---

## Step 3: Propose Restructured Content

For each file that needs changes, build the new content by mapping old → new:

**roadmap.md migration:**
- "Current phase" text → becomes the title of the `[IN-PROGRESS]` phase
- "Done" items → become `[x]` tasks in completed phases or Phase 1
  - If items suggest natural phase boundaries, group into separate phases
  - Otherwise, group all into "Phase 1 — [inferred title] [COMPLETE]"
- "In progress" items → become `[ ] >>` tasks in the `[IN-PROGRESS]` phase
- "Up next" items → become `[ ]` tasks in the `[IN-PROGRESS]` or next `[PLANNED]` phase
- "Later" items → move to `Backlog` (as `[ ]` checkbox items)
- Old `- v Item` → `- [x] Item`
- Old `- >> Item` → `- [ ] >> Item`

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
- Add "Working" section if missing (v2: execution behavior rules)
- Add/update Session Protocol table to v2 format (do/checkpoint/pause rows)
- Add/update Command Reference table to v2 format (status, plan, do, checkpoint,
  cleanup, update, graduate — remove prime, pause, resume, quick, quick-execute)
- Add Core Principle text if missing
- Add Key Documents section if missing, remove `.scaffold/quick/` if present
- Update existing tables to include new commands, remove old ones

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
