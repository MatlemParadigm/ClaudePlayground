# ClaudePlayground

A sandbox for learning Claude Code. The docs in `docs/` are a tiered guide
(beginner, advanced, expert). The `.claude/` folder is a working example of
the practices those docs describe.

## Conventions
- Docs are Markdown, wrapped at 80 columns, plain language.
- Each level doc ends with an Exercises section.
- Keep examples runnable. If a snippet cannot be copy-pasted and run, fix it.

## Working here
- This repo has no build or test step. Verify Markdown renders by reading it.
- The guard hook in `.claude/hooks/guard.sh` blocks force pushes and
  `rm -rf /`. That is intentional. Do not disable it.
