# Level 1: Beginner

Goal: get comfortable, stay in control, and stop fighting the tool.

## 1. Start in the right place

Run `claude` from the root of your project, not your home directory. Claude
Code works with the files it can see, and the project root gives it the whole
picture.

```bash
cd my-project
claude
```

## 2. Write prompts like you would brief a new teammate

Vague prompts get vague results. Say what, where, and why.

| Weak | Better |
|------|--------|
| "fix the bug" | "Login fails with a 500 when the email has uppercase letters. Start in `auth/login.py`." |
| "add tests" | "Add pytest tests for `parse_date` in `utils/dates.py`. Cover ISO strings, empty input, and timezones." |
| "make it faster" | "`export_report` takes 40s on 10k rows. Profile it and propose the top two fixes before changing anything." |

Reference files with `@`. Type `@src/` and press Tab to autocomplete a path.
Claude reads the file instead of guessing.

## 3. Create a `CLAUDE.md`

This is the single highest-value habit. `CLAUDE.md` in your project root is
read at the start of every session. Put in it what you would otherwise repeat:

```markdown
# Project notes for Claude

## Commands
- Run tests: `npm test`
- Lint: `npm run lint`
- Dev server: `npm run dev`

## Conventions
- TypeScript strict mode. No `any`.
- Use `date-fns`, not `moment`.
- Tests live next to the file they test: `foo.ts` -> `foo.test.ts`.

## Things that bite
- `src/legacy/` is frozen. Do not edit it.
```

Type `/init` in a session and Claude drafts one for you. Keep it short. A
long `CLAUDE.md` gets skimmed, a short one gets followed.

## 4. Ask before it builds

For anything bigger than a one-liner, ask Claude to describe its approach
first:

> "Before you change anything, tell me which files you would touch and why."

You catch bad assumptions in ten seconds instead of unwinding them in ten
minutes.

## 5. Review every diff

Claude shows you each change before applying it. Read them. Approve what you
understand, reject or question what you do not. Git is your safety net, so
commit often and keep the working tree clean between tasks:

```bash
git add -A && git commit -m "checkpoint before refactor"
```

## 6. Know the handful of commands that matter

| Command or key | What it does |
|----------------|--------------|
| `/help` | Lists everything else |
| `/clear` | Wipes the conversation. Do this between unrelated tasks. |
| `/compact` | Summarizes the conversation to free up context |
| `Esc` | Interrupts Claude mid-action |
| `Esc` twice | Jump back to an earlier message and retry from there |
| `Shift+Tab` | Cycle permission modes (normal, auto-accept edits, plan) |
| `#` at the start of a message | Save a note straight into `CLAUDE.md` |

## 7. Paste, do not describe

Got an error? Paste the whole stack trace. Got a UI bug? Paste the screenshot
(Ctrl+V or Cmd+V works for images). Claude does much better with the real
thing than with your summary of it.

## Exercises

1. Run `/init` in a small project, then trim the generated `CLAUDE.md` to
   under 30 lines.
2. Ask Claude to explain a file you did not write, using `@path/to/file`.
3. Ask for a small change, read the diff carefully, and reject one part of
   it on purpose. Notice how Claude adjusts.

When these feel natural, move on to [Level 2](02-advanced.md).
