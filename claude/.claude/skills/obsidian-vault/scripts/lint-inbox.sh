#!/bin/bash
# Audits an inbox file for format issues.
# Usage: lint-inbox.sh [YYYY-MM]
# Defaults to current month if no argument given.

SCRIPT_DIR="$(dirname "$0")"

if [[ -n "${1:-}" ]]; then
  VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"
  VAULT="${VAULT/#\~/$HOME}"
  INBOX_FILE="$VAULT/Inbox/$1.md"
else
  INBOX_FILE="$(bash "$SCRIPT_DIR/inbox-path.sh")"
fi

if [[ ! -f "$INBOX_FILE" ]]; then
  echo "error: file not found: $INBOX_FILE" >&2
  exit 1
fi

NOTE_TAGS="coding personal random work project"
LIST_TAGS="reading shopping watching ideas project podcast talk video"
CATEGORIES="food transport personal gifts health education entertainment utilities"
WORKOUT_TYPES="Swim Run Legs Push Pull"

ISSUES=0

report() {
  local line_num="$1" section="$2" msg="$3"
  echo "  line $line_num ($section): $msg"
  ISSUES=$((ISSUES + 1))
}

echo "Linting: $INBOX_FILE"
echo ""

CURRENT_SECTION=""
LINE_NUM=0

while IFS= read -r line; do
  LINE_NUM=$((LINE_NUM + 1))

  case "$line" in
    "##### Captured Tasks"*) CURRENT_SECTION="tasks" ;;
    "##### Finance"*)        CURRENT_SECTION="finance" ;;
    "##### Gym"*)            CURRENT_SECTION="gym" ;;
    "##### Evening"*)        CURRENT_SECTION="evening" ;;
    "##### Notes"*)          CURRENT_SECTION="notes" ;;
    "##### Lists"*)          CURRENT_SECTION="lists" ;;
    "##### "*)               CURRENT_SECTION="" ;;
    "<!--"*)                 continue ;;
  esac

  [[ -z "$CURRENT_SECTION" ]] && continue
  [[ "$line" =~ ^[[:space:]]*$ ]] && continue
  [[ "$line" =~ ^"#####" ]] && continue
  [[ "$line" =~ ^---[[:space:]]*$ ]] && continue

  case "$CURRENT_SECTION" in
    notes)
      if [[ "$line" =~ ^-\ \[date:: ]]; then
        if ! [[ "$line" =~ \[date::\ [0-9]{4}-[0-9]{2}-[0-9]{2}\] ]]; then
          report "$LINE_NUM" notes "malformed date field"
        fi
        tag_found=false
        for tag in $NOTE_TAGS; do
          if [[ "$line" == *"#${tag} "* || "$line" == *"#${tag}" ]]; then
            tag_found=true
            break
          fi
        done
        if ! $tag_found; then
          report "$LINE_NUM" notes "non-standard tag (valid: $NOTE_TAGS)"
        fi
      else
        report "$LINE_NUM" notes "entry doesn't start with '- [date::' (possible orphaned line)"
      fi
      ;;

    finance)
      if [[ "$line" =~ ^-.*\[spent:: ]]; then
        if ! [[ "$line" =~ \[spent::\ [0-9]+(\.[0-9]+)?\] ]]; then
          report "$LINE_NUM" finance "non-numeric spent amount"
        fi
        if [[ "$line" =~ \[category::\ ([a-z]+)\] ]]; then
          cat="${BASH_REMATCH[1]}"
          if ! echo "$CATEGORIES" | grep -Fqw "$cat"; then
            report "$LINE_NUM" finance "invalid category '$cat'"
          fi
        else
          report "$LINE_NUM" finance "missing or malformed category field"
        fi
      elif [[ "$line" =~ ^-.*\[savings:: ]]; then
        if ! [[ "$line" =~ \[amount::\ [0-9]+(\.[0-9]+)?\] ]]; then
          report "$LINE_NUM" finance "non-numeric savings amount"
        fi
      elif [[ "$line" =~ ^- ]]; then
        report "$LINE_NUM" finance "unrecognized entry format"
      fi
      ;;

    gym)
      if [[ "$line" =~ ^-.*\[workout:: ]]; then
        if [[ "$line" =~ \[workout::\ ([A-Za-z]+)\] ]]; then
          wtype="${BASH_REMATCH[1]}"
          if ! echo "$WORKOUT_TYPES" | grep -Fqw "$wtype"; then
            report "$LINE_NUM" gym "invalid workout type '$wtype' (valid: $WORKOUT_TYPES)"
          fi
        fi
        if ! [[ "$line" =~ \[duration::\ [0-9]+\] ]]; then
          report "$LINE_NUM" gym "missing or non-numeric duration"
        fi
      elif [[ "$line" =~ ^- ]]; then
        report "$LINE_NUM" gym "entry missing [workout::] field"
      fi
      ;;

    evening)
      if [[ "$line" =~ ^-.*\[evening:: ]]; then
        if [[ "$line" =~ \[evening::\ ([a-z]+)\] ]]; then
          etype="${BASH_REMATCH[1]}"
          if [[ "$etype" != "build" && "$etype" != "drift" ]]; then
            report "$LINE_NUM" evening "invalid type '$etype' (must be build/drift)"
          fi
          if [[ "$etype" == "build" ]] && ! [[ "$line" =~ \[project-hours:: ]]; then
            report "$LINE_NUM" evening "build entry missing [project-hours::]"
          fi
        fi
      elif [[ "$line" =~ ^- ]]; then
        report "$LINE_NUM" evening "entry missing [evening::] field"
      fi
      ;;

    tasks)
      if [[ "$line" =~ ^[[:space:]]*-\ \[.\] ]]; then
        :
      elif [[ "$line" =~ ^- ]]; then
        report "$LINE_NUM" tasks "entry doesn't look like a task checkbox"
      fi
      ;;

    lists)
      if [[ "$line" =~ ^-.*\[added:: ]]; then
        tag_found=false
        for tag in $LIST_TAGS; do
          if [[ "$line" == *"#${tag} "* || "$line" == *"#${tag}" ]]; then
            tag_found=true
            break
          fi
        done
        if ! $tag_found; then
          report "$LINE_NUM" lists "non-standard tag (valid: $LIST_TAGS)"
        fi
      elif [[ "$line" =~ ^- ]]; then
        report "$LINE_NUM" lists "entry missing [added::] field"
      fi
      ;;
  esac
done < "$INBOX_FILE"

echo ""
if [[ $ISSUES -eq 0 ]]; then
  echo "clean: no issues found"
  exit 0
else
  echo "found $ISSUES issue(s)"
  exit 1
fi
