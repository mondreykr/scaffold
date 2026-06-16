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

**Step 3 — Confirm:**

Report what happened:
- Whether a legacy per-project install was found and removed
- That commands were updated at `~/.claude/commands/scaffold/`
- Remind: "Run `/scaffold:cleanup` if updating from an older version to migrate
  scaffold file formats."
