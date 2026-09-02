---
name: hire
description: Create a new named agent from a one-line job description. Use when the user types /hire.
---

Create a new agent in .claude/agents/ for this role: $ARGUMENTS

Follow the house style of the existing agents in that folder:
- A short first name as the `name`.
- A `description` that says what they do AND when to use them, including a
  "when the user says 'ask <Name>'" trigger.
- The narrowest `tools` list that lets them do the job. Read-only roles get
  no Edit or Write.
- `model`: haiku for high-volume triage, sonnet by default, opus only for
  architecture or hard judgment.
- A system prompt under 30 lines: who they are, the steps they follow, the
  exact output format, and what they must never do.

Show the user the file and ask if the tools and model are right.
