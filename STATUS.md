---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-10T01:49:20+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-9 and the follow-up are merged: #40, #41, #42, #47, #48, #49, #51, #52, #53 and #54.
  The leakage scanner, gitleaks, generator parity, design tokens, prose gate, check-docs,
  links and diagram-tool fixes are complete.
- Issues #43-#46 and #50 are filed. #50: Vale runs at `latest` in both Prose steps.

## In progress / broken

- PR 10, on `fix/sync-tool`: the synced AGENTS.md has one H1 and passes the vendored
  markdownlint; `sync.protect` is honoured; `--check` counts extras, VERSION, README and the
  pin; the sync writes `standards_version`; generated agent files carry a content hash that
  leaves out declared managed regions. `tests/test-sync.sh` covers each.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 10 to merged, then open PR 11 in `.github/workflows/standards-sync.yml`: drop the
schedule, and make a release apply, with the PR body explaining the reviewer gate.

## Blockers / waiting on

- Review of PR 10.
- The first live run of `links.yml`: Wednesday's schedule, or a manual run by the owner.
  This session's token can't start a workflow.
- The release exercise is the owner's, and waits until PR 11 is built.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
