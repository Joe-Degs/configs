---
description: Mark a list item as complete. Usage: /done #tag topic
---

Mark a list item as complete by adding `[done:: YYYY-MM-DD]` field.

## Usage

- `/done #reading Reflections on Trusting Trust`
- `/done #reading trust` (partial match)
- `/done #watching Bryan Cantrill`
- `/done #podcast oxide friends`

## File discovery

```bash
bash ~/.claude/skills/obsidian-vault/scripts/inbox-path.sh
```

Derive vault root from inbox path. Search current + previous 2 months.

## Process

1. Get inbox paths (current + 2 previous months)
2. Parse the tag and search term from user input
3. Search each inbox's `##### Lists` section for matching item
4. Match criteria: has the tag AND contains the search term AND no `[done::]` field
5. If found: add `[done:: YYYY-MM-DD]` field after `[added:: ...]`
6. If multiple matches: show them and ask which one
7. If no match: report not found

## Matching

Search is case-insensitive and partial:
- `/done #reading trust` matches `#reading https://...TrustingTrust.pdf - Reflections on Trusting Trust`
- `/done #reading example.com` matches URL

## Edit format

Transform:
```
- [added:: 2026-01-02] #reading https://example.com - description
```

To:
```
- [added:: 2026-01-02] [done:: 2026-01-05] #reading https://example.com - description
```

Use today's date for the done field.

## Multiple matches

If multiple items match, show numbered list:

```
Found multiple matches:

1. [added:: 2026-01-02] #reading https://example.com/article1 - first article
2. [added:: 2026-01-03] #reading https://example.com/article2 - second article

Which one? (enter number)
```

## Confirmation

After marking done:

```
Marked as done: #reading [topic] (from [month] inbox)
```

## Error cases

- No match: "No uncompleted #[tag] item found matching '[search term]'"
- Already done: "That item is already marked done"
