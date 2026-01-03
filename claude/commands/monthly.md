---
description: Generate monthly review. Usage: /monthly [YYYY-MM]
---

Generate monthly review from Obsidian data using the obsidian-vault skill.

## Usage

- `/monthly` (current month)
- `/monthly 2025-12` (specific month)
- `/monthly last month`

## Process

1. Determine month (default: current month)
2. Get inbox file: `$OBSIDIAN_VAULT_PATH/Inbox/YYYY-MM.md`
3. Read entire inbox file (no date filtering needed)
4. Read `$OBSIDIAN_VAULT_PATH/Config.md` for targets
5. Read `$OBSIDIAN_VAULT_PATH/Areas/Finance-Plans/YYYY-MM.md` for budget
6. Read `$OBSIDIAN_VAULT_PATH/Areas/Fitness-Plans/YYYY-MM.md` for fitness targets
7. Aggregate all data
8. Generate markdown
9. Ask: "Write to Journal/Monthly/YYYY-MM.md or output here?"

## Aggregate

- Tasks: completed, still overdue, total added
- Spending: total vs budget, each category vs limit
- Workouts: total sessions vs weekly target * weeks
- Evenings: build/drift totals, project hours total
- Notes: all, grouped by tag
- Lists: all items added

## Output format

See obsidian-vault skill for review markdown template.
