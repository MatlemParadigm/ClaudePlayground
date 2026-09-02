# Level 3: Advanced, real situations

At this level you're not just using Claude Code. You're building workflows
around it, and letting it run while you do something else.

---

## "Claude keeps forgetting to run the formatter"

**Situation.** You've told it in `CLAUDE.md`. It does it most of the time.
Most isn't enough.

**Do this.** Instructions are requests. Hooks are guarantees. In
`.claude/settings.json`:

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

Now every file Claude edits gets formatted, every time, without Claude
having to remember.

**The same trick for safety.** A `PreToolUse` hook on `Bash` that exits with
code 2 blocks the command and tells Claude why. This repo ships one at
`.claude/hooks/guard.sh` that blocks force pushes and `rm -rf /`. Ask Claude
to force-push something and watch it get refused and pick another route.

---

## "I want a second opinion that isn't biased by the first"

**Situation.** Claude wrote the feature. Asking the same session to review
it is like asking someone to grade their own homework.

**Do this.** Define a reviewer subagent in `.claude/agents/rex.md`:

```markdown
---
name: rex
description: Code reviewer. Read-only. Use after any non-trivial change or when the user says "ask Rex".
tools: Read, Grep, Glob, Bash
model: sonnet
---
You never edit files. Read the diff. Report only bugs that will ship and
behavior changes the author didn't intend. No style nits.
```

Then in your main session:

> Ask Rex to look at this branch.

The subagent runs in its own context, with no memory of why the code was
written that way. It comes back with findings. Your main session fixes them.

**Why it works.** Separate context means genuine fresh eyes. Restricting
tools means it can't "fix" things behind your back.

---

## "Commit messages, but I never want to write one again"

**Situation.** You want Claude in your shell, not just in a chat.

**Do this.** Headless mode with `-p` runs one prompt and exits:

```bash
# in ~/.zshrc or ~/.bashrc
gcm() {
  git diff --cached | claude -p "Write a conventional commit message for this diff. First line under 70 chars. Output only the message." | git commit -F -
}
```

Now `git add -A && gcm`. Other one-liners that earn their keep:

```bash
# Explain a failing CI log
cat ci.log | claude -p "Why did this fail? One paragraph, then the fix."

# Turn a meeting transcript into tickets
claude -p "Extract action items from @notes.md as a markdown checklist"

# Structured output for scripts
claude -p "List every TODO in src/ as JSON: [{file, line, text}]" --output-format json
```

**Why it works.** `-p` composes with pipes. Anything that produces text can
feed Claude. Anything Claude produces can feed the next tool.

---

## "Triage new issues automatically"

**Situation.** Twenty issues a day. Half are missing reproduction steps.

**Do this.** In a GitHub Actions workflow triggered on `issues: opened`:

```yaml
- run: |
    claude -p "Read issue #${{ github.event.issue.number }}. If it's missing
    reproduction steps, version, or expected behavior, post one polite
    comment asking for exactly what's missing. Otherwise add the labels
    that fit from: bug, feature, docs, question." \
      --allowedTools "mcp__github__*" --max-turns 8
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Why it works.** Bounded task, bounded tools, bounded turns. Claude can't
wander off and do something surprising. It does one useful thing per issue
and stops.

---

## "Big migration, no time, several machines worth of work"

**Situation.** Twelve packages, same mechanical change in each, a day of
work if done serially.

**Do this.** One worktree per package, one headless Claude per worktree, all
in parallel:

```bash
for pkg in api web worker billing auth search; do
  git worktree add "../wt-$pkg" -b "migrate-$pkg"
  (
    cd "../wt-$pkg" &&
    claude -p "In packages/$pkg, replace every use of the old Logger class with
      the structured logger from @acme/log. Run this package's tests. Commit
      when green." --max-turns 40 --allowedTools "Edit,Read,Bash(npm test:*),Bash(git:*)"
  ) &
done
wait
```

Come back in twenty minutes. Review six branches. Merge the good ones, rerun
the bad ones with a sharper prompt.

**Why it works.** Worktrees isolate the file systems. Headless mode means no
one has to babysit six terminals.

---

## "Writer and reviewer, adversarial"

**Situation.** Critical feature. You want it built and attacked by different
Claudes.

**Do this.** Terminal A, in the main checkout:

> Implement the rate limiter described in docs/rate-limit-spec.md. Write
> tests as you go. Commit when done.

Terminal B, in a separate worktree on the same branch:

> Read docs/rate-limit-spec.md, then review the implementation on this
> branch adversarially. Try to find inputs that violate the spec. Write
> failing tests for anything you find. Don't fix the code.

Take B's failing tests back to A:

> The reviewer found these failures. Fix the implementation. Don't change
> their tests.

Repeat until B finds nothing.

**Why it works.** A and B share no context. B has no idea what A was
thinking and no reason to be charitable.

---

## "This is too big for one session"

**Situation.** Multi-day feature. Context fills up. Sessions end. You keep
re-explaining.

**Do this.** Make the plan a file, not a conversation:

> Write a detailed implementation plan for the new billing engine to
> PLAN.md. Numbered steps, each one independently testable, with a checkbox.
> Don't implement anything.

Review and edit `PLAN.md` by hand. Then, in a fresh session (`/clear`):

> Read PLAN.md. Do the next unchecked step. Run tests. Check it off, commit,
> and stop.

Repeat. Each session starts clean and knows exactly where it is.

**Why it works.** The plan lives on disk and survives context limits,
laptop reboots, and weekends. Each session does one thing well.

---

## "Something is on fire and I have logs"

**Situation.** 3 a.m. page. 2 GB of logs. You need to know what changed.

**Type this:**

> Here are the last 5,000 lines of app logs (@logs/app.log). Errors started
> around 02:40. Correlate with git log since yesterday and the deploy times
> in @deploys.txt. What's the most likely cause? Give me a rollback command
> and a forward-fix option. Don't run anything.

**Why it works.** Cross-referencing logs, commits, and deploy times is
tedious for humans and trivial for Claude. "Don't run anything" because it's
3 a.m. and you want to be the one who pushes the button.

---

## "Hard design decision, I want it to really think"

**Situation.** Event sourcing vs. CRUD for a new subsystem. You'll live with
this for years.

**Type this:**

> ultrathink. We're deciding between event sourcing and a conventional CRUD
> model for the new inventory service. Read docs/inventory-requirements.md
> and the existing order service for context. Argue both sides seriously,
> then recommend one, with the two things that would change your mind.

**Why it works.** `ultrathink` gives Claude the largest reasoning budget.
Spend it on decisions that are expensive to reverse, not on renames.

---

## "Let it run unattended, safely"

**Situation.** 400 lint errors. Zero judgment required. You don't want to
click approve 400 times.

**Do this.** Inside a container or VM with no credentials you care about:

```bash
claude --dangerously-skip-permissions -p "Fix every lint error reported by
  npm run lint. Don't change behavior. Run tests at the end." --max-turns 100
```

**Why it works.** Boring, well-specified, easily verified by the test suite.
The container is the safety net, plus `--max-turns` as a hard stop and the
guard hook from earlier in this doc.

---

## Habits at this level

- **Anything you've told Claude three times becomes a skill, a hook, or a
  line in `CLAUDE.md`.** In that order of preference: hooks for musts,
  skills for repeated prompts, memory for context.
- **Separate context for separate roles.** Writer, reviewer, researcher.
  Subagents or worktrees.
- **Bound every unattended run.** Allowed tools, max turns, a sandbox.
- **Plans live on disk.** Conversations are ephemeral. Files aren't.
- **Headless mode is a Unix tool.** Pipe into it. Pipe out of it. Alias it.

The people who get the most from Claude Code aren't the ones with the
cleverest prompts. They're the ones who noticed what they kept repeating and
automated it.

One more level: [build a whole company](04-your-ai-company.md).
