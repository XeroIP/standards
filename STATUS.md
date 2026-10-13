---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-13T20:45:43+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-12 and the follow-up are merged: #40, #41, #42, #47, #48, #49, #51-#57. The leakage
  scanner, gitleaks, generator parity, design tokens, prose gate, check-docs, links,
  diagram-tool, sync-tool, sync-workflow and action-pin fixes are complete.
- The release exercise passed after #56 merged: run 38357604144 (approved) opened a PR in a
  trial consumer, run 38358109877 (rejected) never started. The trial is cleaned up, and the
  `sync` environment now admits only `v*` tags and `main`.
- Issues #43-#46 and #50 are filed. #51's wording closed #50 by accident ("fixed: #50");
  it was reopened, and #60 pinned Vale to 3.24.0 in both Prose steps and closed it.
- #61 merged (ffee83d) and closed #36; shift-change PR 2 merged. Shift-change is an observer:
  its v3 keeps its instructions in `.claude/rules/shift-change.md` and never writes
  `CLAUDE.md`. Claude Code 2.1.296 loads that file and its `@../../STATUS.md` import
  alongside `CLAUDE.md`.
- H17 is now gradable, with the sweeper's repository in scope: true. The sweeper rejects
  output without `source: auto` before writing STATUS.md.

## In progress / broken

- PR 13 on `feat/incident-starter`, committed locally and not pushed: the owner reviews the
  diff first. `tools/build-incident-starter.py` writes `docs/documentation/templates/incident.md`
  from `INCIDENT_SECTIONS`; `check-docs.py` fails any front-matter value still holding the
  `<fill in>` marker; it and `build-llms-txt.js` skip the starter by its exact path.
- For PR 14: README:73-74 says the sync token doesn't exist, but it does; a rejected run
  shows as a failure. For #32: the sync's PRs are authored by the token's owner.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 13 to merged, then PR 14, the wording pass.

## Blockers / waiting on

- The first live run of `links.yml`: Wednesday's schedule, or a manual run by the owner.
  This session's token can't start a workflow.
- Owner: run the shift-change installer (`-WhatIf`, then `-Commit`) across the repos.
