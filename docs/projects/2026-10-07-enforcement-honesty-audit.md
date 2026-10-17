---
title: Enforcement-honesty audit
type: project
status: active
updated: 2026-10-17
summary: Every enforcement claim in this repository checked against the mechanism it names, and what that turned up.
services: [check-leakage, gitleaks, generator-parity, build-vale, check-docs, lychee, diagram-checkers, design-tokens, sync-standards, standards-sync, policy-pinned-actions, verify-action-pins, incident-starter]
---

# Enforcement-honesty audit

This repository's standards say a lot of things are enforced: "CI fails", "the hook rejects",
"the scanner catches". Thirty repositories take those sentences on trust. The audit began on
2026-10-07 and asked whether each one was true.

## The question it opened with

Does every enforcement claim name a mechanism that does what the claim says?

A claim can fail that test four ways. The mechanism may not exist. It may exist and cover less
than the sentence says. It may never run where the sentence says it runs. Or it may run and
pass whatever it's given. The repair for each is one of two: build the mechanism, or reword the
claim until it describes what's there. A claim that is a preference gets labelled as one.

## What was measured

### Method

- **Stage 1, inventory.** Four grep sets (enforcement verbs, `## Enforcement` headings,
  "must" or "never" beside a tool name, and gate words such as "refuses" and "exit") ran over
  the prose and the configuration. Every file was then read in full, because a grep finds the
  claims worded the way the grep expects. Each hit line was reconciled to a claim or to a
  recorded reason it isn't one. The pass ended when no line was unexplained.
- **Stage 2, grading.** Each claim was exercised in both directions on its failure path:
  break the thing and watch the gate go red, restore it and watch it go green. Where a gate
  runs in CI, the evidence is a real run, not a local emulation.
- **Stage 3, proposals.** Each repair was written up with its cost and its alternatives, and
  the owner ruled on it before any code was written. The rulings are the spec for PRs 1-14.

### Method notes the rulings require

- **Run records outlive logs.** Logs expire and branches get deleted. The run IDs, not the
  log text, are the evidence, and they survive branch deletion.
- **Fixes add claims.** Every PR in this series wrote new comments, docstrings and changelog
  lines, and some of those were wrong. The sweep was re-run before PR 1 and after PR 14, and
  the claims the fixes introduced were graded too.
- **A run under production tolerances proves the tolerances.** The lychee measurement for
  `raw.githubusercontent.com` links ran against a config that already accepts a 429 with three
  retries, so a rate limit would have shown as a pass. The measurement had to run with 429 not
  accepted. This is the 429 instrument defect.
- **PR bodies are written from the diff.** The first summary of #41 understated the IPv6
  allowlist and missed two consequences the owner found in the patches. Later bodies were
  written from the diff, not from memory of the intent.
- **A mislabelled page is a review item riding on a mechanism.** `check-docs` makes the
  `severity_ui` opt-in declared and consistent, through the `status` and `runbook` tags. It
  can't verify that a page tagged `status` is one. The record labels it that way.
- **A counting script is a mechanism too.** The first comment-block counter mis-tracked
  multi-line docstrings. The re-sweep rewrote it, and it found one claim the earlier reading
  had missed.

### Stage 2 results

182 graded rows.

| Verdict | Rows |
| --- | --- |
| true | 89 |
| false | 47 |
| false (partly) | 39 |
| false (no mechanism) | 6 |
| unexercised | 1 |

So 92 of 182 were false in whole or in part. The one unexercised row, H17, is the handoff
sweeper's `source: auto` rule. It needed the sweeper's repository in scope. With that in scope
it's true: the sweeper rejects output that lacks `source: auto` before it writes STATUS.md.
Stage 2 therefore ends with none unexercised.

Earlier notes say "90 of 180". They predate A25 and A26, two claims about the scanner's CIDR
and prefixed-host handling that building #40 added.

### Re-sweep at e00f32a

e00f32a is PR 14's last commit. No CI run exists for it, so the re-sweep ran each workflow's
step scripts locally and cited the neighbouring runs on main for the rest. The prose half and
the configuration half ran separately.

| Half | Hit lines | Covered by a claim | Excluded with a reason | Unexplained |
| --- | --- | --- | --- | --- |
| Prose | 178 | 94 | 84 | 0 |
| Configuration | 144 | 98 | 46 | 0 |

The configuration half also enumerated 410 comment blocks in 83 files, none undecided, and
justified every tracked extension left out of both passes.

| Re-keyed stage 2 rows | Prose (98) | Configuration (84) |
| --- | --- | --- |
| true | 74 | 73 |
| review item (labelled) | 10 | 2 |
| unexercised | 0 | 1 |
| false (partly) | 11 | 3 |
| false | 1 | 0 |
| false (no mechanism) | 1 | 0 |
| removed with their subject | 1 | 5 |

| New claims from the fixes | Prose (77) | Configuration (90) |
| --- | --- | --- |
| true | 70 | 82 |
| unexercised | 2 | 2 |
| false (partly) | 5 | 4 |
| false | 0 | 2 |

Of the 35 configuration rows that were false in any form at stage 2, 25 are now true, 5 were
removed with their subject, and 2 are labelled review items. Of the prose rows, 16 of 25
`false` and 20 of 26 `false (partly)` are now true. Four rows stage 2 had graded true turned
out false in part: A3, C7 and A21 were stage 2 misses, and H8 was a regression from #56.

## What was tried and abandoned

- **A dated snapshot of the delegated-suffix list (PR 2).** The alternative to a scheduled
  refresh job. The owner ruled for the job, and #41's body says why the snapshot wasn't taken.
  The same ruling rejected two other shapes for the domain check: the full list applied
  everywhere (78 findings at the time of the ruling, all false) and an issue in place of the PR.
- **Dependabot in each consuming repository, to keep the workflow pin current.** The pin
  lives in the consumer, so this is a config and a standing PR stream in thirty repos to keep
  one line fresh. The work scales with repository count while the risk stays rare. The
  preferred route, the sync bot rewriting the pin in the PR it already opens, isn't built.
- **An ungated read token for consumer-side drift detection.** Option 1 of #37. Rejected,
  and the cost accepted: no central view of drift.
- **A vendored gitleaks config with path exclusions.** Rejected in review of #42. The vendored
  copy carries none, and a consumer writes its own root config.
- **A hand-written incident starter.** Generated from `INCIDENT_SECTIONS` instead, with a
  `--check` mode, so the template and the checker can't drift.
- **Validating the starter as a page.** A starter made valid needs a real-looking date, which
  removes the one thing that catches an unfilled copy. It's excluded from page checks by exact
  path, not by directory name.
- **The weekly sync preview.** The `sync` environment's required reviewer held the read-only
  preview too, so three scheduled runs sat waiting unapproved for up to three weeks. #56 dropped
  the schedule and kept the release trigger, which suits a deliberate act and not an unattended
  one.
- **Exercising the release path before PR 11 merged.** The plan put a throwaway non-`v` tag on
  PR 11's branch head. The owner waived it. It ran after #56 merged instead, from two non-`v`
  releases: `audit-release-0` (run 38357604144, approved, opened a PR in a trial consumer) and
  `audit-release-1` (run 38358109877, rejected, no step ran). The trial consumer was deleted,
  and the `sync` environment now admits only `v*` tags and `main`. The version-string shape is
  still graded at the first real release.

## What was found along the way

- **A PR closed an issue by accident.** The wording of #51 matched a GitHub closing
  keyword and closed #50 (Vale installed at `latest`). It was reopened, and
  [#60](https://github.com/XeroIP/standards/pull/60) closed it for real.
- **lychee doesn't retry a TLS-handshake reset.** An HTTP-level reset is retried and a
  handshake reset isn't, so `max_retries = 3` doesn't cover it
  ([#63](https://github.com/XeroIP/standards/issues/63)).
- **Python is restated in five workflows**, against the standard that says to pin it once
  ([#64](https://github.com/XeroIP/standards/issues/64)). Node got `.nvmrc`.
- **Vendored prose carries no import markers**, and nothing detects an edit to an imported
  file ([#65](https://github.com/XeroIP/standards/issues/65)).
- **A public consumer with no `.standards/` fails the leakage step unhelpfully.** It dies on a
  missing `tools/check-leakage.py` with no explanation
  ([#67](https://github.com/XeroIP/standards/issues/67)).
- **The scanner let every CIDR through.** A `/0` range and plain containment made any CIDR
  pass, and a prefixed host skipped the IP-host rule. #40 made CIDR matching exact.
- **main went red on a hand edit.** A hand edit to the generated `CLAUDE.md` failed the
  agent-files check, and the steps behind it, including Vale, were skipped. The restore
  direction of that gate has a real green run too.
- **Dependabot rewrote a SHA inside an echoed example**, leaving a "v4.2.2" label on the
  hash of a newer release (#25). The example now holds a placeholder.
- **The handoff tool moved out of `CLAUDE.md`.** The managed block collided with the sync,
  which deleted the region and exited 0. The instructions now live in
  `.claude/rules/shift-change.md` ([#36](https://github.com/XeroIP/standards/issues/36),
  [#61](https://github.com/XeroIP/standards/pull/61)).
- **H17 became gradable, and true.** See the stage 2 results.
- **The estate carried 85 lines of private detail in examples and records.** Counts only:
  6 lines in 4 files named a service, 11 in 6 described a dated event or a topology, 25 in 15
  and 18 in 5 were illustrative private-project names, 13 are required by a mechanism, 10 were
  generated copies and 2 were false positives. The first two groups were generalised under a
  correction rule added to `structure.md`. Both groups of private-project names are left
  for [#38](https://github.com/XeroIP/standards/issues/38).
- **Four defects the re-sweep found in the code**, fixed in this PR:

| Id | Defect | Fix |
| --- | --- | --- |
| A216 | The `refresh-tld-list.yml` check step died at the first failing check under `bash -e`, so no PR opened and no report was written | Every check runs and records its result |
| V203 | The Vale step exited 1 silently when its cache directory had moved | It says the cache has moved |
| H205 | An unreadable `.standards.yml` was a traceback, against a comment saying it wasn't fatal | A warning, then the defaults |
| A21 | `test-leakage.sh` couldn't see the shared allowlist being replaced, or a substring skip | It notices both |

## Where it ended

### Pull requests

| Plan | PR | Merge | Title |
| --- | --- | --- | --- |
| 1 | [#40](https://github.com/XeroIP/standards/pull/40) | 4326bf8 | Make the leakage scanner report what it claims to |
| 2 | [#41](https://github.com/XeroIP/standards/pull/41) | 1a2a1ea | Count every delegated suffix as a hostname in Markdown prose |
| 3 | [#42](https://github.com/XeroIP/standards/pull/42) | 3ad3291 | Give every consumer a gitleaks config, one release, and a test |
| follow-up | [#47](https://github.com/XeroIP/standards/pull/47) | d46b0f9 | Carry out the owner's conditions on the leakage scanner rulings |
| 4 | [#48](https://github.com/XeroIP/standards/pull/48) | fc50a15 | Make generator parity catch a generated file nobody committed |
| 5 | [#49](https://github.com/XeroIP/standards/pull/49) | b8dce50 | Generate tokens.css, and make the severity opt-in work in every adapter |
| 6 | [#51](https://github.com/XeroIP/standards/pull/51) | d965f56 | Make the prose caps count per file, and fail pull requests on every line |
| 7 | [#52](https://github.com/XeroIP/standards/pull/52) | 7859118 | Make check-docs enforce what adr.md and front-matter.md say it does |
| 8 | [#53](https://github.com/XeroIP/standards/pull/53) | f113f2e | Run lychee on what it reads, weekly, and over llms.txt |
| 9 | [#54](https://github.com/XeroIP/standards/pull/54) | 6d722f3 | Make the diagram checkers fail on any finding, with an example that runs here |
| 10 | [#55](https://github.com/XeroIP/standards/pull/55) | 3b229eb | Make the sync tool honour what its config and docs say, and refuse edits it would delete |
| 11 | [#56](https://github.com/XeroIP/standards/pull/56) | 2417a88 | Let a release sync, drop the schedule that never ran, and honour repos |
| 12 | [#57](https://github.com/XeroIP/standards/pull/57) | dd28a07 | Check every action pin against its tag in CI, and say when the check can't run |
| extra | [#60](https://github.com/XeroIP/standards/pull/60) | 9ae3670 | Pin Vale in both Prose steps, and fail when the two pins differ |
| extra | [#61](https://github.com/XeroIP/standards/pull/61) | ffee83d | Move the shift-change handoff into `.claude/rules/shift-change.md` |
| 13 | [#62](https://github.com/XeroIP/standards/pull/62) | e498c57 | Generate the incident review starter, and fail a copy that still holds its placeholders |
| 14 | [#66](https://github.com/XeroIP/standards/pull/66) | 016bd9b | Make every claim the audit found false either true or labelled, and fix three facts |
| 15 | this PR | on merge | The four defects above, and this record |

### Issues

| Issue | Role |
| --- | --- |
| [#4](https://github.com/XeroIP/standards/issues/4) | Fed. No ADR records the allowlist's rationale yet; the allowlist now says so |
| [#12](https://github.com/XeroIP/standards/issues/12) | Fed. The tools had no tests; #40, #51, #52, #54 and #55 add the first ones |
| [#15](https://github.com/XeroIP/standards/issues/15) | Fed. An earlier issue whose code criteria #31 met; #37 cites it |
| [#32](https://github.com/XeroIP/standards/issues/32) | Fed. Sync PRs are authored by the token's owner; the README now says so |
| [#36](https://github.com/XeroIP/standards/issues/36) | Filed. Marker-aware generator against an installer skip-list; closed by #61 |
| [#37](https://github.com/XeroIP/standards/issues/37) | Filed. Consumer-side drift detection by inversion |
| [#38](https://github.com/XeroIP/standards/issues/38) | Fed. Tracks both groups of private-project names the audit left in place |
| [#43](https://github.com/XeroIP/standards/issues/43) | Filed. Incident table checks |
| [#44](https://github.com/XeroIP/standards/issues/44) | Filed. Profile and stack gate selection |
| [#45](https://github.com/XeroIP/standards/issues/45) | Filed. What the `standards_version` pin does; today it warns and still vendors |
| [#46](https://github.com/XeroIP/standards/issues/46) | Filed. The site build, with the llms.txt backstop task |
| [#50](https://github.com/XeroIP/standards/issues/50) | Filed. Vale installed at `latest`; closed by #60 |
| [#63](https://github.com/XeroIP/standards/issues/63) | Filed after the re-sweep. lychee and the TLS reset |
| [#64](https://github.com/XeroIP/standards/issues/64) | Filed after the re-sweep. Python restated in five workflows |
| [#65](https://github.com/XeroIP/standards/issues/65) | Filed after the re-sweep. No import markers on vendored prose |
| [#67](https://github.com/XeroIP/standards/issues/67) | Filed after PR 14. The unhelpful failure in a public consumer without `.standards/` |

### What's still open

The aggregate claims, M1 ("every page names what enforces it") and its published copy M2, hold
except for two rows: A9, a public consumer with no `.standards/`
([#67](https://github.com/XeroIP/standards/issues/67)), and I202, Python restated in five
workflows ([#64](https://github.com/XeroIP/standards/issues/64)).

Two things have never run:

- the pull-request step of the TLD refresh workflow (A112 and A214), which needs a change in
  the suffix set;
- the `sync` environment's settings (H118), which the environments API won't show a session
  behind the proxy.

The first scheduled run of `links.yml` succeeded on 2026-10-14 (run 38518445881).

The owner has three items. The shift-change installer needs running across the repos. Two
upstream issue drafts are unfiled: the diagram checkers' exit status, and the `/wrapup`
timestamp offset. Dependabot [#59](https://github.com/XeroIP/standards/pull/59) is open.

The confirmation sweep ran on PR 15's head before it merged. 342 hit lines, every one covered
by a claim or a recorded reason. The reworded and fixed rows were re-graded, and none got worse.
45 of 45 deliberate breaks of the mechanisms were caught, against 41 at the first re-sweep. The
only rows left false and unlabelled are A9 and I202. The merged tree is compared against that
head afterward.
