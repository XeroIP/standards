---
title: MkDocs + Material as the documentation toolchain
type: adr
id: ADR-0001
status: proposed
date: 2026-09-09
deciders: [peter]
updated: 2026-09-09
supersedes: null
superseded_by: null
tags: [documentation, tooling, build]
---

# MkDocs + Material as the documentation toolchain

## Context and problem statement

Documentation across thirty repositories is rendered by five separately hand-written HTML
systems. Each has its own stylesheet, its own page shell, and its own idea of what a document
looks like. One incident review in the pilot repository is 1,292 lines of hand-authored HTML.
Consistency between any two of those systems rests on a prose standard plus whoever last
edited the file.

The documentation standard in `../documentation/` assumes a generator: it decouples
navigation order from filenames, it requires internal links to be checked, and it defines a
token-driven visual system that has to reach the page from one source. None of that is
enforceable while pages are hand-written HTML.

One generator has to be chosen for every repository, public and private, before the pilot
restructure lands. Choosing it after the restructure means restructuring twice.

## Decision drivers

- **Source stays plain Markdown.** The same text is read by agents, rendered by GitHub, and
  edited without a preview. A format that only a build can read breaks all three.
- **Adoption cost measured in source changes.** A generator that requires editing every file
  before it renders anything imposes that cost again on each of thirty repositories.
- **Broken internal links fail the build.** The restructure moves nearly every page; a
  link check that reports rather than fails is a link check that gets merged past.
  This driver carries less weight than it first appears to, and the correction belongs here
  rather than in a footnote. `tools/check-docs.py` already fails on a relative link whose
  target does not exist, generator-agnostically, and it is already wired into `docs-ci.yml`.
  What a generator adds on top is resolution against its own navigation tree — and
  `docs-ci.yml` builds no site at all today, so nothing in the current gate exercises that.
  Read this driver as separating a generator that _can_ fail a build from one that only
  reports, not as a capability one candidate uniquely supplies.
- **Navigation order independent of filename.** The `00-`…`19-` ordinal prefixes in the pilot
  repository exist because ordering had nowhere else to live.
- **One token file reaches the rendered page.** The design system is generated from
  `../design/tokens.json`. A generator that has to be forked to accept it is a generator that
  will drift from it.
- **Build fast enough to run on every commit.** A gate people wait on is a gate people skip.
- **Two deployment targets.** Static output published to GitHub Pages for the public site, and
  the same output served by a container behind a forward-auth proxy for private repositories.
  Anything requiring a runtime on the serving host fails the second case.

## Considered options

Each option built the same three pages — an architecture overview, a runbook, and an incident
review — from the same Markdown in `poc/` in the pilot repository, then had the design system
applied and its computed styles asserted against the tokens. Figures below were measured in
one session on one machine with cold caches.

| | Install | Cold build | Output | Source files changed | Markdown source |
| --- | --- | --- | --- | --- | --- |
| MkDocs + Material | 11s | 568ms | 2.8 MB | 0 | native |
| Eleventy | 6s | 660ms | 140 KB | 3 | front matter required |
| Docusaurus | 19s | 22,392ms | 908 KB | 1 | native |
| Sphinx + MyST | 8s | 1,056ms | 1.1 MB | 0 | native |
| Antora | 9s | 1,517ms | 628 KB | 3 | no — AsciiDoc |

**Keep hand-written HTML.** Rejected. It is the status quo whose failure prompted the
decision, and every driver above is unreachable from it.

**Antora.** Rejected on format. It cannot read Markdown, so adoption means converting every
page to AsciiDoc — the largest possible adoption cost against the first two drivers. It is
strongest on multi-repo composition, which is the one place it wins outright. A separate
correction is worth recording, because the earlier evaluation had it wrong: theming Antora
does not require building a UI bundle, since `ui.supplemental_files` merges a local directory
over the published one. The theming objection was withdrawn; the format objection stands.

**Docusaurus.** Rejected on build time and dependency weight — 22 seconds against 568
milliseconds, for a documentation set of three pages. The earlier assumption that MDX would
degrade portability turned out to be wrong: forcing `format: 'mdx'` built all three files
cleanly, and `format: 'detect'` removes the forward-looking risk entirely. Docusaurus was not
rejected for the reason first given.

**Eleventy.** Second on every measure that matters and the recorded fallback. It produced the
smallest output by a factor of twenty, and it accepted the design tokens with zero lines of
mapping and zero overrides, because its stylesheet was already token-driven. Its cost is that
everything a documentation theme provides — navigation, search, page outline, dark mode — is
hand-built and then hand-maintained per repository. The evaluated implementation needed 233
lines of template and CSS and derived its page outline by scraping headings with a regular
expression. It is the right answer if the design work ever exceeds what Material can express.

**Sphinx + MyST.** The strongest argument against the chosen option, and measuring that
argument is what settled the decision. Sphinx alone emits `objects.inv`, an inventory that
lets one project's documentation link into another's by symbol rather than by URL, which for
documentation spread across thirty repositories is the single most relevant capability any
candidate offered.

The inventory a prose documentation set actually emits is narrower than that summary implies.
Building the three pages produced entries of exactly one kind:

```text
incident-rca  std:doc  -1  incident-rca.html   Post-Incident Review — ...
overview      std:doc  -1  overview.html       Architecture Overview
runbook       std:doc  -1  runbook.html        Runbook
```

The key is the document path. A cross-project reference to `overview` breaks when
`overview.md` is renamed, in exactly the way a relative link breaks. Rename-durable targets do
exist, but only for anchors declared by hand: adding `(network-boundary)=` to a page produced
a `std:label` entry pointing at `overview.html#network-boundary`, and nothing else in the
build produced one. That is a hand-maintained identifier namespace — a convention, not a
capability — and the stable-slug rule in [`../documentation/naming.md`](../documentation/naming.md)
already buys the same durability for any generator.

Two further constraints narrow it. Cross-project linking requires every project on both ends
to be Sphinx, and most repositories here are not documentation-shaped. It also requires the
target's inventory to be fetchable at build time, and most of this estate is private and
behind forward auth.

What survives is real but small: Sphinx fails its own build on a dead cross-project
reference, where a link checker reports the same dead link out of band. Sphinx also has a
credible path to PDF — `-b latex` emitted a `.tex` with no TeX toolchain installed. Neither
outweighs the adoption and maintenance profile of the chosen option.

**MkDocs + Material.** Proposed. See below.

## Decision outcome

**Proposed, not decided.** This ADR is `status: proposed` and stays editable until the
decider accepts or rejects it. Nothing in the repository depends on the outcome yet.

The proposal is **MkDocs + Material**, because it satisfied every driver without modification
to a single source file, and because the two drivers with no workaround — Markdown as source,
and adoption cost paid thirty times — are the two it satisfies outright.

It rendered all three pages in 568 milliseconds from 62 lines of configuration and 9 lines of
custom CSS. Five of the six page behaviours the incident standard requires are configuration
flags: sidebar navigation, sticky header, section search, dark-mode toggle, responsive
layout. Print rules were the only custom CSS written. The 1,292-line hand-authored incident
page reproduces from 410 lines of Markdown with no per-incident HTML at all.

`mkdocs build --strict` fails on a broken internal link in half a second. That is narrower
than it sounds and should not be counted twice: link existence is already gated by
`check-docs.py` whichever generator renders the page, so `--strict` contributes resolution
against the `nav:` tree rather than link checking as such. It is also not wired into anything
— `docs-ci.yml` runs no build — so it is headroom the choice makes available, not a guarantee
the choice delivers today.

`nav:` sets order independently of filename, so the ordinal prefixes become cleanup rather
than a prerequisite. That one is delivered outright.

The styling ceiling was the open question, and the design pass closed it. Material carried
the full token set — a serif face at a 64ch measure, an 18px body at weight 450, a 40px serif
H1 — through 16 lines of variable mapping and 21 lines of override. Two behaviours had to be
worked around and are recorded here so they are not rediscovered:

- Material's palette rules outrank variable mapping. `[data-md-color-scheme=slate][data-md-color-primary=indigo]`
  has specificity (0,2,0) and beats an adapter's `:root, [data-md-color-scheme]` at (0,1,0),
  so links stayed indigo after the tokens were set. Setting `primary: custom` and
  `accent: custom` emits the attribute with no rules attached, which leaves the tokens in
  charge. This is a configuration line, not a CSS fight.
- `theme.font` requests weights 300, 400 and 700 only, so the dark theme's weight 450 was
  silently dropped. `extra_css` accepts stylesheets rather than link tags, so the variable
  font is pulled in with `@import` at the top of the adapter.

## Consequences

**A Python toolchain enters repositories that are otherwise JavaScript, Dart, or shell.** The
documentation build becomes the only reason several repositories need a virtual environment.
Pinned in `requirements.txt` and installed in CI, this is a cost paid per repository at setup
and rarely afterwards, but it is a genuine widening of what each repository depends on.

**Cross-repository linking is by URL, checked out of band.** A link from one repository's
documentation into another's is an ordinary link, verified by a link checker rather than by
the build. When a target moves, the source repository's build stays green and the link
checker reports it later. The mitigation is the stable-slug rule plus redirects, both of which
are conventions people have to follow. The finding above is why this is acceptable rather
than why it does not matter: Sphinx would have made it a build failure, and that is the thing
given up.

**Material is one maintainer's project on a sponsorware model.** Features ship first to
Insiders and reach the open edition later, and some never do. Nothing used here is
Insiders-only, and that constraint is now a constraint on the design: a requirement that can
only be met by a paid tier is a requirement to reconsider, not a reason to subscribe.

**Output is 2.8 MB against Eleventy's 140 KB.** Twenty times larger, for a documentation set
of three pages. It does not matter at the sizes involved and it is bundled theme assets rather
than content, but it is the measured difference and it will grow.

**A design direction that fights Material's structure is not reachable.** Everything arrives
through Material's own custom properties and `theme.custom_dir`. The current direction fits;
a future one that does not is the condition that promotes Eleventy, and switching means
rewriting the theme layer in every repository at once.

**Reversal cost is asymmetric and deliberately so.** Because adoption changed zero source
files, the Markdown stays generator-neutral, and moving to Eleventy or Sphinx costs the theme
layer rather than the content. Moving to Antora would cost the content, which is why it was
rejected at the format rather than on its merits.

## Confirmation

The decision is working while all of the following hold:

- A site build runs in the documentation gate at all. `docs-ci.yml` does not build one today,
  so the `--strict` benefit claimed above is unrealised until it does. Wiring it in is the
  step that welds the gate to this decision, and it should not happen before the decision is
  accepted.
- Once it is wired in, `mkdocs build --strict` is green in every repository consuming the
  workflow, and no repository has disabled `--strict` to get it there.
- The token adapter remains generated from `../design/tokens.json`, with no hex value written
  into a repository's own stylesheet.
- No documentation requirement has been met by a Material Insiders feature.
- `theme.custom_dir` stays limited to templates the token system cannot reach. A custom_dir
  that starts absorbing page layout is Material being fought rather than configured, and that
  is the signal to reopen this decision against Eleventy.
