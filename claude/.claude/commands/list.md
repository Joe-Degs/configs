---
description: Add to list. Usage: /list [#tag] [content]
---

Add item to a list in Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/list #reading https://example.com consensus article`
- `/list #shopping new keyboard`
- `/list that article we discussed` (infer #reading from URL)
- `/list #reading https://example.com consensus article 2026-01-31`
- `/list` (ask what to add)

## Parse input

- **tag**: reading, shopping, watching, ideas, project, podcast, talk, video (required)
- **content**: the item (required, quote if multiple words)
- **description**: optional context after content
- **date**: YYYY-MM-DD (optional, only if last arg matches date)

Infer tag: URLs → reading, physical items → shopping, movies/shows → watching

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh lists <tag> "<content>" "<description>" [date]
```

Example:
```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh lists reading "https://example.com" "consensus article"
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh lists reading "https://example.com" "consensus article" 2026-01-31
```

The script constructs the formatted entry, validates the tag, and inserts it.
If the script exits non-zero, report the error to the user.

## Confirm

Report the "ok: ..." line from script output. Example:

```
Added to #reading: https://example.com
```
