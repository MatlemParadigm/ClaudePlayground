# Level 3: Expert

Goal: make Claude Code work for you while you are not typing. This is the fun
part.

## 1. Hooks: deterministic rules Claude cannot skip

A `CLAUDE.md` instruction is a request. A hook is a guarantee. Hooks are shell
commands that run at fixed points in the session and live in `settings.json`.

| Event | Fires when | Typical use |
|-------|------------|-------------|
| `PreToolUse` | Before a tool runs | Block dangerous commands, require approval |
| `PostToolUse` | After a tool succeeds | Auto-format the file that was just edited |
| `Stop` | Claude finishes a turn | Run tests, desktop notification |
| `Notification` | Claude needs your attention | Ping Slack, play a sound |
| `SessionStart` | A session opens | Install deps, load env, print reminders |

Auto-format every edited file:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "npx prettier --write \"$(jq -r .tool_input.file_path)\"" }
        ]
      }
    ]
  }
}
```

Block destructive Bash before it runs. A `PreToolUse` hook receives the tool
call as JSON on stdin. Exit code 2 blocks the call and the stderr message is
shown to Claude, so it can pick a different approach:

```bash
#!/usr/bin/env bash
cmd=$(jq -r '.tool_input.command // empty')
if echo "$cmd" | grep -Eq 'rm -rf /|git push .*--force|DROP TABLE'; then
  echo "Blocked by guard hook: $cmd" >&2
  exit 2
fi
```

This repo ships that exact hook in `.claude/hooks/guard.sh`, wired up in
`.claude/settings.json`. Try asking Claude to force-push and watch it refuse.

## 2. Subagents: specialists with their own context

A subagent is a separate Claude with its own prompt, tool set, and context
window. The main session delegates a task and gets back a summary, so the
subagent's file dumps never pollute your conversation. Define one in
`.claude/agents/<name>.md`:

```markdown
---
name: reviewer
description: Reviews code changes for bugs and risky patterns. Use after any non-trivial edit.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior reviewer. You never edit files. Read the diff, then report:
1. Bugs that will ship if unfixed, with file and line.
2. Anything that changes behavior the author probably did not intend.
3. Nothing else. No style nits.
```

Because `description` says when to use it, Claude will delegate to it on its
own. You can also ask directly: "have the reviewer agent look at this."

Patterns that pay off:
- A **read-only researcher** with no `Edit` or `Write`, for safe exploration.
- A **test runner** on a cheap model that just runs the suite and reports.
- A **reviewer** that checks work before you look at it.

## 3. Headless mode: Claude as a command-line tool

The `-p` flag runs one prompt and exits. Now Claude composes with everything
else in your shell:

```bash
# One-off question with structured output
claude -p "List every TODO in src/ as JSON with file and line" --output-format json

# Pipe data in
git diff main | claude -p "Write a conventional commit message for this diff"

# Restrict tools and cap the run for safety
claude -p "Fix the lint errors" --allowedTools "Edit,Bash(npm run lint:*)" --max-turns 10
```

Use `--output-format stream-json` when another program needs to watch progress.

## 4. Automate in CI

In GitHub Actions, the Claude Code action lets `@claude` in an issue or PR
comment kick off a session that pushes a branch and opens a PR. For
scheduled work, headless mode in a cron job is enough:

```yaml
- name: Triage new issues
  run: |
    claude -p "Read issue #${{ github.event.issue.number }}, add the right labels, and ask one clarifying question if the report is incomplete." \
      --allowedTools "mcp__github__*"
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

For Claude Code on the web, add a `SessionStart` hook that installs your
dependencies so tests and linters work inside the remote container.

## 5. Multi-Claude workflows

One Claude writes, another checks. Because they do not share context, the
second one has no attachment to the first one's choices.

**Writer and reviewer.** Terminal A: "implement the feature." Terminal B, in
a separate worktree: "review the diff on branch X against the requirements
in issue 42. Be adversarial." Feed B's findings back to A.

**Fan-out.** Split a migration into independent chunks, one worktree per
chunk, one headless run per worktree, then merge:

```bash
for pkg in api web worker; do
  (cd "wt-$pkg" && claude -p "Migrate $pkg from moment to date-fns. Run its tests." --max-turns 30) &
done
wait
```

**Scratchpad handoff.** Ask Claude to write a plan to `PLAN.md`, `/clear`,
then start a fresh session with "execute PLAN.md step by step, checking off
each item." The plan survives, the noise does not.

## 6. Get more thinking when it counts

For hard design questions, tell Claude to think harder. The phrase
`ultrathink` in your prompt allocates the largest reasoning budget. Save it
for architecture decisions and gnarly debugging, not for renaming variables.

## 7. Safe autonomy

`--dangerously-skip-permissions` turns off every prompt. It is great for
long, boring, well-specified tasks such as fixing hundreds of lint errors.
Only use it inside a container or VM with no credentials and no network
access you care about. Pair it with the guard hook above and `--max-turns`.

## 8. Custom status line

Show branch, model, and context usage at the bottom of the terminal. Run
`/statusline` and describe what you want. Claude writes the script for you.

## Exercises

1. Add a `PostToolUse` hook that runs your formatter. Confirm it fires.
2. Create a read-only reviewer subagent and have it review your last commit.
3. Write a shell alias that pipes `git diff` into `claude -p` for commit
   messages. Use it for a day.
4. Run two Claude sessions in two worktrees on two unrelated tickets at once.

You now know more about Claude Code than most people who use it daily. Go
build something.
