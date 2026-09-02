# Claude Code Best Practices, by level

Real situations, the exact prompt to type, and what happens next. No feature
tours. Start at the beginner level, get comfortable, then move up.

| Level | Read this | You will learn |
|-------|-----------|----------------|
| Beginner | [docs/01-beginner.md](docs/01-beginner.md) | Understanding a new codebase, fixing a bug from a stack trace, adding a small feature, writing tests, untangling git, commit messages |
| Intermediate | [docs/02-advanced.md](docs/02-advanced.md) | Refactoring safely with plan mode, test-first bug fixes, library migrations, self-review before PRs, matching a mockup, working from tickets, dependency upgrades, flaky tests |
| Advanced | [docs/03-expert.md](docs/03-expert.md) | Hooks that enforce rules, reviewer subagents, Claude in your shell, auto-triaging issues in CI, parallel migrations, writer-vs-reviewer, multi-day plans, incident logs, unattended runs |

## This repo is a live example

Several scenarios in the advanced doc reference a real setup. It's in this
repo, ready to copy into your own project:

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

## How to use this

1. Read the beginner doc. Next time you hit one of those situations, copy the
   prompt instead of improvising.
2. After a week or two of daily use, read the intermediate doc. The
   situations there are what your work actually looks like.
3. When you notice you're typing the same instructions over and over, read
   the advanced doc and automate them.
