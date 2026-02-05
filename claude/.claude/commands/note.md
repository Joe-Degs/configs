---
description: Capture note/thought. Usage: /note [#tag] [content]
---

Capture a note to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/note #coding need to investigate memory leak`
- `/note #work atlas-metrics: SLO framework draft sent for peer review`
- `/note remember to call mom` (infer #personal)
- `/note #work inbound-square: follow up on SLA review 2026-01-31`
- `/note` (infer from context or ask)

## Parse input

- **tag**: coding, personal, random, work, project (default: random)
- **content**: note text (required)
- **date**: YYYY-MM-DD (optional, only if last arg matches date)

Infer tag from content if not explicit.

If tag is `work` and a project or client name is known, prefix the content with `project: ` (example: `inbound-square: ...`).

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh notes <tag> "<content>" [date]
```

Example:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh notes coding "need to investigate memory leak"
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh notes work "inbound-square: follow up on SLA review" 2026-01-31
```

The script constructs the formatted entry, validates the tag, and inserts it.
If the script exits non-zero, report the error to the user.

## Confirm

Report the "ok: ..." line from script output. Example:

```
Noted: #coding need to investigate memory leak
```
