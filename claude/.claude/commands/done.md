---
description: Mark a task or list item as complete. Usage: /done [#tag] topic
---

Mark tasks or list items as complete.

## Usage

**Tasks (no #tag):**
- `/done fix auth bug` - marks task checkbox as done
- `/done budget` - partial match on task description

**List items (with #tag):**
- `/done #reading Reflections on Trusting Trust`
- `/done #reading trust` (partial match)
- `/done #watching Bryan Cantrill`

## Detection logic

- Input starts with `#` → search list items only
- Input has no `#` → search both tasks and list items, show all matches

## File discovery

```bash
bash ~/.claude/skills/obsidian-vault/scripts/inbox-path.sh
```

Derive vault root from inbox path. Search current + previous 2 months.

## Process

1. Get inbox paths (current + 2 previous months)
2. Determine search type:
   - If input starts with `#tag` → list-only mode
   - Otherwise → combined mode (tasks + lists)
3. Search for matches:
   - **Tasks**: `##### Tasks` section, pattern `- [ ].*$SEARCH` (exclude `[x]`)
   - **Lists**: `##### Lists` section, pattern `[added::.*#tag.*$SEARCH` (exclude `[done::]`)
4. If single match: mark as done
5. If multiple matches: show with type indicators, ask which one
6. If no match: report not found

## Task search

Search pattern:
```bash
rg -i "^\s*- \[ \].*$SEARCH" "$VAULT/Inbox" --type md
```

Exclude lines containing `[x]` (already done).

## List search

Search pattern:
```bash
rg -i "^\s*- \[added::.*#$TAG.*$SEARCH" "$VAULT/Inbox" --type md
```

Exclude lines containing `[done::]` (already done).

## Edit formats

**Task transformation:**
```
- [ ] fix the auth bug 🔼 📅 2026-01-10
```
To:
```
- [x] fix the auth bug 🔼 📅 2026-01-10 ✅ 2026-01-05
```

**List transformation:**
```
- [added:: 2026-01-02] #reading https://example.com - description
```
To:
```
- [added:: 2026-01-02] [done:: 2026-01-05] #reading https://example.com - description
```

Use today's date for completion markers.

## Multiple matches

Show type indicators when displaying matches:

```
Found matches:

[task] 1. - [ ] fix auth bug 🔼
[task] 2. - [ ] update auth tests
[list] 3. [added:: 2026-01-02] #reading auth article

Which one? (enter number)
```

## Confirmation

After marking done:

```
Marked as done: [task] fix auth bug (from 2026-01 inbox)
Marked as done: [list] #reading auth article (from 2026-01 inbox)
```

## Error cases

- No match: "No uncompleted item found matching '[search term]'"
- Already done: "That item is already marked done"
