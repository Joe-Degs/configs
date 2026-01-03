---
description: Log savings deposit. Usage: /save [fund] [amount]
---

Log savings deposit to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/save travel 3000`
- `/save emergency 500`
- `/save retirement 1000`
- `/save` (ask for details)

## Parse input

- **fund**: user-defined fund name (required, lowercase)
- **amount**: number (required)

## Format

```
- [savings:: FUND] [amount:: AMOUNT] [date:: YYYY-MM-DD]
```

Use today's date for the date field.

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh finance "- [savings:: travel] [amount:: 3000] [date:: 2026-01-02]"
```

## Confirm

```
Logged: Saved 3000 → travel fund
```
