---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-17T22:19:25+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-14 are merged: #40, #41, #42, #47, #48, #49, #51-#57, #60, #61, #62 and #66. #66
  is the wording pass (016bd9b). The owner also merged Dependabot #58.
- The release exercise passed after #56 merged: run 38357604144 (approved) opened a PR in a
  trial consumer, run 38358109877 (rejected) never started. The trial is cleaned up, and the
  `sync` environment now admits only `v*` tags and `main`.
- H17 is now gradable, with the sweeper's repository in scope: true.
- Issues #63, #64 and #65 came from the re-sweep. #67 was filed for a public consumer with
  no `.standards/`, which fails the leakage step without saying why.
- The claim re-sweep ran at e00f32a with zero unexplained hits.

## In progress / broken

- PR 15 is on `fix/resweep-defects` and about to open. It holds the four code fixes (the
  refresh-tld-list check step, the Vale cache path, `load_profile` on an unreadable
  `.standards.yml`, and `test-leakage.sh` on a replaced allowlist) and the project record
  `docs/projects/2026-10-07-enforcement-honesty-audit.md`.
- The confirmation sweep runs on PR 15's head before it merges, then is compared after merge.
- The audit notes stay outside the repository.

## Next step

Drive PR 15 to merged, then run the confirmation sweep and compare it with the record.

## Blockers / waiting on

- The owner reviews PR 15.
- Open Dependabot PR #59 waits on the owner.
- The owner runs the shift-change installer across the repos.
