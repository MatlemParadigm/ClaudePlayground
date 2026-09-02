# Level 2: Intermediate, real situations

You know the basics. Now the situations get bigger and the prompts get more
deliberate.

---

## "This module needs a real refactor"

**Situation.** `OrderService` is 1,400 lines. Everyone is afraid of it. You
have a sprint to fix that.

**Do this.** Press `Shift+Tab` until you're in plan mode. Claude can read but
not edit. Then:

> Read services/order_service.py and everything that imports it. Don't write
> code. I want to split this into smaller pieces without changing behavior.
> Propose a plan: what the new modules are, what moves where, and what order
> to do it in so tests pass after every step.

Claude comes back with a plan. Push back on it:

> Step 3 breaks the public API. Callers in the billing package would need to
> change. Rework the plan so the public interface stays put.

When the plan is right, approve it, switch out of plan mode, and:

> Do step 1 only. Run the tests. Stop and show me before step 2.

**Why it works.** Plan mode forces the thinking to happen before the edits.
One step at a time means a bad step 3 doesn't cost you steps 1 and 2.

---

## "A bug report came in and I want to fix it properly"

**Situation.** Issue: "Discount codes with lowercase letters are rejected."

**Type this:**

> Write a failing test that reproduces this: discount code "summer20" should
> be accepted the same as "SUMMER20". Run it and confirm it fails. Don't fix
> the bug yet.

Claude writes the test, runs it, shows the failure. Now:

> Make it pass. Don't touch the test.

**Why it works.** Test first means you have proof the bug existed and proof
it's gone. "Don't touch the test" stops Claude from making the test agree
with the bug.

---

## "We're migrating off a library"

**Situation.** 200 files import `moment`. You're moving to `date-fns`.

**Type this:**

> Find every file that imports moment. Group them by how they use it
> (formatting, parsing, math, timezones). Show me the groups and counts.
> Don't change anything.

Now you know the shape of the job. Then:

> Migrate only the formatting group. Do it file by file, run the tests after
> each file, and stop if anything fails. Show me the first two files before
> continuing.

**Why it works.** A 200-file change in one shot is unreviewable. Grouping
turns it into four reviewable changes. "Stop if anything fails" keeps a
broken state from spreading.

---

## "Review my work before I open the PR"

**Situation.** You're about to ask a busy senior for review. You'd rather
they find nothing.

**Type this:**

> Review the diff on this branch against main as a skeptical senior engineer.
> I'm looking for bugs, edge cases I missed, and anything that would make you
> request changes. No style nits. Be blunt.

**Then**, for anything it flags:

> Fix items 1 and 3. I disagree with 2, here's why: [reason]. Tell me if I'm
> wrong.

**Why it works.** Claude will happily argue with you. Cheaper than a review
round trip with a human.

---

## "Make the UI match this mockup"

**Situation.** Design sent a Figma screenshot. Your component looks nothing
like it.

**Do this.** Paste the screenshot (Cmd+V or Ctrl+V), then:

> This is the target design for the settings panel. The current version is in
> components/SettingsPanel.tsx. Update it to match: spacing, layout, and the
> two-column form. Keep our existing color tokens, don't hardcode colors.

Run the app, take a screenshot of the result, paste that too:

> Here's what it looks like now. The labels should be above the inputs, not
> beside them. Fix that.

**Why it works.** Screenshots in both directions. Claude sees the target and
the result, and iterates like a designer would.

---

## "Pull the ticket and just do it"

**Situation.** You've connected your issue tracker through MCP
(`claude mcp add ...` or a committed `.mcp.json`).

**Type this:**

> Read Linear ticket ENG-1423. Summarize what it's asking for in your own
> words, list anything ambiguous, then propose a plan.

The ambiguity list is the point. Take it back to the ticket author, or
decide yourself:

> For the ambiguities: 1 is yes, 2 is no, 3 doesn't matter. Implement it.
> Then post a comment on the ticket summarizing what you did.

**Why it works.** Tickets are vague. Making Claude surface the vagueness
before writing code is where you save the most time.

---

## "Upgrade this dependency and deal with the fallout"

**Situation.** Framework major version bump. Changelog is long.

**Type this:**

> Upgrade React from 18 to 19. Read the official migration guide first. Then
> run the build and tests, and fix breakages one at a time. Keep a running
> list of what you changed and why. If something needs a judgment call, stop
> and ask.

**Why it works.** "Read the guide first" beats guessing. "Stop and ask" for
judgment calls means the routine 90% gets done and you only see the hard
10%.

---

## "This flaky test is driving me crazy"

**Situation.** Passes locally, fails in CI one time in five.

**Type this:**

> tests/test_scheduler.py::test_retry fails intermittently in CI. Run it 20
> times in a loop and tell me how often it fails here. Then read the test and
> the code under test and give me your top three theories, ranked.

Then:

> Theory 1 sounds right. Prove it: make the failure reproduce deterministically
> before you fix it.

**Why it works.** Reproduce, then fix. Claude is patient enough to run a
test 20 times. You aren't.

---

## "Write the docs nobody wrote"

**Situation.** Your internal API has no README. Onboarding takes a week.

**Type this:**

> Read src/api/ and write a README for it aimed at a developer who will call
> this API from another service. Include: what it does, auth, the five most
> used endpoints with example requests, and common errors. Pull the examples
> from the actual tests so they're real.

**Why it works.** "Pull from the tests" keeps the docs honest. Claude
won't invent an endpoint that doesn't exist if you anchor it to real code.

---

## Habits to build at this level

- **Plan mode for anything over 30 minutes of work.**
- **Tests first for bug fixes.** Prove it broken, prove it fixed.
- **Chunk big changes** and review each chunk.
- **Save your repeated prompts as skills.** If you've typed "review this as
  a skeptical senior engineer" three times, put it in
  `.claude/skills/review/SKILL.md` and type `/review` instead. This repo has
  one at `.claude/skills/explain/`.
- **Stop approving the same safe commands.** Add `npm test`, `git diff` and
  friends to `permissions.allow` in `.claude/settings.json`.
- **One task per session.** Parallel work goes in git worktrees, one
  terminal each.
- **`/compact` when a session gets long,** and tell it what to keep:
  `/compact focus on the migration, drop the debugging`.

Ready to stop typing prompts and start automating them? [Level 3](03-expert.md).
