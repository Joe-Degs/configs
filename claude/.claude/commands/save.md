---
description: Log savings deposit. Usage: /save [fund] [amount]
---

Log savings deposit to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/save travel 3000`
- `/save emergency 500`
- `/save retirement 1000`
- `/save travel 3000 2026-01-31`
- `/save` (ask for details)

## Parse input

- **fund**: fund name (required, lowercased by script)
- **amount**: number (required)
- **date**: YYYY-MM-DD (optional, only if last arg matches date)

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh savings <fund> <amount> [date]
```

Example:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh savings travel 3000
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh savings travel 3000 2026-01-31
```

The script constructs the formatted entry with fund name, amount, and date.
If the script exits non-zero, report the error to the user.

## Confirm

Report the "ok: ..." line from script output. Example:

```
Logged: Saved 3000 → travel fund
```
