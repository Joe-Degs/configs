---
description: Add task to Obsidian. Usage: /task [description] [priority] [due]
---

Add a task to Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/task fix syscall handler high by Friday`
- `/task fix the bug` (no priority/date)
- `/task` (infer from context or ask)

## Parse input

- **description**: required
- **priority**: high→⏫, medium→🔼, low→🔽 (optional)
- **due**: date→📅 YYYY-MM-DD (optional)

## Format

```
- [ ] description [priority emoji] [📅 YYYY-MM-DD]
```

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh tasks "- [ ] description ⏫ 📅 2026-01-10"
```

## Confirm

```
Added task: fix syscall handler
```
