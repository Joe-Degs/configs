---
description: Inspect gaps and weak spots in the career evidence system. Usage: /evidence-gaps
---

Inspect unresolved gaps in the career evidence system.

## Usage

- `/evidence-gaps`

## Parse input

- no required arguments
- use `$OBSIDIAN_VAULT_PATH` when set, otherwise default to `/home/joe/Obsidian`

## Process

### Step 1: Run the shared gaps script

```bash
python3 ~/.config/opencode-profiles/golly/opencode/skills/obsidian-vault/scripts/career-evidence/gaps.py --vault-path "$OBSIDIAN_VAULT_PATH" --output-format json
```

If `$OBSIDIAN_VAULT_PATH` is unset, use `/home/joe/Obsidian`.

### Step 2: Present the result

Summarize:
- unresolved follow-up items
- partial records
- unsafe records
- non-resume-ready records
- records with missing dates

Keep the output concise and ranked by what blocks reuse most.

## Confirm

```text
Reported career evidence gaps
```
