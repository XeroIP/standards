---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-09T18:27:38+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-3 and the follow-up are merged: #40, #41, #42 and #47. The leakage scanner and
  gitleaks fixes are complete, with the owner's seven rulings applied.
- Issues #43-#46 are filed: incident tables, profile and stack gates,
  `standards_version` pin semantics, and the site build.

## In progress / broken

- PR 4, on `fix/generator-parity-new-files`: the self-check parity steps use
  `git status --porcelain`, so a generated file nobody committed fails CI.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 4 to merged, then open PR 5: the design tokens fixes in
`docs/design/build-adapters.js` and `docs/design/check-contrast.js`, with a generator for
`docs/design/tokens.css`. Its body states that no page sets `severity_ui`.

## Blockers / waiting on

- Review of PR 4.
- The release exercise is the owner's, and waits until PR 11 is built.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
