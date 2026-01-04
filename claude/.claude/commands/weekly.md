---
description: Generate weekly review. Usage: /weekly [YYYY-WNN]
---

Generate weekly review from Obsidian data using the obsidian-vault skill.

## Usage

- `/weekly` (current week)
- `/weekly 2025-W48` (specific week)
- `/weekly last week`

## File discovery

First, get the inbox path and derive vault location:

```bash
bash ~/.claude/skills/obsidian-vault/scripts/inbox-path.sh
```

This returns something like `/Users/joe/dev/Obsidian/Inbox/2026-01.md`. The vault root is two directories up (remove `/Inbox/YYYY-MM.md`). Use `[vault]` below to reference this derived path.

## Process

1. Determine week (default: current ISO week)
2. Run inbox-path.sh to get inbox file path and derive vault root
3. Read inbox file and filter by date range (Monday-Sunday)
4. Read `[vault]/Config.md` for targets
5. Read `[vault]/Areas/Finance-Plans/YYYY-MM.md` for budget
6. Read `[vault]/Areas/Fitness-Plans/YYYY-MM.md` for fitness targets
7. Aggregate data
8. Generate markdown
9. Ask: "Write to [vault]/Journal/Weekly/YYYY-WNN.md or output here?"

## Aggregate

- Tasks: overdue, completed, added
- Spending: total, by category, vs limits
- Workouts: count vs target, by type
- Evenings: build/drift ratio, project hours
- Notes: grouped by tag
- Lists: new items

## Output format

See obsidian-vault skill for review markdown template.
