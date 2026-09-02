# Level 1: Beginner, real situations

Every section is a situation you will actually be in, the prompt to type, and
what happens next. Copy the prompts. Change the file names.

---

## "I just joined and I don't understand this codebase"

**Situation.** New job, 80k lines of code, nobody has time to walk you
through it.

**Type this:**

> Give me a tour of this repo. What are the main folders, what does each one
> own, and where does a request enter the system?

Claude reads the tree, the README, and a few entry points, then gives you a
map. Follow up with the thing you actually need to work on:

> Trace what happens when a user submits the checkout form. Start from the
> frontend and go all the way to the database. Name each file you pass
> through.

**Then:** pick one file that scared you and ask:

> @src/billing/proration.ts explain this to me like I'm new here. What's the
> one thing that will bite me?

**Why it works.** Claude reads code faster than you and has no ego about
explaining basics. Twenty minutes of this beats a day of clicking around.

---

## "Production is broken and I have a stack trace"

**Situation.** Sentry alert. 500 errors. The stack trace is 40 lines long.

**Type this:** paste the whole trace, then:

> This started happening about an hour ago. Find the root cause. Don't fix
> anything yet, just tell me what's wrong and how confident you are.

Claude reads the files in the trace, looks at recent git history, and gives
you a diagnosis. The "don't fix anything yet" matters: you want to agree on
the cause before code changes.

**Then:**

> That matches what I'm seeing. Fix it with the smallest possible change and
> add a test that would have caught it.

**Why it works.** Pasting the real trace beats describing it. Separating
diagnosis from fix means you never get a confident patch for the wrong bug.

---

## "I need to add a small feature"

**Situation.** Ticket says: add a `--dry-run` flag to the import command.

**Type this:**

> Add a --dry-run flag to the import command in cli/import.py. When set, it
> should log every record it would write but not write anything. Before you
> change any code, tell me which files you'd touch and how.

Claude proposes: touch `cli/import.py`, thread the flag into
`importer.write()`, add two tests. You read it, it looks right, you say:

> Go ahead.

It edits, shows you each diff, runs the tests.

**Then:**

> Commit this with a good message.

**Why it works.** "Tell me first" costs ten seconds and catches wrong
assumptions before they become code you have to revert.

---

## "I wrote a function and I need tests"

**Situation.** You wrote `parse_duration("1h30m")` and you hate writing tests.

**Type this:**

> @utils/time.py write pytest tests for parse_duration. Cover the happy path,
> empty string, garbage input, and combined units like "1h30m15s". Put them
> in tests/test_time.py next to the existing tests and match their style.

Claude reads the existing tests to match style, writes the new ones, runs
them. Two fail. It tells you why: your function doesn't handle seconds.

**Then:** decide whether that's a bug in the test or the function. Say:

> The function should support seconds. Fix the function, not the tests.

**Why it works.** Naming the cases you care about keeps the tests
meaningful. "Match the existing style" keeps the codebase consistent.

---

## "I'm stuck in a git mess"

**Situation.** Mid-rebase, three conflicted files, you're afraid to touch
anything.

**Type this:**

> I'm in the middle of a rebase with conflicts. Show me what's conflicted and
> explain each conflict in plain words. For auth.py I want main's version.
> For the other two, keep my changes. Don't run anything destructive.

Claude runs `git status` and `git diff`, explains each conflict, resolves
them as instructed, and asks before continuing the rebase.

**Why it works.** Git is a language Claude speaks fluently. Telling it what
outcome you want for each file is enough. "Nothing destructive" is a good
habit until you trust it.

---

## "What does this regex / SQL / bash one-liner do?"

**Situation.** You found this in the codebase:

```
^(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$
```

**Type this:** paste it, then:

> Explain this piece by piece. Then give me three inputs that match and
> three that don't.

**Why it works.** Concrete examples are how you actually verify you
understood it.

---

## "I need a commit message / PR description"

**Situation.** You've done the work. You have nothing left for words.

**Type this:**

> Look at the staged changes and write a commit message. First line under 70
> characters, then a short paragraph on why, not what.

Or for a PR:

> Write a PR description for this branch compared to main. Sections: what
> changed, why, how to test. Keep it short.

**Why it works.** Claude has the full diff in front of it. You'd have to
re-read it.

---

## Habits to build at this level

- **Start `claude` from the project root.** It works with what it can see.
- **Reference files with `@path`.** Type `@src/` and hit Tab to autocomplete.
- **Paste, don't describe.** Stack traces, error output, screenshots
  (Ctrl+V or Cmd+V for images).
- **Say "don't change anything yet" when you want to think first.**
- **Read every diff before approving.** Reject the parts you don't like.
  Claude adjusts.
- **`/clear` between unrelated tasks.** Old context makes it worse at the
  new task.
- **Run `/init` once** to create a `CLAUDE.md` with your test and lint
  commands. Keep it under 30 lines.

Comfortable? Go to [Level 2](02-advanced.md).
