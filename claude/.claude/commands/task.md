---
description: Add task to Obsidian. Usage: /task [description] [priority] [due]
---

Add a task to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/task fix syscall handler high by Friday`
- `/task fix the bug` (no priority/date)
- `/task` (infer from context or ask)

## Parse input

- **description**: task text (required)
- **priority**: high, medium, low (optional, passed as separate arg)
- **due**: YYYY-MM-DD (optional, passed as separate arg)

## Date and priority parsing

- use local system date as "today"
- if the description includes an explicit date (YYYY-MM-DD, YYYY/MM/DD, MM/DD/YYYY, Mon DD, Month DD), normalize to YYYY-MM-DD
- if the description includes "today", "tonight", "this morning", "this afternoon", "this evening", "EOD", "end of day", "by end of day", or "COB", set due to today
- if the description includes "tomorrow", "tmr", "tmrw", or "next day", set due to today + 1 day
- if the description includes "this week", "by end of week", or "EOW", set due to Friday of the current week
- if the description includes "next week", set due to Friday of next week
- if the description includes "in N days" or "in N weeks", set due to today + N days or weeks
- if the description includes "urgent", "ASAP", "now", or "critical", set priority to high; if due is not set, also set due to today
- if the description includes "low priority" or "not urgent", set priority to low

## Execute

Important guardrails:
- execute the bash script directly, do not use the Task tool or any subagent
- if the user lists multiple tasks, split them and run one /task per entry
- only ask a question when the description is missing or date parsing is truly ambiguous after applying the rules above

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh tasks "<description>" [priority] [due-date]
```

Example:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh tasks "fix syscall handler" high 2026-01-10
```

The script constructs the formatted entry with emoji priority and date fields, and inserts it.
If the script exits non-zero, report the error to the user.

## Confirm

Report the "ok: ..." line from script output. Example:

```
Added task: fix syscall handler
```
