---
description: Log spending. Usage: /spend [amount] [category] [item] [notes]
---

Log spending to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/spend 50 food lunch at work`
- `/spend 50 food`
- `/spend 50` (ask for category)
- `/spend` (ask for details)

## Parse input

- **amount**: number (required)
- **category**: food, transport, personal, gifts, health, education, entertainment, utilities
- **item**: description (defaults to category if not provided)
- **notes**: additional context

## Format

```
- item [spent:: AMOUNT] [item:: ITEM] [category:: CATEGORY] [date:: YYYY-MM-DD] - notes
```

Use today's date for the date field.

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh finance "- lunch [spent:: 50] [item:: lunch] [category:: food] [date:: 2026-01-02] - at work"
```

## Confirm

```
Logged: 50 → food (lunch)
```
