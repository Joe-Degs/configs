---
name: obsidian-vault
description: |
  Routes natural language to Obsidian capture commands. Triggers on:
  spending ("spent", "bought", "paid", "log spending"), tasks ("add task", "todo", "remind me"),
  workouts ("went to gym", "swam", "ran", "workout"), evenings ("build night", "drift", "productive evening"),
  notes ("note to self", "capture note"), lists ("add to reading list", "add to list"),
  savings ("saved", "deposited", "savings fund"), reviews ("how was my week", "monthly review"),
  bored/stuck ("bored", "stuck", "what should I do", "what now", "need something to do"),
  completion ("done with", "finished reading", "read that article", "watched that", "listened to"),
  syncing ("sync vault", "sync obsidian", "sync configs", "push my changes"),
  planning ("plan", "deep plan", "help me plan", "let's plan"),
  context ("pull context", "get context", "what do I have on", "find my notes on").
---

# Obsidian vault

Routes natural language capture requests to the appropriate slash command.

## Routing table

| User says | Route to | Example transformation |
|-----------|----------|------------------------|
| "spent 50 on lunch" | `/spend` | → /spend 50 food lunch |
| "remind me to call mom" | `/task` | → /task call mom |
| "went swimming for an hour" | `/workout` | → /workout swim 60 |
| "productive night, worked on emulator" | `/evening` | → /evening build 2 emulator |
| "note: check the memory leak" | `/note` | → /note coding check the memory leak |
| "add to reading list: article.com" | `/list` | → /list reading article.com |
| "deposited 3000 to travel fund" | `/save` | → /save travel 3000 |
| "how was my week" | `/weekly` | → /weekly |
| "review december" | `/month-review` | → /month-review 2025-12 |
| "I'm bored" / "what should I do" | `/bored` | → /bored |
| "finished reading that trust paper" | `/done` | → /done #reading trust |
| "done with the oxide podcast" | `/done` | → /done #podcast oxide |
| "sync my vault" / "push obsidian" | `/sync` | → /sync obsidian |
| "sync configs" / "sync dotfiles" | `/sync` | → /sync configs |
| "help me plan kubernetes setup" | `/deepplan` | → /deepplan kubernetes setup |
| "let's plan my trip to ireland" | `/deepplan` | → /deepplan ireland trip |
| "what do I have on emulator" | `/pull-context` | → /pull-context emulator |
| "find my notes on distributed systems" | `/pull-context` | → /pull-context distributed systems |

## How to route

1. Parse user's natural language to identify intent
2. Extract relevant values (amount, category, duration, description, etc.)
3. Follow the corresponding command's instructions to execute
4. For work notes, prefix the content with `project: ` (example: `atlas-metrics: ...`). Infer the project from context when possible. If unknown, ask for the project name.

## Command locations

All commands are in `~/.claude/commands/`:
- `task.md` - add tasks
- `spend.md` - log spending
- `workout.md` - log workouts
- `evening.md` - log build/drift evenings
- `note.md` - capture notes
- `list.md` - add to lists
- `save.md` - log savings deposits
- `weekly.md` - weekly review
- `month-review.md` - monthly review
- `bored.md` - combat drift with suggestions
- `done.md` - mark list items complete
- `sync.md` - sync vault or configs to GitHub
- `deepplan.md` - deep planning with research
- `pull-context.md` - pull vault context for a topic

## Scripts (for command internals)

Commands use these scripts. Do not construct entry formats manually.

- `{baseDir}/scripts/add-entry.sh <section> <params...>` - validates, constructs, and inserts entries
- `{baseDir}/scripts/inbox-path.sh` - get current inbox path
- `{baseDir}/scripts/get-month-data.sh YYYY-MM` - extract month data
- `{baseDir}/scripts/sync-repo.sh <path> [status|commit|pull|push]` - git sync with safety
- `{baseDir}/scripts/lint-inbox.sh [YYYY-MM]` - audit inbox for format issues

### add-entry.sh parameter reference

| section | args | example |
|---------|------|---------|
| notes | `<tag> <content>` | `notes coding "memory leak"` |
| tasks | `<description> [priority] [due]` | `tasks "fix bug" high 2026-01-10` |
| finance | `<amount> <category> <item> [notes]` | `finance 50 food "lunch" "at work"` |
| savings | `<fund> <amount>` | `savings travel 3000` |
| gym | `<type> <duration> <exercises>` | `gym swim 60 "freestyle, drills"` |
| evening | `<type> [hours] <notes>` | `evening build 2 "worked on emulator"` |
| lists | `<tag> <content> [description]` | `lists reading "https://..." "article"` |

## Data formats

See `{baseDir}/references/data-formats.md` for entry specifications.
