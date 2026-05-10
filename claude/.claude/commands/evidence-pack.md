---
description: Build a ranked career evidence packet for a role or job. Usage: /evidence-pack <role|keywords>
---

Build a ranked career evidence packet from the vault evidence system.

## Usage

- `/evidence-pack senior python platform engineer`
- `/evidence-pack python ci/cd backend`
- `/evidence-pack`

## Parse input

- treat the input as a target role or keyword phrase
- if input is omitted, infer the target role from conversation context or ask one short question
- use `$OBSIDIAN_VAULT_PATH` when set, otherwise default to `/home/joe/Obsidian`

## Process

### Step 1: Build the packet

Run the shared evidence packet script:

```bash
python3 ~/.config/opencode-profiles/golly/opencode/skills/obsidian-vault/scripts/career-evidence/pack.py --vault-path "$OBSIDIAN_VAULT_PATH" --role "$INPUT" --output-format json
```

If `$OBSIDIAN_VAULT_PATH` is unset, use `/home/joe/Obsidian`.

### Step 2: Present the result

Summarize:
- selected work history
- selected projects
- strongest metrics
- gaps

Keep the output compact. Do not dump raw JSON unless the user asks.

### Step 3: Offer next actions

Offer natural next steps such as:
- tailor a resume from this packet
- inspect evidence gaps
- save nothing and continue in chat

## Confirm

```text
Built evidence packet for [target]
```
