---
name: obsidian-vault
description: |
  Use when the user says "project folder for Hubtel ML Agents", "project notes for Hubtel ML Agents", "work plans for Hubtel ML Agents", "add project task for Hubtel ML Agents", "project folder for Golly Express", "project notes for Golly Express", "work plans for Golly Express", or "add project task for Golly Express". Also use for Obsidian, vault, inbox, current inbox, project folder, project notes, work plans, Golly Express, Hubtel ML Agents, Hubtel-ML-Agents, Spitfire, dit, nt-mips, Application Tracker, note to self, capture note, add task, todo, spent, workout, sync vault, pull context, evidence pack, or evidence gaps. Routes to Obsidian slash commands and vault paths; note captures use /note, project tasks use /project-task, and inbox writes go through scripts.
---

# Obsidian vault

Routes natural language capture, search, and context requests to the right Obsidian location or slash command.

Fast path examples:

- `project folder for Hubtel ML Agents` -> `Areas/Projects/Hubtel-ML-Agents/`
- `project notes for Golly Express` -> `Areas/Projects/Golly-Express/`
- `work plans for Golly Express` -> current inbox from `{baseDir}/scripts/inbox-path.sh`, then `Areas/Projects/Golly-Express/`, then `Areas/*-Plans/`
- `note to self: check the memory leak` -> `/note random "check the memory leak"`
- `add project task to inspect rerank answer quality for Hubtel ML Agents` -> `/project-task add Areas/Projects/Hubtel-ML-Agents/selfhosted-llm/selfhosted-llm-devlog-2026-05-12 next "inspect rerank answer quality"`

## Routing table

| User says | Route to | Example transformation |
|-----------|----------|------------------------|
| "spent 50 on lunch" | `/spend` | → /spend 50 food lunch |
| "remind me to call mom" | `/task` | → /task call mom |
| "add project task to inspect rerank answer quality" | `/project-task` | → /project-task add Areas/Projects/Hubtel-ML-Agents/selfhosted-llm/selfhosted-llm-devlog-2026-05-12 next "inspect rerank answer quality" |
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
| "where are the project notes for Golly Express" | vault map | → `Areas/Projects/Golly-Express/` |
| "project folder for Hubtel ML Agents" | vault map | → `Areas/Projects/Hubtel-ML-Agents/` |
| "work plans for Golly Express" | current inbox, then project folder | → current inbox from `{baseDir}/scripts/inbox-path.sh`, then `Areas/Projects/Golly-Express/` |
| "what evidence do I have for platform roles" | `/evidence-pack` | → /evidence-pack platform engineer |
| "what gaps do I have in my career evidence" | `/evidence-gaps` | → /evidence-gaps |

## How to route

1. Parse user's natural language to identify intent
2. Extract relevant values (amount, category, duration, description, etc.)
3. Follow the corresponding command's instructions to execute
4. For work notes, prefix the content with the project name and a colon (example: `atlas-metrics: ...`). Do not add a literal `project:` prefix. Infer the project from context when possible. If unknown, ask for the project name.
5. For project-specific follow-ups, use `/project-task` when the target note is known or inferable. The target must be an existing markdown note, not a project folder. If only the project is known and several notes could match, inspect the project folder or ask which note to use. Use `/task` only for the global inbox.
6. For path or location questions, answer with the vault path. Do not route to `/pull-context` unless the user asks to search or summarize context.
7. For project work-plan questions, inspect the current inbox first because daily plans live under `#work plan:` or `#personal plan:` there, then inspect the project folder and `Areas/*-Plans/` if needed.
8. Do not invent command names. Note captures route to `/note`, never `/capture-note`. Project tasks route to `/project-task`, never `/add-project-task`, and never pass a directory as the note argument.

## Vault file placement rules

- Never create new files or folders at the Obsidian vault root unless the user explicitly asks for a root-level vault file.
- Project plans, implementation plans, design docs, and continuation notes belong inside the relevant project folder under `Areas/Projects/<project>/`.
- If no project folder exists for the work, ask where it belongs or create a project folder under `Areas/Projects/` before saving durable planning files.
- Use `ScratchPad/` only for temporary notes or explicitly scratchpad-style work, not durable project plans.

## Vault map

Use `AGENTS.md` at the vault root as the source of truth for the vault map. It defines where things go and the priority search order.

`HOME.md` is a dashboard, not a source of truth. Do not use it as primary context.

Get the current inbox path with `{baseDir}/scripts/inbox-path.sh`. Do not guess the month manually unless the user names a specific `YYYY-MM` month.

Do not edit `Inbox/YYYY-MM.md` directly. Inbox entries must go through the capture commands and scripts so formats stay valid.

### where things go

- tasks, notes, lists, spending, workouts: `Inbox/YYYY-MM.md` through commands/scripts only
- daily plans: `#work plan:` or `#personal plan:` in the inbox notes section, through commands/scripts only
- active projects (work, personal, client): `Areas/Projects/`
- plans: `Areas/*-Plans/`
- subject notes: `Resources/Notes/`
- book notes: `Resources/Book-Notes/`
- scratch and drafts: `ScratchPad/`
- long-term archive: `Archive/`, `_Revista/`, `__Books/`, `__PDFs/`, `__Papers/`, `Excalidraw/`

### priority search order

- current inbox from `{baseDir}/scripts/inbox-path.sh`, `Areas/Context/`, `Config.md`
- `Areas/Projects/`, `Areas/*-Plans/`
- `Journal/Weekly/`, `Journal/Monthly/`
- `Resources/Notes/`, `Resources/Book-Notes/`, `ScratchPad/`
- `Archive/`, `_Revista/`, `__Books/`, `__PDFs/`, `__Papers/`, `Excalidraw/`

### project alias shortcuts

Use these shortcuts before searching when the user names a common project. They exist to resolve spoken project names quickly.

| user phrase | path |
|-------------|------|
| application tracker project | `Areas/Projects/Application-Tracker/` |
| dit | `Areas/Projects/dit/` |
| Golly Express, Golly | `Areas/Projects/Golly-Express/` |
| Hubtel deployment templates | `Areas/Projects/Hubtel-Deployment-Templates/` |
| Hubtel ML Agents, self-hosted LLM | `Areas/Projects/Hubtel-ML-Agents/` |
| nt-mips, NT MIPS | `Areas/Projects/nt-mips/` |
| Spitfire | `Areas/Projects/Spitfire/` |
| Spitfire Docker | `Areas/Projects/Spitfire-Docker.md` |
| algorithms mastery | `Areas/Projects/Algorithms-Mastery.md` |
| DDIA study | `Areas/Projects/DDIA-Study.md` |
| math fundamentals | `Areas/Projects/Math-Fundamentals.md` |
| Nexus Technologies | `Areas/Projects/Nexus-Technologies.md` |
| novel reading | `Areas/Projects/Novel-Reading.md` |
| reading tracker | `Areas/Projects/Reading-Tracker.md` |
| turmoil distributed systems | `Areas/Projects/Turmoil-Distributed-Systems.md` |

When a user asks for a project folder by name, use the alias map first. If the name is not listed, check `Areas/Projects/` before doing a wider vault search.

## Command locations

Commands are in the environment command directory. For this profile, that is `~/.config/opencode-profiles/golly/opencode/commands/`.

Available commands:
- `task.md` - add tasks
- `project-task.md` - add or update project-scoped tasks
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
- `evidence-pack.md` - build a role-focused evidence packet
- `evidence-gaps.md` - inspect gaps in the career evidence system

## Scripts (for command internals)

Commands use these scripts. Do not construct entry formats manually.

- `{baseDir}/scripts/add-entry.sh <section> <params...>` - validates, constructs, and inserts entries
- `{baseDir}/scripts/project-task.sh <add|move|done> <params...>` - manages project-scoped tasks inside project notes
- `{baseDir}/scripts/inbox-path.sh` - get current inbox path
- `{baseDir}/scripts/get-month-data.sh YYYY-MM` - extract month data
- `{baseDir}/scripts/sync-repo.sh <path> [status|commit|pull|push]` - git sync with safety
- `{baseDir}/scripts/lint-inbox.sh [YYYY-MM]` - audit inbox for format issues
- `{baseDir}/scripts/career-evidence/query.py` - query normalized evidence records
- `{baseDir}/scripts/career-evidence/pack.py` - build ranked evidence packets
- `{baseDir}/scripts/career-evidence/gaps.py` - report evidence gaps and weak spots
- `{baseDir}/scripts/career-evidence/stats.py` - summarize evidence counts and readiness

### add-entry.sh parameter reference

| section | args | example |
|---------|------|---------|
| notes | `<tag> <content>` | `notes coding "memory leak"` |
| tasks | `<description> [priority] [due]` | `tasks "fix bug" high 2026-01-10` |
| project task add | `<note> <next\|blocked\|later> <description> [priority] [due]` | `add note.md next "fix bug" high 2026-01-10` |
| project task move | `<note> <search> <next\|blocked\|later>` | `move note.md "fix bug" blocked` |
| project task done | `<note> <search> [done]` | `done note.md "fix bug" 2026-01-10` |
| finance | `<amount> <category> <item> [notes]` | `finance 50 food "lunch" "at work"` |
| savings | `<fund> <amount>` | `savings travel 3000` |
| gym | `<type> <duration> <exercises>` | `gym swim 60 "freestyle, drills"` |
| evening | `<type> [hours] <notes>` | `evening build 2 "worked on emulator"` |
| lists | `<tag> <content> [description]` | `lists reading "https://..." "article"` |

## Data formats

See `{baseDir}/references/data-formats.md` for entry specifications.
