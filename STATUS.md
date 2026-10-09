---
state: active        # active | paused | blocked | done
priority: high       # high | med | low
updated: 2026-10-09T15:28:13+00:00
source: manual       # manual (/wrapup or pre-push) | auto (sweeper)
---
# standards status

## Goal

Audit every enforcement claim in this repository against the mechanism it names, then
either build the missing mechanism or restate the claim as a review item.

## Done recently

- PR 1 (#40, leakage scanner) and PR 2 (#41, every IANA suffix in prose) are merged.
- Issues #43-#46 are filed: incident tables, profile and stack gates,
  `standards_version` pin semantics, and the site build.
- The owner reviewed PRs 1-3 by diff and ruled on seven points. Rulings 1-6 accepted,
  some with conditions; ruling 7 rejected the gitleaks exclusion travelling to consumers.

## In progress / broken

- PR 3 (#42): the sync now writes consumers a gitleaks config with this repository's
  rules and none of its path exclusions. Merge once CI is green.
- The audit notes stay outside the repository until the last fix lands.

## Next step

Open the follow-up to #41 from main. It carries the owner's conditions on rulings 1 and 3-6
in `tools/check-leakage.py`, `tools/update-tlds.py` and the tests. It also restores the
`@`-prefixed `.sh` host in prose, and stops the vendored scanner skipping a consumer's own
fixture directories. Then PR 4.

## Blockers / waiting on

- The handoff block's ownership (#36). Do not re-run that installer against this repo
  until it is settled.
