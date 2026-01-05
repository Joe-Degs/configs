#!/bin/bash
# Usage: sync-repo.sh <repo-path> [status|commit|pull|push]
# Modes:
#   status - show what would be synced (no changes)
#   commit - stage and commit local changes
#   pull   - fetch and rebase/merge remote changes
#   push   - push to remote
#   (no mode) - full sync: commit + pull + push

set -e

REPO="$1"
MODE="${2:-full}"

if [[ -z "$REPO" ]]; then
  echo "Usage: sync-repo.sh <repo-path> [status|commit|pull|push]" >&2
  exit 1
fi

detect_device() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux)  echo "linux" ;;
    *)      echo "unknown" ;;
  esac
}

cd "$REPO" || { echo "Repository not found: $REPO" >&2; exit 1; }

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Not a git repository: $REPO" >&2
  exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
REPO_NAME=$(basename "$REPO")

case "$MODE" in
  status)
    echo "=== Repo: $REPO_NAME ==="
    echo "=== Branch: $BRANCH ==="
    echo ""
    if [[ -n $(git status --porcelain) ]]; then
      echo "Local changes:"
      git status --short
      echo ""
      STATS=$(git diff --stat | tail -1)
      echo "Summary: $STATS"
    else
      echo "No local changes"
    fi
    echo ""
    git fetch origin "$BRANCH" 2>/dev/null || true
    BEHIND=$(git rev-list HEAD..origin/"$BRANCH" --count 2>/dev/null || echo "0")
    if [[ "$BEHIND" -gt 0 ]]; then
      echo "Remote has $BEHIND new commit(s):"
      git log --oneline HEAD..origin/"$BRANCH"
    else
      echo "Remote is up to date"
    fi
    ;;

  commit)
    if [[ -z $(git status --porcelain) ]]; then
      echo "Nothing to commit"
      exit 0
    fi
    git add -A
    DEVICE=$(detect_device)
    STATS=$(git diff --cached --stat | tail -1)
    MSG="sync: $DEVICE - $STATS"
    git commit -m "$MSG"
    echo "Committed: $MSG"
    ;;

  pull)
    git fetch origin "$BRANCH"
    BEHIND=$(git rev-list HEAD..origin/"$BRANCH" --count 2>/dev/null || echo "0")
    if [[ "$BEHIND" -eq 0 ]]; then
      echo "Already up to date"
      exit 0
    fi
    echo "Pulling $BEHIND commit(s)..."
    if ! git rebase origin/"$BRANCH"; then
      echo "Rebase conflict detected" >&2
      echo "Conflicted files:" >&2
      git diff --name-only --diff-filter=U >&2
      echo "" >&2
      echo "Aborting rebase. Resolve manually or run: git rebase --abort" >&2
      git rebase --abort
      exit 1
    fi
    echo "Pull complete"
    ;;

  push)
    git push origin "$BRANCH"
    echo "Pushed to origin/$BRANCH"
    ;;

  full)
    if [[ -n $(git status --porcelain) ]]; then
      git add -A
      DEVICE=$(detect_device)
      STATS=$(git diff --cached --stat | tail -1)
      MSG="sync: $DEVICE - $STATS"
      git commit -m "$MSG"
      echo "Committed: $MSG"
    else
      echo "No local changes to commit"
    fi

    git fetch origin "$BRANCH"
    BEHIND=$(git rev-list HEAD..origin/"$BRANCH" --count 2>/dev/null || echo "0")
    if [[ "$BEHIND" -gt 0 ]]; then
      echo "Pulling $BEHIND commit(s)..."
      if ! git rebase origin/"$BRANCH"; then
        echo "Rebase conflict detected" >&2
        echo "Conflicted files:" >&2
        git diff --name-only --diff-filter=U >&2
        echo "" >&2
        echo "Aborting rebase. Resolve manually." >&2
        git rebase --abort
        exit 1
      fi
    fi

    git push origin "$BRANCH"
    echo "$REPO_NAME synced to origin/$BRANCH"
    ;;

  *)
    echo "Unknown mode: $MODE" >&2
    echo "Usage: sync-repo.sh <repo-path> [status|commit|pull|push]" >&2
    exit 1
    ;;
esac
