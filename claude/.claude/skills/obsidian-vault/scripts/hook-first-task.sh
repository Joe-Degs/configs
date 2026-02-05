#!/bin/bash
# PreToolUse hook: prompt for work summary before first TaskCreate
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
FLAG="/tmp/claude-session-${SESSION_ID}-tasks-started"

if [[ ! -f "$FLAG" ]]; then
  touch "$FLAG"
  echo "What are you about to work on? (This will be logged as a #work note)" >&2
  exit 2
fi
exit 0
