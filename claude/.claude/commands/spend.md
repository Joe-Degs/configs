---
description: Log spending. Usage: /spend [amount] [category] [item] [notes]
---

Log spending to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/spend 50 food lunch at work`
- `/spend 50 food`
- `/spend 50` (ask for category)
- `/spend 50 food lunch "at work" 2026-01-31`
- `/spend` (ask for details)

## Parse input

- **amount**: number (required)
- **category**: food, transport, personal, gifts, health, education, entertainment, utilities (required)
- **item**: short description (required, defaults to category if not provided)
- **notes**: additional context (optional)
- **date**: YYYY-MM-DD (optional, only if last arg matches date)

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh finance <amount> <category> "<item>" "<notes>" [date]
```

Example:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh finance 50 food "lunch" "fufu at work"
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh finance 50 food "lunch" "fufu at work" 2026-01-31
```

The script constructs the formatted entry, validates amount and category, and inserts it.
If the script exits non-zero, report the error to the user.

## Confirm

Report the "ok: ..." line from script output. Example:

```
Logged: 50 → food (lunch)
```
