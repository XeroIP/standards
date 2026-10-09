---
title: Front matter
type: reference
status: active
updated: 2026-10-09
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
| `type` | enum | `tutorial`, `how-to`, `reference`, `explanation`, `adr`, `incident`, `ops-log`, `project` |
| `status` | enum | `draft`, `active`, `superseded`, `archived` |
| `updated` | date | `YYYY-MM-DD`. The last substantive change, not a typo fix. |

## Optional

| Key | Type | Notes |
| --- | --- | --- |
| `summary` | string | One sentence. Used in index cards and in `llms.txt`. |
| `tags` | list | Lowercase, hyphenated. Descriptive, except `runbook` and `status`: see below. |
| `services` | list | Systems this page concerns. Required on `ops-log` and `incident`. |
| `issue` | string | `#N` or a URL. |
| `supersedes` / `superseded_by` | string | Path to another page. Required when `status: superseded`. |
| `severity_ui` | boolean | See below. |

## `severity_ui`

Set `severity_ui: true` to make the severity palette — healthy, degraded, failed — available
on that page. It resolves to plain ink everywhere else.

It's allowed on three kinds of page, and the page's type and tags say which kind it is:

| Type | Needs |
| --- | --- |
| `incident` | nothing more |
| `how-to` | `runbook` in `tags` |
| `reference` | `status` in `tags` |

So a reference page not tagged `status` cannot render severity: the build fails it if it sets
`severity_ui`, or if its body carries a `data-severity-ui` attribute without the key. The
point is that a calm reference page never inherits an alert vocabulary it has no use for.

`runbook` and `status` are the two tags that carry meaning; every other tag is descriptive. A
tag alone changes nothing, and a page renders severity only with `severity_ui: true`.

The check makes the opt-in declared and consistent with the page type. It can't tell whether a
page tagged `runbook` really is one, so that part is a review item.

Colour never carries status alone. Pair it with a stripe, a chip, or a word, so the meaning
survives greyscale printing and colour-blind readers.

## Type-specific requirements

**`adr`** also requires `id` (`ADR-NNNN`), `date`, `deciders`, and `status` drawn from
the ADR lifecycle in [`adr.md`](adr.md) rather than the general set above.

**`incident`** also requires `services`, `severity`, `window` (start and end), and
`data_loss`. See [`incident-reviews.md`](incident-reviews.md).

**`ops-log`** also requires `services` and `change_type`, one of `change`,
`investigation`, `maintenance`, `incident-followup`.

`change_type` is a separate key rather than a second meaning for `type`, because `type` already
carries the document type and no page can hold both under one name. This was written as `type`
and was unsatisfiable as specified; it went unnoticed because only `services` was enforced.

**`project`** also requires `services`. `issue` is expected wherever the work was
tracked in one. See [`structure.md`](structure.md) for when a page is a project record rather
than a how-to.

## Example

```yaml
---
title: Restore a container from backup
type: how-to
status: active
updated: 2026-09-07
summary: Recovers a single service from the nightly archive without touching the array.
tags: [backup, recovery, runbook]
services: [service-a]
severity_ui: true
---
```

## Enforcement

`docs-ci.yml` validates every page against this schema and fails on a missing required key, an
unknown key, a `type` outside the enum, a malformed date, or `status: superseded` without
`superseded_by`. Unknown keys fail deliberately: a typo in a key name is silent otherwise, and
a page that has been quietly excluded from an index is worse than one that fails the build.

It also fails `severity_ui` set to anything but `true` or `false`, set on a page whose type and
tags don't allow it, or a `data-severity-ui` attribute in a page that doesn't set it.
