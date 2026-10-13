---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-13T19:52:57+00:00
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
- #36, ruled: shift-change is an observer. Its v3 keeps its instructions in
  `.claude/rules/shift-change.md` and never writes `CLAUDE.md` (shift-change PR 2). Claude
  Code 2.1.296 loads that file and its `@../../STATUS.md` import alongside `CLAUDE.md`.
- H17 is now gradable, with the sweeper's repository in scope: true. The sweeper rejects
  output without `source: auto` before writing STATUS.md.

## In progress / broken

- On `fix/handoff-rules-file`, outside the audit series: the #35 stopgap leaves AGENTS.md and
  `.claude/rules/shift-change.md` (the v3 installer's output) takes its place. Closes #36.
  Merges after shift-change PR 2.
- For PR 14: README:73-74 says the sync token doesn't exist, but it does; a rejected run
  shows as a failure. For #32: the sync's PRs are authored by the token's owner.
- The audit notes stay outside the repository until the last fix lands.

## Next step

After shift-change PR 2 and this branch's PR merge, build PR 13: the incident starter,
`docs/documentation/templates/incident.md`, generated from `INCIDENT_SECTIONS` with `--check`.

## Blockers / waiting on

- The first live run of `links.yml`: Wednesday's schedule, or a manual run by the owner.
  This session's token can't start a workflow.
- Owner: review shift-change PR 2, then this branch's PR. After both merge, the installer is
  safe to run here: it writes only its own files.
