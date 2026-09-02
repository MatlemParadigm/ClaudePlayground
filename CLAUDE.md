# ClaudePlayground

A sandbox for learning Claude Code. The docs in `docs/` are a tiered guide
(beginner, advanced, expert). The `.claude/` folder is a working example of
the practices those docs describe.

## Conventions
- Docs are Markdown, wrapped at 80 columns, plain language.
- Each level doc ends with an Exercises section.
- Keep examples runnable. If a snippet cannot be copy-pasted and run, fix it.

## The staff
Agents in `.claude/agents/` are named people (Penny, Ada, Dev, Quinn, Rex,
Sage, Doc, Max, Sam, Ops). Delegate by name. Skills in `.claude/skills/`
are the processes that run them. See `docs/04-your-ai-company.md`.

## Working here
- This repo has no build or test step. Verify Markdown renders by reading it.
- The guard hook in `.claude/hooks/guard.sh` blocks force pushes and
  `rm -rf /`. That is intentional. Do not disable it.
