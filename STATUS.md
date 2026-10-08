---
state: blocked       # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-08T05:54:16+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- Stage 2 is complete. Every inventoried claim has a verdict with evidence, from deliberate
  breaks on a throwaway branch (eleven rounds, each restored to green) or local runs of the
  same tools.
- The stage 3 proposal is drafted: fourteen pull requests grouped by mechanism, five new
  issues and six owner actions. The audit notes stay outside the repository until the fixes
  land.

## In progress / broken

- Nothing is half-built. The throwaway branch `audit/gate-exercise` still exists, because
  this session's credentials can't delete branches. It differs from main only in this
  file and has no queued runs.

## Next step

Get the owner's rulings on the stage 3 questions, then open the first pull request: the
leakage scanner fixes in `tools/check-leakage.py` and `tests/test-leakage.sh`.

## Blockers / waiting on

- The owner's rulings on the stage 3 proposal's open questions.
- The owner: delete `audit/gate-exercise`, cancel the three waiting sync runs, enable the
  security reporting channel the docs name, run the private-path runbook.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
