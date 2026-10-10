---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-10T00:44:44+00:00
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
  `llms.txt` points at raw Markdown on main, follows `mkdocs.yml`'s `site_url` once it
  exists, and is checked against the checkout on push and pull request runs.
- A temporary `measure-raw` job on that branch counts 429s from CI. It decides
  `.lychee.toml`'s 429 policy and must be removed before the PR merges.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Read the `measure-raw` table from the branch's push run, set the 429 policy in
`.lychee.toml` with the reason, remove the job, then open PR 8.

## Blockers / waiting on

- The release exercise is the owner's, and waits until PR 11 is built.
- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
