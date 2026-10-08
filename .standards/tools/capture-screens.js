#!/usr/bin/env node
// Capture a built site's pages in light and dark, for review.
//
// This is a review aid, not a gate. Screenshots answer "does this look right",
// which is a question a person has to settle; `check-rendered-design.js`
// answers "did the tokens reach the page", which is a question a machine
// settles better. Do not wire this into CI expecting it to catch anything —
// a full set of plausible-looking captures is exactly what a broken theme
// toggle produces.
//
// Usage:
//   node tools/capture-screens.js --site site/ --pages / /how-to/deploy/ --out screens/
//
// Exit codes: 0 all captured, 1 at least one page failed, 2 could not run.

const fs = require("fs");
const path = require("path");
const { serve, launchBrowser } = require("./lib/serve-static");

function parseArgs(argv) {
  const args = { site: null, pages: [], out: "screens", port: 8398, width: 1440, height: 1000 };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--site") args.site = argv[++i];
    else if (a === "--out") args.out = argv[++i];
    else if (a === "--port") args.port = Number(argv[++i]);
    else if (a === "--width") args.width = Number(argv[++i]);
    else if (a === "--height") args.height = Number(argv[++i]);
    else if (a === "--full") args.full = true;
    else if (a === "--pages") { while (argv[i + 1] && !argv[i + 1].startsWith("--")) args.pages.push(argv[++i]); }
    else { console.error(`unknown argument: ${a}`); process.exit(2); }
  }
  return args;
}

// A URL is not a filename. Flatten it to something stable and sortable so a
// directory of captures can be diffed between runs.
const slug = (url) => url.replace(/^\/+|\/+$/g, "").replace(/[^a-zA-Z0-9._-]+/g, "-") || "index";

(async () => {
  const args = parseArgs(process.argv);
  if (!args.site || !args.pages.length) {
    console.error("usage: capture-screens.js --site <built dir> --pages <url> [<url>...] [--out dir]");
    process.exit(2);
  }
  if (!fs.existsSync(args.site)) {
    console.error(`site directory not found: ${args.site}`);
    process.exit(2);
  }

  fs.mkdirSync(args.out, { recursive: true });
  const server = await serve(path.resolve(args.site), args.port);
  const browser = await launchBrowser();
  const results = [];

  for (const scheme of ["light", "dark"]) {
    const ctx = await browser.newContext({
      viewport: { width: args.width, height: args.height },
      colorScheme: scheme,
      deviceScaleFactor: 1,
    });
    const tab = await ctx.newPage();
    for (const page of args.pages) {
      const file = path.join(args.out, `${slug(page)}__${scheme}.png`);
      try {
        const resp = await tab.goto(`http://localhost:${args.port}${page}`, {
          waitUntil: "networkidle", timeout: 30000,
        });
        if (!resp || resp.status() >= 400) throw new Error(`HTTP ${resp && resp.status()}`);
        await tab.waitForTimeout(400);
        await tab.screenshot({ path: file, fullPage: Boolean(args.full) });
        results.push({ page, scheme, ok: true, file });
      } catch (e) {
        console.log(`FAIL ${page} ${scheme}: ${e.message}`);
        results.push({ page, scheme, ok: false, error: e.message });
      }
    }
    await ctx.close();
  }

  await browser.close();
  server.close();

  const ok = results.filter((r) => r.ok).length;
  console.log(`\n${ok}/${results.length} captured into ${args.out}/`);

  // A light and dark capture that are byte-identical mean the page rendered one
  // theme twice. Reported here because a reviewer looking at the images would
  // see two plausible screenshots and notice nothing — but the real check for
  // this is check-rendered-design.js, which compares computed colour and does
  // not need the images at all.
  const identical = [];
  for (const page of args.pages) {
    const l = path.join(args.out, `${slug(page)}__light.png`);
    const d = path.join(args.out, `${slug(page)}__dark.png`);
    if (fs.existsSync(l) && fs.existsSync(d) && fs.readFileSync(l).equals(fs.readFileSync(d))) {
      identical.push(page);
    }
  }
  if (identical.length) {
    console.log(`\n${identical.length} light/dark pair(s) are byte-identical:`);
    for (const p of identical) console.log(`  ${p}`);
    console.log("The theme toggle is not switching. Run check-rendered-design.js for the detail.");
  }

  if (results.some((r) => !r.ok)) process.exitCode = 1;
})();
