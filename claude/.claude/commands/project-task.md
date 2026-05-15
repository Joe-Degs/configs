---
description: Add or update a project-scoped Obsidian task. Usage: /project-task <add|move|done> ...
---

Manage tasks inside project notes instead of the global inbox.

## Usage

- `/project-task add Areas/Projects/Hubtel-ML-Agents/selfhosted-llm/selfhosted-llm-devlog-2026-05-12 next "inspect browser rerank answer quality" medium`
- `/project-task add Areas/Projects/Hubtel-ML-Agents/selfhosted-llm/research-agent-evals-and-retrieval-2026-05-13 blocked "wire Langfuse dataset evals" high 2026-05-20`
- `/project-task move Areas/Projects/Hubtel-ML-Agents/selfhosted-llm/selfhosted-llm-devlog-2026-05-12 "answer quality" later`
- `/project-task done Areas/Projects/Hubtel-ML-Agents/selfhosted-llm/selfhosted-llm-devlog-2026-05-12 "answer quality"`

## Parse input

- **operation**: `add`, `move`, or `done`
- **note**: vault-relative or absolute path to an existing markdown note; `.md` is optional
- **status**: `next`, `blocked`, or `later` for `add` and `move`
- **description**: task text for `add`
- **search**: case-insensitive text used to find one open project task for `move` or `done`
- **priority**: `high`, `medium`, or `low` for `add` only
- **due**: `YYYY-MM-DD` for `add` only
- **done date**: `YYYY-MM-DD` for `done`; default is today

If the project note is clear from context, infer it. If multiple notes could match, ask which note to use. Do not fall back to `/task` for project-specific work.

## Date and priority parsing

Use the same parsing rules as `/task` before calling the script:

- normalize explicit dates to `YYYY-MM-DD`
- `today`, `tonight`, `EOD`, and `COB` mean today
- `tomorrow`, `tmr`, and `tmrw` mean today + 1 day
- `this week` means Friday of the current week
- `next week` means Friday of next week
- `urgent`, `ASAP`, `now`, and `critical` mean high priority; if due is missing, set due to today
- `low priority` and `not urgent` mean low priority

## Execute

Important guardrails:
- execute the bash script directly, do not use the Task tool or any subagent
- project-specific tasks go into project notes, never the global inbox
- split multiple tasks and run one `/project-task add` per entry
- only ask a question when the note, description, or match is ambiguous after applying the rules above

```bash
bash ~/.claude/skills/obsidian-vault/scripts/project-task.sh add <note> <next|blocked|later> "<description>" [priority] [due-date]
bash ~/.claude/skills/obsidian-vault/scripts/project-task.sh move <note> "<search>" <next|blocked|later>
bash ~/.claude/skills/obsidian-vault/scripts/project-task.sh done <note> "<search>" [done-date]
```

The script creates a `## project tasks` section when needed and keeps tasks under `### next`, `### blocked`, `### later`, and `### done`.

## Confirm

Report the `ok: ...` line from script output. Examples:

```text
ok: added [next] - [ ] inspect browser rerank answer quality 🔼
ok: moved [next -> later] - [ ] inspect browser rerank answer quality 🔼
ok: completed [later -> done] - [x] inspect browser rerank answer quality 🔼 ✅ 2026-05-15
```
