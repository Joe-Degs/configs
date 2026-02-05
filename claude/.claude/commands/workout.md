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
- `/workout pull 90 "rows, pull ups" 2026-02-03`

## Parse input

- **type**: swim, run, legs, push, pull (required, case-insensitive)
- **duration**: minutes (required)
- **exercises**: comma-separated list (required, quote if contains commas)
- **date**: YYYY-MM-DD (optional, only if last arg matches date)

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh gym <type> <duration> "<exercises>" [date]
```

Example:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh gym swim 60 "freestyle, drills"
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh gym pull 90 "rows, pull ups" 2026-02-03
```

The script constructs the formatted entry with workout type, exercises, duration, and date.
If the script exits non-zero, report the error to the user.

## Confirm

Report the "ok: ..." line from script output. Example:

```
Logged: Swim (60 min) - freestyle, drills
```
