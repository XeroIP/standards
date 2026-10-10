---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-10T18:01:29+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-11 and the follow-up are merged: #40, #41, #42, #47, #48, #49, #51-#56. The leakage
  scanner, gitleaks, generator parity, design tokens, prose gate, check-docs, links,
  diagram-tool, sync-tool and sync-workflow fixes are complete.
- #56 merged without the throwaway-release exercise, at the owner's call. The release
  trigger, the environment gate, the apply condition and PR creation in a consumer are
  ungraded until the first real release.
- Issues #43-#46 and #50 are filed. #50: Vale runs at `latest` in both Prose steps.

## In progress / broken

- Nothing open. The audit notes stay outside the repository until the last fix lands.

## Next step

Branch from `main` and build PR 12, the pins: `policy-pinned-actions.yml` and
`verify-action-pins.sh`.

## Blockers / waiting on

- The first real release grades the release sync. It needs `STANDARDS_SYNC_TOKEN`, which
  doesn't exist yet (owner).
- The first live run of `links.yml`: Wednesday's schedule, or a manual run by the owner.
  This session's token can't start a workflow.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
