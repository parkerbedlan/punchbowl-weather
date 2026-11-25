---
name: challenge-wrap-up
description: Final step of the Punchbowl Weather take-home challenge. Exports the full Claude Code conversation to AI-TRANSCRIPT.md, drafts a structured collaboration summary in AI-SUMMARY.md, and commits both. Run this after the acceptance criteria are complete and before returning the challenge.
---

# Challenge wrap-up

Produce the two files the review team reads alongside the code, then commit them.

The reviewers can see *what* was built by reading the diff. What they cannot see is
which decisions the candidate made, which ones the assistant proposed, and what was
considered and rejected. That is what these two files are for.

## Step 1 — Export the transcript

Run the exporter from the repository root:

```bash
ruby .claude/skills/challenge-wrap-up/scripts/export_transcript.rb
```

This finds every Claude Code session that ran in this project directory, in order,
and writes `AI-TRANSCRIPT.md`.

Do **not** write this file from memory. Long sessions are compacted, so anything
reconstructed from context is a paraphrase with turns silently missing. The session
logs on disk are the only faithful record.

If the command fails with something like `No version is set for command ruby`, a
version manager is shimming `ruby` and there is no version pinned at the repo root.
Run it from the backend instead, which has one:

```bash
cd backend && ruby ../.claude/skills/challenge-wrap-up/scripts/export_transcript.rb \
  --project .. --out ../AI-TRANSCRIPT.md
```

Useful flags: `--truncate 0` keeps full tool output, `--thinking` includes the
assistant's reasoning blocks, `--subagents` includes subagent messages. The defaults
keep the file readable; reach for these only if asked.

Report the file size back. If it is very large, mention that `--truncate 500` will
shrink it, but do not re-run with a smaller limit unless the candidate asks — the
point of this file is that it is complete.

## Step 2 — Draft the summary

Write `AI-SUMMARY.md`. Ground it in evidence, not recollection:

- `git log --stat` for what was actually built, in what order
- `grep -n "^### Human" AI-TRANSCRIPT.md` to recover the arc of the conversation,
  including the parts of it that are no longer in context
- Read around any turn that looks like a decision point, a correction, or a reversal

Use these sections:

1. **Approach** — how the work was broken down, and why in that order.
2. **Working with Claude** — what the candidate directed versus what the assistant
   proposed unprompted. How the work was verified.
3. **Decisions with real alternatives** — for each, what was chosen, what else was
   on the table, and why. The load-bearing ones in this challenge are the caching
   strategy, how favorite metrics survive an unfavorite, how alerts avoid
   re-notifying, and how duplicate locations are detected.
4. **Corrections** — places the assistant was wrong, went the wrong direction, or
   produced work that was thrown away, and how that was caught. Reviewers care about
   this section more than any other; it is the clearest evidence of engineering
   judgment rather than acceptance.
5. **Verification** — what was actually run and observed: tests, the app in a
   browser, any measurements taken. Distinguish "the tests pass" from "I watched it
   work".
6. **Deliberately not done** — scope that was considered and cut, with the reasoning.
7. **Known gaps and next steps** — shortcuts, stubs, and what would come next.

Rules for writing it:

- **Never invent the candidate's reasoning.** Report a decision you can see in the
  transcript or the diff; do not narrate a motive for it that you cannot support.
- Where the *why* behind a real decision is not recoverable, either ask the candidate
  directly (at most three questions, and only for genuine gaps) or leave an explicit
  `TODO:` line for them to fill in. An honest gap is better than a confident guess.
- Aim for something readable in five minutes. Specifics over completeness.

## Step 3 — Commit

```bash
git add AI-TRANSCRIPT.md AI-SUMMARY.md
git commit -m "Add AI collaboration transcript and summary"
```

Then confirm both files are committed and the tree is clean.
