---
title: Post-incident reviews
type: reference
status: active
updated: 2026-09-07
summary: One required structure for incident reviews, replacing three divergent templates and the hand-written HTML they were rendered in.
---

# Post-incident reviews

## What changed, and why

Three incident templates were in use across the account, none aware of the others: a
745-line HTML-and-CSS specification in `my-unraid-notes`, a lighter Markdown template in
`panda-media`, and a decision-record shape in `home-automation/*/reviews/`. This supersedes
all three.

The older specification required hand-writing a full HTML skeleton and stylesheet per
incident. One review came to 1,292 lines of HTML. That approach was abandoned for the reason
it always is: consistency depended on a person copying a stylesheet correctly under the worst
conditions the job offers, which is the day after an outage.

The same page now comes from Markdown with front matter, rendered by a template. Every
behaviour the old standard demanded — sidebar navigation, sticky header with breadcrumbs, a
section filter, a dark-mode toggle, print output, responsive layout — is a property of the
template and the [design tokens](../design/), not of the document.

**The document's job is the content. The template's job is everything else.**

## Front matter

```yaml
---
title: Overseerr unavailable for 144 hours
type: incident
status: active
updated: 2026-08-21
severity: SEV-3
services: [service-a]
window:
  start: 2026-08-13T23:00:57-06:00
  end: 2026-08-19T23:06:39-06:00
data_loss: false
revision: 3
severity_ui: true
---
```

`window` is used to compute and display duration, so it is never written out by hand and can
never disagree with the timeline. `severity_ui: true` unlocks the severity palette on this
page.

## Required sections, in this order

1. Overview — executive summary, then revision history
2. Impact and scope
3. Timeline
4. Technical findings
5. Root cause analysis
6. Resolution and recovery
7. Corrective and preventive actions
8. Monitoring and observability lessons
9. Monitoring plan
10. Open questions
11. Appendix: evidence
12. Appendix: investigation walkthrough

A section with nothing to say says so in a sentence and stays. A missing heading fails the
build; an honest "nothing here" does not.

## The executive summary

Written in paragraphs, not bullets. It has to stand alone if the rest of the page is never
read, which is the normal case for anyone above the person who wrote it. It states:

- What system, what window, what severity
- Who or what was affected, and how much
- The root cause, or the most likely cause explicitly labelled as unconfirmed
- What action restored service
- Current status: resolved, mitigated, or being watched
- What remains unproven

A summary that recounts the narrative in order has failed. It is a decision-ready overview,
and the ordering above is roughly the ordering of what a reader needs.

## Evidence and inference are never mixed

The single rule that matters most.

Confirmed facts carry an **Evidence** admonition and name their source — a log line, a
heartbeat record, a command's output. Inferences carry an **Unproven** admonition and say what
would settle the question.

An incident review that presents a plausible story as a finding is worse than one that admits
it does not know. It closes the investigation and gets cited later as established.

Write "host syslog no longer reaches that date, so what changed the file's ownership is not
established" and leave it open.

## Timeline

A table: timestamp, event, and a state of `ok`, `warn`, or `crit`. Timestamps carry a timezone
and are ordered. The state drives a stripe and a chip in the rendered page — colour is never
the only carrier, so the timeline survives print and colour-blind readers.

Timeline entries are observations, not narration. "First `EACCES`; crash loop begins" is an
entry. "The team began investigating" is not, unless the time it happened is a finding.

## Monitoring and observability lessons

Required, and not optional in the way the rest of a template is. It is the bridge from an
incident to work that prevents the next one. At minimum:

- What signals were missing, weak, or ambiguous
- What telemetry would have cut time to detect or diagnose
- What alerting was absent, noisy, or unrelated to the real failure mode
- Which logs, metrics, or traces proved useful and should be kept or expanded
- What platform or tooling gap prevented better visibility

Each finding becomes a concrete action with an owner and a date in section 7. "Improve
monitoring" is not an action.

Note the failure mode this section exists to catch: monitoring can work perfectly and the
outage still last six days, because detection and response are different systems. Time to
detect and time to act are separate measurements and both belong in section 2.

## Corrective actions

A table of action, owner, due date, and status. Every one traceable to a finding above it. An
action with no finding is a good idea that belongs in an issue, not in this document.

## Revision history

Reviews get revised, and early revisions are often wrong in ways that matter. The revision
table records what changed and why — including, explicitly, what an earlier revision got wrong
and what evidence corrected it.

A superseded claim is struck through and kept, not deleted. Someone read revision 1 and may
still be acting on it.

## Public summaries

Where an incident affected people outside the team, a separate short page goes in the
end-user documentation, linked from the review. It carries impact, duration, current status,
and what is being done — no internal hostnames, no topology, no root-cause detail that only
makes sense with system knowledge.

It is a different document for a different reader. Do not publish the review with sections
removed.

## Enforcement

`docs-ci.yml` fails on a missing required section, a missing required front-matter key, a
timeline row without a timezone or a state, and a corrective action without an owner or a due
date. Whether evidence and inference are honestly separated is a review item — no linter can
check it, and pretending otherwise would be the same mistake this standard exists to fix.
