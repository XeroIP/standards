---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-14T05:27:08+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-13 are merged: #40, #41, #42, #47, #48, #49, #51-#57, #60, #61 and #62. #62 is the
  incident starter (e498c57). The leakage scanner, gitleaks, generator parity, design tokens,
  prose gate, check-docs, links, diagram-tool, sync-tool, sync-workflow and action-pin fixes
  are complete.
- The release exercise passed after #56 merged: run 38357604144 (approved) opened a PR in a
  trial consumer, run 38358109877 (rejected) never started. The trial is cleaned up, and the
  `sync` environment now admits only `v*` tags and `main`.
- H17 is now gradable, with the sweeper's repository in scope: true. The sweeper rejects
  output without `source: auto` before writing STATUS.md.
- Shift-change v3 writes `CLAUDE.md` only to remove its own pre-v3 block from a hand-written
  one. It never otherwise writes it. Its instructions live in `.claude/rules/shift-change.md`.
- Issues #63 (lychee doesn't retry a TLS reset), #64 (Python restated in five workflows) and
  #65 (no import markers on vendored prose) were filed.
- The claim re-sweep ran at e00f32a: every grep hit is matched to a claim or a recorded
  exclusion, with none unexplained. 24 rows were left false; PR 14 rewords 19 of them.

## In progress / broken

- PR 14 (wording pass) is open for the owner's review.
- Next is PR 15: fix the four code defects the re-sweep found, then the project record, which
  moves to PR 15:
  - the refresh-tld-list check step dies under bash -e without a report;
  - the Vale step exits 1 silently when its cache dir is missing;
  - load_profile tracebacks on an unreadable .standards.yml;
  - test-leakage.sh can't see the allowlist being replaced.
- The audit notes stay outside the repository.

## Next step

Drive PR 14 to merged, then build PR 15.

## Blockers / waiting on

- The owner reviews PR 14, including the estate generalisation (paths only:
  docs/documentation/adr.md, naming.md, incident-reviews.md, ADR-0001, both docs/projects
  records).
- Open Dependabot PRs #58 and #59 wait on the owner.
- The owner runs the shift-change installer across the repos.
