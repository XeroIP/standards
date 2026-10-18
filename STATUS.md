---
state: done          # active | paused | blocked | done
priority: med        # high | med | low
updated: 2026-10-18T22:30:47+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- The audit is complete. All 15 PRs are merged: #40, #41, #42, #47, #48, #49, #51-#57, #60,
  #61, #62, #66 and #68 (ac82536). The record is
  `docs/projects/2026-10-07-enforcement-honesty-audit.md`.
- The confirmation sweep passed at 205800e. The merged tree is identical to #68's final
  head, and a sweep of it gives the same 342 hit lines per file. Only A9 (#67) and I202
  (#64) are left false, both tracked.
- The owner merged Dependabot #58.

## In progress / broken

- Nothing in progress. The audit notes stay outside the repository.

## Next step

None for the audit. Open follow-ups are the filed issues, starting with #67 and #64, which
are the last two false claims; then #63, #65, #43-#46 and #38.

## Blockers / waiting on

- Owner: Dependabot PR #59.
- Owner: run the shift-change installer across the repos.
- Owner: file the two upstream issue drafts (diagram checkers' exit status; the handoff
  timestamp offset).
- Never exercised: the TLD refresh workflow's pull-request step, and the `sync`
  environment's settings, which this session can't read.
