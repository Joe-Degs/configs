---
description: Add to list. Usage: /list [#tag] [content]
---

Add item to a list in Obsidian Inbox using the obsidian-vault skill.

## Usage

- `/list #reading https://example.com - consensus article`
- `/list #shopping new keyboard`
- `/list that article we discussed` (infer #reading from URL)
- `/list` (ask what to add)

## Parse input

- **tag**: #reading, #shopping, #watching, #ideas, #projects
- **content**: item description

Infer tag: URLs→#reading, physical items→#shopping, movies/shows→#watching

## Format

```
- [added:: YYYY-MM-DD] #tag content - description
```

Use today's date.

## Execute

```bash
bash ~/.claude/skills/obsidian-vault/scripts/add-entry.sh lists "- [added:: 2026-01-02] #reading https://example.com - consensus article"
```

## Confirm

```
Added to #reading: https://example.com
```
