---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-09T05:20:33+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- All four stage 3 design choices are ruled, and the claim sweep was re-run at the head
  before the first fix: nothing unexplained.
- Stage 2 is complete and the owner actions are all done.
- Building the first fix found three more ways the leakage scanner passed values it
  should report: any CIDR, a host written with its prefix, and every IPv6 address. They
  are fixed in that same pull request. The audit notes now grade 182 claims.

## In progress / broken

- PR 1 (#40), the leakage scanner fixes: repository scope for vendored copies, exact
  domain matching, a path-prefix fixture exclusion, exact CIDR blocks, and IPv6. Waiting
  on CI and review.
- PR 2, on `fix/leakage-scanner-every-suffix`, is stacked on PR 1: Markdown prose counts
  every IANA suffix and the private-use names, from `tools/iana-tlds.txt`, refreshed weekly
  by `.github/workflows/refresh-tld-list.yml`. Retarget it to main once #40 merges.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Open PR 3 from main: vendor `.gitleaks.toml` through `tools/sync-standards.py`, make
`.github/workflows/secret-scan.yml` fall back to it, and pin gitleaks to one version in CI
and in `.pre-commit-config.yaml`.

## Blockers / waiting on

- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
