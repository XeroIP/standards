---
title: Observability standard
type: reference
status: draft
updated: 2026-09-07
summary: Not yet written. This page states the scope and the questions it has to answer.
---

# Observability standard

**Status: not written.** This page exists so the gap is visible rather than implied, and so
the scope is settled before anyone starts filling it in.

## Scope

- **Structured logging** — a required field schema, level semantics, what never gets logged
- **Metric naming** — Prometheus conventions: units in the name, base units, label cardinality
- **Alert design** — symptom-based rather than cause-based, SLO-driven where an SLO exists
- **Runbook per alert** — every alert links to the procedure for the condition it fires on
- **Retention** — how long logs and metrics are kept, and what that costs when it is too short

## What it has to answer

Drawn from a real incident, which is the right source for this standard.

A service was down for 144 hours. Detection took under seven minutes and worked exactly as
designed. Three alerts were delivered and received. The outage still ran six days.

The standard has to address why:

- **A container reporting `Up` while the process inside it crash-looped.** The image's own
  supervisor contained the loop, so the restart counter never incremented and every
  container-level check passed. What is the right health signal when the orchestrator's own
  view is wrong?
- **Re-alerts for one unchanged condition presenting as flapping.** Three notifications for a
  single continuous outage read as an intermittent problem. How should a continuing condition
  be distinguished from a recurring one?
- **Time to detect and time to act as separate measurements.** Monitoring was not the failure.
  Response was. Both belong in an incident's impact section, and the standard should say so.
- **Retention that outlives an investigation.** Host logs no longer reached the date in
  question, so the triggering change could not be established. What is the minimum retention
  that makes a root cause findable?

## Until it exists

[Incident reviews](../documentation/incident-reviews.md) requires a monitoring and
observability lessons section on every review, with each finding becoming a corrective action
that has an owner and a date. That requirement is in force now, and the findings it produces
are the raw material this standard will be written from.
