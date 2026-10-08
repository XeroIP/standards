---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-08T13:46:26+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- Stage 2 is complete and the stage 3 proposal is drafted. The audit notes stay outside the
  repository until the fixes land.
- The owner actions are done: the security reporting channel is enabled, release tags are
  protected by a ruleset, and the waiting sync runs are cancelled.

## In progress / broken

- This throwaway branch, `audit/gate-exercise`, carries the last probes: a public-repo
  visibility opt-out, then a draft pull request that tests the prose gate on
  pull_request events. Its commits are deliberate breaks and restores, and the pull request
  is closed unmerged when they finish.
- The owner is running the private-path runbook in the private pilot repository.

## Next step

Finish the draft pull request's rounds on this branch, record each run against its claim,
close the pull request unmerged, then hand the branch to the owner for deletion.

## Blockers / waiting on

- The owner's rulings on the stage 3 proposal's open questions.
- The private-path runbook results.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
