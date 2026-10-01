# Contributing

The checklist is `skills/rocke-pr-review/checklist.md`. It is the single source of truth.

## Every change is a PR

- Branch from `main` as `users/<your-login>/<topic>`, open a PR, request review from
  `AviralGoelAMD`. The owner merges.
- Never push to `main`. This repo's plan cannot enforce it, so it is a rule we keep by hand.
  A commit that reaches `main` by mistake is undone with a revert PR, never a force-push.

## Adding or changing a checklist item

1. Search the checklist first. Most new catches are another instance of an existing item:
   add your PR number to it, or sharpen its wording, instead of adding a near-duplicate.
2. A new item is one `- [ ]` line in the right section (`## A.`–`## J.`), written so an agent
   can grade it from a diff, with one example PR number and a short reason.
3. Mark it `★` only when missing it caused a real bug or a reviewer catch.
4. Keep the format: section headers `## <letter>. <title>`, items `- [ ] ...`. The skill
   parses exactly these.

## Never include

- Absolute performance values (latency, throughput, TFLOP/s, bandwidth). Write lessons
  qualitatively; a relative factor is fine only when the lesson needs it.
- Customer information, product/marketing/SKU names or internal code names (use gfx target
  names such as `gfx942`), CU counts, clocks or power figures.
- Internal links or internal tool paths (Jira, Confluence, Perforce, internal repos). Jira IDs
  as plain text are fine.
- Personal or process notes.

This repo is public: AMD's public-data rules and rocKE `platform/AGENTS.md` §Compliance apply
to every file, commit message and PR here.

## Before you open the PR

Run the skill on your own change (a checklist edit is a Markdown diff, so §J applies) and
paste each section's `graded X/Y` line into the PR description. For `install.sh` changes,
run `bash tests/install_test.sh` and paste its last line.
