---
description: Combat drift with suggestions. Usage: /bored
---

Surface options when feeling bored, tired, or stuck. Encouraging tone, not guilt-tripping.

## Critical rule

**This command is READ-ONLY.** Never modify inbox files. Never remove or mark items as done. If user says "already read that" or "done with that", suggest a different item - do not edit the inbox. Completion happens via `/done` command only.

## File discovery

First, get the inbox path and derive vault location:

```bash
bash ~/.claude/skills/obsidian-vault/scripts/inbox-path.sh
```

This returns something like `/Users/joe/dev/Obsidian/Inbox/2026-01.md`. The vault root is two directories up (remove `/Inbox/YYYY-MM.md`).

## Quarterly inbox scanning

Scan current month plus 2 previous months for list items:

```
[vault]/Inbox/2026-01.md  (current)
[vault]/Inbox/2025-12.md  (previous month)
[vault]/Inbox/2025-11.md  (2 months ago)
```

Calculate previous months from current date. Read each file that exists.

## Process

1. Run inbox-path.sh to get current inbox path and derive vault root
2. Calculate paths for previous 2 months (handle year boundary: 2026-01 → 2025-12 → 2025-11)
3. Read all inbox files that exist
4. **Ask user what they're in the mood for** (use AskUserQuestion tool)
5. Filter and aggregate based on mood selection
6. Present suggestions or engage accordingly

## Mood prompt (two-stage)

AskUserQuestion allows max 4 options. Use two-stage approach:

### Stage 1: Category

```
Use AskUserQuestion with header "Mood" and question "What are you in the mood for?":
1. "Consume something" - "Read, listen, or watch from your backlog"
2. "Do something" - "Task or continue a project"
3. "Explore ideas" - "Riff on a random note together"
4. "Just hang" - "No agenda, just chat"
```

### Stage 2: Specifics (if needed)

**If "Consume something":**
```
Use AskUserQuestion with header "Type" and question "What kind?":
1. "Read" - "Articles, papers, blog posts"
2. "Listen" - "Podcasts, talks"
3. "Watch" - "Videos, conferences"
```

**If "Do something":**
```
Use AskUserQuestion with header "Type" and question "What kind?":
1. "Quick task" - "Low-effort task to knock out"
2. "Continue project" - "[show active project name if exists]"
```

**If "Explore ideas" or "Just hang":** No follow-up needed, proceed directly.

## Mood behaviors

| Mood | Behavior |
|------|----------|
| read | Surface oldest `#reading` items without `[done::]` |
| listen | Surface `#podcast`, `#talk` items without `[done::]` |
| watch | Surface `#video`, `#watching` items without `[done::]` |
| task | Find low-priority tasks without due dates from `##### Captured Tasks` |
| riff | Pick a random note from `##### Notes` and engage conversationally - ask questions, explore the idea, stimulate curiosity, see where it leads |
| chat | No agenda - just have a conversation, ask how they're doing, talk about whatever |
| project | Show active project status and suggest continuing |

## Riff mode

When user selects "riff on an idea":
1. Pick a random note from `##### Notes` across scanned inboxes
2. Read it aloud and ask a curious question about it
3. Engage in back-and-forth exploration
4. Goal: stimulate thinking, not produce output
5. Let the conversation flow naturally

Example:
```
I found this note from [date]:
> "[note content]"

That's interesting - [ask a probing question or share a related thought].
What were you thinking when you captured this?
```

## Chat mode

When user selects "just chat":
- No tasks, no productivity framing
- Ask how they're doing
- Talk about interests, ideas, whatever comes up
- Be a good conversation partner

## Data extraction

From each inbox's `##### Lists` section, extract items WITHOUT `[done::]` field:

Sort by `[added::]` date, oldest first (surface forgotten items).

## Project continuity

From `#project` entries across all scanned inboxes:
- Group by project name (word after `#project`)
- Find most recent entry per project
- Calculate days since last entry
- If < 3 days and user didn't explicitly choose another mood: mention it

## Output format (for content moods)

After mood selection, present filtered suggestions:

```markdown
## Here's something for you

**From your backlog:**
- [oldest matching item] - added [date]
- [next oldest] - added [date]

---
*Mark items done with `/done #reading [topic]` when finished.*
```

## Behavior rules

1. **READ-ONLY**: Never modify any files
2. If active project < 3 days old: mention it (but don't force)
3. Surface oldest items first to prevent hoarding
4. Filter out items with `[done::]` field
5. Tone: encouraging, supportive, not shaming
6. If user rejects a suggestion: offer another from same category
7. Riff and chat modes are conversational - no structure needed
