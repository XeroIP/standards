---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-09T22:22:26+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-6 and the follow-up are merged: #40, #41, #42, #47, #48, #49 and #51. The leakage
  scanner, gitleaks, generator parity, design token and prose gate fixes are complete.
- Issues #43-#46 and #50 are filed. #50: Vale runs at `latest` in both Prose steps.

## In progress / broken

- PR 7, on `fix/check-docs`: the vendor exclusion is this repository's own
  `docs/prose/vendor/`; zero pages exit 2; ADR sections and `supersedes` are checked;
  `severity_ui` needs the page type and tag that allow it. `tests/test-check-docs.sh`
  covers each check in both directions.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 7 to merged, then open PR 8 on the links job: path triggers plus a weekly schedule
in `self-check.yml`, `llms.txt` as a lychee input, and an explicit `.lychee.toml`.

## Blockers / waiting on

- Review of PR 7.
- The release exercise is the owner's, and waits until PR 11 is built.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
