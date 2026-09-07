#!/usr/bin/env node
// Generates a per-generator adapter stylesheet from tokens.json.
//
// Two reasons this is generated rather than hand-written five times:
//   1. One source of truth. A colour changes in tokens.json and every adapter
//      follows; no generator can silently drift.
//   2. Each generator signals its active theme differently — Material stamps
//      data-md-color-scheme, Docusaurus and Furo use data-theme, Antora stamps
//      nothing at all. Only the *selector* differs; the values never do.
//
// Each adapter emits the --dx-* tokens under that generator's theme selectors,
// then maps them onto the generator's own variables. Typography overrides sit
// in `extra` because they are the part that tests how hard a theme resists.

const fs = require("fs");
const path = require("path");

const T = JSON.parse(fs.readFileSync(path.join(__dirname, "tokens.json"), "utf8"));
const { type, shape } = T;

const COLOR_KEYS = [
  "bg", "surface", "raised", "ink", "muted", "border",
  "accent", "accentSoft", "accentInk", "ok", "warn", "crit",
];

const kebab = (k) => k.replace(/[A-Z]/g, (c) => "-" + c.toLowerCase());

function colorBlock(theme, indent = "  ") {
  const t = T.themes[theme];
  const lines = COLOR_KEYS.map((k) => `${indent}--dx-${kebab(k)}: ${t[k]};`);
  lines.push(`${indent}--dx-weight-body: ${t.weightBody};`);
  return lines.join("\n");
}

function typeBlock(indent = "  ") {
  return [
    `${indent}--dx-font-display: ${type.fontDisplay};`,
    `${indent}--dx-font-body: ${type.fontBody};`,
    `${indent}--dx-font-mono: ${type.fontMono};`,
    `${indent}--dx-measure: ${type.measure};`,
    `${indent}--dx-size-body: ${type.sizeBody};`,
    `${indent}--dx-lh-body: ${type.lineHeightBody};`,
    `${indent}--dx-size-h1: ${type.sizeH1};`,
    `${indent}--dx-lh-h1: ${type.lineHeightH1};`,
    `${indent}--dx-track-h1: ${type.trackingH1};`,
    `${indent}--dx-weight-h1: ${type.weightH1};`,
    `${indent}--dx-size-h2: ${type.sizeH2};`,
    `${indent}--dx-weight-h2: ${type.weightH2};`,
    `${indent}--dx-size-h3: ${type.sizeH3};`,
    `${indent}--dx-radius: ${shape.radius};`,
    `${indent}--dx-rule: ${shape.rule};`,
  ].join("\n");
}

// darkSelector/lightSelector: how this generator signals its active theme.
// `auto` is the un-stamped state, where only prefers-color-scheme separates them.
const TARGETS = {
  "mkdocs-material": {
    out: "docs/design/adapters/mkdocs-material.css",
    // theme.font makes Material request 300/400/700 only, so the dark theme's
    // 450 would silently fall back to 400. extra_css takes stylesheets, not
    // link tags, so the variable font is pulled in with @import instead.
    fontImport: true,
    lightSelector: ':root, [data-md-color-scheme="default"]',
    darkSelector: '[data-md-color-scheme="slate"]',
    auto: null, // Material always stamps a scheme, so no media query is needed.
    map: `
/* Map onto Material's own variables. */
:root, [data-md-color-scheme] {
  --md-default-bg-color: var(--dx-bg);
  --md-default-fg-color: var(--dx-ink);
  --md-default-fg-color--light: var(--dx-muted);
  --md-default-fg-color--lighter: var(--dx-muted);
  --md-default-fg-color--lightest: var(--dx-border);
  --md-primary-fg-color: var(--dx-surface);
  --md-primary-bg-color: var(--dx-ink);
  --md-accent-fg-color: var(--dx-accent);
  --md-typeset-color: var(--dx-ink);
  --md-typeset-a-color: var(--dx-accent);
  --md-code-bg-color: var(--dx-raised);
  --md-code-fg-color: var(--dx-ink);
  --md-text-font: "Newsreader";
  --md-code-font: "IBM Plex Mono";
}`,
    extra: `
/* Typography. Material sizes everything in rem off a 20px root, so the body
   size is expressed as a ratio rather than a px value. */
.md-typeset { font-size: 0.9rem; line-height: var(--dx-lh-body); font-weight: var(--dx-weight-body); }
.md-content__inner { max-width: var(--dx-measure); margin-inline: auto; }
.md-typeset h1 {
  font-family: var(--dx-font-display); font-size: 2rem; line-height: var(--dx-lh-h1);
  letter-spacing: var(--dx-track-h1); font-weight: var(--dx-weight-h1); color: var(--dx-ink);
}
.md-typeset h2 {
  font-family: var(--dx-font-display); font-size: 1.15rem;
  font-weight: var(--dx-weight-h2); letter-spacing: 0;
}
.md-typeset h3 { font-family: var(--dx-font-display); font-size: 0.95rem; font-weight: var(--dx-weight-h2); }
.md-typeset table:not([class]) { font-size: 0.72rem; border-color: var(--dx-border); }
.md-typeset table:not([class]) th { background: var(--dx-raised); }
.md-typeset code { border-radius: var(--dx-radius); }
.md-typeset blockquote {
  border-left: 3px solid var(--dx-accent); background: var(--dx-accent-soft);
  color: var(--dx-ink); padding: 0.6rem 0.9rem; border-radius: 0 var(--dx-radius) var(--dx-radius) 0;
}
.md-header, .md-tabs { background: var(--dx-surface); color: var(--dx-ink); border-bottom: 1px solid var(--dx-border); }
.md-nav { font-size: 0.66rem; }`,
  },

  eleventy: {
    out: "docs/design/adapters/eleventy.css",
    lightSelector: ":root",
    darkSelector: ':root[data-theme="dark"]',
    auto: ':root:not([data-theme="light"])',
    map: `
/* Eleventy's stylesheet reads --dx-* directly; no second variable set. */`,
    extra: "",
  },

  docusaurus: {
    out: "docs/design/adapters/docusaurus.css",
    lightSelector: ":root",
    darkSelector: ":root[data-theme='dark']",
    auto: null, // Docusaurus stamps data-theme on first paint.
    map: `
/* Map onto Infima's variables. */
:root, :root[data-theme='dark'] {
  --ifm-background-color: var(--dx-bg);
  --ifm-background-surface-color: var(--dx-surface);
  --ifm-font-color-base: var(--dx-ink);
  --ifm-color-primary: var(--dx-accent);
  --ifm-link-color: var(--dx-accent);
  --ifm-code-background: var(--dx-raised);
  --ifm-toc-border-color: var(--dx-border);
  --ifm-table-border-color: var(--dx-border);
  --ifm-table-head-background: var(--dx-raised);
  --ifm-navbar-background-color: var(--dx-surface);
  --ifm-font-family-base: var(--dx-font-body);
  --ifm-heading-font-family: var(--dx-font-display);
  --ifm-font-family-monospace: var(--dx-font-mono);
  --ifm-font-size-base: var(--dx-size-body);
  --ifm-line-height-base: var(--dx-lh-body);
  --ifm-h1-font-size: var(--dx-size-h1);
  --ifm-heading-font-weight: var(--dx-weight-h2);
  --ifm-global-radius: var(--dx-radius);
}`,
    extra: `
html, body { background: var(--dx-bg); }
.markdown { font-weight: var(--dx-weight-body); }
.theme-doc-markdown { max-width: var(--dx-measure); }
.markdown h1:first-child {
  font-size: var(--dx-size-h1); line-height: var(--dx-lh-h1);
  letter-spacing: var(--dx-track-h1); font-weight: var(--dx-weight-h1);
}
.markdown blockquote {
  border-left: 3px solid var(--dx-accent); background: var(--dx-accent-soft);
  border-radius: 0 var(--dx-radius) var(--dx-radius) 0;
}`,
  },

  "sphinx-myst": {
    out: "docs/design/adapters/sphinx-furo.css",
    lightSelector: ":root",
    darkSelector: 'body[data-theme="dark"]',
    auto: 'body:not([data-theme="light"])',
    map: `
/* Map onto Furo's variables. Furo reads these on every surface it paints. */
:root, body[data-theme="dark"], body:not([data-theme="light"]) {
  --color-background-primary: var(--dx-bg);
  --color-background-secondary: var(--dx-surface);
  --color-background-hover: var(--dx-raised);
  --color-background-border: var(--dx-border);
  --color-foreground-primary: var(--dx-ink);
  --color-foreground-secondary: var(--dx-muted);
  --color-foreground-muted: var(--dx-muted);
  --color-foreground-border: var(--dx-border);
  --color-brand-primary: var(--dx-accent);
  --color-brand-content: var(--dx-accent);
  --color-link: var(--dx-accent);
  --color-link--hover: var(--dx-accent);
  --color-inline-code-background: var(--dx-raised);
  --color-table-header-background: var(--dx-raised);
  --color-table-border: var(--dx-border);
  --font-stack: var(--dx-font-body);
  --font-stack--monospace: var(--dx-font-mono);
}`,
    extra: `
article { font-size: var(--dx-size-body); line-height: var(--dx-lh-body); font-weight: var(--dx-weight-body); }
.content { max-width: var(--dx-measure); }
article h1 {
  font-family: var(--dx-font-display); font-size: var(--dx-size-h1); line-height: var(--dx-lh-h1);
  letter-spacing: var(--dx-track-h1); font-weight: var(--dx-weight-h1);
}
article h2 { font-family: var(--dx-font-display); font-size: var(--dx-size-h2); font-weight: var(--dx-weight-h2); }
article h3 { font-family: var(--dx-font-display); font-size: var(--dx-size-h3); font-weight: var(--dx-weight-h2); }
article blockquote {
  border-left: 3px solid var(--dx-accent); background: var(--dx-accent-soft);
  border-radius: 0 var(--dx-radius) var(--dx-radius) 0;
}`,
  },

  antora: {
    out: "docs/design/adapters/antora.css",
    lightSelector: ":root",
    darkSelector: ':root[data-theme="dark"]',
    // Antora's default UI stamps no theme attribute and ships no toggle, so the
    // media query is the only thing that can switch it. Recorded as a finding.
    auto: ":root",
    map: `
/* Antora's default UI exposes almost no custom properties, so the adapter has
   to target its element classes directly rather than remap variables. */`,
    extra: `
body { background: var(--dx-bg); color: var(--dx-ink); font-family: var(--dx-font-body); font-weight: var(--dx-weight-body); }
.nav, .toolbar, .toc { background: var(--dx-surface); color: var(--dx-ink); border-color: var(--dx-border); }
.nav-menu, .nav-list a, .toc a { color: var(--dx-muted); }
.doc { max-width: var(--dx-measure); font-size: var(--dx-size-body); line-height: var(--dx-lh-body); }
/* Antora's own rule is .doc>h1.page:first-child at (0,3,1); the adapter has to
   match that depth or the heading silently keeps the theme's size. */
.doc h1, .doc h1.page, .doc > h1.page:first-child {
  font-family: var(--dx-font-display); font-size: var(--dx-size-h1); line-height: var(--dx-lh-h1);
  letter-spacing: var(--dx-track-h1); font-weight: var(--dx-weight-h1); color: var(--dx-ink);
}
.doc p, .doc li, .doc td, .doc th, .doc dt, .doc dd, .doc .paragraph { color: var(--dx-ink); }
.doc a, .doc a:hover, .doc a:visited { color: var(--dx-accent); }
.doc h2 { font-family: var(--dx-font-display); font-size: var(--dx-size-h2); font-weight: var(--dx-weight-h2); color: var(--dx-ink); border-bottom: 0; }
.doc h3 { font-family: var(--dx-font-display); font-size: var(--dx-size-h3); font-weight: var(--dx-weight-h2); color: var(--dx-ink); }
.doc a { color: var(--dx-accent); }
.doc table.tableblock { border-color: var(--dx-border); }
.doc table.tableblock th { background: var(--dx-raised); color: var(--dx-ink); }
.doc table.tableblock td, .doc table.tableblock th { border-color: var(--dx-border); }
.doc code, .doc pre { background: var(--dx-raised); color: var(--dx-ink); font-family: var(--dx-font-mono); }
.doc .admonitionblock { background: var(--dx-accent-soft); border-left: 3px solid var(--dx-accent); }`,
  },
};

const banner = (name) => `/* GENERATED by design/build-adapters.js from design/tokens.json.
   Do not edit — change the tokens and re-run. Target: ${name}.
   Fonts: ${type.googleFonts} */\n`;

let count = 0;
for (const [name, cfg] of Object.entries(TARGETS)) {
  let css = banner(name);

  // @import must precede every other rule, so it goes in before anything else.
  if (cfg.fontImport) css += `\n@import url("${type.googleFonts}");\n`;

  css += `\n${cfg.lightSelector} {\n${typeBlock()}\n\n${colorBlock("light")}\n}\n`;

  if (cfg.auto) {
    css += `\n@media (prefers-color-scheme: dark) {\n  ${cfg.auto} {\n${colorBlock("dark", "    ")}\n  }\n}\n`;
  }
  css += `\n${cfg.darkSelector} {\n${colorBlock("dark")}\n}\n`;

  css += `${cfg.map}\n`;

  // Severity stays unreachable unless a page opts in.
  css += `
:root { --dx-ok: var(--dx-ink); --dx-warn: var(--dx-ink); --dx-crit: var(--dx-ink); }
[data-severity-ui] {
  --dx-ok: var(--dx-ok-raw); --dx-warn: var(--dx-warn-raw); --dx-crit: var(--dx-crit-raw);
}
`;

  if (cfg.extra) css += `${cfg.extra}\n`;

  const out = path.resolve(__dirname, "..", "..", cfg.out);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, css);
  console.log(`${name.padEnd(18)} -> ${cfg.out} (${css.split("\n").length} lines)`);
  count++;
}
console.log(`\n${count} adapters generated from tokens.json`);
