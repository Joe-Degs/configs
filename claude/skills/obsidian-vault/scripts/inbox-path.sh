#!/bin/bash
# Returns path to current month's inbox file
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"
echo "$VAULT/Inbox/$(date +%Y-%m).md"
