---
description: Sync vault or configs to GitHub. Usage: /sync <obsidian|configs>
---

Sync a git repository with GitHub, with safety checks and confirmation.

## Usage

- `/sync obsidian` - sync Obsidian vault
- `/sync configs` - sync dotfiles/configs repo
- `/sync vault` - alias for obsidian
- `/sync dotfiles` - alias for configs

## Parse input

- **target**: obsidian/vault or configs/dotfiles
- Map target to repo path:
  - obsidian/vault → `$OBSIDIAN_VAULT_PATH` (default: `~/dev/Obsidian`)
  - configs/dotfiles → `$DOTFILES_PATH` (default: `~/dev/configs`)

## Process

### Step 1: Show status

Run status mode first to show what would be synced:

```bash
bash ~/.claude/skills/obsidian-vault/scripts/sync-repo.sh "$REPO_PATH" status
```

Present the output to user showing:
- local changes (if any)
- remote changes (if any)

### Step 2: Ask for confirmation

If there are local changes to commit, ask user:
- "Proceed with sync?"
- Allow user to abort

If there are remote changes that might conflict, warn user.

### Step 3: Execute sync

Only after user confirms:

```bash
bash ~/.claude/skills/obsidian-vault/scripts/sync-repo.sh "$REPO_PATH"
```

### Step 4: Handle conflicts

If rebase conflict occurs:
- Script aborts rebase and reports conflicted files
- Present the conflict to user
- Discuss options together (keep ours, keep theirs, manual merge, abort)
- Execute the agreed resolution strategy
- User and Claude collaborate to resolve

## Confirm

```
Synced: [repo-name] → origin/[branch]
```

Or if nothing to sync:

```
Already up to date: [repo-name]
```
