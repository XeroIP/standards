#!/usr/bin/env node
// Generates llms.txt from the docs/ tree.
//
// llms.txt (llmstxt.org) is a machine-readable index at the site root: a model
// handed only the URL can find every standard without crawling. It is generated
// from front matter for the same reason navigation is — a hand-maintained index
// drifts, and an index that lies is worse than no index.
//
// Usage:
//   node tools/build-llms-txt.js          write llms.txt
//   node tools/build-llms-txt.js --check  exit 1 if it is out of date

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const DOCS = path.join(ROOT, "docs");
const OUT = path.join(ROOT, "llms.txt");
const BASE = "https://xeroip.github.io/standards";

// Front matter only; the body is never parsed. Values are scalars or inline
// lists, which is all the schema in docs/documentation/front-matter.md allows.
function frontMatter(text) {
  const m = /^---\n([\s\S]*?)\n---/.exec(text);
  if (!m) return null;
  const out = {};
  for (const line of m[1].split("\n")) {
    const kv = /^([\w_]+):\s*(.*)$/.exec(line);
    if (!kv) continue;
    let [, key, value] = kv;
    value = value.trim().replace(/^['"]|['"]$/g, "");
    if (value.startsWith("[")) {
      value = value.slice(1, value.lastIndexOf("]")).split(",")
        .map((s) => s.trim().replace(/^['"]|['"]$/g, "")).filter(Boolean);
    }
    out[key] = value;
  }
  return out;
}

function walk(dir) {
  const found = [];
  for (const name of fs.readdirSync(dir).sort()) {
    const p = path.join(dir, name);
    if (fs.statSync(p).isDirectory()) { found.push(...walk(p)); continue; }
    if (!name.endsWith(".md")) continue;
    const text = fs.readFileSync(p, "utf8");
    const fm = frontMatter(text);
    if (!fm || !fm.title) continue;
    found.push({ path: path.relative(ROOT, p), fm });
  }
  return found;
}

const AREAS = [
  ["docs/documentation", "Documentation"],
  ["docs/prose", "Prose"],
  ["docs/coding", "Coding"],
  ["docs/design", "Design"],
  ["docs/diagrams", "Diagrams"],
  ["docs/observability", "Observability"],
  ["docs/adr", "Decision records"],
];

const pages = walk(DOCS);

const lines = [];
lines.push("# XeroIP engineering standards");
lines.push("");
lines.push("> Shared standards for documentation, prose, code, design, and diagrams across");
lines.push("> every XeroIP repository. Markdown throughout, so the source is the same text a");
lines.push("> model reads. Each area's README is the entry point; the pages under it are the");
lines.push("> rules and name what enforces them.");
lines.push("");
lines.push("This file is generated from front matter by tools/build-llms-txt.js.");

for (const [prefix, heading] of AREAS) {
  const inArea = pages.filter((p) => p.path.startsWith(prefix + "/"));
  if (!inArea.length) continue;
  // README first, then the rest alphabetically.
  inArea.sort((a, b) => {
    const ar = a.path.endsWith("README.md") ? 0 : 1;
    const br = b.path.endsWith("README.md") ? 0 : 1;
    return ar - br || a.path.localeCompare(b.path);
  });
  lines.push("");
  lines.push(`## ${heading}`);
  lines.push("");
  for (const { path: rel, fm } of inArea) {
    const url = `${BASE}/${rel.replace(/\.md$/, "").replace(/\/README$/, "/")}`;
    const summary = fm.summary || "";
    const draft = fm.status === "draft" ? " *(draft)*" : "";
    lines.push(`- [${fm.title}](${url})${draft}${summary ? `: ${summary}` : ""}`);
  }
}

lines.push("");
lines.push("## Optional");
lines.push("");
lines.push(`- [AGENTS.md](${BASE}/AGENTS.md): instructions for agents working in the standards repo itself.`);
lines.push(`- [rules.yml](${BASE}/docs/prose/rules.yml): the prose markers in machine-readable form, with tier and marker id.`);
lines.push(`- [tokens.json](${BASE}/docs/design/tokens.json): design tokens, the source every adapter is generated from.`);
lines.push("");

const content = lines.join("\n");

if (process.argv.includes("--check")) {
  const existing = fs.existsSync(OUT) ? fs.readFileSync(OUT, "utf8") : null;
  if (existing !== content) {
    console.error("stale: llms.txt. Run: node tools/build-llms-txt.js");
    process.exit(1);
  }
  console.log("llms.txt is up to date");
} else {
  fs.writeFileSync(OUT, content);
  console.log(`wrote llms.txt — ${pages.length} pages indexed across ${AREAS.length} areas`);
}
