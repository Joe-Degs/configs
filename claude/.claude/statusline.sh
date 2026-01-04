#!/bin/bash
input=$(cat)

# Parse JSON
model=$(echo "$input" | jq -r '.model.display_name')
dir=$(echo "$input" | jq -r '.workspace.current_dir | split("/") | last')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size')
ctx_used=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')

# Context percentage
pct=$((ctx_used * 100 / ctx_size))

# Git branch + dirty state
branch=$(git branch --show-current 2>/dev/null)
if [[ -n "$branch" ]]; then
    [[ -n $(git status --porcelain 2>/dev/null) ]] && branch="$branch*"
    git_info=" \e[35m($branch)\e[0m"
fi

printf "\e[36m$model\e[0m \e[32m$dir\e[0m$git_info \e[33m${pct}%%\e[0m"
