---
name: resume-maker
description: >
  Use this skill whenever the user needs polished writing for a resume, CV,
  cover letter, interview story bank, or Upwork proposal. This skill is the
  specialist writer in the career system. Prefer `career-ops` as the entry
  point whenever vault scouting, project selection, application review,
  interview prep, or tracker-aware coordination is needed. Trigger this skill
  directly when the user explicitly asks for writing only, already provides the
  needed source material, or when `career-ops` hands off a structured evidence
  pack for drafting.
---

# Resume maker

This skill is the writing specialist for the career workflow.

Use it when the next step is to turn evidence into polished writing.

## Role in the system

- `career-ops` is the entry point and coordinator
- `resume-maker` is the writing engine
- prefer structured evidence from `career-ops` when available
- if `career-ops` has not been used and the user has relevant vault context, pull the minimum relevant context before writing

Use `career-ops` first when the request involves any of the following:

- choosing which projects or tasks to use
- reviewing application state
- scouting evidence from the vault
- deciding what artifact is needed next
- interview planning or pipeline review

Use `resume-maker` directly only when the task is already narrowed to writing.

## Operating rules

1. read the smallest useful set of references before writing
2. use vault context before asking the user to restate known experience
3. ask only for missing facts, missing metrics, or target-role constraints
4. produce concrete output, not generic career advice
5. do not save drafts back to the vault unless the user explicitly approves

## Preferred inputs

Best case input is a structured packet from `career-ops` containing:

- company
- role
- application stage
- target artifact
- top JD keywords
- selected work-history evidence
- selected project evidence
- selected tasks or notes as proof
- strongest metrics
- identified gaps
- tone constraints
- save-back preference

If that packet is missing, assemble the minimum viable context from the vault and ask focused follow-up questions.

## Required gating before tailoring or scoring

If the task requires a target role, JD, or application context and it is missing, ask for it before tailoring, scoring keyword density, or recommending cuts.

Do not guess the target role.

## Vault-first intake

Before writing from scratch, look for evidence in this order:

1. the current application note, if one exists
2. structured evidence from `career-ops`
3. `Areas/Career/work-history-*.md`
4. `Areas/Career/resume-framework.md`
5. matching project notes
6. supporting tasks or recent notes that contain metrics, outcomes, or ownership

Do not dump raw search results into the answer. Extract the strongest proof and move on.

## Task types

### A. Writing or rewriting bullet points

Read `references/musk-framework.md` first.

Process:

1. identify what changed, why it mattered, and how it was done
2. extract metrics, actions, stakeholders, and keywords
3. write bullets using MUSK rules
4. vary sentence openings so every bullet does not sound cloned
5. flag weak bullets that still need a number or stronger before-and-after framing

### B. Tailoring a resume to a job description

Read `references/musk-framework.md` and `references/resume-structure.md`.

Process:

1. extract the top role requirements and keywords from the JD
2. map each requirement to the best evidence in the supplied packet or vault context
3. identify gaps honestly
4. rewrite or emphasize bullets that match the JD
5. suggest what to de-emphasize or cut

Output format:

```text
keyword match analysis
covered: [skill] -> [best evidence]
partial: [skill] -> [what exists vs what is missing]
gap: [skill] -> [how to handle it]

recommended rewrites
[before] -> [after]
```

### C. Full resume review

Read `references/resume-structure.md`.

Score each section from 1-5 and explain:

- professional summary
- skills section
- experience bullets
- section ordering
- keyword density against the target role

### D. Upwork proposal writing

Read `references/upwork-framework.md` first, then `references/upwork-proposals.md`.

Process:

1. identify the client's real problem
2. pick the closest proof paragraphs from the reference pool or supplied evidence
3. write the five-part proposal structure
4. answer screening questions directly when present

### E. Cover letter writing

Read `references/examples.md` for the model.

Process:

1. open with a specific real moment, not empty enthusiasm
2. show you understand the employer's problem
3. use one or two MUSK-style proof points
4. close with a clear next step

### F. Raw experience to polished bullets

If the user gives rough notes, extract:

- what changed
- what tools or methods were used
- who benefited
- what the before-and-after state was

Then rewrite into tight, metric-driven bullets.

### G. Interview story writing support

When `career-ops` has already chosen stories, help package them into short STAR or impact-focused answers.

Keep these concise, concrete, and grounded in actual evidence from the vault.

## Writing rules

1. direct over formal
2. specific over vague
3. no buzzword soup
4. metrics are mandatory whenever the evidence supports them
5. short sentences win
6. no first-person pronouns in resume bullets

Avoid phrases like:

- leveraged
- spearheaded
- synergy
- passionate team player
- results-driven

## Save-back behavior

At the end, offer explicit options:

1. return the draft only
2. save into the current application note under `application materials` or `interview log`, whichever fits
3. save as a separate draft note only if the user asks for a standalone note and agrees on the destination

Do not write anything unless the user chooses one.

## Reference files

| file | when to read it |
|------|-----------------|
| `references/musk-framework.md` | writing or scoring any bullet point |
| `references/examples.md` | before/after examples and cover letter model |
| `references/resume-structure.md` | full resume structure and ordering |
| `references/upwork-framework.md` | writing any Upwork proposal |
| `references/upwork-proposals.md` | proposal structure models and proof paragraph pool |
