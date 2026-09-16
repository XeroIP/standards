#!/usr/bin/env node
// Generates CLAUDE.md and .github/copilot-instructions.md from AGENTS.md.
//
// AGENTS.md is the cross-vendor convention and the only file anyone edits. The
// two generated files exist because vendor tooling looks for its own filename
// and would otherwise read nothing. They are byte-identical to AGENTS.md apart
// from a header saying so.
//
// The alternative — a pointer file saying "see CLAUDE.md" — was rejected because
// it privileges one vendor and costs every other tool an indirection it may not
// follow. Duplication is fine when it is generated and CI proves it has not drifted.
//
// Usage:
//   node tools/build-agent-files.js          write the files
//   node tools/build-agent-files.js --check  exit 1 if they are out of date

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const SOURCE = path.join(ROOT, "AGENTS.md");

const TARGETS = [
  {
    file: "CLAUDE.md",
    header: [
      "<!-- GENERATED from AGENTS.md by tools/build-agent-files.js. Do not edit.",
      "     Change AGENTS.md and re-run the generator; CI fails if these drift. -->",
      "",
      "> Claude Code reads this file. It is a copy of `AGENTS.md`, which is the source",
      "> of truth for every agent working in this repository.",
    ],
  },
  {
    file: path.join(".github", "copilot-instructions.md"),
    header: [
      "<!-- GENERATED from AGENTS.md by tools/build-agent-files.js. Do not edit.",
      "     Change AGENTS.md and re-run the generator; CI fails if these drift. -->",
      "",
      "> GitHub Copilot reads this file. It is a copy of `AGENTS.md`, which is the source",
      "> of truth for every agent working in this repository.",
    ],
  },
];

if (!fs.existsSync(SOURCE)) {
  console.error("AGENTS.md not found — nothing to generate from.");
  process.exit(1);
}

const source = fs.readFileSync(SOURCE, "utf8");
// Drop the source's own H1; each generated file gets its own title line so the
// vendor note sits above the content rather than interrupting it.
const body = source.replace(/^#\s+AGENTS\.md\s*\n+/, "");

const check = process.argv.includes("--check");
let stale = 0;

for (const target of TARGETS) {
  const out = path.join(ROOT, target.file);
  const content = `# Repository instructions\n\n${target.header.join("\n")}\n\n${body}`;
  const existing = fs.existsSync(out) ? fs.readFileSync(out, "utf8") : null;

  if (check) {
    if (existing !== content) {
      console.error(`stale: ${target.file}`);
      stale++;
    }
    continue;
  }

  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, content);
  console.log(`wrote ${target.file} (${content.split("\n").length} lines)`);
}

if (check) {
  if (stale) {
    console.error(`\n${stale} generated file(s) out of date. Run: node tools/build-agent-files.js`);
    process.exit(1);
  }
  console.log(`${TARGETS.length} generated agent file(s) match AGENTS.md`);
}
