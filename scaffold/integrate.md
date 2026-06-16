---
description: Absorb artifacts into scaffold and reconcile content
argument-hint: [path/to/artifact | --sync]
---

**Precondition:** Verify that all five scaffold files exist: CLAUDE.md,
`.scaffold/project.md`, `.scaffold/state.md`, `.scaffold/roadmap.md`,
`.scaffold/decisions.md`. If any are missing, stop and say:
"Scaffold files missing — run /scaffold:setup first."

**Boundary:** This command updates scaffold files only. It does NOT modify
project files, execute work, or write plan docs. It MAY copy an external
artifact into `.scaffold/knowledge/`.

---

## Determine Mode

Check arguments:

- **Path provided** (e.g., `/scaffold:integrate docs/spec/SPEC.md`):
  → **Absorb mode.** Go to Step 1.
- **`--sync` provided** (e.g., `/scaffold:integrate --sync`):
  → **Sync mode.** Go to Step 6.
- **No arguments:**
  → **Scan mode.** Go to Step 0.

---

## Step 0: Scan for Un-integrated Artifacts (scan mode only)

Look for artifacts that may need integration:

1. Scan `.scaffold/investigations/` for substantial research findings
2. Scan `.scaffold/knowledge/` for docs that may have been placed manually
3. Check conversation context for recently completed specs, architecture
   docs, or other major artifacts

If candidates found, present them:

> "Found artifacts that may need integration:
> - [path] — [one-line description]
>
> Integrate one of these, provide a different path, or `--sync` to
> reconcile existing files."

Wait for user response. If they choose an artifact, proceed to Step 1
with that path. If they say `--sync` or "just sync," go to Step 6.
If nothing found:

> "No un-integrated artifacts found. Run with `--sync` to reconcile
> existing scaffold files, or provide a path to an artifact."

---

## Step 1: Load Everything Into Memory (absorb mode)

**This step is non-negotiable. Read ALL of these files before proceeding.**

Read in this order:
1. `.scaffold/project.md` — current vision, scope, requirements
2. `.scaffold/decisions.md` — all decisions
3. `.scaffold/roadmap.md` — phases, deliverables, criteria
4. `.scaffold/state.md` — active focus and open threads
5. `CLAUDE.md` — constraints, tech stack, rules
6. All files in `.scaffold/knowledge/` — existing knowledge documents
7. The new artifact (the path provided by the user)

**If the artifact path doesn't exist:** Stop and report. Don't guess at
alternative paths.

**If `.scaffold/knowledge/` doesn't exist:** That's fine — create it in Step 3.

---

## Step 2: Analyze the Artifact

Identify what the artifact contains. Not all artifacts have all of these —
extract what's present:

- **Requirements** — verifiable product rules, constraints, "must" statements
- **Decisions** — choices with rationale and rejected alternatives
- **Scope boundaries** — what is explicitly out of scope or excluded
- **Hard constraints** — non-negotiable rules that apply to every session
- **Vision/problem refinements** — updated understanding of what's being
  built and why
- **Design direction** — visual design, interaction models, data models,
  architecture patterns (these stay in the knowledge doc, not extracted)
- **Implementation notes** — tech recommendations, library choices

Summarize what you found:

> "This artifact contains:
> - [N] requirements (verifiable product rules)
> - [N] decisions (choices with rationale)
> - [N] scope boundary changes
> - [N] hard constraints
> - Detailed [flows/design/architecture] (will stay in knowledge doc)
>
> Proceeding with integration."

---

## Step 3: Store the Artifact

Create `.scaffold/knowledge/` if it doesn't exist.

Copy the artifact to `.scaffold/knowledge/YYYYMMDD-slug.md` where:
- `YYYYMMDD` is today's date (without dashes)
- `slug` is a brief descriptor derived from the artifact's title or content

If a knowledge doc with the same slug already exists, ask:

> "A knowledge doc `[filename]` already exists. Replace it, or save as
> `[new-filename]`?"

---

## Step 4: Identify Conflicts

Compare the artifact's content against existing scaffold files. For each
piece of extracted information, classify as:

- **New** — not present in scaffold files. Will be added.
- **Consistent** — already in scaffold files and matches. No action needed.
- **Conflict** — present in scaffold files but contradicts the artifact.
  Requires resolution.
- **Superseded** — an existing scaffold entry that the artifact explicitly
  replaces or reverses.

**Present ALL conflicts before resolving any of them:**

> "## Conflicts Found
>
> **Requirements:**
> - Artifact says: [X]. project.md says: [Y].
>   → Recommend: update project.md to match artifact (artifact is newer)
>
> **Decisions:**
> - Artifact Decision #N reverses decisions.md entry [date — title].
>   → Recommend: prune the old entry (git keeps it), add new decision
>
> **Constraints:**
> - Artifact adds constraint: [X]. CLAUDE.md doesn't have it.
>   → Recommend: add to Hard constraints
>
> **Scope:**
> - Artifact excludes [X]. project.md scope boundaries don't mention it.
>   → Recommend: add to scope boundaries
>
> Approve all, or tell me which to adjust."

**STOP. Wait for user confirmation.**

If the user wants to override a recommendation, respect that and note why.
If there are no conflicts: "No conflicts — all new content. Proceeding."

---

## Step 5: Update Scaffold Files

Apply all approved changes in one pass. Update each file completely before
moving to the next.

### 5a. `.scaffold/project.md`

- **Vision** — update "What is this?" if the artifact refines it.
  Don't overwrite wholesale — merge the refinement.
- **Scope boundaries** — add new exclusions from the artifact.
  Remove scope boundaries that the artifact explicitly reverses.
- **Requirements** — add new requirements as `- [ ]` checkboxes with
  the exact wording from the artifact. Update existing requirements if
  the artifact refines them (update the text, don't duplicate).
  Mark requirements as `[x]` only if the artifact confirms they're met.

### 5b. `.scaffold/decisions.md`

- Add ALL new decisions from the artifact, in scaffold format:
  ```
  ### YYYY-MM-DD — [What was decided]
  **Category:** [Tech | Architecture | Design | Scope | Resolved Blocker]
  **Context:** [What prompted this choice]
  **Decision:** [What was chosen]
  **Why:** [The reasoning, including any tempting alternative that was rejected]
  ```
  Only decisions that clear the logging bar (a future reader could reverse
  and regret) — skip the self-evident.
- Add decisions at the TOP (newest first).
- For each decision: include context, choice, reasoning, and the rejected
  alternative. Do NOT condense to one-liners — preserve the full rationale.
- For reversed decisions: prune the old entry (git keeps the history); add the
  new one. There is no `Status` field and no `## Archived` section. (No git?
  Replace the old entry with a one-line "superseded by [artifact name], [date]"
  note instead of deleting.)
- Do NOT duplicate decisions that already exist in decisions.md with
  matching content. If the artifact has a richer version of an existing
  decision, update the existing entry.

### 5c. `CLAUDE.md`

- **Hard constraints** — add constraints from the artifact that apply to
  every session (e.g., "No cloud, no installation", "Desktop only",
  "Works in all browsers"). These are non-negotiable rules, not design
  preferences.
- **Tech stack** — update if the artifact specifies technology choices.
- Do NOT add design preferences or implementation details to CLAUDE.md.
  Only hard constraints and tech stack.

### 5d. `.scaffold/roadmap.md`

- If the artifact implies phase structure changes, propose them (but don't
  silently change phases).
- If the artifact corresponds to a completed phase, verify that phase
  is marked appropriately.

### 5e. `.scaffold/state.md`

- Update Active focus if the integration changes project context.
  **ELI5 — explain it like the reader is five.** Plain words, short
  sentences, no jargon shortcuts, no status-report officialese. If a
  five-year-old wouldn't follow the gist, rewrite it.
- Clear stale Open Questions that the artifact resolved (remove the line;
  the resolution lives in the artifact and decisions.md).
- Add Open Questions from the artifact if any remain unresolved.

Update `<!-- Last updated -->` dates on ALL modified files.

---

## Step 6: Sync Mode (--sync, no new artifact)

**This mode reconciles existing scaffold files without new input.**

### 6a. Load Everything

Read ALL scaffold files + ALL knowledge docs + CLAUDE.md. Same as Step 1
but without a new artifact.

### 6b. Cross-File Consistency Check

Check for and report:

- **Decision drift** — decisions.md entries that contradict project.md
  requirements or CLAUDE.md constraints
- **Stale requirements** — project.md requirements that no longer match
  what knowledge docs or decisions specify
- **Orphaned scope boundaries** — project.md says "not X" but roadmap
  includes X, or vice versa
- **Missing decisions** — knowledge docs reference decisions not in
  decisions.md
- **Stale state** — state.md references phases, plans, or blockers that
  no longer exist
- **Constraint gaps** — knowledge docs establish constraints not reflected
  in CLAUDE.md
- **Duplication** — the same decision or requirement appears in multiple
  places with different wording
- **Staleness** — any file with `<!-- Last updated -->` older than 14 days

### 6c. Present Findings

> "## Sync Report
>
> **Inconsistencies:** [N] found
> [list each with current state and proposed fix]
>
> **Stale content:** [N] items
> [list each with what's stale and proposed update]
>
> **Gaps:** [N] found
> [list each with what's missing and where]
>
> **Duplicates:** [N] found
> [list each with locations and proposed consolidation]
>
> Approve all, or tell me which to adjust."

If everything is clean: "All scaffold files are consistent. No changes needed."

**STOP. Wait for user confirmation.**

### 6d. Apply Fixes

Apply all approved changes. Same update rules as Step 5 — one pass,
all files, preserve full rationale.

---

## Step 7: Review and Commit

Show a summary of all changes:

> "## Integration Summary
>
> **Knowledge doc:** [filename] (new/updated/none)
> **project.md:** [N requirements added/updated, N scope changes]
> **decisions.md:** [N decisions added, N reversed, N updated]
> **CLAUDE.md:** [N constraints added/updated]
> **state.md:** [changes if any]
> **roadmap.md:** [changes if any]"

Run `git diff .scaffold/ CLAUDE.md` to show exact changes.

**STOP. Wait for user confirmation before committing.**

If git is initialized:
`git add CLAUDE.md .scaffold/ && git commit -m "integrate: [brief description]"`

---

## Principles

**Nothing lost.** The full artifact lives in `.scaffold/knowledge/`. The
extraction into scaffold files is the operational summary. Both are needed.

**Thorough extraction.** Decisions get full scaffold-format entries with
context, choice, reasoning, and alternatives. Requirements get exact
wording. Don't condense or summarize — preserve the detail.

**Conflicts are explicit.** Never silently resolve a contradiction. Present
both sides, recommend a resolution, and wait for the user.

**Additive by default, corrective when needed.** New content is added.
Conflicting content is flagged. Reversed decisions are pruned (git is the history), not flagged-and-kept.

**The artifact is authoritative for what it covers.** If a completed spec
says "manual load/save" and project.md says "auto-saves between sessions,"
the spec wins — but the user confirms the resolution.

---

## Boundaries

Integrate does NOT:
- **Execute work** — it updates scaffold files, not project files
- **Write plan docs** — that is /scaffold:scope
- **Make strategic decisions** — it extracts and reconciles, user decides
- **Delete knowledge docs** — knowledge docs accumulate as project history
- **Modify the source artifact** — the original in docs/ (or wherever)
  is never touched
