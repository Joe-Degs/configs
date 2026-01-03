---
description: Capture note/thought. Usage: /note [#tag] [content]
---

Capture a note to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/note #coding need to investigate memory leak`
- `/note remember to call mom` (infer #personal)
- `/note` (infer from context or ask)

## Parse input

- **tag**: #coding, #personal, #random, #work, #project (default: #random)
- **content**: note text

Infer tag from content if not explicit.

## Format

```
- [date:: YYYY-MM-DD] #tag content
```

Use today's date.

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh notes "- [date:: 2026-01-02] #coding need to investigate memory leak"
```

## Confirm

```
Noted: #coding need to investigate memory leak
```
