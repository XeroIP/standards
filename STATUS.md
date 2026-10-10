---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-10T02:54:18+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-10 and the follow-up are merged: #40, #41, #42, #47, #48, #49, #51-#55. The leakage
  scanner, gitleaks, generator parity, design tokens, prose gate, check-docs, links,
  diagram-tool and sync-tool fixes are complete.
- Issues #43-#46 and #50 are filed. #50: Vale runs at `latest` in both Prose steps.

## In progress / broken

- PR 11, on `fix/sync-workflow`: no schedule; a published release applies; `repos` narrows
  a manual run. It merges only after the owner's throwaway-release exercise.
- The audit notes stay outside the repository until the last fix lands.

## Next step

When the owner names the throwaway consumer, add a commit on `fix/sync-workflow` that lists
only it in the matrix, for the exercise; after the two runs, restore the matrix. Then PR 12:
the pins (`policy-pinned-actions.yml`, `verify-action-pins.sh`).

## Blockers / waiting on

- The release exercise (owner): a throwaway private consumer, adopted; the `sync`
  environment's rules admitting a non-`v` tag; creating and deleting the release and tag;
  approving the first run and rejecting the second.
- The first live run of `links.yml`: Wednesday's schedule, or a manual run by the owner.
  This session's token can't start a workflow.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
