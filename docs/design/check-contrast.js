#!/usr/bin/env node
// Verifies every foreground/background pair declared in tokens.json against
// WCAG 2.1 contrast minimums, in both themes. Exits non-zero on any failure so
// it can gate CI. Run after any colour change in tokens.css.
const fs = require("fs");
const path = require("path");

const tokens = JSON.parse(fs.readFileSync(path.join(__dirname, "tokens.json"), "utf8"));

function channel(v) {
  const c = v / 255;
  return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

function luminance(hex) {
  const m = /^#?([0-9a-f]{6})$/i.exec(hex.trim());
  if (!m) throw new Error(`not a 6-digit hex colour: ${hex}`);
  const n = parseInt(m[1], 16);
  return (
    0.2126 * channel((n >> 16) & 255) +
    0.7152 * channel((n >> 8) & 255) +
    0.0722 * channel(n & 255)
  );
}

function contrast(a, b) {
  const la = luminance(a);
  const lb = luminance(b);
  const [hi, lo] = la > lb ? [la, lb] : [lb, la];
  return (hi + 0.05) / (lo + 0.05);
}

let failures = 0;
const rows = [];

for (const [themeName, theme] of Object.entries(tokens.themes)) {
  for (const pair of tokens.contrastPairs) {
    const fg = theme[pair.fg];
    const bg = theme[pair.bg];
    if (!fg || !bg) {
      console.error(`missing token in ${themeName}: ${pair.fg} or ${pair.bg}`);
      failures++;
      continue;
    }
    const ratio = contrast(fg, bg);
    const pass = ratio >= pair.min;
    if (!pass) failures++;
    rows.push({
      theme: themeName,
      role: pair.role,
      pair: `${pair.fg} on ${pair.bg}`,
      ratio: ratio.toFixed(2),
      min: pair.min.toFixed(1),
      status: pass ? "pass" : "FAIL",
    });
  }
}

const w = (s, n) => String(s).padEnd(n);
console.log(
  w("theme", 6) + w("role", 22) + w("pair", 26) + w("ratio", 8) + w("min", 6) + "status"
);
console.log("-".repeat(74));
for (const r of rows) {
  console.log(
    w(r.theme, 6) + w(r.role, 22) + w(r.pair, 26) + w(r.ratio, 8) + w(r.min, 6) + r.status
  );
}
console.log("-".repeat(74));
console.log(`${rows.length - failures}/${rows.length} pairs pass`);

if (failures > 0) {
  console.error(`\n${failures} contrast failure(s). Fix tokens.css and tokens.json together.`);
  process.exit(1);
}
