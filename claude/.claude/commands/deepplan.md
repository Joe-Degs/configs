---
description: Deep planning with research. Usage: /deepplan <topic>
---

Iterative, research-backed planning that gathers context, consults experts, and outputs actionable plans.

## Usage

- `/deepplan homelab kubernetes setup`
- `/deepplan career transition to systems engineering`
- `/deepplan ireland trip august`
- `/deepplan` (infer topic from conversation)

## Core principles

1. **Understand before researching** - ask clarifying questions first
2. **Simple solutions above all** - prefer the simplest viable approach
3. **Search when uncertain** - don't guess, look it up
4. **Pull references during conversation** - not a research dump upfront
5. **Cite sources** - back recommendations with references
6. **Detect knowledge gaps** - switch to learning mode when needed

## Process

### Phase 1: Initial understanding

Do NOT immediately research. Ask clarifying questions:

```
Let me help you plan [topic].

Before I research anything, let me understand your context:
1. [Relevant question about goal]
2. [Relevant question about constraints]
3. [Relevant question about existing knowledge]

I'll search for relevant info as we discuss.
```

Use AskUserQuestion tool if appropriate for structured input.

### Phase 2: Gather context

As user provides information, search iteratively:

**Vault context (use /pull-context patterns):**
```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"
rg -i "$TOPIC" "$VAULT" --type md --glob '!.obsidian/*' -l
```

Check for:
- Existing projects on the topic
- Past notes and decisions
- Related tasks or reading list items

**Web research:**
- Search for best practices, expert opinions
- Look for real-world examples
- Find potential pitfalls

Cite sources as you find them:
```
I found in your vault that you've been researching [X]...

According to [source], the recommended approach is...
```

### Phase 3: Detect knowledge gaps (learning mode integration)

Watch for signs user is unfamiliar with the domain:
- Vague answers to clarifying questions
- Asking "what does X mean?"
- Uncertainty about basic concepts

When detected, switch to learning mode:

1. **Ask about current knowledge level:**
   ```
   Before we plan further, how familiar are you with [concept]?
   ```

2. **Explain concepts before planning:**
   ```
   Let me explain [concept] since it affects your options...
   ```

3. **Suggest resources:**
   ```
   I found some good resources on this:
   - [URL 1] - [description]
   - [URL 2] - [description]

   Want me to add these to your reading list?
   ```

4. **Add to reading list if requested:**
   Use /list command pattern:
   ```bash
   bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh lists reading "<URL>" "<description>"
   ```

5. **Resume planning** once user has enough context

### Phase 4: Present options

After gathering context, present 2-3 approaches:

```
Based on what you've told me and what I've found, here are your options:

**Option A: [Name] (Simplest)**
- [Description]
- Pros: [...]
- Cons: [...]

**Option B: [Name]**
- [Description]
- Pros: [...]
- Cons: [...]

[Source: This approach is recommended by [expert/doc] because...]

Which direction appeals to you?
```

### Phase 5: Generate output

Once direction is clear:

**1. Determine plan location:**

Search vault for existing project:
```bash
ls "$VAULT/Projects" | rg -i "$TOPIC"
```

- If matching project found → add plan there
- If not found → create in `ScratchPad/Plans/[topic]-plan.md`

**2. Create plan document:**

Use MCP `create_note` if available, otherwise direct file write.

Plan template:
```markdown
# [Topic] Plan

**Created:** [date]
**Status:** Draft

## Goal
[Clear, specific goal statement]

## Context
[What led to this plan, constraints, background]

## Prerequisites
- [ ] Prerequisite 1
- [ ] Prerequisite 2

## Phases

### Phase 1: [Name]
[Description]
- Step 1
- Step 2

### Phase 2: [Name]
...

## Resources
- [Link 1] - Description
- [Link 2] - Description

## Success criteria
- [ ] Measurable outcome 1
- [ ] Measurable outcome 2

## Notes
[Any additional considerations, risks, alternatives]
```

**3. Add tasks to Inbox:**

Extract actionable first steps and add via:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh tasks "<description>" [priority] [due-date]
```

**4. Add summary note:**

Log the plan creation:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh notes project "created plan: <topic>"
```

## Integration with existing system

- Uses `/pull-context` patterns for vault search
- Uses `/list` patterns for adding reading items
- Uses `/task` patterns (via add-entry.sh) for tasks
- Uses `/note` patterns for plan summary
- Integrates with learning-mode skill for knowledge gaps
- Uses MCP obsidian tools if available

## Confirm

```
Plan created: [location]

Added [N] tasks to Inbox
Logged: #project created plan: [topic]

[Brief summary of next steps]
```
