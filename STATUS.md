---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-10T00:48:32+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PRs 1-7 and the follow-up are merged: #40, #41, #42, #47, #48, #49, #51 and #52. The
  leakage scanner, gitleaks, generator parity, design tokens, prose gate and check-docs fixes
  are complete.
- Issues #43-#46 and #50 are filed. #50: Vale runs at `latest` in both Prose steps.

## In progress / broken

- PR 8, on `fix/links`: lychee in its own `links.yml`, run on a path diff and weekly;
  `llms.txt` points at raw Markdown on main and follows `mkdocs.yml`'s `site_url` once it
  exists; lychee skips those URLs on push and pull request runs, and `tests/test-llms-txt.sh`
  checks each names a file; 429 is no longer accepted. The temporary 429 measurement ran
  (no 429s in ten runs) and is removed.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Drive PR 8 to merged, then open PR 9: exit status, a self-contained example and an import
marker for the diagram tools under `docs/diagrams/tools/`.

## Blockers / waiting on

- Review of PR 8.
- The release exercise is the owner's, and waits until PR 11 is built.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
