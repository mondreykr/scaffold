---
description: Update scaffold commands to latest version
---

I'm updating the scaffold commands to the latest version.

**Step 1 — Check for legacy per-project install:**

Look for `.claude/commands/scaffold/` in the current project directory (NOT the
home directory). If it exists, this is a legacy per-project install from before
commands moved to user-level.

- Tell the user: "Found per-project scaffold commands at `.claude/commands/scaffold/`.
  These are no longer needed — scaffold commands now live at `~/.claude/commands/scaffold/`
  (user-level, shared across all projects). Want me to delete the per-project copy?"
- If user approves, delete `.claude/commands/scaffold/` from the project
- If the `.claude/commands/` directory is now empty, delete it too
- If user declines, warn that per-project commands may shadow the global ones

**Step 2 — Pull latest commands:**

Run:
```bash
npx degit mondreykr/scaffold/scaffold $HOME/.claude/commands/scaffold --force
```

This overwrites only the command files at the user level. Project data in
`.scaffold/` and `CLAUDE.md` is never touched.

**Step 3 — Detect old layout + confirm:**

The current project may now have NEW commands against an OLD layout — the most
dangerous window in the whole rollout. Check the project for pre-restructure
markers: a single `.scaffold/decisions.md` (file, not a `decisions/` folder), a
`.scaffold/plans/` directory, a per-phase build plan inside `roadmap.md`, or a
missing `.scaffold/architecture.md`.

- **If any marker is present**, emit a hard directive (do not soften it):
  > "⚠ This project is on the OLD scaffold layout, but the commands were just
  > updated. Run `/scaffold:cleanup` NOW — before any other scaffold command
  > (`status` / `plan` / `go` / `checkpoint`). They expect the new layout and
  > will misread the old one."
- If the layout is already current, no migration is needed.

Report what happened:
- Whether a legacy per-project install was found and removed
- That commands were updated at `~/.claude/commands/scaffold/`
- The old-layout directive above, if it applied
