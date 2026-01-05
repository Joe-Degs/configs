#!/bin/bash
# Returns path to current month's inbox file
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"
VAULT="${VAULT/#\~/$HOME}"
echo "$VAULT/Inbox/$(date +%Y-%m).md"
