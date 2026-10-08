---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-08T02:13:29+00:00
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

- The audit's stage 1 checkpoint has three questions still open.

## Next step

Answer checkpoint question 4, then start stage 2 by building a throwaway consuming repo
with `python3 tools/sync-standards.py --target <scratch repo> --adopt`.

## Blockers / waiting on

- The owner's answers to the open checkpoint questions.
- The handoff block's ownership: an external installer writes it into `CLAUDE.md`, which is
  generated here. Do not re-run that installer against this repo until that is settled.
