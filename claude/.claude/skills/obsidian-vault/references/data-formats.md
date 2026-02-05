# Data formats

All entries use Obsidian inline fields `[field:: value]` parsed by Dataview.

## Tasks

```
- [ ] description [priority] [dates]
- [x] completed description ✅ YYYY-MM-DD
```

**Priority** (optional):
- ⏫ = high
- 🔼 = medium
- 🔽 = low

**Dates** (optional):
- 📅 YYYY-MM-DD = due date
- ⏳ YYYY-MM-DD = scheduled date
- ✅ YYYY-MM-DD = completion date
- 🔁 = recurring

Examples:
```
- [ ] fix syscall handler ⏫ 📅 2026-01-10
- [ ] review chapter 🔼
- [x] send email ✅ 2026-01-02
```

## Spending

```
- description [spent:: AMOUNT] [item:: NAME] [category:: CATEGORY] [date:: YYYY-MM-DD] - notes
```

**Categories**: food, transport, personal, gifts, health, education, entertainment, utilities

Examples:
```
- lunch [spent:: 45] [item:: lunch] [category:: food] [date:: 2026-01-02] - fufu at work
- bolt ride [spent:: 67] [item:: bolt] [category:: transport] [date:: 2026-01-02]
```

## Workouts

```
- description [workout:: TYPE] [exercises:: LIST] [duration:: MINUTES] [date:: YYYY-MM-DD]
```

**Types**: Swim, Run, Legs, Push, Pull

Examples:
```
- morning swim [workout:: Swim] [exercises:: freestyle, drills] [duration:: 60] [date:: 2026-01-02]
- leg day [workout:: Legs] [exercises:: squats, RDL, leg press] [duration:: 90] [date:: 2026-01-02]
```

## Evenings

```
- [evening:: TYPE] [date:: YYYY-MM-DD] [project-hours:: N] [notes:: description]
```

**Types**:
- `build` = productive (include project-hours)
- `drift` = unproductive (skip project-hours)

Examples:
```
- [evening:: build] [date:: 2026-01-02] [project-hours:: 2] [notes:: worked on emulator]
- [evening:: drift] [date:: 2026-01-02] [notes:: youtube rabbit hole]
```

## Notes

```
- [date:: YYYY-MM-DD] #tag content
```

Entries must be single-line, plain text, no markdown formatting.

**Tags**: #coding, #personal, #random, #work, #project

**Tag meaning**:
- #work: day job or client/freelance obligations, meetings, deliverables
- #project: personal or learning projects, side work not tied to employer
- #coding: code-level notes, debugging, implementation details
- #personal: life admin, health, family, errands
- #random: quick capture that does not fit other tags

For work/project context, use compound form: `#work project-name: description` or `#project project-name: description`
For plans, use `#work plan: ...` or `#personal plan: ...`

Examples:
```
- [date:: 2026-01-02] #coding need to investigate memory leak
- [date:: 2026-01-02] #personal call mom this weekend
- [date:: 2026-01-02] #work hubtel-templates: fix deployment config
```

## Savings

```
- [savings:: FUND] [amount:: AMOUNT] [date:: YYYY-MM-DD]
```

**Funds**: user-defined (e.g., travel, emergency, retirement)

Examples:
```
- [savings:: travel] [amount:: 3000] [date:: 2026-01-02]
- [savings:: emergency] [amount:: 500] [date:: 2026-01-02]
- [savings:: retirement] [amount:: 1000] [date:: 2026-01-02]
```

## Lists

```
- [added:: YYYY-MM-DD] #tag content - description
```

**Tags** (canonical list): #reading, #shopping, #watching, #ideas, #project, #podcast, #talk, #video

Examples:
```
- [added:: 2026-01-02] #reading https://example.com - consensus article
- [added:: 2026-01-02] #shopping mechanical keyboard - low profile
- [added:: 2026-01-03] #podcast https://oxide.computer/podcasts - Oxide and Friends
- [added:: 2026-01-03] #talk https://youtube.com/... - Bryan Cantrill on DTrace
```

### Marking items done

Add `[done:: YYYY-MM-DD]` field to mark list items complete:

```
- [added:: YYYY-MM-DD] [done:: YYYY-MM-DD] #tag content - description
```

Examples:
```
- [added:: 2026-01-02] [done:: 2026-01-05] #reading https://example.com - consensus article
- [added:: 2026-01-03] [done:: 2026-01-04] #podcast episode - listened on commute
```

Use `/done #tag [search term]` to mark items complete. The `/bored` command filters out items with `[done::]` when suggesting content.

### Project tracking

Use `#project` tag to track active projects with checkpoints:

```
- [added:: YYYY-MM-DD] #project name - notes/checkpoint
```

Examples:
```
- [added:: 2026-01-03] #project emulator - started syscall implementation
- [added:: 2026-01-05] #project emulator - checkpoint: basic io working
- [added:: 2026-01-06] #project life-os - commands done, router skill working
- [added:: 2026-01-08] #project ddia-book - chapter 5, page 152 on leader election
```

Use "checkpoint:" prefix to mark milestones. The `/bored` command uses these entries to track active work and suggest what to continue.
