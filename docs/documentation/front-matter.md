---
title: Front matter
type: reference
status: active
updated: 2026-09-07
summary: The required YAML schema on every page, and the opt-in that scopes severity colour.
---

# Front matter

Every Markdown page carries YAML front matter. It is what lets navigation, indexes, and the
`llms.txt` manifest be generated rather than hand-maintained — and a hand-maintained index is
the thing that always drifts.

## Required on every page

| Key | Type | Notes |
| --- | --- | --- |
| `title` | string | Sentence case. Repeated as the body H1; see [page anatomy](page-anatomy.md). |
| `type` | enum | `tutorial`, `how-to`, `reference`, `explanation`, `adr`, `incident`, `ops-log` |
| `status` | enum | `draft`, `active`, `superseded`, `archived` |
| `updated` | date | `YYYY-MM-DD`. The last substantive change, not a typo fix. |

## Optional

| Key | Type | Notes |
| --- | --- | --- |
| `summary` | string | One sentence. Used in index cards and in `llms.txt`. |
| `tags` | list | Lowercase, hyphenated. |
| `services` | list | Systems this page concerns. Required on `ops-log` and `incident`. |
| `issue` | string | `#N` or a URL. |
| `supersedes` / `superseded_by` | string | Path to another page. Required when `status: superseded`. |
| `severity_ui` | boolean | See below. |

## `severity_ui`

Set `severity_ui: true` to make the severity palette — healthy, degraded, failed — available
on that page. It resolves to plain ink everywhere else, so a reference page cannot render
severity colour even if its markup asks for it.

Allowed on `incident`, `how-to` pages that are runbooks, and status pages. The point is that a
calm reference page never inherits an alert vocabulary it has no use for.

Colour never carries status alone. Pair it with a stripe, a chip, or a word, so the meaning
survives greyscale printing and colour-blind readers.

## Type-specific requirements

**`adr`** additionally requires `id` (`ADR-NNNN`), `date`, `deciders`, and `status` drawn from
the ADR lifecycle in [`adr.md`](adr.md) rather than the general set above.

**`incident`** additionally requires `services`, `severity`, `window` (start and end), and
`data_loss`. See [`incident-reviews.md`](incident-reviews.md).

**`ops-log`** additionally requires `services` and `type` from `change`, `investigation`,
`maintenance`, `incident-followup`.

## Example

```yaml
---
title: Restore a container from backup
type: how-to
status: active
updated: 2026-09-07
summary: Recovers a single service from the nightly archive without touching the array.
tags: [backup, recovery]
services: [service-a]
severity_ui: true
---
```

## Enforcement

`docs-ci.yml` validates every page against this schema and fails on a missing required key, an
unknown key, a `type` outside the enum, a malformed date, or `status: superseded` without
`superseded_by`. Unknown keys fail deliberately: a typo in a key name is silent otherwise, and
a page that has been quietly excluded from an index is worse than one that fails the build.
