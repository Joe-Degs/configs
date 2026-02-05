#!/bin/bash
# Returns path to inbox file for a month
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"
VAULT="${VAULT/#\~/$HOME}"
MONTH="${1:-}"

if [[ -z "$MONTH" ]]; then
  MONTH=$(date +%Y-%m)
elif ! [[ "$MONTH" =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
  echo "error: invalid month '$MONTH' (expected YYYY-MM)" >&2
  exit 1
fi

echo "$VAULT/Inbox/$MONTH.md"
