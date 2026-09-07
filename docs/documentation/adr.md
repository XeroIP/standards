---
title: Architecture decision records
type: reference
status: active
updated: 2026-09-07
summary: MADR-format decision records, superseding the ad-hoc decision documents already in use.
---

# Architecture decision records

An ADR records one decision: the context that applied, the options considered, what was
chosen, and what that costs. It is written when the decision is made and is not edited
afterwards.

Format is [MADR](https://adr.github.io/madr/), unmodified. It is the common ADR format, which
matters more than any improvement worth making to it.

## When to write one

When a choice closes off an alternative a reasonable person would otherwise try.

The reliable signal: the decision keeps getting re-explained. If the same question is answered
in three different conversations, in a comment, and in a paragraph buried in a runbook, it
needed an ADR and does not have one.

Real examples currently living as prose in one repo, each of which is an ADR: no forward-auth
on Jellyfin, Cloudflare stays DNS-only for media hosts, Overseerr is a deliberate exception
routed through a tunnel, quarantine rather than delete on transcode failure.

Not an ADR: choosing a variable name, adopting a tool with no alternative, anything reversible
in an afternoon.

## File and identity

`adr/NNNN-short-slug.md`, numbered from `0001`, never renumbered. The number is the ADR's
identity — "superseded by ADR-0012" has to keep meaning — which is why ADRs are the one
exception to the [no ordinal prefixes](naming.md) rule.

## Front matter

```yaml
---
title: No forward-auth on Jellyfin
type: adr
id: ADR-0007
status: accepted
date: 2026-06-24
deciders: [peter]
updated: 2026-06-24
supersedes: null
superseded_by: null
tags: [auth, media]
---
```

## Lifecycle

| Status | Meaning |
|---|---|
| `proposed` | Written, not yet decided. Editable. |
| `accepted` | Decided. **Immutable** from this point. |
| `rejected` | Considered and declined. Kept — the reasoning has value. |
| `superseded` | A later ADR replaced it. `superseded_by` is required. |
| `deprecated` | No longer applies, and nothing replaced it. |

**Accepted ADRs are not edited.** Not to fix the reasoning, not to reflect a later change.
Write a new ADR that supersedes it and link both directions. The record of what was believed
at the time is the entire value; editing it destroys exactly the thing being recorded.

Typo fixes are fine. Changing the decision, the options, or the consequences is not.

## Sections

**Context and problem statement.** What forced a decision. Written so it makes sense to
someone who was not there, in the present tense of the time it was written.

**Decision drivers.** The constraints that actually mattered, listed. If a constraint did not
influence the outcome, leave it out.

**Considered options.** Every option genuinely weighed, including the one chosen. An ADR
listing a single option is a note, not a decision record — and an ADR listing straw men is
worse than none, because it manufactures a justification.

**Decision outcome.** What was chosen, and why it beat the others. Named directly:
"Chose X because Y", not "X was selected as it appeared to offer advantages".

**Consequences.** What this costs. Good and bad, and the bad matters more — it is what the
next person needs when the decision starts to hurt. Include what becomes harder, what is now
locked in, and what would have to change to reverse it.

An ADR with no negative consequences was not thought about hard enough. Every real decision
gives something up.

**Confirmation**, optional. How you would tell whether this decision is working — the check,
metric, or observation that would show it going wrong.

## Superseding

The new ADR sets `supersedes: ADR-NNNN`; the old one sets `superseded_by` and
`status: superseded`. Both stay published, and the old one is not edited beyond those two
keys.

The new ADR's context explains what changed since the old one — new information, a shifted
constraint, or a consequence that turned out worse than expected. "We changed our minds" is
acceptable when it is true and the reason is given.

## Migrating existing decision documents

`home-automation/*/reviews/decision-*.md` already does most of this: it has a `Status:` line,
a "What failed" section, and reasoning that names what was ruled out and why. Migrating means
adding front matter, renumbering into `adr/`, and splitting the diagnosis narrative into a
Context section and a Considered options section.

The content is sound. Only the container changes.

## Enforcement

`docs-ci.yml` fails on a missing required section, an `id` that does not match the filename, a
`status: superseded` without `superseded_by`, a `supersedes` pointing at a nonexistent ADR, or
a gap in the numbering. Whether an accepted ADR has been edited is caught in review — git
history shows it plainly, and no linter needs to.
