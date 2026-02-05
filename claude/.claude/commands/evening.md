---
description: Log evening. Usage: /evening [build|drift] [hours] [notes]
---

Log evening productivity to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/evening build 2 worked on emulator`
- `/evening drift youtube rabbit hole`
- `/evening build` (ask for hours/notes)
- `/evening build 2 worked on emulator 2026-01-31`
- `/evening` (ask build or drift)

## Parse input

- **type**: build or drift (required)
- **hours**: number (required for build, omit for drift)
- **notes**: what happened (required)
- **date**: YYYY-MM-DD (optional, only if last arg matches date)

## Execute

Build:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh evening build <hours> "<notes>" [date]
```

Drift:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh evening drift "<notes>" [date]
```

Examples:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh evening build 2 "worked on emulator"
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh evening build 2 "worked on emulator" 2026-01-31
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh evening drift "youtube rabbit hole"
```

The script constructs the formatted entry with evening type, date, and fields.
If the script exits non-zero, report the error to the user.

## Confirm

Report the "ok: ..." line from script output. Examples:

Build:
```
Logged: build evening (2 hrs) - worked on emulator
```

Drift:
```
Logged: drift evening - youtube rabbit hole
```
