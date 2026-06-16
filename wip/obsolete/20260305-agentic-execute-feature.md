# Research Prompt: Agentic Execution Patterns for Scaffold

**NOTE**: all of the content below was brainstormed by me and a claude instance outside the scope of this project. Take it with a grain of salt. It didn't have the details. Some things may not line up exactly. Use it at a brainstorm start point for you and me to think through.

---

## Research Target

Search GitHub for the open-source project **"get-shit-done" (GSD)** — likely at
`github.com/[owner]/get-shit-done` or similar. Read its README, command definitions,
and any workflow documentation you can find.

Specifically investigate:

1. **How does GSD spawn and manage research agents?**
   - What triggers a research agent vs. inline research?
   - How is the research agent scoped and constrained?
   - How does research output feed back into the main workflow?

2. **In-series vs. in-parallel execution**
   - Does GSD execute tasks sequentially or in parallel by default?
   - What's the decision logic for choosing one over the other?
   - How does it handle dependencies between parallel tasks?

3. **Context window management**
   - How does GSD handle the context window boundary between planning and execution?
   - Does it use `/clear` or equivalent? How is state preserved across that boundary?

4. **Agent scope guardrails**
   - How does GSD prevent agents from drifting beyond their assigned scope?
   - What are the stop/escalate conditions?

---

## Evaluation Frame

After researching GSD, evaluate its patterns against the scaffold
architecture by answering these specific questions:

**A. Research integration**
Where should research live in the scaffold lifecycle — as a tail step of `plan`,
as a standalone command, or as a subagent spawned by `execute`? What does GSD
suggest, and does that fit the constraint that `plan` must not overflow its
context window?

**B. Execute mode flag**
The current proposal is for the plan doc to carry a per-task `mode:` flag
(`sequential` vs `agent`). Is this consistent with how GSD approaches task
typing? Is there a better pattern?

**C. Verify-by as agent guardrail**
The scaffold uses `verify-by` criteria in the plan doc as the stop condition
for execute. Is this sufficient as an agent scope guardrail, or does GSD suggest
something more robust?

**D. Anything GSD does that would be a clear improvement**
Identify 1–3 specific patterns from GSD worth adopting, with a brief rationale
for each.

---

## Output Format

Produce a structured findings document with:

1. **GSD Summary** — what the project is and its core design philosophy (3–5 sentences)
2. **Pattern Findings** — answers to the four research questions above
3. **Evaluation** — answers to A, B, C, D against the scaffold architecture
4. **Recommended Changes** — concrete, specific proposed additions or modifications
   to the scaffold design (reference actual command names and document sections)
5. **Open Questions** — anything that needs a human decision before implementation

Keep findings grounded in what GSD actually does. Flag clearly when you are
extrapolating vs. directly observing a pattern.