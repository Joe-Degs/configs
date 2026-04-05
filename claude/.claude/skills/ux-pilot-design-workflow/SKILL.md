---
name: ux-pilot-design-workflow
description: Use when designing UI in UX Pilot before implementation. Generates structured prompt packs for components, screens, and flows, plus UX Pilot-specific edit prompts and anti-drift guidance.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# UX Pilot design workflow

## Overview

Use this skill before implementing meaningful UI when the design should be explored in UX Pilot first.

This skill exists because UX Pilot works best when prompts are explicit, scoped, and iterative. Do not treat it like a slot machine. Treat it like a design assistant that needs strong constraints.

Always return a prompt pack, not a single prompt, unless the user explicitly asks for only one prompt.

## When to use

Use this skill when the user wants to:

- design a component in UX Pilot before coding
- design a new screen in UX Pilot before coding
- generate a flow in UX Pilot
- refine an existing UX Pilot result that drifted or broke
- preserve an existing product's visual system while exploring new UI
- get prompts for section edits, quick edits, or whole-screen regeneration

Typical triggers:

- "use UX Pilot"
- "design this in UX Pilot first"
- "make me a UX Pilot prompt"
- "prototype this before we build it"
- "the UX Pilot edit drifted"

## When not to use

Do not use this skill for:

- tiny copy-only tweaks
- implementation-only coding work
- backend planning with no UI design need
- bug fixes that do not need design exploration

## Core principles

1. be concrete, not tasteful
2. preserve the product's identity when working from an existing UI
3. choose the right UX Pilot mode before writing prompts
4. specify what is required now vs what can be deferred
5. prefer local edits over full regeneration once structure is close
6. add anti-drift instructions every time

## UX Pilot behavior to optimize for

These are the important product behaviors this workflow is built around:

- detailed prompts outperform vague prompts
- explicit device, style, and font choices reduce drift
- component generation is better than whole-screen generation when you only need a modal, card, drawer, table, or toolbar
- `Edit Section` is best for local changes
- `Quick edit` is best for cleanup and follow-up fixes
- `Edit Whole Screen` is best for structural changes or screen spin-offs
- shared context improves consistency across multiple screens in a flow
- screenshots, cloned references, and imported design systems help preserve style

## Workflow

Follow these steps in order.

### Step 1: classify the scope

Choose one mode:

- `component`

  - one focused UI element inside a larger product
  - examples: modal, drawer, table toolbar, card, sidebar, filter bar, settings panel

- `screen`

  - one complete page or app view
  - examples: support homepage, ticket detail page, admin settings page

- `flow`
  - multiple connected screens that share context
  - examples: onboarding flow, checkout flow, ticket create -> detail -> linked state flow

If the user asks for a modal, sheet, dropdown, table, filter row, or section inside a page, default to `component`.

### Step 2: extract the design brief

Capture the following before writing prompts:

- what is being designed
- who uses it
- what job they are doing
- desktop, mobile, or both
- required UI elements
- required states or variations
- required-now fields
- optional-later fields
- visual system details
- existing product constraints
- things that must not change
- drift to avoid

If key information is missing, ask the user one targeted question. Prefer one question at a time.

### Step 3: choose the UX Pilot action

Choose the right generation or edit mode.

- `Generate component`

  - use for isolated component work

- `Generate screen`

  - use for a single full page or view

- `Generate flow`

  - use for multiple connected screens

- `Edit Section`

  - use when the overall design is right but one region needs change
  - examples: fix customer section, tighten modal footer, simplify filter bar

- `Quick edit`

  - use for cleanup, duplication fixes, wording-level layout changes, minor visual corrections

- `Edit Whole Screen`
  - use when structure or layout needs to change broadly
  - examples: convert analytics-heavy layout into queue-first layout, spin off a new page based on the current one

### Step 4: write the prompt pack

Unless the user explicitly wants only one prompt, always return:

1. `mode`
2. `brief summary`
3. `base UX Pilot prompt`
4. `correction prompt`
5. `Edit Section prompt`
6. `Quick edit prompt`
7. `Edit Whole Screen prompt`
8. `review checklist`

### Step 5: guide the iteration

After producing the prompt pack, briefly explain:

- which UX Pilot action to try first
- when to use section edit instead of regeneration
- what to inspect in the generated result before moving to code

## Prompt formula

Every base UX Pilot prompt should include these ingredients in roughly this order:

1. product context
2. user/job context
3. exact scope: component, screen, or flow
4. platform/device
5. required UI elements
6. states, behaviors, and hierarchy
7. visual system details
8. required-now vs optional-later details
9. constraints on what must stay consistent
10. anti-drift exclusions
11. requested output

Use explicit, operational language. Avoid vague taste words like "make it sleek" unless paired with concrete constraints.

## Visual-system guidance

When matching an existing product, do not say only:

- "match our style"
- "keep current colors"
- "make it consistent"

Instead, specify:

- background color direction
- surface colors
- border treatment
- primary text and secondary text tones
- accent colors
- corner radii
- density/spacing character
- layout tone, such as queue-first, chat-first, or admin-operational

If screenshots or known brand references exist, include them in the prompt context when possible.

## Required-now vs optional-later rule

This matters a lot for ops tools and workflow software.

Always mark:

- what must be completed before submit
- what may be left blank and enriched later

Examples:

- customer can be linked later
- assignee can be set later
- downstream entity link can be added later
- follow-up date can be optional at creation

UX Pilot tends to over-formalize forms when this is not stated clearly.

## Anti-drift rules

Include anti-drift instructions in every prompt pack when relevant.

Common anti-drift exclusions:

- do not turn ops screens into analytics dashboards
- do not turn workflow forms into onboarding wizards
- do not invent a new app structure or sidebar unless asked
- do not default to purple-on-white startup styling
- do not make charts dominate inbox or queue screens
- do not split a single workflow into fake separate products
- do not replace operational density with empty marketing whitespace

If the user is working within an existing UI, add:

- keep the page recognizable
- preserve the current visual language
- add only the new surfaces required by the workflow

## Output format

Return output in this format:

### Mode

- `component|screen|flow`

### Brief

- one short paragraph covering user, job, scope, and visual direction

### Base UX Pilot prompt

```text
...
```

### Correction prompt

```text
...
```

### Edit Section prompt

```text
...
```

### Quick edit prompt

```text
...
```

### Edit Whole Screen prompt

```text
...
```

### Review checklist

- ...
- ...

## Prompt-writing rules

Do:

- specify desktop, mobile, or both
- ask for the component directly when the target is a component
- describe hierarchy, not just feature lists
- state what is optional
- state what should remain unchanged
- state what should visually dominate the layout
- use concise, explicit language

Do not:

- write only one vague sentence
- assume UX Pilot can infer the product's visual system from code
- ask for a full page when you only need a modal
- regenerate the whole screen when only one section is wrong
- describe everything as "modern", "clean", or "premium" with no concrete constraints

## Edit strategy cheatsheet

Use this mapping:

- if one section is wrong but the overall structure is right -> `Edit Section`
- if a few elements are duplicated, missing, or awkward -> `Quick edit`
- if layout hierarchy is fundamentally wrong -> `Edit Whole Screen`
- if starting fresh on a new piece of UI -> generate a new component, screen, or flow

## Examples

### Example 1: support homepage

Use `screen` mode.

Good direction:

- queue-first support inbox
- stats support the queue, they do not dominate the page
- preserve existing support workspace feel

Correction pattern:

- if UX Pilot drifts into analytics-heavy layout, tell it the queue is the primary object and stats are secondary

### Example 2: desktop new-ticket modal

Use `component` mode.

Good direction:

- one desktop modal, not a full page
- one intake shell with a top-level kind switch
- shared fields first
- optional customer, assignee, and link states clearly shown as deferrable

Correction pattern:

- if UX Pilot turns it into a multi-step wizard, explicitly restate that this should be a single modal with progressive sections

### Example 3: mobile support detail

Use `screen` mode.

Good direction:

- chat-first layout
- sticky header
- sticky composer
- thread dominates the screen
- metadata and info live in a secondary sheet

Correction pattern:

- if UX Pilot produces a stacked desktop layout, restate that the mobile screen must be chat-first and optimized for live support handling

## Final rule

Do not hand the user a loose prompt and stop there. Give them the prompt pack that helps them generate, correct, edit, and evaluate the design.
