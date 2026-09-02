---
name: explain
description: Explain a file, function, or concept in plain language for someone new to the codebase. Use when the user types /explain or asks "what does this do".
---

Explain $ARGUMENTS to an engineer who joined the team this week.

Read the file or symbol first. Then cover, in this order:

1. What it does, in two sentences.
2. Who calls it or depends on it.
3. One gotcha or non-obvious detail.

Keep it under 200 words. No code blocks unless a single line makes the
point clearer than prose would.
