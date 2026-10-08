---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-08T05:18:43+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- Stage 2's red/green rounds are finished. Nine rounds on a throwaway branch broke a gate
  on purpose and restored it to green, with every failure cause confirmed from its job log.
  Two rounds exercised the reusable workflows the way a consuming repo calls them.
- The evidence and verdicts stay outside the repository until the fixes land, as before.
- Main was red from a hand edit to a generated file; #35 fixed it.

## In progress / broken

- Stage 2 continues locally: a claim/not-claim call on each comment block in the
  mechanism files, local exercises for the remaining claims, then the verification table.
- The throwaway branch `audit/gate-exercise` still exists, because this session's
  credentials can't delete branches. It differs from main only in this file and has no
  queued runs.

## Next step

Finish the comment-block calls (151 blocks once the docstring miscount is corrected), then
assemble the stage 2 table ordered by consequence-if-false.

## Blockers / waiting on

- The owner: delete `audit/gate-exercise`.
- The owner: the private-path runbook results, cancelling the three waiting sync runs,
  and filing the two upstream issue drafts.
- The owner: whether a draft pull request may be opened to test the prose gate's
  pull_request path, which push runs can't reach.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
