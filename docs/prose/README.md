---
title: Prose standard
type: reference
status: active
updated: 2026-09-07
summary: House writing style, derived from multi-vendor research and enforced by generated Vale rules.
---

# Prose standard

| File | What it is |
|---|---|
| [`master-language-rule.md`](master-language-rule.md) | The full rule pack: markers, evidence type, confidence, allowed contexts, replacements. Imported. |
| [`rules.yml`](rules.yml) | The subset a linter can act on. Every entry names its marker id. |
| [`validation-checklist.md`](validation-checklist.md) | The human pass, tiered critical / important / optional. Imported. |
| [`vendor/`](vendor/) | Ready-to-paste writing instructions per LLM vendor. Imported. |
| `../../styles/XeroIP/` | Generated Vale rules. Never edited by hand. |

## Where this came from

`XeroIP/english-ai-rule` runs one research prompt against several models, applies an honesty
check to each run, and synthesises the results only when three or more runs at the same prompt
version from different vendors agree. The current pack is the v2.4 synthesis from five runs
across three vendors.

That repo stays the upstream. Rules change there and are re-imported here; editing the
imported files directly loses the provenance that makes the pack worth trusting.

## Tiers

| Tier | Meaning | Vale severity |
|---|---|---|
| **Ban** | Confidence ≥80, low false-positive risk, two or more vendor-independent runs agreeing. Remove on first pass. | `error` — fails CI |
| **Limit** | Confidence ≥60, or ≥80 with medium false-positive risk. Allowed under a cap or in a named context. | `warning` |
| **Monitor** | Confidence <60, or any high false-positive risk. Logged, never enforced. | `suggestion` |

## What is enforced, and what is not

21 markers generate Vale rules: 11 errors, 8 warnings, 2 suggestions.

Five markers deliberately generate nothing. Cadence flattening, formulaic paragraph
architecture, triple-adjective stacking, inline pseudo-lists, and contraction avoidance all
need structural analysis that a regex cannot do without firing constantly on correct prose. A
rule that cries wolf gets ignored, and then the rules that matter get ignored with it. Those
five live on the human checklist, which is where they belong.

Two more are `monitor` for the same reason: bilateral hedging looks identical to a genuine
pros-and-cons comparison, and em-dash density needs a prose window Vale has no concept of.

## Frequency caps

The master rule expresses caps per 500 or 300 words. Vale counts per file. The generator
converts a cap to a per-document `occurrence` rule and records the original in a comment,
because the approximation is close enough to catch real overuse and wrong enough to be worth
stating plainly.

## Running it

```bash
vale .                    # lint everything
vale docs/documentation/  # lint one tree
node tools/build-vale.js  # regenerate after editing rules.yml
```

CI runs `vale` at `MinAlertLevel = warning`, so errors and warnings both surface while
suggestions stay quiet. It also re-runs the generator and fails if the committed styles differ
from what `rules.yml` produces.

`docs/prose/` is excluded from linting. The research files quote every banned marker as an
example, so linting them would report the standard against itself.

## Vendor files

`vendor/portable.md` is the canonical version; the Claude, ChatGPT, and Cursor/Copilot files
are condensed adaptations of it. These shape generation rather than checking output — the
soft-default counterpart to Vale's hard checks.

Their design note is worth keeping in view: the failure mode they guard against is
over-correction. Mechanically dodging every flagged word until the prose turns stilted is
itself a machine tell. Naturalness and voice win ties.
