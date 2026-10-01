---
name: rocke-pr-review
description: >
  Use when asked to review a rocKE (ROCm/rocm-libraries hip-kernel-provider) PR against the
  team's PR review checklist — "review this PR against the checklist", "run the rocke
  checklist on PR N", "pre-push review", "did I miss anything on this PR". Grades every
  checklist item with evidence, one reviewer per section, so nothing is skimmed.
---

# rocke-pr-review

## Overview

A single agent handed ~100 checklist items skims: it summarizes "the relevant ones" and
silently drops the rest. This skill is a gate, not a memory exercise. Drive the review from
the checklist file, grade **every item** with a verdict and evidence, and split the work so
one reviewer handles one section.

**Core rule: one row per checklist item. Every item gets a verdict. A dropped item is a
failed review, not a clean one.**

## Non-negotiable contract

1. **The checklist file is the source of truth.** Read `checklist.md` in this skill's folder
   (next to this `SKILL.md`) fresh on every run. Never grade from memory. Parse the
   `## <letter>. <title>` headers and every `- [ ]` line under them; count the items in each
   section yourself (the count changes as the team adds items).
2. **Grade every item.** Output a table per section, one row per `- [ ]` item, columns:
   `§ · item (verbatim, trimmed) · verdict · severity · evidence`.
   - verdict ∈ `PASS | FAIL | N/A | NEEDS-INFO` — never blank, never omitted.
   - evidence is required for every verdict: `file:line` for PASS/FAIL, a one-line reason for
     N/A, what is missing for NEEDS-INFO. A bare "PASS" with no evidence is a skim; reject it.
   - severity only on FAIL: `BLOCKER | HIGH | MEDIUM | LOW`. `★` items default to ≥ HIGH.
3. **Completeness.** Each section ends with `graded X/Y`, where Y is the parsed item count.
   X must equal Y. An item you cannot grade is `NEEDS-INFO`, not absent.
4. **Never post.** The report is for the user only. Do not run `gh pr comment`,
   `gh pr review`, or any API call that writes to GitHub. If the user asks for a reply, draft
   it, show it, and post only after they explicitly approve that text.

## Process

1. **Load** `checklist.md`; record the per-section item counts.
2. **Get the diff**: `gh pr diff <N> --repo ROCm/rocm-libraries`, or for local work
   `git diff <base>...HEAD`. Read the full files each hunk touches, not only the patch, and
   the C++ twin of any changed selector, spec, lowering or dispatch code (C++ is live).
   - If the diff contains a design or algorithm document, also read the emitters and dispatch
     files it describes, every sibling doc in its directory and peer family directories, and
     `git show origin/develop:<path>` for every symbol whose novelty it claims.
3. **Read the grading context** box at the top of `checklist.md` (review-response diffs,
   C++ is live, three-stage parity). It changes how items are graded.
4. **Fan out — one reviewer per section.**
   - If your tool can run subagents, start one per section, all in parallel.
   - If it cannot, grade the sections one at a time; finish and print one section's table
     with its `graded X/Y` before starting the next.
   - Give each reviewer: its section's items verbatim, the diff, the touched files, the
     grading context, and the §H or §J instructions below if it owns that section. Each
     returns its full table with `graded X/Y`; nothing summarized away.
5. **§H (paged / indirection diffs): trace, don't scan.** Before grading, produce one row per
   device-side mask or bound: `(source of its extent)` vs `(compile-time range the kernel
   visits)`, and whether they agree. Then list every launch input that feeds a device bound
   or mask (`block_tables`, `kv_lens`, strides, counts) and confirm each has a host validation
   AND a negative test. A check found on one input means: check its siblings.
6. **§J (any Markdown in the diff).** On a docs-only diff, sections A–I legitimately grade
   N/A, so a green report proves nothing; §J is the review. Before grading, produce:
   (a) a **shape table** — one row per equation: operands with shapes, inner dims agree?,
   result shape vs declared; (b) a **symbol table** — every symbol in a formula, where it is
   defined, its domain (linear vs log, which log base), flagging any symbol with two
   meanings; (c) a **novelty table** — every "added / new / now shared" claim with its
   `git show origin/develop:<path>` verdict.
7. **Combine.** Concatenate the section tables verbatim. Re-check every BLOCKER and HIGH
   finding yourself (open the `file:line`, confirm the control flow) before reporting it.
   Then print: total `graded / total`, and findings sorted BLOCKER → HIGH → MEDIUM → LOW,
   each as `§ · file:line · fix`. Overall verdict is **FAIL** if there is any BLOCKER or any
   ungraded item, otherwise **PASS**.
8. **Output.** Print the report in the chat. Write it to a file only if the user asks.

## Grading rules that catch what skims miss

- **N/A is a verdict with a reason**, not silence: "N/A: no C++ twin for this Python-only
  kernel family" is fine; blank is not.
- **Green ≠ done** (§G): CI, host and compile checks are necessary, not sufficient. C++ is
  often not built in CI (a skip is not a pass). Kernel work is done only on silicon (fp32
  reference, bf16 tolerance).
- **No perf numbers** (§E★): none, absolute or relative, including vs AITER, in code,
  commit messages or the PR description.
- **A bug is a CLASS** (§C★): a fix at one site is incomplete until you grep the C++ twin,
  the other arch's helper, and every sibling deciding the same invariant.
- **Verify first-hand**: trace `file:line` and confirm control flow; never relay a
  reviewer's or tool's claim unchecked.

## Review-response diffs get the same gate

A fix pushed to satisfy a reviewer is a new diff. Grade it from the top: it is late, it
feels small, and it is where defects concentrate. Code written to make a claim checkable is
itself unverified (grade it as a deliverable). A hoist or refactor must preserve failure
modes, not only success paths.

## Common mistakes (skim modes — reject these)

| Skim behavior | Required instead |
|---|---|
| Prose summary of "key findings" | Per-item table; the summary is derived from it |
| Silently dropping items that "don't apply" | `N/A` + one-line reason for each |
| Bare `PASS` with no evidence | `file:line` (or an explicit reason) on every row |
| One reviewer grades all ~100 items | One reviewer per section |
| "Small diff, skip §G/§H" | Every section is graded, even when mostly N/A |
| Trusting green CI for C++ | Review C++ by hand / run `check_byte_identity.py` |
| "It's docs-only, nothing to break" | §J with its shape, symbol and novelty tables |
| Reading a doc's equations for plausibility | Type-check them: inner dims, declared vs result shape |

## Red flags — you are skimming, stop

- The report has fewer rows than the checklist has items.
- A section lacks `graded X/Y`, or X ≠ Y.
- A PASS with no `file:line`.
- You read only the patch, not the touched files or the C++ twin.
- A paged/indirection diff without the §H trace table.
- A Markdown diff graded green without the §J tables.
- The diff is a review-response push and you graded only the original diff.
- A new guard or detector graded PASS without anyone constructing the condition it claims
  to catch.
