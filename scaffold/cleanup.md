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
   `YYYYMMDD-slug.md` convention (date without dashes, brief slug)
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
- Hold the content for Step 3's state.md migration — the resume context
  becomes part of the rebuilt Active focus paragraph there. Then delete the file.
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

**state.md — check for v1 sections:**
- Old sections: "What's not working", "What's working well", "Parking lot",
  "Next session"

**state.md — check for v2 sections (current target is v3):**
- `## Status` field (any value) — v3 removes the status enum entirely;
  routing is content-derived.
- `## Current Position` — v3 renames to `## Active focus`.
- `## Next Action` — v3 renames to `## Next`.
- `## Session Context` (with sub-fields Progress / Key context / Next step) —
  v3 removes this section; fold its content into Active focus when migrating.
- `## Closed` — v3 removes retrospective archives; route resolved items to
  decisions.md / roadmap.md and delete the section.
- Project-specific extra sections beyond Active focus / Next / Blockers /
  Open Questions — v3 removes these; route content to its natural home or
  drop with user approval.

**state.md — check for empty Blockers / Open Questions:**
- v3 always has both sections present; "None." when empty (do not omit the
  section heading).

**decisions.md — check for:**
- Old category-grouped format (## Tech, ## Architecture, etc. as organizing headers)
  - Should be flat chronological with `**Category:**` field per entry

**CLAUDE.md — check for:**

The current lean template contains only: Title, Command Reference, Core Principle,
Hard constraints, Tech stack. Anything else is either deprecated or custom user
content that needs explicit user routing.

*Deprecated sections to remove (do not silently strip — see Step 3 for handling):*
- `## Who I am` — user-level concern; belongs in `~/.claude/CLAUDE.md` if anywhere
- `## Rules` — per-user preferences and scaffold operating rules that Claude defaults
  + slash command logic now cover
- `## Working` — `/scaffold:status` reads the plan doc; `/scaffold:do` enforces scope;
  freeform scope discipline is per-user preference
- `### Session Protocol` (or `## Session Protocol`) — Claude infers natural-language
  → command mapping from command descriptions; the explicit table is over-instruction
- `### Key Documents` — `/scaffold:status` surfaces these

*Structural fixes:*
- If `### Command Reference` and `### Core Principle` exist as `###` subsections
  nested under `## Working`, promote both to top-level `##` headers after Working
  is removed

*Content fixes within Command Reference:*
- Old command references: `/scaffold:prime`, `/scaffold:pause`, `/scaffold:resume`,
  `/scaffold:quick`, `/scaffold:quick-execute`, `/scaffold:verify` — all removed;
  drop the corresponding rows
- Missing `/scaffold:integrate` row — add:
  `| /scaffold:integrate | Absorb — ingest artifacts (specs, research) into scaffold |`
- Verify the full row set matches the current template: status, plan, scope, do,
  checkpoint, integrate, cleanup, update, graduate

*Content fixes within Core Principle (if present in old form):*
- v2 Core Principle should say "Commands are optional tools" not "Plan updates
  scaffold files directly" — update the wording if outdated

*Stale path references anywhere in CLAUDE.md:*
- `.scaffold/quick/` — remove
- `docs/` pointers to scaffold-owned content — scaffold's home for specs/design docs
  is `.scaffold/knowledge/`, not `docs/`. If the project keeps a top-level `docs/`,
  that's the project's call; only flag references that look like scaffold-owned
  files living outside scaffold.

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

Target shape (v3, four sections, forward-looking only):

```markdown
<!-- Last updated: YYYY-MM-DD -->
# State

## Active focus
[One paragraph. Plain-language synopsis + forward-look.]

## Next
[Concrete action when resuming. 1-2 sentences or short bullets.]

## Blockers
[Always present. "None." when empty.]

## Open Questions
[Always present. "None." when empty.]
```

Migration steps:

1. **Drop the `## Status` field entirely.** v3 derives routing from content.
2. **Rename `## Current Position` → `## Active focus`.** Trim to one paragraph
   if it has bullets, sub-headings, or code blocks. Keep the synopsis;
   drop retrospective journaling.
3. **Rename `## Next Action` → `## Next`.** Trim prose to a concrete action;
   drop embedded prompts, narrative paragraphs.
4. **Fold `## Session Context` into Active focus.** The Progress / Key
   context / Next step content gets absorbed into the Active focus
   paragraph (or its sub-bullets into Next, where appropriate). Then
   delete the Session Context section.
5. **Delete any `## Closed` section.** Route the items inside it to their
   natural home: resolved blockers → decisions.md (Category: Resolved
   Blocker); answered questions → wherever the answer was captured (often
   decisions.md or knowledge docs); completed work → roadmap.md.
6. **Delete project-specific extra sections** (e.g., calendars, schedules).
   Route content to its natural home — roadmap, plan doc, or knowledge
   doc — or surface in Active focus if genuinely status-level.
7. **Ensure Blockers and Open Questions are present.** Add "None." if empty.

Legacy v1 sections:
- "What's not working" → Blockers (with current-state content; resolved items dropped)
- "What's working well" → Drop (preferences route to CLAUDE.md)
- "Parking lot" / "Future Ideas" → move to roadmap.md Backlog
- "Next session" → Next (rewrite as concrete resume action)

**decisions.md migration:**
- Extract entries from category sections (## Tech, ## Architecture, ## Design, ## Scope)
- Add `**Category:** [section name]` field to each entry
- Flatten into single chronological list, newest first (sort by date in ### header)
- Drop the `**Status:**` field from every entry — v3 has no status enum
- Dissolve any `## Archived` section: prune reversed/superseded entries (git
  keeps the history). If the project has no git, fold each archived entry back
  inline as a one-line "superseded by …" note rather than keeping a graveyard.

**CLAUDE.md migration:**

Target shape (lean template, 5 sections only):
1. Title + one-line description
2. `## Command Reference` (top-level)
3. `## Core Principle` (top-level)
4. `## Hard constraints` (project-specific)
5. `## Tech stack` (project-specific)

Migration steps:

1. **Promote nested subsections.** If `### Command Reference` and `### Core Principle`
   exist as children of `## Working`, lift them to top-level `##`.

2. **Identify deprecated sections.** For each of `## Who I am`, `## Rules`, `## Working`
   (body bullets, not the subsections you already promoted), `### Session Protocol`
   (or `## Session Protocol`), `### Key Documents`:
   - If section is empty or matches the old template defaults verbatim, mark for silent removal.
   - If section contains custom user content (anything beyond the boilerplate), do NOT
     silently drop it. Present each one to the user in Step 4 with three options:
     (a) drop, (b) move to `~/.claude/CLAUDE.md`, (c) keep in this CLAUDE.md as a
     custom section below Tech stack.

3. **Fix the surviving Command Reference table:**
   - Drop rows referencing removed commands (`prime`, `pause`, `resume`, `quick`,
     `quick-execute`, `verify`)
   - Add the `/scaffold:integrate` row if absent
   - Verify the full row set matches: status, plan, scope, do, checkpoint, integrate,
     cleanup, update, graduate

4. **Fix the surviving Core Principle:**
   - If outdated wording ("Plan updates scaffold files directly" or similar), update
     to: "Every command leaves ALL state documents accurate and self-consistent. Any
     command could be the last thing that runs before a week-long gap. Commands are
     optional tools — the minimum ceremony is status → work → checkpoint."

5. **Hard constraints and Tech stack:** preserve as-is (project-specific content).

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
`git add CLAUDE.md .scaffold/ && git commit -m "scaffold: migrate to current format"`

Show a summary of what was migrated.
