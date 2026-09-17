---
title: Documentation generator survey
type: project
status: active
updated: 2026-09-10
summary: The twenty-generator screen that should have preceded the bake-off, and the thirteen rejections.
services: [documentation-generators]
---

# Documentation generator survey

The five-candidate bake-off in [the bake-off](2026-09-06-documentation-toolchain-bake-off.md) tested a list that came from the plan, not from a
survey. This document is the survey that should have preceded it: what exists, what was
screened out and on which criterion, and which candidates earn a build.

## How the version data was obtained

Every date below was read on 2026-09-10 from a package registry, not from a comparison
article. The method is recorded because the first pass got a date wrong by two years, and the
reason it did is instructive.

`github.com` is not directly reachable from the environment this was run in: the network proxy
binds it to the session's own repositories and returns `403` for anything else, the releases
atom feed included. `registry.npmjs.org`, `pypi.org` and `index.crates.io` bypass the proxy,
so they are the reliable source, and they mirror the same releases.

Where a project publishes nothing to those registries, its release page was read and the
figures cross-checked. Two failure modes showed up and both are worth knowing:

- A summarised page fetch reported Hugo as `v0.166.0, September 9 2024`. The version series
  was roughly right and the year was two years out. The npm mirror `hugo-extended` gives
  `0.165.0` published `2026-09-06`, which reconciles it.
- GitHub omits the year on release dates within the current year. `02 Sep 11:13` on the
  Starlight page matches npm's `2026-09-02` exactly, which confirms the convention — and
  explains how a reader, human or otherwise, invents a year that is not on the page.

The lesson for the standards themselves: a date with no year is a date that will be misread.

## Screening criteria

Taken from the decision drivers already recorded in ADR-0001, so the screen and the decision
are judged against the same requirements. A candidate failing any of these is out regardless
of its other merits.

| | Criterion | Why it is disqualifying |
|---|---|---|
| C1 | Markdown is the source, unmodified | The source is read by agents, rendered by GitHub, and edited without a preview. A format only a build can read breaks all three. |
| C2 | Static HTML output, rendered at build time | Two deploy targets, one behind a forward-auth proxy. Client-side rendering also hides content from a printer and from anything that does not run JavaScript. |
| C3 | A current stable release line | Thirty repositories and a multi-year commitment. A stable line that has not shipped in over a year, or a next line stuck in prolonged alpha, is a maintenance risk being taken on deliberately. |
| C4 | Open source and self-hostable | The private site runs on hardware under our control. A hosted product cannot go there at any price. |
| C5 | Theming reachable from a token file without forking | The design system is generated from `design/tokens.json`. A generator requiring a fork will drift from it. |

Discriminators — build speed, navigation decoupled from filename, link checking as a build
gate, search, dark mode, print output, versioning — separate the survivors and are settled by
building, not by reading.

## The field

### Already built

| Candidate | Outcome |
|---|---|
| MkDocs + Material | Recommended in ADR-0001, `proposed` |
| Eleventy | Second, recorded fallback |
| Sphinx + MyST | Third |
| Docusaurus | Rejected — build time and dependency weight |
| Antora | Rejected — fails C1, cannot read Markdown |

### Screened in — these earn a build

**Astro Starlight.** Markdown and MDX native, static output, Pagefind search, dark mode and
i18n in the box, and theming through CSS custom properties. `@astrojs/starlight` 0.42.0
published 2026-09-02, corroborated by the release page showing `02 Sep 11:13` for the same
tag — two independent sources agreeing on the same day.

The reservation is C3, and it is a judgement rather than a failure: Starlight is pre-1.0 after
roughly three years and forty-two minor releases. Pre-1.0 in this ecosystem often signals
willingness to break rather than immaturity, and every minor release is permitted to break.
Against thirty repositories on a pinned version that is a cost, not a blocker.

It is the strongest omission from the original five and the one a reviewer is most likely to
name.

**Hugo, with a documentation theme.** Markdown native, static, and a single Go binary with no
language runtime — which is the one property no other candidate here has. Nothing to install
into thirty repositories except a binary, and the fastest builds in the category by a wide
margin.

Release cadence is monthly and current: `0.161.0` on 2026-07-20, `0.162.0` on 2026-08-12,
`0.163.0` on 2026-09-09 via the `hugo-bin` mirror, with `hugo-extended` at `0.165.0` on
2026-09-06. The two mirrors disagree slightly on which version is newest, which is a mirror
artefact rather than a Hugo one; the cadence is what matters and it is the most frequent in
this survey.

Two theme paths, and they are different products with different release rhythms:

| Theme | Latest | Character |
|---|---|---|
| Docsy | published 2026-08-30 | What Kubernetes and much of CNCF publish with. Heavily Bootstrap-based. Actively maintained. |
| Hextra | `v0.12.3`, 05 May | The modern alternative, Tailwind-flavoured. Four months since the last release, after `v0.12.1` in March and `v0.12.2` in April. |

**The theme, not Hugo, decides C5**, and neither theme is a clear pick: Docsy is current but
its Bootstrap foundation is the furthest of any candidate from the design system already
built, while Hextra is closer in spirit and moving more slowly. This is the one candidate
where the build has to test a theme rather than a generator.

Hugo's real cost is its templating language, which is genuinely awkward, and the fact that any
customisation beyond a theme's variables means writing it.

### Screened out, with the criterion

| Candidate | Out on | Detail |
|---|---|---|
| **VitePress** | C3 | Latest stable 1.6.4 published 2025-08-05 — thirteen months. The `next` line has been in alpha since at least 2026-03, reaching `2.0.0-alpha.20` on 2026-09-04. Adopting means choosing between a stale stable and a prolonged alpha. Otherwise a strong fit, and worth revisiting when 2.0 ships. |
| **Nextra** | discriminator | 4.6.1, 2025-12-04. Next.js-based, so it occupies the same position as Docusaurus — React framework, heavy build, high styling ceiling — which the bake-off already tested and rejected on build weight. Building it would re-run a finished experiment. |
| **Fumadocs** | discriminator | 16.15.8, 2026-09-07, very actively developed. Same reasoning as Nextra, and MDX-first rather than Markdown-first, which pushes against C1. |
| **Rspress** | discriminator | 1.47.2, 2026-05-07. Rspack-based, credible, but a markedly smaller community than the alternatives in its class, and in that class Docusaurus was already rejected. |
| **Jekyll + Just the Docs** | discriminator | Passes every criterion and is natively supported by GitHub Pages, which is a real advantage for the public site. Ruby toolchain, a slower build, and a theme generation behind the alternatives. Named rather than built. |
| **mdBook** | discriminator | `0.5.4`, confirmed via the crates.io index. Single Rust binary, `SUMMARY.md` gives navigation decoupled from filenames, very fast. Built for linear books rather than a four-quadrant documentation set, and weaker on tables, admonitions and search. A reasonable minimalism control if one is wanted. |
| **Quarto** | discriminator | 1.10.18, 2026-07-24. The only candidate besides Sphinx with a first-class path to typeset PDF, via Pandoc and LaTeX. Aimed at scientific and computational publishing, and heavier than this estate needs — unless PDF becomes a requirement, in which case it re-enters against Sphinx. |
| **Zola** | C5 | Single Rust binary and fast, but no documentation theme in the same class, so the design system would be built from scratch — which is Eleventy's position without Eleventy's flexibility. |
| **Docsify** | **C2** | Renders in the browser at request time. No static HTML, so nothing survives without JavaScript, print output is unreliable, and a crawler or an offline reader sees an empty shell. |
| **GitBook, Mintlify, ReadMe, Archbee, Retype** | **C4** | Hosted products. The private site runs on our own hardware behind forward auth, which a SaaS product cannot do. |
| **Wiki.js, BookStack, Outline** | **C1** | Database-backed wikis. Content does not live in git as Markdown files, so it cannot be reviewed in a pull request, vendored, or read by an agent from the working tree. |
| **Read the Docs** | not a generator | A hosting platform that runs Sphinx or MkDocs. Relevant to deployment, not to this choice. |
| **Quartz, Docus, Vocs, Slate, Redoc** | scope or scale | Obsidian-flavoured, Nuxt-flavoured, Vite-flavoured, and two API-reference-only tools. Named so the omission is deliberate. |
| **Pandoc plus a Makefile** | C5, practically | Everything a documentation theme provides would be written and then maintained. This is Eleventy's cost without Eleventy's ecosystem. |

## A finding about the current recommendation

MkDocs core has not shipped a stable release since **1.6.1 on 2024-08-30** — two years. It is
not abandoned: `2.0.dev3` was published on **2026-09-02**, and the `2.0.dev0`…`dev3` series
began 2026-08-28. Material is separately and actively released, at 9.7.7 on 2026-07-17.

So the recommended candidate sits on a core that is between major versions, with a 2.0 in
active development and no stable release in two years. That cuts both ways and should be
recorded rather than smoothed over:

- A long gap between stable releases is what a settled tool looks like, and Material carries
  most of the surface that matters here.
- A major version arriving immediately after thirty repositories standardise on 1.6.1 is real
  churn, and the pinned `mkdocs==1.6.1` in `poc/mkdocs-material/requirements.txt` will need a
  deliberate migration rather than a version bump.

Neither Starlight's pre-1.0 status nor MkDocs' pending 2.0 is disqualifying. Both belong in
ADR-0001's consequences, because both are commitments being made on behalf of thirty
repositories.

## Recommendation

Build **Starlight** and **Hugo with a modern documentation theme**. Two additions to the
existing harness — `_content/` already holds the source pages, `design/build-adapters.js`
generates a per-generator adapter, and `tools/probe.js` asserts computed styles against the
tokens — so each is a directory, a config, an adapter, and a make target.

Everything else in this survey is either already built, out on a stated criterion, or a
re-run of an experiment that is finished.

If Starlight and Hugo both lose, ADR-0001 is materially stronger for having tested them. If
either wins, that is better known now than after thirty repositories adopt something else.
