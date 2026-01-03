#!/bin/bash
# Creates new month inbox file from template

VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"
INBOX_FILE="$VAULT/Inbox/$(date +%Y-%m).md"
SCRIPT_DIR="$(dirname "$0")"
TEMPLATE="$SCRIPT_DIR/../assets/inbox-template.md"

if [[ -f "$INBOX_FILE" ]]; then
  echo "Inbox file already exists: $INBOX_FILE"
  exit 0
fi

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Template not found: $TEMPLATE" >&2
  exit 1
fi

# Ensure Inbox directory exists
mkdir -p "$(dirname "$INBOX_FILE")"

# Replace placeholders in template
MONTH_NAME=$(date +%B)
YEAR=$(date +%Y)
sed "s/{{MONTH}}/$MONTH_NAME/g; s/{{YEAR}}/$YEAR/g" "$TEMPLATE" > "$INBOX_FILE"

echo "Created: $INBOX_FILE"
