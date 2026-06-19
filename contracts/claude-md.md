---
schema_version: 1
---

# Contract — `CLAUDE.md` (user repo root)

**Purpose.** Orientation + how-to-work-here for a user's repo: the skill reference,
the core principle, a 3–5 line product orientation, a pointer into `.scaffold/`, and
project-specific hard constraints that no scaffold file owns.

**Band.** Living truth — but a Claude Code special file (auto-read), not a `.scaffold/`
artifact.

**Owner(s).** Created by `scaffold-setup`; updated rarely by `scaffold-plan` /
`scaffold-checkpoint`; migrated by `scaffold-cleanup`. Read by `scaffold-status`.

## Frontmatter

**Exception — no scaffold frontmatter.** `CLAUDE.md` is a Claude Code special file
with its own conventions; its identity is its filename/location. Adding scaffold schema
frontmatter would be surprising noise. This is the only doc type exempt.

## Required structure

```markdown
# <Project>

## Skill Reference
| Skill | Role |
|-------|------|
| `/scaffold-setup` | Initialize — scaffold the structure for a new project |
| `/scaffold-status` | Orient — read state, present options |
| `/scaffold-plan` | Consult + author — discuss direction, persist into the right docs |
| `/scaffold-go` | Execute — run the active phase brief |
| `/scaffold-checkpoint` | Save + reconcile — verify, update files, sweep, commit |
| `/scaffold-audit` | Audit — deep conformance + reality check (on demand) |
| `/scaffold-integrate` | Absorb — ingest an artifact (spec, research) into scaffold |
| `/scaffold-cleanup` | Migrate an existing project to this structure |
| `/scaffold-update` | Update scaffold skills to the latest version |

## Core Principle
Every skill leaves ALL state documents accurate and self-consistent.
Any skill could be the last thing that runs before a week-long gap.
Skills are optional tools — the minimum ceremony is status → work → checkpoint.

## About this project
[3–5 line product orientation + a pointer into `.scaffold/` so a cold read knows where
truth lives.]

## Hard constraints
[Project-specific constraints no scaffold file owns. Optional.]
```

## Rules

- **Boundary with `project.md`:** here = how to work + one-line "what this is";
  `project.md` = the full what/who/why/scope. No duplicated orientation.
- Everything about *how it's built* (stack, run/env) lives in `architecture.md`,
  referenced from here — never duplicated.
- Claude infers natural-language → skill mapping from the Skill Reference; no separate
  session-protocol table.

## Anti-patterns

- User-identity / personal calibration (belongs in `~/.claude/CLAUDE.md`).
- Tech stack / run instructions inline (belongs in `architecture.md`).
- A "Key Documents" list (`scaffold-status` surfaces these each session).
