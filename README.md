# Claude Code Best Practices, by level

A short, practical guide to working well with Claude Code. Start at the
beginner level, get comfortable, then move up. Each level builds on the one
before it.

| Level | Read this | You will learn |
|-------|-----------|----------------|
| Beginner | [docs/01-beginner.md](docs/01-beginner.md) | Starting sessions, writing good prompts, `CLAUDE.md`, reviewing changes safely |
| Advanced | [docs/02-advanced.md](docs/02-advanced.md) | Plan mode, test-first workflows, custom skills, permissions, MCP servers, worktrees |
| Expert | [docs/03-expert.md](docs/03-expert.md) | Hooks, subagents, headless mode, CI automation, multi-Claude workflows |

## This repo is a live example

The `.claude/` folder here is not decoration. It is a working setup you can
copy into your own project:

```
CLAUDE.md                      # project memory Claude reads on every session
.claude/settings.json          # permissions and hooks
.claude/hooks/guard.sh         # PreToolUse hook that blocks destructive commands
.claude/skills/explain/SKILL.md  # custom /explain skill
.claude/agents/reviewer.md     # read-only code review subagent
```

Open this folder in a terminal, run `claude`, and try:

```
/explain README.md
```

Then ask: "use the reviewer agent to review docs/01-beginner.md".

## Suggested learning path

1. Read the beginner doc and do the three exercises at the bottom.
2. Spend a week using Claude Code daily. Come back for the advanced doc.
3. Once you find yourself repeating the same instructions, read the expert
   doc and automate them with hooks, skills, and subagents.
