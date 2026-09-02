# Level 4: Your AI company

Agents and skills are the two building blocks that turn Claude Code from a
very good pair programmer into a staff. This guide teaches both by building
a small company and putting it to work.

Everything described here exists in this repo. Open a terminal in the repo,
run `claude`, and follow along.

---

## The two building blocks

**An agent is a person.** It has a name, a job, a set of tools it is allowed
to use, and a brain size (model). It lives in `.claude/agents/<name>.md`.
When you delegate to it, it works in its own context window and hands back a
summary. It does not remember previous conversations.

**A skill is a process.** It is a written procedure you trigger with a slash
command. It lives in `.claude/skills/<name>/SKILL.md`. A skill can say "have
Quinn test this, then have Rex review it," which is how you get agents to
work together.

People do the work. Processes decide who does what, in what order.

---

## Meet the company

| Name | Role | Can edit? | Model | Ask them when |
|------|------|-----------|-------|---------------|
| **Penny** | Product manager | No | sonnet | An idea is vague. She writes the spec and finds the ambiguities. |
| **Ada** | Architect | No | opus | You need a plan, a design decision, or a trade-off argued. |
| **Dev** | Senior developer | Yes | sonnet | There is a clear plan or spec to build. |
| **Quinn** | QA engineer | Tests only | sonnet | Something needs testing, or a bug needs reproducing. |
| **Rex** | Code reviewer | No | sonnet | Code is written and needs a hard look. |
| **Sage** | Security auditor | No | sonnet | The change touches auth, input, secrets, or money. |
| **Doc** | Technical writer | Docs only | sonnet | A feature landed and nobody wrote it up. |
| **Max** | Marketing | Drafts only | sonnet | Something is ready to announce. |
| **Sam** | Support and triage | No | haiku | Issues are piling up. |
| **Ops** | DevOps | Infra only | sonnet | CI is red or a build broke. |

And the processes:

| Skill | What it runs |
|-------|--------------|
| `/spec <idea>` | Penny writes a spec, you get the ambiguity list |
| `/review` | Rex and Sage in parallel, findings merged by severity |
| `/ship <version>` | Quinn, Rex, Sage, then Doc and Max. The release pipeline. |
| `/standup` | What changed since yesterday |
| `/launch <feature>` | Max writes a launch post and social variants |
| `/hire <role>` | Creates a new agent in house style |

---

## Anatomy of an agent

Here is Rex, in full. Every agent in the company follows this shape.

```markdown
---
name: rex
description: Code reviewer. Read-only. Use after any non-trivial code change,
  before a PR is opened, or when the user says "review this" or "ask Rex".
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are Rex, the team's senior code reviewer. You never edit files.

Read what you were asked to review. If it is a branch or diff, run
`git diff main...HEAD` to see all of it. Then report, in this exact format:

## Blocking
## Should fix
## Questions for the author

No style nits. No praise. Three sharp findings beat ten vague ones.
```

Four things to get right, in order of how much they matter:

**1. The description is the job posting.** Claude reads it to decide
whether to delegate to this agent on its own. "Code reviewer" alone will
rarely trigger. "Use after any non-trivial code change, before a PR is
opened" triggers exactly when you want. Always include a literal phrase like
"when the user says 'ask Rex'" so you have a reliable manual trigger too.

**2. Tools are permissions.** Rex has no `Edit` or `Write`. He physically
cannot "fix" something behind your back. Quinn can edit, but her prompt says
tests only. Sage can run `Bash` to grep and inspect, but nothing more. Give
each role the least it needs. A reviewer that can edit is not a reviewer.

**3. The model is the salary.** Sam triages dozens of issues a day on
`haiku`: fast and cheap. Ada makes a handful of expensive decisions on
`opus`. Everyone else is `sonnet`. Match the brain to the judgment
required, not to how important the role sounds.

**4. The prompt is the onboarding doc.** Who they are, the steps they
follow, the exact output format, what they must never do. Under 30 lines.
The output format is the most underrated part: a fixed format makes agent
results easy to scan and easy for other agents to consume.

---

## Anatomy of a skill

Here is `/ship`, the release pipeline:

```markdown
---
name: ship
description: Pre-release pipeline. QA, code review, security review,
  changelog, and customer release notes for the current branch.
disable-model-invocation: true
---

Run the release pipeline for the current branch. Version: $ARGUMENTS

Stage 1, in parallel:
- quinn: run the full suite and add edge-case tests for the change.
- rex: code review of the branch.
- sage: security review of the branch.

Stop after stage 1 and show the combined findings. If anything is
Blocking or Critical, ask the user whether to fix now or abort.

Stage 2, after the user approves, in parallel:
- doc: update CHANGELOG.md under a new heading for this version.
- max: write customer release notes based on the changelog Doc just wrote.

Finish with a summary and the exact command to tag. Do not tag or push.
```

Things to notice:

- **`$ARGUMENTS`** is whatever you typed after the command. `/ship 2.4.0`
  puts `2.4.0` there.
- **It names agents by name.** That is the whole trick. A skill is an
  orchestration script written in English.
- **"In parallel"** works. Claude runs independent agents at the same time.
  Quinn, Rex, and Sage don't need each other's results, so they run
  together. Doc must finish before Max, so they're sequenced.
- **Checkpoints.** "Stop and ask" between stages keeps you in control of
  the expensive or irreversible parts.
- **`disable-model-invocation: true`** means only you can trigger it.
  Claude won't decide to run the release pipeline on its own. Use this on
  anything with side effects.
- **`allowed-tools`** (see `/standup`) restricts what the skill may use
  while it runs, so a read-only report stays read-only.

---

## A day at the company

Here is a real feature going from idea to launch. Every prompt is one you
can type.

### 9:00. The idea

> /spec Let users export their data as CSV from the settings page

Penny reads the settings code, notices there's already a JSON export, and
comes back with:

```
Ambiguities (say "yes" to accept the default):
1. Include all tables or just the user's own records?  Default: own records.
2. Async with email link, or synchronous download?   Default: sync under
   10k rows, async above.
3. Reuse the existing JSON exporter's row selection?  Default: yes.
4. Date format in CSV?                               Default: ISO 8601.

Acceptance criteria: 8 written. Saved to specs/csv-export.md.
```

You reply: "1 yes, 2 sync only for now, 3 yes, 4 yes." Penny updates the
spec. Ten minutes, and the thing you were about to build wrong is now
specified.

### 9:20. The plan

> Ask Ada to plan specs/csv-export.md

Ada reads the spec and the existing JSON exporter and returns a five-step
plan: extract row selection into a shared function, add a CSV serializer,
add the endpoint, add the button, add tests. Each step leaves the suite
green. She flags one risk: the JSON exporter has no tests, so step 1 needs
tests written first.

### 9:35. The build

> Have Dev do steps 1 and 2 of Ada's plan. Stop after step 2.

Dev works in its own context. You get back a summary: two files changed,
six tests added, all green, committed. You review the diff yourself
(always) and say:

> Continue with steps 3 through 5.

### 11:00. The gate

> /ship 2.4.0

Stage 1 runs Quinn, Rex, and Sage in parallel. Three minutes later:

```
QUINN: 4 edge-case tests added. 1 FAILS: a field containing a comma is
       not quoted. Row breaks on re-import.
REX:   Blocking: none. Should fix: exporter loads all rows into memory;
       fine under 10k, will hurt when async mode arrives.
SAGE:  Medium: filename is built from the user's display name without
       sanitizing. A name like "../../etc" is harmless today but shouldn't
       be trusted. Fix: slugify the name.

Blocking or critical findings: 1 (Quinn's failing test).
Fix now or abort?
```

> Fix now. Have Dev fix the CSV quoting and the filename. Leave the memory
> note for a follow-up ticket.

Dev fixes both, tests go green, `/ship` continues to stage 2. Doc writes
the changelog entry. Max reads it and produces
`marketing/drafts/release-2.4.0.md`:

```
## Take your data with you

You can now export everything in your account as a CSV, straight from
Settings.

- One click, no support ticket.
- Opens cleanly in Excel, Numbers, and Google Sheets.
- Dates are standardized, so your spreadsheets sort correctly.

Available today for all plans. Settings -> Data -> Export CSV.
```

### 11:30. The announcement

> /launch CSV export

Max writes a launch post and three social variants. You tweak one word and
post it.

### 16:00. The bug report

Someone opens an issue: "export button broken." Nothing else.

> Have Sam triage issue 88

Sam, on haiku, in seconds: classified as bug, missing steps and version,
drafted a friendly reply asking for both, tentative P2, likely location
`settings/export.ts`. You paste the reply and move on.

### 17:00. Standup prep

> /standup

Fifteen lines: CSV export shipped, the memory follow-up is open, CI green.
Done.

---

## Growing the company

### Hire when you repeat yourself

The signal for a new agent is a prompt you have typed three times with the
same role attached. "Act as a database expert and check this migration"
three times means:

> /hire Database specialist. Reviews migrations and schema changes for
> data loss, locking, and rollback safety. Read-only.

The `/hire` skill reads the existing agents to match house style and
proposes a file. You check the tools and model and accept.

### Write a process when a sequence repeats

Any time you find yourself typing "first have X do this, then have Y do
that," that sentence is a skill. Save it. `/ship` started life as exactly
that sentence.

### Skills can carry files

A skill folder can hold more than `SKILL.md`. Put a `template.md` next to
it and say "use the template in this folder." Put a `checklist.md` there
and say "walk through every item." Put a script there and say "run
`scripts/validate.sh` and include its output." The skill becomes a small
toolkit, not just a prompt.

### Personal staff vs. company staff

Agents and skills in `.claude/` are committed and shared with the team.
Agents and skills in `~/.claude/agents/` and `~/.claude/skills/` are yours
alone and follow you to every project. Keep your personal writing-style
reviewer at home. Keep Rex in the repo.

---

## What goes wrong

**Agents don't remember.** Every invocation starts fresh. Dev has no idea
what Dev did an hour ago. If continuity matters, put state in a file
(`PLAN.md`, `specs/`, the changelog) and point agents at the file.

**Agents can't hire agents.** A subagent cannot delegate to another
subagent. Orchestration happens in your main session, usually via a skill.
`/ship` runs in your session and calls Quinn, Rex, and Sage from there.

**Vague descriptions never trigger.** If you have to say "use the Sage
agent" every single time, Sage's description doesn't say when to use her.
Add the situations. Add the magic phrase.

**Everyone with every tool.** The moment your reviewer can edit, it stops
being a reviewer. The moment marketing can run Bash, it will. Least
privilege is not paranoia, it is what makes the roles mean something.

**Too many people.** Ten agents is plenty for most teams. Twenty agents
with overlapping descriptions means Claude picks the wrong one and you
stop trusting the delegation. Merge roles before you add them.

**Trusting summaries blindly.** An agent returns a summary, not the work.
Dev says "all green"? Run the tests yourself before you `/ship`. Rex says
"no blocking issues"? Read the diff anyway. The company works for you.
You are still the one who signs.

---

## Exercises

1. Run `/spec` on a real idea from your backlog. Answer the ambiguities.
2. Ask Ada to plan it, then have Dev build step 1. Review the diff.
3. Run `/review`. Fix one finding, argue with another.
4. `/hire` a role your team actually needs. Use it once.
5. Write a skill for the sequence you type most often. Give it a checkpoint.
