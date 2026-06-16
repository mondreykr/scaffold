---
description: Graduate to a heavier framework — snapshot, archive, and hand off
argument-hint: [--thorough]
---

**Precondition:** Verify that all five scaffold files exist: CLAUDE.md,
`.scaffold/project.md`, `.scaffold/state.md`,
`.scaffold/roadmap.md`, `.scaffold/decisions.md`.
If any are missing, stop and report which files are absent.

The project is graduating from Scaffold to a more capable framework.
Your job is to consolidate everything into a clean handoff package and remove the
scaffold so it doesn't conflict.

**1. Read all scaffold files:**
- `.scaffold/project.md`
- `.scaffold/state.md`
- `.scaffold/roadmap.md`
- `.scaffold/decisions.md`
- CLAUDE.md
- Any plan files in `.scaffold/plans/`, investigation files in `.scaffold/investigations/`,
  and knowledge documents in `.scaffold/knowledge/`

**2. Create the snapshot:**
Create `.scaffold/snapshot/PROJECT-CONTEXT.md` — a single structured file that
consolidates everything worth carrying forward:

```
# Project Context (Scaffold Graduation Snapshot)

## Vision
[From .scaffold/project.md — what this is, who it's for, success criteria, scope]

## Current State
[From .scaffold/state.md — active focus, next, blockers, open questions]

## Roadmap
[From .scaffold/roadmap.md — all phases with their status and tasks]

## Decisions
[From .scaffold/decisions.md — all decisions with their context and reasoning]

## Knowledge Documents
[From .scaffold/knowledge/ — list each with title and one-line description.
These are controlling documents (specs, architecture docs) that contain
detailed requirements and design direction for the project.]

## Tech Stack
[From CLAUDE.md]

## Hard Constraints
[From CLAUDE.md]
```

**3. Archive the scaffold:**
- Move `.scaffold/project.md`, `.scaffold/state.md`,
  `.scaffold/roadmap.md`, `.scaffold/decisions.md`
  to `.scaffold/archive/`
- Move `.scaffold/plans/`, `.scaffold/investigations/`, and `.scaffold/knowledge/` to `.scaffold/archive/` (if they exist)
- Move all scaffold commands (setup.md, status.md, plan.md, scope.md, do.md,
  checkpoint.md, cleanup.md, update.md, graduate.md) from
  `.claude/commands/scaffold/` to `.scaffold/archive/scaffold/`

**4. Verify the archive:**
Before modifying CLAUDE.md, confirm all expected files landed in their archive
locations:
- `.scaffold/archive/project.md`
- `.scaffold/archive/state.md`
- `.scaffold/archive/roadmap.md`
- `.scaffold/archive/decisions.md`
- `.scaffold/archive/scaffold/setup.md`
- `.scaffold/archive/scaffold/status.md`
- `.scaffold/archive/scaffold/plan.md`
- `.scaffold/archive/scaffold/scope.md`
- `.scaffold/archive/scaffold/do.md`
- `.scaffold/archive/scaffold/checkpoint.md`
- `.scaffold/archive/scaffold/cleanup.md`
- `.scaffold/archive/scaffold/update.md`
- `.scaffold/archive/scaffold/graduate.md`

If anything is missing, stop and report what failed to move.

**5. Update CLAUDE.md:**
- Remove scaffold-specific sections (`## Command Reference`, `## Core Principle`)
- Keep `## Hard constraints` and `## Tech stack`
- If the project has any custom sections beyond the lean template (added during
  setup or cleanup), preserve them as-is
- Add a pointer: "Previous scaffold context is at `.scaffold/snapshot/PROJECT-CONTEXT.md`"

**6. Commit:**
`git add -A && git commit -m "graduate: scaffold -> [new framework]"`

**7. Tell me:**
- What was consolidated into the snapshot
- What was archived
- "Point your new framework at `.scaffold/snapshot/PROJECT-CONTEXT.md` for
  full project context."

**Enhanced mode (`/scaffold:graduate --thorough`):**

If "--thorough" appears in the arguments, before running the standard graduation,
launch an Explore subagent (thoroughness: "very thorough") to find all
references to scaffold files across the codebase:

1. Search for string references to scaffold file paths (`.scaffold/state.md`,
   `.scaffold/roadmap.md`, `.scaffold/plans/`, `.scaffold/investigations/`, etc.) in all project files
2. Check README.md and any documentation for mentions of scaffold files
3. Check CI/CD config files for scaffold-related steps
4. Check any scripts that reference scaffold paths

Report findings: "Found N references to scaffold files that will break after
graduation:" followed by file:line for each.

Wait for the user to resolve flagged references before proceeding with
standard graduation. If there are no references, proceed immediately.

If the subagent fails or times out, warn the user and ask whether to
proceed with standard graduation anyway.
