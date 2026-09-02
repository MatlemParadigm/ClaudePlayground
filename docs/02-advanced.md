# Level 2: Advanced

Goal: shape how Claude works, not just what it works on.

## 1. Use plan mode for anything non-trivial

Press `Shift+Tab` until you see plan mode, or start with:

```bash
claude --permission-mode plan
```

In plan mode Claude can read and search but cannot edit. It researches, writes
a plan, and waits for your approval. The rhythm that works:

1. **Explore.** "Read the auth module and the three places that call it. Do not write code yet."
2. **Plan.** "Propose a plan to add refresh tokens. List files, risks, and tests."
3. **Code.** Approve the plan, switch back to normal mode, and let it build.
4. **Commit.** "Commit this with a clear message and summarize what changed."

## 2. Go test-first

Claude is very good at making tests pass. Use that.

> "Write failing tests for the behavior described in issue 42. Run them and
> confirm they fail. Do not write the implementation yet."

Then:

> "Now make the tests pass without changing the tests."

The tests become a contract Claude cannot quietly reinterpret.

## 3. Build your own skills

A skill is a reusable prompt you invoke with a slash command. Create
`.claude/skills/<name>/SKILL.md`:

```markdown
---
name: explain
description: Explain a file or function in plain language for a newcomer
---

Explain $ARGUMENTS to someone who joined the team this week.
Cover: what it does, who calls it, one gotcha. Under 200 words.
```

Now `/explain src/billing.ts` works in every session. This repo has a working
one in `.claude/skills/explain/`. Good candidates for skills: your PR
description format, your release checklist, your "review this like our
staff engineer would" prompt.

## 4. Tune permissions once, not every session

Approving the same safe command fifty times a day is a waste. Put it in
`.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test:*)",
      "Bash(npm run lint:*)",
      "Bash(git status)",
      "Bash(git diff:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Read(.env)"
    ]
  }
}
```

Use `/permissions` to see and edit the current rules. Commit the project
file so the team shares it. Keep personal overrides in
`.claude/settings.local.json`, which stays out of git.

## 5. Layer your `CLAUDE.md` files

Claude reads all of these and merges them:

| File | Scope | Commit it? |
|------|-------|------------|
| `~/.claude/CLAUDE.md` | Every project on your machine | No |
| `./CLAUDE.md` | This project, whole team | Yes |
| `./CLAUDE.local.md` | This project, only you | No |
| `./packages/api/CLAUDE.md` | Only when working inside that folder | Yes |

Put personal style preferences in the global file. Put team conventions in
the project file. Put the one weird thing about the API package next to the
API package.

## 6. Connect tools with MCP

MCP servers give Claude new tools: databases, issue trackers, browsers,
internal APIs. Add one from the terminal:

```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
claude mcp list
```

Or commit a `.mcp.json` at the project root so everyone gets the same
servers. Once connected, just ask: "look at issue 42 and fix it."

## 7. Run sessions in parallel with worktrees

Git worktrees let you run several independent Claude sessions on the same
repo without them stepping on each other:

```bash
git worktree add ../my-project-feature-a feature-a
cd ../my-project-feature-a && claude
```

One terminal per worktree. One task per session. Merge when done.

## 8. Manage context on purpose

Context is finite. Long sessions get slower and sloppier.

- `/clear` between unrelated tasks. Always.
- `/compact focus on the database changes` to keep what matters.
- `claude --continue` picks up your last session. `claude --resume` lets you
  choose from recent ones.

## Exercises

1. Take a real feature request. Do the full explore, plan, code, commit loop
   in plan mode.
2. Write one skill for something you have typed at least three times.
3. Add your five most common safe commands to the project `settings.json`.

Ready for automation? Continue to [Level 3](03-expert.md).
