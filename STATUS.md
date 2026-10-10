---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-10T01:24:46+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-8 and the follow-up are merged: #40, #41, #42, #47, #48, #49, #51, #52 and #53. The
  leakage scanner, gitleaks, generator parity, design tokens, prose gate, check-docs and
  links fixes are complete.
- Issues #43-#46 and #50 are filed. #50: Vale runs at `latest` in both Prose steps.

## In progress / broken

- PR 9, on `fix/diagram-tools`: both diagram checkers exit 0 or 1 instead of the count,
  the example is self-contained under `docs/diagrams/tools/examples/`, import markers and a
  boundary note record the divergence, and `tests/test-diagram-tools.sh` covers it.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 9 to merged, then open PR 10 in `tools/sync-standards.py`: demote the shared base's
H1 when assembling AGENTS.md, and lint the tool's own output in a sync test.

## Blockers / waiting on

- Review of PR 9.
- The first live run of `links.yml`: Wednesday's schedule, or a manual run by the owner.
  This session's token can't start a workflow.
- The release exercise is the owner's, and waits until PR 11 is built.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
