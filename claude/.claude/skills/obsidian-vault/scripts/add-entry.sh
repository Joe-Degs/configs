#!/bin/bash
# Usage: add-entry.sh <section> "<entry>"
# Sections: tasks, finance, gym, evening, notes, lists

SECTION="$1"
ENTRY="$2"

if [[ -z "$SECTION" || -z "$ENTRY" ]]; then
  echo "Usage: add-entry.sh <section> \"<entry>\"" >&2
  echo "Sections: tasks, finance, gym, evening, notes, lists" >&2
  exit 1
fi

SCRIPT_DIR="$(dirname "$0")"
INBOX_FILE="$(bash "$SCRIPT_DIR/inbox-path.sh")"

if [[ ! -f "$INBOX_FILE" ]]; then
  echo "Inbox file not found: $INBOX_FILE" >&2
  echo "Creating new inbox file..." >&2
  bash "$SCRIPT_DIR/create-inbox.sh"
fi

case "$SECTION" in
  tasks)   MARKER="<!-- QuickAdd adds tasks here automatically -->" ;;
  finance) MARKER="<!-- QuickAdd adds spending logs here -->" ;;
  gym)     MARKER="<!-- QuickAdd adds workout logs here -->" ;;
  evening) MARKER="<!-- Log how you spent your evening" ;;
  notes)   MARKER="<!-- QuickAdd adds brain farts" ;;
  lists)   MARKER="<!-- QuickAdd adds list items here" ;;
  *)       echo "Unknown section: $SECTION" >&2
           echo "Valid sections: tasks, finance, gym, evening, notes, lists" >&2
           exit 1 ;;
esac

# Check if marker exists
if ! grep -q "$MARKER" "$INBOX_FILE"; then
  echo "Section marker not found in inbox file" >&2
  exit 1
fi

# Insert entry before the marker using perl (works on macOS)
# Match marker at start of line, capture rest of line
perl -i -pe "s|^(\Q$MARKER\E.*)|$ENTRY\n\$1|" "$INBOX_FILE"

echo "Added to $SECTION in $(basename "$INBOX_FILE")"
