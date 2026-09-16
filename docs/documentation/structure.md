---
title: Documentation structure
type: reference
status: active
updated: 2026-09-07
summary: Diátaxis plus ADRs, incidents, an ops log, and project records, and which gates each repo profile runs.
---

# Documentation structure

Every documentation tree uses [Diátaxis](https://diataxis.fr/): four types, separated because
they answer different questions and fail differently when mixed. Four additions cover what
Diátaxis does not model — decisions, incidents, a running operations log, and project records.

The four Diátaxis types describe a system as it currently stands, and are rewritten whenever it
changes. The four additions are the engineering record: dated accounts of decisions taken,
events survived, changes applied, and work carried out, which are not rewritten because the
past does not change. Diátaxis scopes itself to the documentation of a product rather than the
history of the effort that produced it, so adding record types fills a gap it declines to
cover rather than contradicting it.

## The four types

| Type | Answers | Reader is | Fails when |
| --- | --- | --- | --- |
| **Tutorial** | "Teach me by doing" | Learning | It assumes knowledge, or branches |
| **How-to** | "Help me do this task" | Working, knows the goal | It explains theory instead of steps |
| **Reference** | "Tell me the facts" | Looking something up | It narrates, or omits a value |
| **Explanation** | "Help me understand why" | Away from the keyboard | It turns into a procedure |

The separation is the whole point. A runbook that pauses to explain the architecture stops
being usable at 3am, and an architecture document that turns into a procedure stops being
readable at all. When a page wants to do both, split it and link.

## Layout

```text
docs/
  tutorials/        # learning-oriented, ordered, each one completable
  how-to/           # task-oriented, one goal per page
  reference/        # fact-oriented, structured, scannable
  explanation/      # understanding-oriented, prose
  adr/              # decisions, MADR format, immutable once accepted
  incidents/        # post-incident reviews, generated from the template
  ops-log/          # one file per dated operational change
  projects/         # dated records of one bounded piece of work
```

A repo uses the directories it needs. A tool with no operational surface has no `ops-log/`; a
homelab has no `tutorials/`. Empty directories are not created in advance.

## Which type is this page?

Ask what the reader is doing at the moment they open it.

- Following along at a keyboard, learning something new → **tutorial**
- At a keyboard with a goal already in mind → **how-to**
- Checking a value, a port, a flag, a threshold → **reference**
- Trying to understand a decision or a mechanism → **explanation**

If the honest answer is "two of these", the page is two pages.

## Choosing between an ADR and an explanation

Both cover "why". They differ in tense and mutability.

An **ADR** records a decision at a point in time: the context that applied, the options
weighed, what was chosen, and what it costs. Once accepted it is not edited — a later decision
supersedes it, and both stay readable. Use one when a choice closed off alternatives that a
reasonable person would otherwise try.

An **explanation** describes how something works now, and is rewritten whenever that changes.

The test: if someone asked "why is it like this?" and the answer includes "because in March we
decided", that is an ADR.

## The ops log

`ops-log/` holds one file per dated operational change: `YYYY-MM-DD-slug.md` with front matter
naming date, services, type, and issue. One file per entry, not one growing file.

This exists because the alternative was tried and failed. A single append-only log reached
3,368 lines in one repo, which is unscannable for a person, unretrievable for an agent (the
whole file has to be read to answer any question about it), and a merge conflict on every
concurrent edit. Per-entry files fix all three.

An ops-log entry is not a commit message. It records what changed on a system and what was
observed, and survives after the commit that caused it has scrolled out of memory.

## Project records

`projects/` holds one file per bounded piece of work: `YYYY-MM-DD-slug.md` dated to when the
work started, with front matter naming the services touched and the issue it answers.

A project record is the account of an effort — the question it opened with, what was measured,
what was tried and abandoned, what was found along the way, and where it ended. It is written
as the work proceeds and closed when the work closes.

This type exists because such pages are the most common thing misfiled in a Diátaxis tree, and
every available slot damages them:

- **Filed as how-to**, the reader is handed a procedure that was never meant to be repeated.
  A page whose steps were correct once, against one array on one date, reads as an instruction
  to run them again. That is the how-to failure mode with the added hazard of acting on a
  stale system state.
- **Filed as reference**, the narrative — the wrong premise corrected in the second paragraph,
  the approach that produced nothing — reads as fact about the current system. Reference pages
  are consulted rather than read through, so a reader arrives mid-page and takes an abandoned
  measurement for a live one.
- **Filed as explanation**, the dated specifics and dead ends are noise against a page that is
  supposed to describe how something works now, and the page stops being rewritable, because
  rewriting it would destroy the record.
- **Filed as ops-log**, granularity breaks. An ops-log entry is one change on one date; a
  project spans weeks, and splitting it into entries scatters the reasoning that made it
  coherent. The ops log may cite a project record; it cannot hold one.

The distinguishing test is tense and repeatability. If a page describes work that happened,
including what did not work, and nobody should perform its steps again, it is a project
record. If the steps are meant to be run again, it is a how-to — extract it and link.

The cost of the fifth directory is that a writer has one more choice to get wrong. The cost of
not having it is that this content lands in how-to, where being wrong is operationally
dangerous rather than merely untidy.

## Profiles

`.standards.yml` declares which gates a repo runs.

| Profile | Runs | For |
| --- | --- | --- |
| `docs-only` | Markdown lint, prose lint, link check, build | Documentation repos with no application code |
| `mixed` | The above plus language gates for `stacks` | Docs plus scripts or config |
| `code` | All gates; docs gates scoped to `docs/` | Applications |

Opting out is a declaration in the repo, visible in review. A workflow that has been quietly
deleted is not an opt-out; it is drift.

## When these do not apply

A one-off site, a scratch project, an experiment, something built in an afternoon to answer a
question — these need no profile, no gate, and no justification. Build them however is fastest.
ADR-0001 chose the toolchain for documentation that thirty repositories share; it did not make
MkDocs mandatory for everything that renders HTML.

The test is scale, not preference. A standard earns its cost when the same decision is made
repeatedly, across repositories or over time, and drift between those instances would hurt.
Below that line it is overhead charged against work that would otherwise be finished.

Two consequences, because the failure mode runs in both directions:

- **Adopting later is cheap by design.** The content is Markdown, the design system is one
  token file, and the generator can be swapped without touching source. A one-off that turns
  out to matter gets brought in when it turns out to matter, not pre-emptively.
- **A standard nobody may decline gets ignored rather than declined**, and an ignored standard
  is worse than an absent one, because it still looks enforced. Declining is a legitimate
  outcome and needs no defence.

This is a standard for documentation, not a policy for every file in the estate.
