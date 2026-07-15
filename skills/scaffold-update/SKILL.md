---
name: scaffold-update
description: Update the scaffold skills to the latest version and clean up legacy installs — pull the current /scaffold-[skill] skills, remove stale command-era installs that would shadow them, and flag an old .scaffold/ layout that needs migrating. Touches no .scaffold/ project content. Use whenever the user wants to update, upgrade, or refresh scaffold itself (the skills), or pull the latest version — even if they only say "update scaffold" or "get the latest scaffold".
---

# scaffold-update

Pull the latest scaffold **skills** and tidy up after older installs. This touches only
the installed skills under `~/.claude/skills/` — project data in `.scaffold/` and
`CLAUDE.md` is never modified.

**Boundary.** Updates the installed skill files only. It does not read, migrate, or write
any `.scaffold/` content (that's `cleanup`/`checkpoint`); it does not touch project code.

---

## Step 1: Pull the latest skills

Scaffold ships as skills, each a folder `scaffold-<skill>/SKILL.md` installed at
`~/.claude/skills/`. Pull the current set:

```bash
npx degit mondreykr/scaffold/skills $HOME/.claude/skills --force
```

This overwrites the `scaffold-*` skill folders in place and leaves any unrelated skills in
`~/.claude/skills/` untouched. After the pull, confirm all nine `scaffold-*/SKILL.md`
landed (setup, status, plan, go, checkpoint, audit, integrate, cleanup, update); if any is
missing the copy was truncated — re-run the command.

## Step 2: Retire command-era installs

Scaffold used to ship as **commands**, not skills. A leftover command install will shadow
or duplicate the skills — find and offer to remove it:

- **User-level commands** at `~/.claude/commands/scaffold/` — the old global install.
  Offer to delete: "Found command-era scaffold at `~/.claude/commands/scaffold/`. Scaffold
  is skills now; these are stale and can shadow the new `/scaffold-[skill]` skills. Remove
  them?"
- **Per-project commands** at `.claude/commands/scaffold/` (in the project dir, not home)
  — a legacy per-project install. Same offer; if its parent `.claude/commands/` is then
  empty, remove that too.

If the user declines, warn that stale command files may shadow the skills.

## Step 3: Detect an old `.scaffold/` layout + direct to cleanup

New skills against an **old layout** is the most dangerous window — the skills expect the
current structure and will misread a pre-restructure one. Check the project for markers.

**Pre-restructure layout** (the milestone migration): a single `.scaffold/decisions.md`
(file, not a `decisions/` folder), a `.scaffold/plans/` directory, a per-phase build plan
inside `roadmap.md`, a missing `.scaffold/architecture.md`, or `.scaffold/` docs lacking
`type`/`schema_version` frontmatter.

**Pre-rename layout (`schema_version: 1`)** — the brief→plan / plan.md→milestone.md rename.
Markers, any one of which means the repo predates it and every current skill will misread
it: any `.scaffold/` doc carrying **`schema_version: 1`**, a frontmatter **`type:
milestone-plan`** or **`type: phase-brief`**, or a milestone folder holding a **`plan.md`**
(the current name is `milestone.md`). Without this check, `update` would report a v1 repo
as "already current" — the exact silent misread this step exists to prevent.

If any marker (either layout) is present, emit a hard directive (do not soften):
> "⚠ This project is on an OLD scaffold layout, but the skills were just updated. Run
> /scaffold-cleanup NOW — before any other scaffold skill (status / plan / go /
> checkpoint). They expect the current layout and will misread the old one."

If the layout is already current, no migration is needed.

## Step 4: Report

State what happened: whether a command-era install was found and removed; that the skills
were updated at `~/.claude/skills/`; and the old-layout directive above, if it applied.

## Boundaries

Update does NOT: read, migrate, or write any `.scaffold/` content (that's
`cleanup`/`checkpoint`); modify project code; or migrate an old layout itself (it detects
and routes to `/scaffold-cleanup`).
