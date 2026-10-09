---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-09T15:35:36+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-3 are merged: #40 (leakage scanner), #41 (every IANA suffix in prose) and #42
  (gitleaks in consumers, one release, and a copy without this repository's exclusions).
- Issues #43-#46 are filed: incident tables, profile and stack gates,
  `standards_version` pin semantics, and the site build.

## In progress / broken

- The follow-up to #41, on `fix/leakage-scanner-rulings`, carries the owner's conditions on
  rulings 1 and 3-6. It also stops the vendored scanner skipping a consumer's fixture
  directories, and limits the user-part rule for `@` to `.md`.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive the follow-up to green and merged, then open PR 4: make the self-check generators
job see new files, with `git status --porcelain` in `.github/workflows/self-check.yml`.

## Blockers / waiting on

- Review of the follow-up PR.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
