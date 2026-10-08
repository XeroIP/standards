---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-08T04:47:47+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- Started the enforcement-honesty audit. Its working notes stay outside the repository
  until the fixes land.
- Main was red: the handoff block had been hand-added to `CLAUDE.md`, a generated file, and
  the parity gate rejected it. The block now lives in `AGENTS.md` and both agent files are
  regenerated from it.

## In progress / broken

- Stage 2 is exercising gates on the throwaway branch `audit/gate-exercise`. Its commits are
  deliberate breaks and restores, and the branch is deleted when the cycles finish.

## Next step

Finish the red/green cycles on `audit/gate-exercise`, record each run ID against its claim, then
delete the branch and confirm no queued runs survive it.

## Blockers / waiting on

- The owner's answers to the open checkpoint questions.
- The handoff block's ownership: an external installer writes it into `CLAUDE.md`, which is
  generated here. Do not re-run that installer against this repo until that is settled.
