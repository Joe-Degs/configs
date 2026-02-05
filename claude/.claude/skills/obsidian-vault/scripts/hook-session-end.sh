#!/bin/bash
# SessionEnd hook: auto-log session info to ScratchPad hook-log
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
CWD=$(echo "$INPUT" | jq -r '.cwd')
REASON=$(echo "$INPUT" | jq -r '.reason')
FLAG="/tmp/claude-session-${SESSION_ID}-tasks-started"

if [[ -f "$FLAG" ]]; then
  rm -f "$FLAG"
  LOG_FILE="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}/ScratchPad/hook-log.md"
  [[ ! -f "$LOG_FILE" ]] && exit 0

  TODAY=$(date +%Y-%m-%d)
  PROJECT=$(basename "$CWD")
  ENTRY="- [date:: ${TODAY}] session ended in ${PROJECT} (${REASON}), tasks were created"
  MARKER="<!-- hook-sessions -->"

  MARKER_LINE=$(grep -Fn "$MARKER" "$LOG_FILE" | head -1 | cut -d: -f1)
  [[ -z "$MARKER_LINE" ]] && exit 0

  {
    head -n "$((MARKER_LINE - 1))" "$LOG_FILE"
    printf '%s\n' "$ENTRY"
    tail -n +"$MARKER_LINE" "$LOG_FILE"
  } > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
exit 0
