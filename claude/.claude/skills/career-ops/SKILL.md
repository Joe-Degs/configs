---
name: career-ops
description: >
  Use this skill whenever the user needs end-to-end help with job applications,
  career materials, interview prep, application review, or tracker-driven career
  operations. This includes reviewing the application tracker, scouting matching
  work history and project evidence from the vault, choosing which projects and
  tasks best support a role, identifying missing materials, preparing interview
  briefs, reviewing application pipeline next steps, and coordinating writing
  work through resume-maker. Treat this as the preferred entry point for
  application-stage work. Trigger this skill when the user says things like
  "help me apply", "review my applications", "prep me for this interview",
  "which projects match this role", "what should I use from my vault", or asks
  for end-to-end application support.
---

# Career ops

This skill is the entry point and coordinator for the career application system.

`career-ops` decides what needs to happen next, gathers evidence from the vault, and hands writing work to `resume-maker` when appropriate.

## Core role

- inspect the current application ecosystem before asking the user to restate known facts
- scout the best supporting evidence from the vault
- decide the next useful artifact or action based on the application stage
- coordinate with `resume-maker` when polished writing is needed
- keep save-back explicit and opt-in

## Trigger boundary

Use `career-ops` by default for application-stage work, especially when the task includes any of these:

- vault scouting
- project selection
- task selection
- tracker review
- application review
- interview prep
- deciding what should be written next

Hand off to `resume-maker` only after the evidence and target artifact are clear.

## Primary sources

Read from these sources in priority order. See `references/source-priority.md`.

- `Areas/Career/Applications/*.md`
- `Areas/Career/Applications/_tracker.md`
- `Areas/Career/work-history-*.md`
- `Areas/Career/resume-framework.md`
- project notes under `Areas/Projects/**`
- relevant tasks and notes in `Inbox/*.md`
- supporting notes in `ScratchPad/**` and other relevant vault areas

## Required workflow

### 1. classify the request

Determine whether this is primarily:

- new application planning
- role-fit scouting
- artifact planning
- interview prep
- application review
- pipeline review
- post-interview review

If the request is only polished writing and the user already supplied the necessary evidence, `resume-maker` can be used directly.

### 2. scout context first

Use the `vault-context` subagent for the initial search to keep main context clean.

Then load only the most relevant files.

Do not paste giant raw note dumps. Build a ranked shortlist.

### 3. build the evidence shortlist

Extract and rank evidence by:

- JD relevance
- measurable impact
- recency
- ownership depth
- interview usefulness

Include:

- best matching work-history items
- best matching projects
- supporting tasks or notes
- strongest metrics
- obvious gaps or weak spots

For each shortlisted item, keep enough source detail to trace where the claim came from.

### 4. choose the next action

Use application stage and user intent to decide what to do next.

If the task depends on a JD, target role, or interview context and it is missing, ask for it before doing fit analysis, tailoring, or prep.

Examples:

- `saved` -> fit check, evidence gathering, artifact planning
- `applied` -> follow-up planning and interview prep
- `screening` -> story selection and likely question prep
- `interviewing` -> interview brief, story bank, targeted follow-ups
- `offer` -> decision support and negotiation prep
- `rejected` -> capture lessons and feedback

### 5. hand off writing work when needed

If the next step is a writing artifact, prepare a structured evidence pack using `references/evidence-pack-schema.md` and invoke `resume-maker`.

The handoff should be explicit. State what artifact is needed and what evidence was selected.

### 6. offer save-back options

Read from the vault by default.

At the end, offer save-back options such as:

- save nothing
- append to the current application note
- save a separate interview prep or review note
- update the application materials or interview log section

Do not save anything unless the user chooses one.

## Standard outputs

Depending on the request, `career-ops` should produce some or all of:

- fit summary
- keyword map
- evidence shortlist
- strongest projects and tasks to cite
- gap analysis
- recommended next artifact
- interview brief
- story bank
- pipeline next actions

## Coordination rules

1. `career-ops` owns evidence selection
2. `resume-maker` owns polished writing
3. keep answers ranked and concise
4. ask focused follow-up questions only when evidence is incomplete
5. prefer using what already exists in the vault over asking the user to rewrite their work from memory
6. prefer saving into the current application note unless the user explicitly wants a separate note

## References

| file | purpose |
|------|---------|
| `references/source-priority.md` | search order and evidence ranking rules |
| `references/evidence-pack-schema.md` | handoff format for resume-maker |
| `references/workflows.md` | stage-aware workflows and save-back choices |
