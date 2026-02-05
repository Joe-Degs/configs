#!/bin/bash
# PostToolUse hook: log TaskCreate to ScratchPad hook-log
LOG_FILE="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}/ScratchPad/hook-log.md"
SUBJECT=$(jq -r '.tool_input.subject // empty')
[[ -z "$SUBJECT" ]] && exit 0
[[ ! -f "$LOG_FILE" ]] && exit 0

TODAY=$(date +%Y-%m-%d)
ENTRY="- [ ] [date:: ${TODAY}] ${SUBJECT}"
MARKER="<!-- hook-tasks -->"

MARKER_LINE=$(grep -Fn "$MARKER" "$LOG_FILE" | head -1 | cut -d: -f1)
[[ -z "$MARKER_LINE" ]] && exit 0

{
  head -n "$((MARKER_LINE - 1))" "$LOG_FILE"
  printf '%s\n' "$ENTRY"
  tail -n +"$MARKER_LINE" "$LOG_FILE"
} > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
exit 0
