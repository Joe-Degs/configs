---
description: Log workout. Usage: /workout [type] [duration] [exercises...]
---

Log workout to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/workout swim 60 freestyle drills`
- `/workout legs 90 squats rdl leg press`
- `/workout run 40 easy 5k`
- `/workout push 75 bench dumbbell press`
- `/workout` (ask for details)

## Parse input

- **type**: Swim, Run, Legs, Push, Pull (required, case-insensitive but capitalize in output)
- **duration**: minutes (required)
- **exercises**: comma-separated list from remaining args

## Format

```
- description [workout:: TYPE] [exercises:: LIST] [duration:: MINUTES] [date:: YYYY-MM-DD]
```

Use today's date for the date field.

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh gym "- morning swim [workout:: Swim] [exercises:: freestyle, drills] [duration:: 60] [date:: 2026-01-02]"
```

## Confirm

```
Logged: Swim (60 min) - freestyle, drills
```
