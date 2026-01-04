#!/bin/bash
set -euo pipefail

MONTH="${1:-}"
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/dev/Obsidian}"

if [[ -z "$MONTH" ]]; then
    echo "Usage: get-month-data.sh YYYY-MM"
    echo "Example: get-month-data.sh 2025-12"
    exit 1
fi

INBOX_FILE="$VAULT/Inbox/$MONTH.md"

if [[ ! -f "$INBOX_FILE" ]]; then
    echo "Error: Inbox file not found: $INBOX_FILE"
    exit 1
fi

echo "=== Month Data: $MONTH ==="
echo ""

echo "## Spending by Category"
if grep -qE '\[spent::' "$INBOX_FILE" 2>/dev/null; then
    grep -E '\[spent::' "$INBOX_FILE" | \
        perl -ne 'if (/\[spent::\s*([\d.]+)\].*\[category::\s*(\w+)\]/) { print "$2 $1\n" }' | \
        awk '{
            categories[$1] += $2
            total += $2
        }
        END {
            for (cat in categories) {
                printf "  %s: %.2f\n", cat, categories[cat]
            }
            printf "  ---\n"
            printf "  TOTAL: %.2f\n", total
        }' | sort
else
    echo "  (none logged)"
fi

echo ""
echo "## Workouts by Type"
if grep -qE '\[workout::' "$INBOX_FILE" 2>/dev/null; then
    grep -E '\[workout::' "$INBOX_FILE" | \
        perl -ne 'if (/\[workout::\s*(\w+)\]/) { print "$1\n" }' | \
        sort | uniq -c | \
        awk '{ printf "  %s: %d sessions\n", $2, $1 }'
else
    echo "  (none logged)"
fi

echo ""
echo "## Evening Tracking"
BUILD_COUNT=$(grep -c '\[evening:: build\]' "$INBOX_FILE" 2>/dev/null || echo "0")
DRIFT_COUNT=$(grep -c '\[evening:: drift\]' "$INBOX_FILE" 2>/dev/null || echo "0")
PROJECT_HOURS=$(grep -E '\[project-hours::' "$INBOX_FILE" 2>/dev/null | \
    perl -ne 'if (/\[project-hours::\s*([\d.]+)\]/) { $sum += $1 } END { print $sum // 0 }')
PROJECT_HOURS=${PROJECT_HOURS:-0}

echo "  Build nights: $BUILD_COUNT"
echo "  Drift nights: $DRIFT_COUNT"
echo "  Project hours: $PROJECT_HOURS"
if [[ "$BUILD_COUNT" -gt 0 && "$DRIFT_COUNT" -gt 0 ]]; then
    RATIO=$(echo "scale=2; $BUILD_COUNT / $DRIFT_COUNT" | bc)
    echo "  Build/Drift ratio: $RATIO"
fi

echo ""
echo "## Tasks"
TOTAL_TASKS=$(grep -cE '^\s*- \[[ x]\]' "$INBOX_FILE" 2>/dev/null || echo "0")
COMPLETED_TASKS=$(grep -cE '^\s*- \[x\]' "$INBOX_FILE" 2>/dev/null || echo "0")
OPEN_TASKS=$((TOTAL_TASKS - COMPLETED_TASKS))
echo "  Total: $TOTAL_TASKS"
echo "  Completed: $COMPLETED_TASKS"
echo "  Open: $OPEN_TASKS"

echo ""
echo "## Savings Deposits"
if grep -qE '\[savings::' "$INBOX_FILE" 2>/dev/null; then
    grep -E '\[savings::' "$INBOX_FILE" | \
        perl -ne 'if (/\[savings::\s*(\w+)\].*\[amount::\s*([\d.]+)\]/) { print "$1 $2\n" }' | \
        awk '{
            funds[$1] += $2
            total += $2
        }
        END {
            for (fund in funds) {
                printf "  %s: %.2f\n", fund, funds[fund]
            }
            printf "  ---\n"
            printf "  TOTAL: %.2f\n", total
        }' | sort
else
    echo "  (none logged)"
fi

echo ""
echo "## Notes Count"
NOTES_COUNT=$(grep -cE '^\s*- \[date::.*\] #' "$INBOX_FILE" 2>/dev/null || echo "0")
echo "  Notes captured: $NOTES_COUNT"

echo ""
echo "## List Items Count"
LIST_COUNT=$(grep -cE '^\s*- \[added::' "$INBOX_FILE" 2>/dev/null || echo "0")
echo "  Items added: $LIST_COUNT"
