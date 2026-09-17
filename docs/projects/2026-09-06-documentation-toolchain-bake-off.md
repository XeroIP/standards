---
title: Documentation toolchain bake-off
type: project
status: active
updated: 2026-09-10
summary: Seven documentation generators built the same three pages; the measured result behind ADR-0001.
services: [mkdocs-material, hugo, eleventy, sphinx-myst, antora, starlight, docusaurus]
---

# Documentation toolchain bake-off

> **Transplanted from the pilot repository.** This is the measured evidence behind
> [ADR-0001](../adr/0001-mkdocs-material-as-the-documentation-toolchain.md). It was
> written while the decision was still open, and its opening recommendation is
> superseded by that ADR, which selected MkDocs + Material with Hugo recorded as the
> tie and Eleventy as the fallback. The body is left as it was written; a record of
> what was believed mid-evaluation is the thing worth keeping.
>
> The build harness it describes (`poc/`, its Makefile, and the 42 screenshots) was not
> retained. The screenshots were never committed — `poc/.gitignore` excluded them — and
> the harness was a one-session scaffold, not a maintained artifact.

Recommendation: **MkDocs + Material**, with Eleventy as the documented fallback — now under
review, because Hugo matched or beat it on every measure the recommendation rested on. See
"What the two late candidates changed" below.

Seven candidates. The first five came from the plan; Starlight and Hugo were added after
[the field survey](2026-09-10-documentation-generator-survey.md) screened the field properly and found that the original list was never a survey.

Every figure here was measured in one session on one machine with cold caches.

## Measured

| Measure | MkDocs Material | Hugo + Hextra | Starlight | Eleventy | Sphinx + MyST | Docusaurus | Antora |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Dependency install | 11s | one binary | 47s | 6s | 8s | 19s | 7s + 2s gem |
| Dependency weight | 4 packages | 76 MB binary + 1.2 MB theme | 238 MB | 4 packages | 6 packages | 289 MB | 30 MB + gem |
| Cold build | **568ms** | **637ms** | 4,980ms | 660ms | 1,056ms | 22,392ms | 1,517ms |
| Output size | 2.8 MB | 736 KB | 1.3 MB | **140 KB** | 1.1 MB | 908 KB | 628 KB |
| Source files changed | **0** | **0** | 3 (front matter + H1 removed) | 3 (front matter) | **0** | 1 | 3 (converted to AsciiDoc) |
| Custom CSS written | 9 lines | 0 | 0 | 137 lines | 5 lines | 5 lines | not attempted |
| Config written | 62 lines | 46 lines | 34 lines | ~155 lines | 26 lines | 39 lines | 37 lines |
| Markdown as source | native | native | front matter required | front matter required | native | native | **no** |
| Dark mode | built in | built in | built in | hand built | built in | built in | **none** |
| Full-text search | built in | built in | Pagefind | **outline only** | built in | built in | built in |
| Broken links fail build | `--strict` | **no** | **no** | no | `file:line` | warn by default | JSON |
| Cross-repo linking | no | no | no | no | `objects.inv` | no | native |
| Language runtime in repo | Python | **none** | Node | Node | Python | Node | Node + Ruby |

Custom CSS is 0 for the two new candidates because both were themed entirely by the generated
adapter — no hand-written stylesheet at all. The 9 and 5 line figures for the older candidates
are print rules predating the token system.

## Rubric, scored 1–5

| Criterion | MkDocs | Hugo | Starlight | Eleventy | Sphinx | Docusaurus | Antora |
| --- | --- | --- | --- | --- | --- | --- | --- |
| LLM-readable source | 5 | 5 | 3 | 4 | 5 | 4 | 1 |
| Low maintenance burden | 5 | 5 | 3 | 3 | 4 | 2 | 2 |
| Styling ceiling | 3 | 3 | 5 | 5 | 3 | 5 | 2 |
| Multi-repo fit | 2 | 3 | 2 | 2 | 4 | 2 | 5 |
| Build speed | 5 | 5 | 3 | 5 | 4 | 1 | 4 |
| Incident template expressiveness | 5 | 4 | 5 | 4 | 4 | 5 | 3 |
| Ecosystem longevity | 5 | 5 | 3 | 4 | 5 | 5 | 3 |
| **Total of 35** | **30** | **30** | **24** | **27** | **29** | **24** | **20** |

The totals summarize the reasoning; they did not produce it. Hugo tying MkDocs is the finding,
not the number.

Starlight's 3 for LLM-readable source is the H1 removal, not the Markdown: it renders the
front-matter `title` as the page H1 unconditionally, so every source file loses its own
heading. Hugo's 3 for multi-repo fit is Hugo modules — not `objects.inv`, but a real
dependency mechanism where MkDocs, Eleventy and Starlight have none.

## Why MkDocs Material

It rendered all three pages without changing a single source file, in 568ms, from 62 lines of
config and 9 lines of custom CSS. Five of the six page behaviors required by
`docs/incidents/incident-review-standards.md` are configuration flags: sidebar navigation,
sticky header, section search, dark-mode toggle, responsive layout. Print rules were the only
custom CSS.

The 1,292-line hand-written `incident-2026-08-13-overseerr.html` reproduces from 410 lines of
Markdown with no per-incident HTML. `mkdocs build --strict` fails on broken internal links in
half a second, which is the guardrail the Diátaxis restructure needs. And `nav:` sets ordering
independently of filename, so the ordinal `00-`…`19-` prefixes become cleanup rather than a
migration prerequisite.

The cost is the styling ceiling: a custom token set arrives through Material's CSS custom
properties and `theme.custom_dir` rather than on a blank page. All three design directions are
reachable that way. A direction that fought Material's structure would not be — which is the
condition that promotes Eleventy.

## What the choice gives up

Sphinx alone emits `objects.inv`, letting one repo's docs link into another's. Sphinx also has
a real path to PDF: `-b latex` emitted a `.tex` with no TeX toolchain installed.

**Correction — the inventory does not survive renames.** This section first claimed it did.
Dumping the inventory the Sphinx POC actually builds shows entries of one kind, keyed by
document path:

```text
incident-rca  std:doc  -1  incident-rca.html   Post-Incident Review — ...
overview      std:doc  -1  overview.html       Architecture Overview
runbook       std:doc  -1  runbook.html        Runbook
```

A cross-project reference to `overview` breaks when `overview.md` is renamed, exactly as a
relative link does. Rename-durable targets exist only for anchors declared by hand: adding
`(network-boundary)=` to `overview.md` and rebuilding produced a `std:label` entry pointing at
`overview.html#network-boundary`, and nothing else in the build produced one. That is a
hand-maintained identifier namespace — a convention any generator can adopt — rather than a
capability only Sphinx has.

What is genuinely given up is narrower: Sphinx fails its own build on a dead cross-project
reference, where lychee reports the same dead link out of band. Intersphinx also needs both
ends on Sphinx and the target inventory fetchable at build time, and most of this estate is
private.

The decision and this evidence are recorded as ADR-0001 in `XeroIP/standards`.

## Corrections to the plan's assumptions

**MDX did not degrade portability.** Forcing `format: 'mdx'` on all three files built cleanly.
The source has one bare `{` and zero bare `<`. The risk is forward-looking — a future page
with `{{ template }}` syntax or a `Foo<Bar>` generic would fail — and `format: 'detect'`
removes it. Docusaurus was rejected on build time and dependency weight instead.

**Eleventy's prior use did not earn it a bonus.** Scored on the same rubric, it placed second.
Its 140KB output and directly editable token block are real advantages; the regex-scraped page
outline and 233 lines of hand-maintained template and CSS per repo are the real cost.

## What the two late candidates changed

**Hugo ties MkDocs at 30/35, and it ties on the criteria the recommendation was built from.**

The MkDocs case rested on three things: zero source changes, a sub-second build, and
behaviours that are configuration rather than code. Hugo matches all three — 637ms against
568ms is a tie, its three source files were byte-identical (verified with `cmp`, not assumed),
and its config is 46 lines against 62.

It then answers an objection MkDocs cannot. ADR-0001 records as a consequence that MkDocs
"puts a Python toolchain into repositories that are otherwise JavaScript, Dart or shell."
Hugo is a single Go binary: **no language runtime lands in the consuming repository at all.**
For a thirty-repo rollout that is the sharpest practical difference any candidate has offered.

Its theme also installs as a pinned Hugo module through `proxy.golang.org` rather than as a
git submodule — a real dependency, in `go.mod`, with no `--recursive` clone to forget.

What Hugo gives up against MkDocs: Go templating for anything past a theme's variables, a
monthly release cadence that deprecates as it goes (this POC hit one on its first build), and
a theme decision that is genuinely unresolved — Hextra is closer in spirit to this design
system but four months quiet, while Docsy is current and Bootstrap-based.

**Starlight placed fifth and is not close.** It builds in 4,980ms, carries 238 MB of
`node_modules`, and needs the largest source change of any Markdown-native candidate: front
matter added _and_ the body H1 removed, because it renders the front-matter title as the page
H1 unconditionally. That directly contradicts the documentation standard's resolution of the
same question, where a body H1 is kept so the raw Markdown stays readable to an agent, to
GitHub, and in an editor.

Its search is the best of the seven — Pagefind indexes full page text as a build artifact —
and its `--sl-*` theming surface is clean. Neither offsets the rest.

**Neither new candidate fails a build on a broken internal link.** Both were given three pages
carrying 19 relative links to documents that do not exist. Both exited 0 and reported nothing;
Hugo reported nothing even with `--printPathWarnings`. MkDocs `--strict` and Sphinx `-W` both
catch all of them.

This matters less than it looks: `tools/check-docs.py` in the standards repo already fails on
a nonexistent relative-link target, generator-agnostically. As a difference between candidates
it is real; as a reason to pick one, it is thinner than ADR-0001 originally claimed, which is
why that driver has since been corrected.

**A clean screenshot run hid a broken theme toggle.** The first pass reported `42/42
screenshots captured` and exited 0. Six of those were wrong: Hugo's light and dark files were
byte-identical, because `params.theme.default: dark` in `hugo.yaml` does not set a preferred
default in Hextra — its `theme.js` consults `prefers-color-scheme` only when the value is
neither `light` nor `dark`, so pinning it removed light mode from the site entirely.

Nothing failed. Three dark pages were saved under light filenames, and looking at the images
would have shown six plausible screenshots. `tools/shoot.js` now compares every light/dark
pair and fails when they match.

**The probe earned its place again.** Starlight's body text computed at 16px while
`--sl-text-body` was correctly set to 18px, because Starlight's own `body` rule sets
font-family, line-height, colour and background and no font-size — so nothing consumed the
variable. A screenshot of that looks entirely plausible. Hugo passed all eight assertions on
the first run, the only new candidate to do so.

Final state: **110/112 token assertions hold across 7 generators in 2 themes, 2 declared
exceptions, 0 failures.**

The suite covered dark only until Hugo shipped with light mode disabled and every dark
assertion still passed. It now runs both themes, and the exception count doubled because
Antora's broken-xref link colour is correctly excused in each — not because anything new
broke.

## Reproducing

```bash
make -C poc all          # build all seven
make -C poc poc-mkdocs   # serve one, with live reload
node poc/tools/shoot.js  # recapture the 42 screenshots
```

Per-candidate detail is in each directory's `NOTES.md`.

## Screenshots

42 captures — seven candidates, three pages, light and dark — at 1440×1000 in
`poc/screenshots/`, named `<candidate>__<page>__<scheme>.png`.

| | |
| --- | --- |
| Candidates | `mkdocs-material`, `hugo`, `starlight`, `eleventy`, `sphinx-myst`, `docusaurus`, `antora` |
| Pages | `incident`, `overview`, `runbook` |
| Schemes | `light`, `dark` |

**They are not in the repository.** `poc/.gitignore` excludes `screenshots/`, because they are
reproducible from the pinned manifests and 6.3 MB of PNGs would be re-committed on every
capture. A fresh clone has none until `make -C poc all && node poc/tools/shoot.js` runs.

To read them in a browser rather than as files:

```bash
make -C poc results-html   # writes poc/RESULTS.html, ~8.4 MB, all 42 embedded
```

`RESULTS.html` is a self-contained page — every image is a data URI, nothing loads from the
network — with the measured table and a candidate / page / theme switcher. It is generated and
ignored for the same reason the PNGs are, and it fails rather than rendering blank panes if any
capture is missing.

`shoot.js` also compares each light/dark pair and fails when they are byte-identical, because a
candidate rendering one theme twice is a finding rather than a capture error — see the Hugo
entry below.

---

## Applying the design system

Console Editorial — Editorial's structure and type carrying the Operations console
palette — was applied to **all seven** candidates, so the toolchain choice stays open and
gets decided on rendered evidence rather than on the styling-ceiling estimate above.

`design/tokens.json` is the single source. `design/build-adapters.js` generates one adapter
stylesheet per generator; no hex value is written twice, and no generator can drift.
`poc/tools/probe.js` then reads computed styles from each built site and asserts them
against the tokens — screenshots show whether a page looks right, the probe says whether the
design system actually reached it.

**Result at the time: 39/40 assertions hold, 1 declared exception, 0 failures** across the
five candidates that then existed, dark theme only. All five rendered Console Editorial
faithfully: `#0C0F13` ground, Newsreader at 18px weight 450, 40px serif H1, `#3FD0C9` links.
The current figure, seven candidates in both themes, is above.

### How hard each resisted

| | Variable mapping | Overrides needed | What fought back |
| --- | --- | --- | --- |
| **Eleventy** | 0 lines | 0 lines | Nothing. Its stylesheet was already token-driven; the change was a variable rename. |
| **Sphinx + Furo** | 19 lines | 12 lines | Nothing. Furo's `--color-*` set maps one-to-one and no rule outranked it. |
| **Docusaurus** | 20 lines | 11 lines | Infima paints the ground on `html`, leaving `body` transparent — one extra rule. |
| **MkDocs Material** | 16 lines | 21 lines | Palette specificity, see below. |
| **Antora** | 1 line | 19 lines | No variable system at all; every rule targets element classes, and one needed (0,3,1). |

### The two real fights

**Material's palette outranks variable mapping.** Links stayed indigo after the adapter set
`--md-typeset-a-color`, because `[data-md-color-scheme=slate][data-md-color-primary=indigo]`
is specificity (0,2,0) and the adapter's `:root, [data-md-color-scheme]` is (0,1,0). The fix
is a config change, not a CSS fight: `primary: custom` and `accent: custom` emit the
attribute with no rules attached, leaving the tokens in charge.

Material also silently dropped the dark theme's weight 450. `theme.font` makes Material
request 300/400/700 only, and `extra_css` accepts stylesheets rather than link tags, so the
variable font is pulled in with `@import` at the top of the adapter instead.

**Antora needed selector-depth matching.** Its `.doc>h1.page:first-child{font-size:2rem}` is
(0,3,1) and beat the adapter's `.doc h1.page` at (0,2,1) — the heading kept the theme's size
while accepting the theme's font, which is exactly the kind of half-applied result a
screenshot hides and the probe catches.

### Correction to Antora's earlier notes

`poc/antora/NOTES.md` said theming Antora means building a UI bundle — a separate Gulp
project producing a versioned zip. **That was wrong.** `ui.supplemental_files` merges a local
directory over the bundle, so a `partials/head-styles.hbs` override plus a CSS file was
enough. The format problem stands and is still disqualifying; the theming problem does not.

### What this does not change

Antora still cannot read Markdown, and Docusaurus still takes 22 seconds to build. The
design work moved neither. What it did move is the styling-ceiling question that the MkDocs
recommendation hedged on: **Material carried the full design**, including a serif face at a
64ch measure, once its palette was set to `custom`. The ceiling is real but it is a config
line, not a fork.

### Reproducing

```bash
node design/check-contrast.js   # 30/30 WCAG AA pairs, both themes
node design/build-adapters.js   # regenerate all seven adapters from tokens.json
make -C poc all                 # build all seven
node poc/tools/probe.js         # assert computed styles against the tokens
node poc/tools/shoot.js         # recapture the 42 screenshots
```
