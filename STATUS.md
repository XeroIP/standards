---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-09T19:32:40+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-4 and the follow-up are merged: #40, #41, #42, #47 and #48. The leakage scanner,
  gitleaks and generator parity fixes are complete.
- Issues #43-#46 are filed: incident tables, profile and stack gates,
  `standards_version` pin semantics, and the site build.

## In progress / broken

- PR 5, on `fix/design-tokens`: `tokens.css` generated with the adapters, the severity opt-in
  fixed in every adapter and both themes, and `check-rendered-design.js` exit codes.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 5 to merged, then open PR 6: the prose gate in `tools/build-vale.js` (counts by
`scope: raw`) and the reviewdog filter in `.github/workflows/docs-ci.yml`.

## Blockers / waiting on

- Review of PR 5.
- The release exercise is the owner's, and waits until PR 11 is built.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
