#!/bin/bash
set -euo pipefail

die() { echo "error: $*" >&2; exit 1; }
today() { date +%Y-%m-%d; }
is_date() { [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; }

usage() {
  cat >&2 <<'EOF'
usage:
  project-task.sh add <note> <next|blocked|later> <description> [high|medium|low] [YYYY-MM-DD]
  project-task.sh move <note> <search> <next|blocked|later>
  project-task.sh done <note> <search> [YYYY-MM-DD]
EOF
  exit 1
}

resolve_note() {
  local note_path="${1:-}"
  [[ -n "$note_path" ]] || die "missing note path"

  note_path="${note_path/#\~/$HOME}"
  if [[ "$note_path" != /* ]]; then
    local vault="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"
    vault="${vault/#\~/$HOME}"
    note_path="$vault/$note_path"
  fi

  [[ "$note_path" == *.md ]] || note_path="${note_path}.md"
  [[ -f "$note_path" ]] || die "note not found: $note_path"
  printf '%s\n' "$note_path"
}

normalize_active_status() {
  local status="${1:-}"
  status="$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')"
  case "$status" in
    next|blocked|later) printf '%s\n' "$status" ;;
    done) die "use the done command to complete project tasks" ;;
    *) die "invalid status '$status' (valid: next, blocked, later)" ;;
  esac
}

priority_marker() {
  case "$1" in
    high) printf ' ⏫' ;;
    medium) printf ' 🔼' ;;
    low) printf ' 🔽' ;;
    *) die "invalid priority '$1' (valid: high, medium, low)" ;;
  esac
}

replace_with_awk() {
  local note="$1"
  shift
  local tmp
  tmp="$(mktemp "${note}.tmp.XXXXXX")"
  if "$@" "$note" > "$tmp"; then
    mv "$tmp" "$note"
  else
    rm -f "$tmp"
    die "failed to update $note"
  fi
}

has_project_tasks_block() {
  awk '
    tolower($0) ~ /^##[[:space:]]+project tasks[[:space:]]*$/ { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$1"
}

has_status_heading() {
  local note="$1" status="$2"
  awk -v wanted="### $status" '
    BEGIN { wanted = tolower(wanted); in_project_tasks = 0; found = 0 }
    tolower($0) ~ /^##[[:space:]]+project tasks[[:space:]]*$/ { in_project_tasks = 1; next }
    in_project_tasks && /^##[[:space:]]+/ { in_project_tasks = 0 }
    in_project_tasks && tolower($0) == wanted { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$note"
}

insert_missing_status_heading() {
  local note="$1" status="$2"
  replace_with_awk "$note" awk -v heading="### $status" '
    BEGIN { in_project_tasks = 0; inserted = 0 }
    tolower($0) ~ /^##[[:space:]]+project tasks[[:space:]]*$/ { in_project_tasks = 1; print; next }
    in_project_tasks && /^##[[:space:]]+/ {
      if (!inserted) {
        print ""
        print heading
        print ""
        inserted = 1
      }
      in_project_tasks = 0
    }
    { print }
    END {
      if (in_project_tasks && !inserted) {
        print ""
        print heading
        print ""
      }
    }
  '
}

ensure_project_task_scaffold() {
  local note="$1"
  if ! has_project_tasks_block "$note"; then
    {
      printf '\n## project tasks\n\n'
      printf '### next\n\n'
      printf '### blocked\n\n'
      printf '### later\n\n'
      printf '### done\n'
    } >> "$note"
    return
  fi

  local status
  for status in next blocked later done; do
    if ! has_status_heading "$note" "$status"; then
      insert_missing_status_heading "$note" "$status"
    fi
  done
}

insert_under_status() {
  local note="$1" status="$2" entry="$3"
  replace_with_awk "$note" awk -v wanted="### $status" -v entry="$entry" '
    BEGIN { wanted = tolower(wanted); inserted = 0 }
    {
      print
      if (!inserted && tolower($0) == wanted) {
        print entry
        inserted = 1
      }
    }
    END { if (!inserted) exit 2 }
  '
}

find_open_task() {
  local note="$1" search="$2"
  [[ -n "$search" ]] || die "missing search text"

  local matches count
  matches="$(awk -v search="$search" '
    BEGIN { needle = tolower(search); in_project_tasks = 0; status = "" }
    tolower($0) ~ /^##[[:space:]]+project tasks[[:space:]]*$/ { in_project_tasks = 1; status = ""; next }
    in_project_tasks && /^##[[:space:]]+/ { in_project_tasks = 0; status = "" }
    in_project_tasks {
      lowered = tolower($0)
      if (lowered ~ /^###[[:space:]]+(next|blocked|later|done)[[:space:]]*$/) {
        status = lowered
        sub(/^###[[:space:]]+/, "", status)
        sub(/[[:space:]]+$/, "", status)
        next
      }
      if (status != "" && $0 ~ /^[[:space:]]*-[[:space:]]*\[[ xX]\][[:space:]]+/) {
        if ($0 ~ /^[[:space:]]*-[[:space:]]*\[[xX]\]/) next
        if (index(lowered, needle) > 0) {
          printf "%d\t%s\t%s\n", NR, status, $0
        }
      }
    }
  ' "$note")"

  count="$(printf '%s\n' "$matches" | awk 'NF { count++ } END { print count + 0 }')"
  case "$count" in
    0) die "no open project task found matching '$search' in $note" ;;
    1) printf '%s\n' "$matches" ;;
    *)
      echo "error: multiple open project tasks found matching '$search' in $note" >&2
      printf '%s\n' "$matches" | awk -F '\t' '{ printf "  line %s [%s] %s\n", $1, $2, $3 }' >&2
      exit 1
      ;;
  esac
}

remove_line_and_insert() {
  local note="$1" line_num="$2" status="$3" entry="$4"
  replace_with_awk "$note" awk -v delete_line="$line_num" -v wanted="### $status" -v entry="$entry" '
    BEGIN { wanted = tolower(wanted); inserted = 0 }
    NR == delete_line { next }
    {
      print
      if (!inserted && tolower($0) == wanted) {
        print entry
        inserted = 1
      }
    }
    END { if (!inserted) exit 2 }
  '
}

format_task() {
  local description="$1"
  shift
  [[ -n "$description" ]] || die "missing description"

  local priority="" due="" arg
  for arg in "$@"; do
    case "$arg" in
      high|medium|low) priority="$(priority_marker "$arg")" ;;
      *)
        if is_date "$arg"; then
          due=" 📅 $arg"
        else
          die "unknown task option '$arg' (expected high, medium, low, or YYYY-MM-DD)"
        fi
        ;;
    esac
  done

  printf -- '- [ ] %s%s%s\n' "$description" "$priority" "$due"
}

mark_task_done() {
  local task_line="$1" done_date="$2"
  if [[ "$task_line" =~ ^([[:space:]]*)-\ \[\ \](.*)$ ]]; then
    task_line="${BASH_REMATCH[1]}- [x]${BASH_REMATCH[2]}"
  else
    die "task is not an open checkbox: $task_line"
  fi

  task_line="$(printf '%s' "$task_line" | sed -E 's/[[:space:]]+✅[[:space:]][0-9]{4}-[0-9]{2}-[0-9]{2}//g')"
  printf '%s ✅ %s\n' "$task_line" "$done_date"
}

command="${1:-}"
[[ -n "$command" ]] || usage
shift

case "$command" in
  add)
    [[ $# -ge 3 ]] || usage
    note="$(resolve_note "$1")"
    status="$(normalize_active_status "$2")"
    description="$3"
    shift 3
    ensure_project_task_scaffold "$note"
    entry="$(format_task "$description" "$@")"
    insert_under_status "$note" "$status" "$entry"
    echo "ok: added [$status] $entry"
    ;;

  move)
    [[ $# -eq 3 ]] || usage
    note="$(resolve_note "$1")"
    search="$2"
    status="$(normalize_active_status "$3")"
    ensure_project_task_scaffold "$note"
    match="$(find_open_task "$note" "$search")"
    line_num="$(printf '%s\n' "$match" | cut -f1)"
    current_status="$(printf '%s\n' "$match" | cut -f2)"
    task_line="$(printf '%s\n' "$match" | cut -f3-)"
    remove_line_and_insert "$note" "$line_num" "$status" "$task_line"
    echo "ok: moved [$current_status -> $status] $task_line"
    ;;

  done)
    [[ $# -ge 2 && $# -le 3 ]] || usage
    note="$(resolve_note "$1")"
    search="$2"
    done_date="${3:-$(today)}"
    is_date "$done_date" || die "invalid done date '$done_date' (expected YYYY-MM-DD)"
    ensure_project_task_scaffold "$note"
    match="$(find_open_task "$note" "$search")"
    line_num="$(printf '%s\n' "$match" | cut -f1)"
    current_status="$(printf '%s\n' "$match" | cut -f2)"
    task_line="$(printf '%s\n' "$match" | cut -f3-)"
    done_entry="$(mark_task_done "$task_line" "$done_date")"
    remove_line_and_insert "$note" "$line_num" done "$done_entry"
    echo "ok: completed [$current_status -> done] $done_entry"
    ;;

  *) usage ;;
esac
