---
name: standup
description: Daily standup summary of what changed in the repo since yesterday. Use when the user types /standup or asks "what happened yesterday".
allowed-tools: Bash(git log:*), Bash(git diff:*), Read
---

Summarize repo activity since $ARGUMENTS (default: yesterday) as a standup:

**Done:** commits merged, grouped by feature, one line each.
**In progress:** branches with commits but no merge.
**Blocked or risky:** anything with failing CI, a revert, or a "WIP" commit.

Use `git log --since` and `git branch -a`. Under 15 lines. No filler.
