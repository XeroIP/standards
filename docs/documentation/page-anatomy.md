---
title: Page anatomy
type: reference
status: active
updated: 2026-09-07
summary: Headings, tables, code blocks, the four admonitions, and accessibility requirements.
---

# Page anatomy

How a page is built, once its type and name are settled.

## Headings

Every page carries both a front-matter `title` and a body H1, and they say the same thing.

The duplication is deliberate. `title` is metadata: it drives navigation, generated indexes,
and `llms.txt`, and it has to be machine-readable. The body H1 is the document's own title,
and it has to be there because the raw Markdown is read directly — by an agent, by GitHub's
renderer, by an editor — and a file whose first line is prose reads as a fragment.

Optimising for the generated site alone would drop the H1. The raw file is a first-class
consumer here, so it keeps one. markdownlint's MD025 is configured with
`front_matter_title: ""` so the two are not counted as competing top-level headings.

Keep them in step. A page whose H1 disagrees with its `title` will show one string in the
navigation and another on the page.

Sections start at H2 and nest to H4 at most. Past H4 the outline stops being navigable and the
page wants splitting. Heading text is sentence case, describes content rather than announcing
it — "Restoring a single container", not "Overview of the restore process" — and does not
repeat the page title.

## Opening

Open with the content. A page does not explain that it exists, what it will cover, or how it
relates to its neighbours; the reader arrived from a navigation tree that already told them.

- **How-to** opens with what the reader will have when they finish, then prerequisites.
- **Reference** opens with the table or the values. Prose after, if any.
- **Explanation** opens with the thing being explained.
- **Tutorial** opens with what will be built and what is needed to start.

## Tables

Reference content is a table wherever it can be. Comparisons, options, thresholds, and matrices
are tables, not prose paragraphs describing a table.

Every table gets a header row. Any table wide enough to overflow sits in its own horizontally
scrolling container — the page body never scrolls sideways. Where digits line up in a column,
they use tabular figures.

## Code and commands

Every fenced block declares its language. An undeclared block loses highlighting and copy
affordances.

A command block shows the command and, where the result matters, what success looks like.
Prompts (`$`, `#`) are omitted so the block can be copied.

Destructive commands carry a warning admonition directly above them, naming what is destroyed
and what makes it recoverable.

## Admonitions

Four, and no more:

| Admonition | For |
|---|---|
| **Note** | Context a reader might otherwise miss |
| **Warning** | An action with consequences that are hard to undo |
| **Evidence** | On incident pages: an observed fact, distinct from narrative |
| **Unproven** | On incident pages: an inference, explicitly not established |

`Evidence` and `Unproven` exist because a post-incident review that blurs the two is worse
than useless — it launders a guess into a finding. Keeping them visually distinct is a
requirement of the incident standard, not a stylistic choice.

Admonitions are not decoration. A page where several paragraphs in a row are admonitions has
lost its hierarchy; nothing stands out because everything does.

## Length

There is no line limit. A page covers one thing completely.

A how-to that has grown past roughly fifteen steps is usually two tasks. A reference page past
a few hundred lines is usually several tables that want their own pages. The signal is not the
count; it is whether the page still has one subject.

## Images and diagrams

Every image has alt text describing what it shows, not what it is called.

Diagrams are generated from a source that is checked in — Mermaid, Graphviz, or WireViz per
[the diagram standard](../diagrams/README.md) — so they can be regenerated when the thing
they describe changes. A hand-placed SVG cannot be, and goes stale silently.

Both the source and the rendered output are committed, so a reader without the toolchain still
sees the diagram.

## Accessibility

Not optional, and mostly free if done while writing:

- Alt text on every image
- Header rows on every table
- Link text that describes the destination — never "click here" or a bare URL
- Headings that nest without skipping a level
- Colour never the only carrier of meaning

## Enforcement

markdownlint covers heading nesting, fenced-block languages, table headers, and link text.
Vale covers prose, per [the prose standard](../prose/README.md). Alt text and colour-only
meaning are review items; no linter catches them reliably, so they are on the checklist
instead of pretending to be automated.
