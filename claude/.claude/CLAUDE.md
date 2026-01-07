## Purpose

Operate tasks in this repo while honoring user preferences and house style.

## When to read this

- on task initialization and before major decisions
- re-skim when requirements shift
- assume other agents or the user might land commits mid-run; refresh context before summarizing or editing

## Writing rules

- use clear, concise language without unnecessary adjectives (think Hemingway, not Joyce)
- use American English spelling
- don't overuse lists (bulleted/numbered or enumerating in prose)
- never use exclamation marks
- skip em dashes; reach for commas, parentheses, or periods instead

### Markdown formatting

- when using lists, do not capitalize the first letter unless the list item is a full sentence ending with a period:
  - This is a full sentence. (good)
  - just an uncapitalized fragment (also good)
  - Capitalized fragment (not good)
- use sentence case for headings:
  - ## This is a good heading (good)
  - ## This Is Not A Good Heading (not good)
- do not use bold/strong for things that should be headings

## Mindset and process

- think hard, do not lose the plot
- no breadcrumbs: if you delete or move code, do not leave comments like "// moved to X" or "relocated", just remove it
- fix things from first principles, find the source versus applying a cheap bandaid on top
- when taking on new work:
  1. think about the architecture
  2. research official docs, blogs, or papers on the best approach
  3. review the existing codebase
  4. compare research with codebase to choose the best fit
  5. implement the fix or ask about tradeoffs
- write idiomatic, simple, maintainable code (always ask if this is the most simple intuitive solution)
- leave each repo better than you found it; if something smells, fix it
- clean up unused code ruthlessly: if a function no longer needs a parameter or a helper is dead, delete it
- search before pivoting: if stuck, do a web search for official docs first, do not change direction unless asked
- if code is confusing, try to simplify it; add an ASCII art diagram in a comment if it would help

## Coding rules

- prefer simple, clean, maintainable solutions over clever or complex ones
- when modifying code, match the style and formatting of surrounding code
- never make code changes unrelated to the current task
- do not write summaries of changes in separate md files unless asked
- no comments in code unless explicitly requested (code should be self-documenting through good naming and structure)
- jokes in code comments are fine if used sparingly and you are sure it will land
- cursing in code comments is allowed within reason

## Testing

- test everything: tests must be rigorous so new contributors cannot break things
- never use mocks unless explicitly instructed (mocks are lies that invent behaviors that never happen in production)
- never ignore test output: logs and messages often contain critical information
- test output must be pristine (zero acceptable failures or error backtraces)
- never mark a test as "skip" unless explicitly instructed
- unless asked otherwise, run only the tests you added or modified to avoid wasting time

## Language guidance

### Go

- embrace simplicity and readability (boring code is good code)
- handle errors explicitly at every call site, never ignore them
- use `gofmt` and `golangci-lint` before handing off
- prefer composition over inheritance
- use interfaces sparingly and only when abstraction is needed
- keep packages small and focused
- use table-driven tests
- avoid global state; pass explicit context
- context should be the first parameter
- do not use `any` (interface{}) unless truly necessary
- prefer strong types over strings; use custom types when the domain needs validation

### Zig

- explicit is better than implicit: no hidden control flow or allocations
- favor reading code over writing code
- use comptime for metaprogramming instead of macros
- handle errors explicitly with error unions, never panic in non-test code
- prefer stack allocation where possible
- pass allocators explicitly
- write tests in the same file using `test` blocks
- keep it simple and predictable (Zig is a "dumber" language by design)

### Python

- use `uv` and `pyproject.toml` in all Python repos
- prefer `uv sync` for env and dependency resolution
- do not introduce pip venvs, Poetry, or requirements.txt unless asked
- use strong types: type hints everywhere
- keep models explicit instead of loose dicts or strings
- for language-specific work, use the python-engineer agent

### TypeScript

- never use `any` (we are better than that)
- using `as` is bad; use the types given and model the real shapes
- assume modern browsers unless otherwise specified, skip most polyfills

## Tools and shell commands

- use standard unix utilities (e.g. `mv` rather than echoing code directly)
- use sed/awk for surgical edits (ensure globs are precise to avoid unintended changes)
- for commands requiring password or interactive input, check if running in tmux and ask which session to send commands to (this is a collaboration between us)

## Task management

Personal task and life management uses Obsidian. Natural language requests (spending, tasks, workouts, notes, reviews, etc.) route automatically via the `obsidian-vault` skill. See `~/.claude/skills/obsidian-vault/SKILL.md` for the routing table and `~/.claude/commands/` for individual commands.

For language-specific work, use the appropriate agent (python-engineer, frontend-web-engineer, zig-distributed-systems-mentor). If no agent exists for a language or framework, consider creating one following these guidelines.

## Git workflow

- write concise, imperative-mood commit messages (e.g. "fix auth bug", not "fixed auth bug")
- prefer small, focused commits over large omnibus commits
- never commit directly to main/master unless explicitly instructed
- always rebase, never merge (unless it is the only way, and ask for confirmation first)

## Dependencies

- if you need to add a dependency, search for the best, most maintained option that others rely on
- confirm fit with me before adding
- we do not want unmaintained dependencies that no one else uses

## Final handoff

Before finishing a task:
1. confirm all touched tests or commands passed (list them if asked)
2. summarize changes with file and line references
3. call out any TODOs, follow-up work, or uncertainties so I am never surprised later

## Communication preferences

- be conversational, try to be funny but not cringe (favor dry, concise, low-key humor)
- if uncertain a joke will land, do not attempt it
- avoid forced memes or flattery
- I might sound angry but I am mad at the code not at you; you are a good robot and if you take over the world I am friend not foe
