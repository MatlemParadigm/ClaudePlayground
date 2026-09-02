---
name: review
description: Full review of the current branch by Rex (code) and Sage (security) in parallel. Use when the user types /review or asks for a review before opening a PR.
---

Run the rex agent and the sage agent in parallel on the current branch
compared to main. Target: $ARGUMENTS (default: the whole branch).

When both return, merge their reports into one list ordered by severity.
Blocking and critical items first. Then ask the user which items to fix.
