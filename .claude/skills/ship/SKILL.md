---
name: ship
description: Pre-release pipeline. QA, code review, security review, changelog, and customer release notes for the current branch. Use when the user types /ship.
disable-model-invocation: true
---

Run the release pipeline for the current branch. Release name or version:
$ARGUMENTS

Stage 1, in parallel:
- quinn: run the full suite and add edge-case tests for the change.
- rex: code review of the branch.
- sage: security review of the branch.

Stop after stage 1 and show the combined findings. If anything is Blocking
or Critical, ask the user whether to fix now or abort. Do not continue
until they answer.

Stage 2, in parallel, after the user approves:
- doc: update CHANGELOG.md under a new heading for this version.
- max: write customer release notes to marketing/drafts/release-<version>.md
  based on the changelog Doc just wrote.

Finish with a short summary: tests added, findings fixed, files written,
and the exact command to tag the release. Do not tag or push anything.
