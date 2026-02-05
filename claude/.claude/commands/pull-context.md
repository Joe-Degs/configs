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

### Step 0: Use vault-context agent

To keep main context clean, run the vault-context subagent for the initial search.
Only load full files if the user asks.

```text
Task tool: subagent_type="vault-context"
prompt: "Find context for: <topic>. Return summary with counts and file paths only."
```

If vault-context is unavailable, fall back to the ripgrep steps below.

### Step 1: Search using ripgrep

Derive vault root from inbox-path.sh, then search across vault for topic matches.
If topic has multiple words, match any word by default.

```bash
INBOX_PATH=$(bash ~/.claude/skills/obsidian-vault/scripts/inbox-path.sh)
VAULT=$(dirname "$(dirname "$INBOX_PATH")")

TOPIC_REGEX=$(echo "$TOPIC" | tr ' ' '|')

rg -i -l -e "$TOPIC_REGEX" "$VAULT" -g '*.md' -g '!.obsidian/**'
```

### Step 2: Search structured content

Use patterns from data-formats.md:

**Active tasks mentioning topic (all Inbox months):**
```bash
TOPIC_REGEX=$(echo "$TOPIC" | tr ' ' '|')
rg -i "^\s*- \[ \].*(${TOPIC_REGEX})" "$VAULT/Inbox" -g '*.md' -g '!.obsidian/**' -g '!Archive/**'
```

**Notes with topic (all Inbox months):**
```bash
TOPIC_REGEX=$(echo "$TOPIC" | tr ' ' '|')
rg -i "^\s*- \[date::.*\].*(${TOPIC_REGEX})" "$VAULT/Inbox" -g '*.md' -g '!Archive/**'
```

**List items (reading, ideas, projects) (all Inbox months):**
```bash
TOPIC_REGEX=$(echo "$TOPIC" | tr ' ' '|')
rg -i "^\s*- \[added::.*\].*(${TOPIC_REGEX})" "$VAULT/Inbox" -g '*.md' -g '!Archive/**'
```

**Project entries (all Inbox months):**
```bash
TOPIC_REGEX=$(echo "$TOPIC" | tr ' ' '|')
rg -i "#project.*(${TOPIC_REGEX})" "$VAULT/Inbox" -g '*.md' -g '!Archive/**'
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
