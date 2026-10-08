---
state: blocked       # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-08T13:48:59+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- Stage 2 is complete, including the last public probes: a public repository's visibility
  opt-out, and draft pull request #39, which tested the prose gate on pull_request events.
  #39 is closed unmerged.
- The owner enabled the security reporting channel, protected release tags with a ruleset,
  and cancelled the waiting sync runs.
- The stage 3 proposal is drafted. The audit notes stay outside the repository until the
  fixes land.

## In progress / broken

- The owner is running the private-path runbook in the private pilot repository.
- The throwaway branch `audit/gate-exercise` is finished with. It differs from main only
  in this file and has no queued runs, and this session's credentials can't delete it.

## Next step

Get the owner's rulings on the stage 3 questions, then open the first pull request: the
leakage scanner fixes in `tools/check-leakage.py` and `tests/test-leakage.sh`.

## Blockers / waiting on

- The owner's rulings on the stage 3 proposal, and the private-path runbook results.
- The owner: delete `audit/gate-exercise`; add the "restrict updates" rule to the tag
  ruleset.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
