---
state: blocked       # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-08T16:14:28+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- Stage 2 is complete, including the private-path runbook the owner ran in the private
  pilot repository. The claim count was re-derived at the current head and is 180: a
  mechanism claim added after the first sweep was missing and is now graded.
- The owner actions are all done: the security reporting channel is enabled, release tags
  are protected against deletion and every update, the waiting sync runs are cancelled,
  and the throwaway branch is deleted.
- The owner accepted the stage 3 recommendations, the rescoped sync-tool fix, and the
  first of four design choices (how the leakage scanner decides what counts as a domain).

## In progress / broken

- Nothing is half-built. The audit notes stay outside the repository until the fixes land.

## Next step

Get the owner's ruling on the remaining three stage 3 design choices, one at a time, then
open the first pull request: the leakage scanner fixes in `tools/check-leakage.py` and
`tests/test-leakage.sh`. Re-run the claim sweep at that head first.

## Blockers / waiting on

- The owner's rulings on the remaining three design choices.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
