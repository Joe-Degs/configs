---
description: Planning snapshot and next actions. Usage: /pulse [today|tomorrow|YYYY-MM-DD]
---

Build a planning snapshot from the vault. This is read-only until the user approves changes.

## Usage

- `/pulse`
- `/pulse tomorrow`
- `/pulse 2026-02-05`

## Parse input

- **date**: planning date (default: today). Accepts `tomorrow` or `YYYY-MM-DD`.

## Gather

- current inbox: `Inbox/YYYY-MM.md` for the current month
- prior inboxes: last 2 months for carryovers
- projects: `Areas/Projects/`
- learning: `Areas/Learning-Systems.md`
- fitness plan: `Areas/Fitness-Plans/YYYY-MM`
- recent workouts and evenings: current inbox

## Output

Return a short plan with these sections:

- urgent now
- due soon (next 3 days)
- work projects
- personal projects
- learning block
- workout suggestion based on this week's sessions and the monthly plan
- spending reminder
- carryovers

If planning for tomorrow, label the output as tomorrow's plan.

## Actions

Ask before making changes. If the user approves:

- add or reschedule tasks
- write a plan note to the current inbox notes section using `#work plan:` or `#personal plan:`

## Execute

For plan notes:

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh notes <tag> "plan: <content>" [date]
```

The script constructs the formatted entry and inserts it.
If the script exits non-zero, report the error to the user.
