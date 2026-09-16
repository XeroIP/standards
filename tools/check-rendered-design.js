#!/usr/bin/env node
// Assert that the design tokens reached the rendered page.
//
// `docs/design/check-contrast.js` validates the palette: 30 foreground and
// background pairs against WCAG AA. It says nothing about whether any of those
// values arrive at a browser. This does.
//
// The distinction is not academic. Two real cases from applying the token
// system across seven generators:
//
//   - Starlight defines `--sl-text-body` and never applies it. Its own `body`
//     rule sets font-family, line-height, colour and background, and no
//     font-size, so content inherits the browser default. The variable read
//     back correctly at 18px while the text rendered at 16px. Every colour
//     assertion passed.
//   - MkDocs Material silently dropped font-weight 450, because `theme.font`
//     requests 300/400/700 only.
//
// Both look entirely plausible in a screenshot. Neither is visible to a
// palette checker. The only thing that catches them is reading computed style
// out of a real browser and comparing it to the token that was supposed to
// produce it.
//
// Usage:
//   node tools/check-rendered-design.js --site site/ --pages / /how-to/deploy/
//   node tools/check-rendered-design.js --site site/ --pages / --tokens path/to/tokens.json
//   node tools/check-rendered-design.js --site site/ --pages / --exceptions design-exceptions.json
//
// Exit codes: 0 all assertions hold, 1 at least one failed, 2 could not run.

const fs = require("fs");
const path = require("path");
const { serve, launchBrowser } = require("./lib/serve-static");

const DEFAULT_TOKENS = [
  path.join(__dirname, "..", "docs", "design", "tokens.json"), // running inside the standards repo
  path.join(__dirname, "..", "docs", "design", "tokens.json"), // running from a vendored .standards/
];

function parseArgs(argv) {
  const args = { site: null, pages: [], tokens: null, exceptions: null, port: 8399 };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--site") args.site = argv[++i];
    else if (a === "--tokens") args.tokens = argv[++i];
    else if (a === "--exceptions") args.exceptions = argv[++i];
    else if (a === "--port") args.port = Number(argv[++i]);
    else if (a === "--pages") { while (argv[i + 1] && !argv[i + 1].startsWith("--")) args.pages.push(argv[++i]); }
    else { console.error(`unknown argument: ${a}`); process.exit(2); }
  }
  return args;
}

function resolveTokens(explicit) {
  if (explicit) return explicit;
  for (const p of DEFAULT_TOKENS) if (fs.existsSync(p)) return p;
  return null;
}

// CSS reports colours as rgb(); compare on that footing rather than parsing back.
function hexToRgb(hex) {
  const n = parseInt(hex.replace("#", ""), 16);
  return `rgb(${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255})`;
}

/**
 * Read the values a token system is supposed to control, from the live page.
 *
 * The element choices are heuristics that hold across generators: the first
 * substantial paragraph is body copy wherever it sits in the DOM, and the
 * first link inside a paragraph or table cell is content rather than
 * navigation chrome. Naming a generator's own class here would make the gate
 * unusable on any other generator.
 */
const MEASURE = () => {
  const cs = (el) => (el ? getComputedStyle(el) : null);
  const para = [...document.querySelectorAll("p")].find((p) => p.innerText.trim().length > 120);
  const link = [...document.querySelectorAll("a")].find((a) => a.closest("p, td"));
  const h1 = document.querySelector("h1");
  const body = cs(document.body);
  const ps = cs(para), ls = cs(link), hs = cs(h1);
  const first = (f) => (f ? f.split(",")[0].replace(/["']/g, "").trim() : null);
  return {
    bodyBg: body.backgroundColor,
    paraFound: Boolean(para),
    paraFont: ps ? first(ps.fontFamily) : null,
    paraSize: ps ? ps.fontSize : null,
    paraWeight: ps ? ps.fontWeight : null,
    paraColor: ps ? ps.color : null,
    linkFound: Boolean(link),
    linkColor: ls ? ls.color : null,
    h1Font: hs ? first(hs.fontFamily) : null,
    h1Size: hs ? hs.fontSize : null,
  };
};

(async () => {
  const args = parseArgs(process.argv);
  if (!args.site || !args.pages.length) {
    console.error("usage: check-rendered-design.js --site <built dir> --pages <url> [<url>...]");
    process.exit(2);
  }
  if (!fs.existsSync(args.site)) {
    console.error(`site directory not found: ${args.site}`);
    process.exit(2);
  }
  const tokensPath = resolveTokens(args.tokens);
  if (!tokensPath) {
    console.error("tokens.json not found. Pass --tokens <path>.");
    process.exit(2);
  }
  const T = JSON.parse(fs.readFileSync(tokensPath, "utf8"));
  const exceptions = args.exceptions ? JSON.parse(fs.readFileSync(args.exceptions, "utf8")) : {};

  const server = await serve(path.resolve(args.site), args.port);
  const browser = await launchBrowser();
  const report = [];
  let couldNotMeasure = 0;

  for (const page of args.pages) {
    const perScheme = {};
    for (const scheme of ["dark", "light"]) {
      const ctx = await browser.newContext({ viewport: { width: 1440, height: 1000 }, colorScheme: scheme });
      const tab = await ctx.newPage();
      const url = `http://localhost:${args.port}${page}`;
      const resp = await tab.goto(url, { waitUntil: "networkidle", timeout: 30000 });
      if (!resp || resp.status() >= 400) {
        console.error(`FAIL ${page} (${scheme}): HTTP ${resp && resp.status()}`);
        await ctx.close();
        couldNotMeasure++;
        continue;
      }
      await tab.waitForTimeout(400);
      const m = await tab.evaluate(MEASURE);
      perScheme[scheme] = m;

      // A page with no substantial paragraph cannot be judged. Say so rather
      // than reporting a vacuous pass — a gate that silently measures nothing
      // is the failure mode this whole tool exists to catch.
      if (!m.paraFound) {
        console.error(`FAIL ${page} (${scheme}): no paragraph over 120 characters to measure`);
        couldNotMeasure++;
      }

      const t = T.themes[scheme];
      const checks = [
        ["ground", m.bodyBg, hexToRgb(t.bg)],
        ["body font", m.paraFont, T.type.fontBody.split(",")[0].replace(/["']/g, "").trim()],
        ["body size", m.paraSize, T.type.sizeBody],
        // Body weight differs by theme on purpose: light serif on a near-black
        // ground halates and reads thinner than the same face on paper.
        ["body weight", m.paraWeight, String(t.weightBody)],
        ["body colour", m.paraColor, hexToRgb(t.ink)],
        ["h1 font", m.h1Font, T.type.fontDisplay.split(",")[0].replace(/["']/g, "").trim()],
        ["h1 size", m.h1Size, T.type.sizeH1],
      ];
      if (m.linkFound) checks.push(["link colour", m.linkColor, hexToRgb(t.accent)]);

      report.push({ page, scheme, checks, exceptions: (exceptions[page] || {}) });
      await ctx.close();
    }

    // Both themes rendering identically means the toggle is not switching —
    // the page is rendering one theme twice. Found this way on a real site
    // whose config pinned the theme, where every dark assertion passed and
    // light mode had simply been removed from the build.
    const d = perScheme.dark, l = perScheme.light;
    if (d && l && d.bodyBg === l.bodyBg && T.themes.dark.bg !== T.themes.light.bg) {
      report.push({
        page, scheme: "both",
        checks: [["theme switches", `both ${d.bodyBg}`, "light and dark to differ"]],
        exceptions: exceptions[page] || {},
      });
    }
  }

  await browser.close();
  server.close();

  const w = (s, n) => String(s == null ? "-" : s).padEnd(n);
  let fails = 0, excused = 0;
  let lastKey = null;
  for (const r of report) {
    const key = `${r.page} (${r.scheme})`;
    if (key !== lastKey) { console.log(`\n${key}`); lastKey = key; }
    console.log("  " + w("property", 16) + w("actual", 26) + w("expected", 26) + "ok");
    for (const [name, actual, expected] of r.checks) {
      const ok = String(actual) === String(expected);
      const isExcused = !ok && r.exceptions[name];
      if (!ok && !isExcused) fails++;
      if (isExcused) excused++;
      console.log("  " + w(name, 16) + w(actual, 26) + w(expected, 26) +
        (ok ? "yes" : isExcused ? "expected" : "NO"));
      if (isExcused) console.log("      ^ " + r.exceptions[name]);
    }
  }

  const total = report.reduce((n, r) => n + r.checks.length, 0);
  const pages = new Set(report.map((r) => r.page)).size;
  console.log(
    `\n${total - fails - excused}/${total} assertions hold across ${pages} page(s) ` +
    `in 2 themes, ${excused} declared exception(s), ${fails} failure(s)`
  );
  if (couldNotMeasure) console.log(`${couldNotMeasure} measurement(s) could not be taken.`);
  if (fails > 0 || couldNotMeasure > 0) process.exitCode = 1;
})();
