---
title: Console Editorial
type: reference
status: active
updated: 2026-09-07
summary: The design system — editorial structure and typography carrying an operations-console palette, dark canonical.
---

# Console Editorial

Editorial structure and typography carrying an operations-console palette. Dark is canonical;
light is derived from it.

| File | What it is |
| --- | --- |
| `tokens.json` | **Source of truth.** Colour, type, and shape values, plus the contrast pairs to verify. |
| `tokens.css` | The same values as CSS custom properties, for anything that loads CSS directly. |
| `build-adapters.js` | Generates one adapter stylesheet per site generator from `tokens.json`. |
| `adapters/` | The generated per-generator stylesheets. Never edited by hand. |
| `check-contrast.js` | Verifies every declared pair against WCAG AA in both themes. Exits non-zero on failure. |

## Type

Newsreader for display and body, IBM Plex Mono for data. 64ch measure, 18px body at 1.72
line height, 40px H1.

**Body weight differs by theme: 400 light, 450 dark.** Light serif on a near-black ground
halates and reads thinner than the same face on paper; Newsreader's variable weight axis
absorbs it. This is the only non-colour token that changes between themes.

## Colour

| Token | Dark (canonical) | Light (derived) |
| --- | --- | --- |
| `--dx-bg` | `#0C0F13` | `#F5F7F9` |
| `--dx-surface` | `#141920` | `#FFFFFF` |
| `--dx-raised` | `#1C232C` | `#EEF2F5` |
| `--dx-ink` | `#DCE3EC` | `#131920` |
| `--dx-muted` | `#8B97A6` | `#5C6773` |
| `--dx-border` | `#242C36` | `#DBE1E8` |
| `--dx-accent` | `#3FD0C9` | `#10736D` |

The accent keeps its hue and changes luminance: `#3FD0C9` reaches 10.1:1 on the dark ground
but only 2.4:1 on white, so light mode darkens it to `#10736D` at 5.3:1.

Severity — `--dx-ok`, `--dx-warn`, `--dx-crit` — resolves to `--dx-ink` unless an ancestor
carries `data-severity-ui`, set from front matter on incidents, runbooks, and status pages.
A reference or explanation page that asks for a severity colour gets ink, by construction.
Status is always carried by form as well as colour, so it survives greyscale print and
colour-blind readers.

## Rules

1. Components read tokens. A literal colour in a component is a bug.
2. Adapters map tokens onto a generator's own variables. They never redefine a value.
3. Adapters are generated. Edit `tokens.json` and re-run `build-adapters.js`.
4. `check-contrast.js` passes before any colour change is committed.

## Verifying

```bash
node docs/design/check-contrast.js   # 30/30 pairs pass WCAG AA in both themes
node docs/design/build-adapters.js   # regenerate all seven adapters
```

The system was applied to five site generators and verified by reading computed styles from
each built site: 39/40 assertions hold, with one declared exception and no failures. The
evidence lives in `XeroIP/my-unraid-notes` under `poc/RESULTS.md`.

## Adapters

An adapter maps these tokens onto a generator's own variables. It never redefines a value.
Two generators needed more than a mapping, and both are worth knowing before picking one:

- **MkDocs Material** reinstates its own palette at CSS specificity (0,2,0), which outranks a
  variable mapping. Set `primary: custom` and `accent: custom` in `mkdocs.yml` so the palette
  emits its attribute with no rules attached. Material also requests only font weights
  300/400/700 via `theme.font`, so the variable font is pulled in with `@import`.
- **Antora** exposes no theme variables at all, so its adapter overrides element rules
  directly, and one selector has to reach specificity (0,3,1) to beat
  `.doc>h1.page:first-child`.
- **Starlight** publishes a clean `--sl-*` set that maps one-to-one, with one trap: it defines
  `--sl-text-body` and never applies it. Its own `body` rule sets font-family, line-height,
  colour and background and no font-size, so content inherits the browser default and the
  measure is silently wrong. The adapter sets `font-size` on `.sl-markdown-content` explicitly.
- **Hugo** has no single adapter, because the theme decides the surface rather than Hugo. The
  one here targets **Hextra**: Tailwind's `.dark` class strategy rather than a data attribute,
  and `assets/css/custom.css` as the extension point, which Hextra concatenates last so the
  adapter wins on source order. Docsy would need its own adapter and does not have one.

## Checking that the tokens reached the page

`check-contrast.js` validates the palette — 30 pairs against WCAG AA. It says nothing about
whether any of those values arrive at a browser, and that gap is where the real failures were:
Starlight defined `--sl-text-body` and never applied it, so body copy rendered at the browser
default while every colour assertion passed; Material silently dropped font-weight 450. Both
look entirely plausible in a screenshot.

`tools/check-rendered-design.js` reads computed style out of a real browser and compares it to
the token that was supposed to produce it:

```bash
node tools/check-rendered-design.js --site site/ --pages / /how-to/deploy-stack/
```

It runs every page in both themes, and asserts one thing no per-theme check can: that the two
themes actually differ. A page whose ground colour is identical in light and dark is rendering
one theme twice — which is how a site shipped with light mode removed from the build while
every dark assertion passed.

A known-correct deviation is declared rather than tolerated:

```json
{ "/reference/api/": { "link colour": "Broken-link warnings are red here on purpose." } }
```

Pass it with `--exceptions`. An exception excuses the named property on the named page and
nothing else.

**Playwright is an optional dependency**, because most repositories never build a site:

```bash
npm install --no-save playwright && npx playwright install chromium
```

`CHROMIUM_PATH` overrides the browser when an image already has one, which avoids downloading
several hundred megabytes to satisfy a version check.

`tools/capture-screens.js` takes the same arguments and writes light and dark captures for
review. It is an aid, not a gate — a full set of plausible-looking screenshots is exactly what
a broken theme toggle produces.
