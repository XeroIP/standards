---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-13T06:54:17+00:00
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
- The release exercise ran after #56 merged, from a throwaway branch listing only a trial
  consumer. Run 38357604144 (approved): the release started it, it waited at the `sync`
  gate, Sync and PR ran without `apply`, and the PR opened with labels on contents and
  pull-requests access alone; VERSION and `standards_version` matched. Run 38358109877
  (rejected): the job never started. Trial repo, tags, releases and branch are deleted.
- Issues #43-#46 and #50 are filed. #50: Vale runs at `latest` in both Prose steps.

## In progress / broken

- PR 12, on `fix/pins`: `verify-action-pins.sh` runs in a `pins` job in self-check and says
  when it can't read a repository; the policy job's example pin is a placeholder; AGENTS.md
  restates what CI does with tags.
- For PR 14: README:73-74 says the sync token doesn't exist, but it does; a rejected run
  shows as a failure. For #32: the sync's PRs are authored by the token's owner.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 12 to merged, then build PR 13: the incident starter,
`docs/documentation/templates/incident.md`, generated from `INCIDENT_SECTIONS` with `--check`.

## Blockers / waiting on

- Owner, optional: limit the `sync` environment to `v*` tags and `main`. It has no
  branch or tag restriction, so its required reviewer is the only gate on the token.
- The first live run of `links.yml`: Wednesday's schedule, or a manual run by the owner.
  This session's token can't start a workflow.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
