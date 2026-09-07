---
title: YAML and GitHub Actions
type: reference
status: active
updated: 2026-09-07
summary: yamllint, actionlint, and the SHA-pinning policy promoted from rolling-text.
---

# YAML and GitHub Actions

## Tooling

| Concern | Tool |
|---|---|
| YAML lint | yamllint |
| Workflow lint | actionlint |
| Action pinning | `policy-pinned-actions.yml` |

## Third-party actions are pinned to a full commit SHA

```yaml
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

A tag is mutable. Whoever controls the action's repository can move `v4` to any commit at any
time, and that commit runs with the workflow's secrets. Pinning to a 40-character SHA removes
that.

The version goes in a trailing comment so the pin stays readable and Dependabot can update it.

`policy-pinned-actions.yml` fails any workflow referencing a third-party action by tag. It
came from `rolling-text`, where it was already in force, and is now the shared version.

First-party `actions/*` are held to the same rule. The account has been compromised before.

## Workflow rules

- `permissions:` declared explicitly at the workflow or job level. The default is too broad.
- `concurrency:` on anything that deploys, so two pushes cannot race.
- Pin the language toolchain by file — `.nvmrc`, `.python-version` — and read it in the
  workflow rather than restating the version. A version in two places disagrees eventually.
- Never interpolate untrusted input into a `run:` block. Pass it through `env:` instead;
  `${{ github.event.issue.title }}` in a shell command is a script injection.

## YAML style

- Two-space indent, no tabs.
- Quote strings that could be read as another type: `"yes"`, `"3.10"`, `"on"`. YAML 1.1 reads
  unquoted `yes` as a boolean and `3.10` as the number 3.1, and both have caused real outages.
- Explicit `null` over an empty value.
