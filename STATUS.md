---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-09T20:06:26+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-5 and the follow-up are merged: #40, #41, #42, #47, #48 and #49. The leakage
  scanner, gitleaks, generator parity and design token fixes are complete.
- Issues #43-#46 and #50 are filed. #50 is new: Vale runs at `latest` in both Prose steps.

## In progress / broken

- PR 6, on `fix/prose-gate`: the cap rules count the whole file (`scope: raw`), with
  `tests/test-vale.sh` run on CI's own Vale binary; the prose README's marker count is
  generated; both Prose steps pass `filter_mode: nofilter`.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 6 to merged, then open PR 7 in `tools/check-docs.py`: exclude
`docs/prose/vendor/` by exact path, make zero pages checked exit 2, and the J4 tag checks.

## Blockers / waiting on

- Review of PR 6.
- The release exercise is the owner's, and waits until PR 11 is built.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
