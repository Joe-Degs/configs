---
description: Log evening. Usage: /evening [build|drift] [hours] [notes]
---

Log evening productivity to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/evening build 2 worked on emulator`
- `/evening drift youtube rabbit hole`
- `/evening build` (ask for hours/notes)
- `/evening` (ask build or drift)

## Parse input

- **type**: build or drift (required)
- **hours**: number (only for build, optional)
- **notes**: what happened

## Format

Build:
```
- [evening:: build] [date:: YYYY-MM-DD] [project-hours:: N] [notes:: description]
```

Drift:
```
- [evening:: drift] [date:: YYYY-MM-DD] [notes:: description]
```

Use today's date.

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh evening "- [evening:: build] [date:: 2026-01-02] [project-hours:: 2] [notes:: worked on emulator]"
```

## Confirm

Build:
```
Logged: build evening (2 hrs) - worked on emulator
```

Drift:
```
Logged: drift evening - youtube rabbit hole
```
