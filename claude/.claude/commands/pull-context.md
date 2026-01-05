---
description: Pull vault context for current work. Usage: /pull-context <topic>
---

Search Obsidian vault for context related to a topic before starting work.

## Usage

- `/pull-context kubernetes` - find all kubernetes-related notes, tasks, lists
- `/pull-context emulator project` - find context for emulator project
- `/pull-context` - infer topic from conversation context

## Parse input

- **topic**: search term(s) for finding relevant context
- **vault path**: `$OBSIDIAN_VAULT_PATH` (default: `~/dev/Obsidian`)

## Integration with existing system

Use existing scripts and data formats:
- Reference `{baseDir}/references/data-formats.md` for entry patterns
- Use same vault path resolution as `inbox-path.sh`
- MCP tools if available: `search_notes`, `read_notes`

## Process

### Step 1: Search using ripgrep

Search across vault for topic matches:

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"

rg -i -l "$TOPIC" "$VAULT" --type md --glob '!.obsidian/*'
```

### Step 2: Search structured content

Use patterns from data-formats.md:

**Active tasks mentioning topic:**
```bash
rg -i "^\s*- \[ \].*$TOPIC" "$VAULT" --type md
```

**Notes with topic:**
```bash
rg -i "^\s*- \[date::.*\].*$TOPIC" "$VAULT/Inbox" --type md
```

**List items (reading, ideas, projects):**
```bash
rg -i "^\s*- \[added::.*\].*$TOPIC" "$VAULT/Inbox" --type md
```

**Project entries:**
```bash
rg -i "#project.*$TOPIC" "$VAULT/Inbox" --type md
```

### Step 3: Check Projects folder

```bash
ls "$VAULT/Projects" | rg -i "$TOPIC"
```

If matching project folder exists, list its contents.

### Step 4: Use MCP if available

If obsidian MCP is connected:
- `search_notes` to find files by name
- `read_notes` to load file content

### Step 5: Present context summary

Organize findings into:
- **Project files**: matching project folders and their contents
- **Active tasks**: uncompleted tasks mentioning the topic
- **Notes**: dated notes with the topic
- **List items**: reading list, ideas, project entries
- **Other files**: any other vault files mentioning topic

### Step 6: Offer to load files

Ask which specific files to load into conversation context for deeper review.

## Confirm

```
Found context for [topic]:
- [N] files in Projects/
- [N] active tasks
- [N] notes
- [N] list items

[Key findings summary]

Load any files?
```
