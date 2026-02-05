#!/bin/bash
# Usage: add-entry.sh <section> <params...>
#
#   notes    <tag> <content> [date]
#   tasks    <description> [priority] [due-date]
#   finance  <amount> <category> <item> [notes] [date]
#   savings  <fund> <amount> [date]
#   gym      <type> <duration> <exercises> [date]
#   evening  <type> [hours] <notes> [date]
#   lists    <tag> <content> [description] [date]

die() { echo "error: $*" >&2; exit 1; }
today() { date +%Y-%m-%d; }
current_month() { date +%Y-%m; }
is_numeric() { [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]; }
is_date() { [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; }
month_from_date() { echo "${1:0:7}"; }
target_month_for_date() {
  local entry_date="$1"
  local entry_month
  local current
  entry_month="$(month_from_date "$entry_date")"
  current="$(current_month)"
  if [[ "$entry_month" < "$current" ]]; then
    echo "$entry_month"
  fi
}

SECTION="${1:-}"
[[ -z "$SECTION" ]] && die "usage: add-entry.sh <section> <params...>"
shift

SCRIPT_DIR="$(dirname "$0")"

NOTE_TAGS="coding personal random work project"
LIST_TAGS="reading shopping watching ideas project podcast talk video"
CATEGORIES="food transport personal gifts health education entertainment utilities"
WORKOUT_TYPES="swim run legs push pull"
TARGET_MONTH=""

case "$SECTION" in
  notes)
    TAG="${1:-}"; [[ -z "$TAG" ]] && die "notes: missing tag"
    TAG="${TAG#\#}"
    shift
    ARGS=("$@")
    DATE=""
    if [[ ${#ARGS[@]} -gt 0 ]]; then
      LAST_INDEX=$((${#ARGS[@]} - 1))
      LAST="${ARGS[$LAST_INDEX]}"
      if is_date "$LAST"; then
        DATE="$LAST"
        unset 'ARGS[$LAST_INDEX]'
      fi
    fi
    CONTENT="${ARGS[*]}"; [[ -z "$CONTENT" ]] && die "notes: missing content"
    echo "$NOTE_TAGS" | grep -Fqw "$TAG" || die "notes: invalid tag '$TAG' (valid: $NOTE_TAGS)"
    ENTRY_DATE="${DATE:-$(today)}"
    ENTRY="- [date:: ${ENTRY_DATE}] #${TAG} ${CONTENT}"
    TARGET_MONTH="$(target_month_for_date "$ENTRY_DATE")"
    MARKER="<!-- QuickAdd adds brain farts"
    ;;

  tasks)
    DESC="${1:-}"; [[ -z "$DESC" ]] && die "tasks: missing description"
    shift
    PRIORITY="" DUE=""
    for arg in "$@"; do
      case "$arg" in
        high)   PRIORITY=" ⏫" ;;
        medium) PRIORITY=" 🔼" ;;
        low)    PRIORITY=" 🔽" ;;
        *)      is_date "$arg" && DUE=" 📅 $arg" ;;
      esac
    done
    ENTRY="- [ ] ${DESC}${PRIORITY}${DUE}"
    TARGET_MONTH=""
    MARKER="<!-- QuickAdd adds tasks here automatically -->"
    ;;

  finance)
    AMOUNT="${1:-}"; [[ -z "$AMOUNT" ]] && die "finance: missing amount"
    shift
    CATEGORY="${1:-}"; [[ -z "$CATEGORY" ]] && die "finance: missing category"
    shift
    ITEM="${1:-}"; [[ -z "$ITEM" ]] && die "finance: missing item"
    shift
    ARGS=("$@")
    DATE=""
    if [[ ${#ARGS[@]} -gt 0 ]]; then
      LAST_INDEX=$((${#ARGS[@]} - 1))
      LAST="${ARGS[$LAST_INDEX]}"
      if is_date "$LAST"; then
        DATE="$LAST"
        unset 'ARGS[$LAST_INDEX]'
      fi
    fi
    NOTES="${ARGS[*]}"
    is_numeric "$AMOUNT" || die "finance: amount '$AMOUNT' is not numeric"
    echo "$CATEGORIES" | grep -Fqw "$CATEGORY" || die "finance: invalid category '$CATEGORY' (valid: $CATEGORIES)"
    ENTRY_DATE="${DATE:-$(today)}"
    ENTRY="- ${ITEM} [spent:: ${AMOUNT}] [item:: ${ITEM}] [category:: ${CATEGORY}] [date:: ${ENTRY_DATE}]"
    [[ -n "$NOTES" ]] && ENTRY="${ENTRY} - ${NOTES}"
    TARGET_MONTH="$(target_month_for_date "$ENTRY_DATE")"
    MARKER="<!-- QuickAdd adds spending logs here -->"
    ;;

  savings)
    FUND="${1:-}"; [[ -z "$FUND" ]] && die "savings: missing fund name"
    shift
    AMOUNT="${1:-}"; [[ -z "$AMOUNT" ]] && die "savings: missing amount"
    shift
    DATE="${1:-}"
    if [[ -n "$DATE" ]] && ! is_date "$DATE"; then
      die "savings: invalid date '$DATE' (expected YYYY-MM-DD)"
    fi
    is_numeric "$AMOUNT" || die "savings: amount '$AMOUNT' is not numeric"
    FUND=$(echo "$FUND" | tr '[:upper:]' '[:lower:]')
    ENTRY_DATE="${DATE:-$(today)}"
    ENTRY="- [savings:: ${FUND}] [amount:: ${AMOUNT}] [date:: ${ENTRY_DATE}]"
    TARGET_MONTH="$(target_month_for_date "$ENTRY_DATE")"
    MARKER="<!-- QuickAdd adds spending logs here -->"
    ;;

  gym)
    TYPE="${1:-}"; [[ -z "$TYPE" ]] && die "gym: missing type"
    shift
    DURATION="${1:-}"; [[ -z "$DURATION" ]] && die "gym: missing duration"
    shift
    ARGS=("$@")
    DATE=""
    if [[ ${#ARGS[@]} -gt 0 ]]; then
      LAST_INDEX=$((${#ARGS[@]} - 1))
      LAST="${ARGS[$LAST_INDEX]}"
      if is_date "$LAST"; then
        DATE="$LAST"
        unset 'ARGS[$LAST_INDEX]'
      fi
    fi
    EXERCISES="${ARGS[*]}"; [[ -z "$EXERCISES" ]] && die "gym: missing exercises"
    is_numeric "$DURATION" || die "gym: duration '$DURATION' is not numeric"
    TYPE_LOWER=$(echo "$TYPE" | tr '[:upper:]' '[:lower:]')
    echo "$WORKOUT_TYPES" | grep -Fqw "$TYPE_LOWER" || die "gym: invalid type '$TYPE' (valid: $WORKOUT_TYPES)"
    TYPE_CAP="$(echo "${TYPE_LOWER:0:1}" | tr '[:lower:]' '[:upper:]')${TYPE_LOWER:1}"
    case "$TYPE_LOWER" in
      swim) DESC_PREFIX="swim session" ;;
      run)  DESC_PREFIX="run session" ;;
      legs) DESC_PREFIX="leg day" ;;
      push) DESC_PREFIX="push session" ;;
      pull) DESC_PREFIX="pull session" ;;
    esac
    ENTRY_DATE="${DATE:-$(today)}"
    ENTRY="- ${DESC_PREFIX} [workout:: ${TYPE_CAP}] [exercises:: ${EXERCISES}] [duration:: ${DURATION}] [date:: ${ENTRY_DATE}]"
    TARGET_MONTH="$(target_month_for_date "$ENTRY_DATE")"
    MARKER="<!-- QuickAdd adds workout logs here -->"
    ;;

  evening)
    TYPE="${1:-}"; [[ -z "$TYPE" ]] && die "evening: missing type (build/drift)"
    shift
    [[ "$TYPE" == "build" || "$TYPE" == "drift" ]] || die "evening: type must be 'build' or 'drift'"
    if [[ "$TYPE" == "build" ]]; then
      HOURS="${1:-}"; [[ -z "$HOURS" ]] && die "evening build: missing project-hours"
      is_numeric "$HOURS" || die "evening: hours '$HOURS' is not numeric"
      shift
      ARGS=("$@")
      DATE=""
      if [[ ${#ARGS[@]} -gt 0 ]]; then
        LAST_INDEX=$((${#ARGS[@]} - 1))
        LAST="${ARGS[$LAST_INDEX]}"
        if is_date "$LAST"; then
          DATE="$LAST"
          unset 'ARGS[$LAST_INDEX]'
        fi
      fi
      NOTES="${ARGS[*]}"; [[ -z "$NOTES" ]] && die "evening: missing notes"
      ENTRY_DATE="${DATE:-$(today)}"
      ENTRY="- [evening:: build] [date:: ${ENTRY_DATE}] [project-hours:: ${HOURS}] [notes:: ${NOTES}]"
    else
      ARGS=("$@")
      DATE=""
      if [[ ${#ARGS[@]} -gt 0 ]]; then
        LAST_INDEX=$((${#ARGS[@]} - 1))
        LAST="${ARGS[$LAST_INDEX]}"
        if is_date "$LAST"; then
          DATE="$LAST"
          unset 'ARGS[$LAST_INDEX]'
        fi
      fi
      NOTES="${ARGS[*]}"; [[ -z "$NOTES" ]] && die "evening: missing notes"
      ENTRY_DATE="${DATE:-$(today)}"
      ENTRY="- [evening:: drift] [date:: ${ENTRY_DATE}] [notes:: ${NOTES}]"
    fi
    TARGET_MONTH="$(target_month_for_date "$ENTRY_DATE")"
    MARKER="<!-- Log how you spent your evening"
    ;;

  lists)
    TAG="${1:-}"; [[ -z "$TAG" ]] && die "lists: missing tag"
    TAG="${TAG#\#}"
    shift
    CONTENT="${1:-}"; [[ -z "$CONTENT" ]] && die "lists: missing content"
    shift
    ARGS=("$@")
    DATE=""
    if [[ ${#ARGS[@]} -gt 0 ]]; then
      LAST_INDEX=$((${#ARGS[@]} - 1))
      LAST="${ARGS[$LAST_INDEX]}"
      if is_date "$LAST"; then
        DATE="$LAST"
        unset 'ARGS[$LAST_INDEX]'
      fi
    fi
    DESC="${ARGS[*]}"
    echo "$LIST_TAGS" | grep -Fqw "$TAG" || die "lists: invalid tag '$TAG' (valid: $LIST_TAGS)"
    ENTRY_DATE="${DATE:-$(today)}"
    ENTRY="- [added:: ${ENTRY_DATE}] #${TAG} ${CONTENT}"
    [[ -n "$DESC" ]] && ENTRY="${ENTRY} - ${DESC}"
    TARGET_MONTH="$(target_month_for_date "$ENTRY_DATE")"
    MARKER="<!-- QuickAdd adds list items here"
    ;;

  *) die "unknown section '$SECTION' (valid: notes, tasks, finance, savings, gym, evening, lists)" ;;
esac

if [[ -n "$TARGET_MONTH" ]]; then
  INBOX_FILE="$(bash "$SCRIPT_DIR/inbox-path.sh" "$TARGET_MONTH")"
else
  INBOX_FILE="$(bash "$SCRIPT_DIR/inbox-path.sh")"
fi

if [[ ! -f "$INBOX_FILE" ]]; then
  if [[ -n "$TARGET_MONTH" ]]; then
    bash "$SCRIPT_DIR/create-inbox.sh" "$TARGET_MONTH"
  else
    bash "$SCRIPT_DIR/create-inbox.sh"
  fi
fi

ENTRY=$(printf '%s' "$ENTRY" | tr '\n' ' ')

MARKER_LINE=$(grep -Fn "$MARKER" "$INBOX_FILE" | head -1 | cut -d: -f1)
[[ -z "${MARKER_LINE:-}" ]] && die "section marker not found in $INBOX_FILE"

{
  head -n "$((MARKER_LINE - 1))" "$INBOX_FILE"
  printf '%s\n' "$ENTRY"
  tail -n +"$MARKER_LINE" "$INBOX_FILE"
} > "$INBOX_FILE.tmp" && mv "$INBOX_FILE.tmp" "$INBOX_FILE"

if grep -Fq -- "$ENTRY" "$INBOX_FILE"; then
  echo "ok: $ENTRY"
else
  die "entry not found after insertion"
fi
