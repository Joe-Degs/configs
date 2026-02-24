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
8. Present the review summary (read-only)
9. Ask for user reflection and plan changes
10. Ask: "Write to Inbox Monthly review section or output only?"

## Aggregate

- Tasks: completed, still overdue, total added
- Spending: total vs budget, each category vs limit
- Workouts: total sessions vs weekly target * weeks
- Evenings: build/drift totals, project hours total
- Notes: all, grouped by tag
- Lists: all items added

## Interaction

After presenting the summary, ask:

- "What do you think should change next month?"
- "Are your priorities or plan targets changing?"

Do not write reflections or the monthly review into the inbox until the user confirms.

Then ask: "Run the brutal pass too?"

If the user says yes, run `/month-review` for the same month and present it next.

If the user wants the monthly summary written to the inbox:

- Insert a `##### Monthly review` section if missing
- Add a single line review: `- [review:: YYYY-MM] ...`
- Ask if they want reflection entries added, and only add them after approval

## Output format

See obsidian-vault skill for review markdown template.
