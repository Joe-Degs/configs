---
description: Brutal monthly review. Usage: /month-review [YYYY-MM]
---

Generate a brutally honest monthly review following the "facts that haunt" philosophy.

## Philosophy

> "I need to see the consequences of my inaction somewhere so that it haunts me into action."

This is not a feel-good summary. This is a mirror that does not lie.

### Principles

1. Hard numbers, not soft language - "You spent 800 on gifts" not "spending was slightly elevated"
2. Patterns matter - "3rd month in a row gifts exceeded budget"
3. Year-to-date implications - "At this pace, you'll miss your goal by X"
4. Unlogged = bad signal - "Only 22 of 31 evenings logged. The other 9 are probably drift."
5. No excuses embedded - State facts, let user draw conclusions

## Usage

- `/month-review` (last complete month)
- `/month-review 2025-12` (specific month)

## File discovery

First, get the inbox path and derive vault location:

```bash
bash ~/.claude/skills/obsidian-vault/scripts/inbox-path.sh
```

This returns something like `/Users/joe/dev/Obsidian/Inbox/2026-01.md`. The vault root is two directories up (remove `/Inbox/YYYY-MM.md`). Use `[vault]` below to reference this derived path.

## Data sources

| Source | Path | Purpose |
|--------|------|---------|
| Inbox | `[vault]/Inbox/YYYY-MM.md` | Raw spending, workouts, evenings, tasks |
| Config | `[vault]/Config.md` | Evening and fitness targets |
| Finance Plan | `[vault]/Areas/Finance-Plans/YYYY-plan.md` | Budget limits, savings goals |
| Context | `[vault]/Areas/Context/` | Personal goals and targets |

## Process

1. Determine month (default: last complete month, not current)
2. Run inbox-path.sh to derive vault root
3. Run extraction script:
   ```bash
   bash ~/.claude/skills/obsidian-vault/scripts/get-month-data.sh YYYY-MM
   ```
4. Read `[vault]/Config.md` frontmatter for targets
5. Read `[vault]/Areas/Finance-Plans/YYYY-plan.md` for limits and savings goals
6. Read `[vault]/Areas/Context/` files for personal targets and deadlines
7. Calculate days in month, data coverage percentage
8. Generate each section with verdicts

## Output structure

### Header

```markdown
# [Month Name] [Year] Review

**Period:** [Month] 1-[last day], [Year]
**Days in month:** [N]
**Data coverage:** [X] days logged ([Y]%)
```

### Section 1: Spending

Compare each category against limits from finance plan frontmatter.

| Category | Spent | Limit | Gap | Verdict |
|----------|-------|-------|-----|---------|
| category | actual | limit | difference | ❌ OVER / ⚠️ Over / ✅ |

- ❌ OVER: 50%+ over limit
- ⚠️ Over: 1-49% over limit
- ✅: At or under limit

List biggest bleeds and any multi-month patterns.

### Section 2: Savings goals progress

Read savings goals from finance plan (fields like `*Target`, `*Deadline`).

For each goal:
- Calculate months remaining to deadline
- Required monthly pace
- Sum savings deposits with matching `[savings:: fundname]`
- Project if on track
- Calculate shortfall and recovery pace needed

Verdict per goal: ON TRACK or NOT ON TRACK

### Section 3: Fitness

From Config.md (weekly targets):
- gymSessionsTarget
- swimSessionsTarget
- runSessionsTarget

Calculate monthly targets = weekly × 4

| Type | Actual | Target | % | Verdict |
|------|--------|--------|---|---------|
| Gym | N | N | % | verdict |
| Swim | N | N | % | verdict |
| Run | N | N | % | verdict |

- ❌: below 50%
- ⚠️: 50-80%
- ✅: 80%+

Identify weakest area.

### Section 4: Evenings

From Config.md:
- buildNightsTarget (weekly) → multiply by 4 for monthly
- driftNightsMax (weekly) → multiply by 4 for monthly max
- projectHoursTarget (weekly) → multiply by 4 for monthly

Calculate:
- Potential hours: days in month × 5 hours
- Utilization: project hours / potential hours

| Metric | Actual | Target | Verdict |
|--------|--------|--------|---------|
| Build | N | target | verdict |
| Drift | N | max | verdict |
| Hours | N | target | verdict |

Include: unlogged nights (days - build - drift), build/drift ratio, utilization %

### Section 5: Tasks

From inbox task counts:
- Completed this month
- Still open
- Overdue (due date before review date, still open)

List specific overdue items.

### Section 6: Reflections (generated)

Generate based on data:

**Wins:** `[win:: description]` for any targets met or exceeded
**Gaps:** `[improve:: description]` for any missed targets or concerning patterns
**Next Month Focus:** `[focus:: description]` for top 3-4 priorities

After generating, ask: "Write these reflections to Inbox? (y/n)"

If yes, insert into `##### Reflection` section of the inbox file.

### Section 7: To process

Read any items in the `##### To Process` section of the inbox file.

## Tone

Be brutal and direct:

- "You spent 800 on gifts. Limit was 400. This is the 3rd month."
- "15% utilization of evening hours. 131 hours went somewhere."
- "At this pace, you'll miss your savings goal by X."

No soft language. No excuses. Just facts that haunt.
