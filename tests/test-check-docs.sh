#!/usr/bin/env bash
# Exercises what tools/check-docs.py claims to fail, in both directions.
#
# Each case builds a small docs tree in a temporary directory, valid except for
# the thing under test. A failing case asserts the exit status, the message and
# that it's the only problem, so a page failing for some other reason can't
# pass as the check working. Nothing here is committed Markdown, so the
# repository-wide checks have no fixture of this test's to report.
#
# Backticks in single quotes here are Markdown code, not command substitution.
# shellcheck disable=SC2016
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
checker="$root/tools/check-docs.py"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
status=0
n=0
checker_override=""

# A fresh, empty tree for the next case.
tree() { n=$((n + 1)); tree="$work/case$n"; mkdir -p "$tree"; }

# page FILE TYPE [FRONT-MATTER LINE...]: a page titled Probe, body from stdin.
# A later line overrides an earlier key, as `status:` does for an ADR.
page() {
  local file="$1" type="$2" line
  shift 2
  mkdir -p "$(dirname "$file")"
  {
    printf -- '---\ntitle: Probe\ntype: %s\nstatus: active\nupdated: 2026-01-01\n' "$type"
    for line in "$@"; do echo "$line"; done
    printf -- '---\n\n# Probe\n\n'
    cat
  } >"$file"
}

# expect NAME EXIT [MESSAGE]: run the checker on $tree. With exit 1, MESSAGE
# must appear and be the only problem.
expect() {
  local name="$1" want="$2" msg="${3:-}" rc=0
  python3 "${checker_override:-$checker}" "$tree" >"$work/out" 2>&1 || rc=$?
  if [[ $rc -ne $want ]]; then
    echo "  FAIL: $name: expected exit $want, got $rc"
  elif [[ -n "$msg" ]] && ! grep -qF -- "$msg" "$work/out"; then
    echo "  FAIL: $name: no \"$msg\" in the output"
  elif [[ $want -eq 1 ]] && ! grep -q ' 1 problem(s)$' "$work/out"; then
    echo "  FAIL: $name: more than the one problem under test"
  else
    echo "  ok: $name"
    return 0
  fi
  sed 's/^/    /' "$work/out"
  status=1
}

adr() { # adr FILE ID [FRONT-MATTER LINE...]: a complete ADR, body optional on stdin
  local file="$1" id="$2"
  shift 2
  { cat; printf '## Context and problem statement\n\nx\n\n## Decision drivers\n\nx\n\n'
    printf '## Considered options\n\nx\n\n## Decision outcome\n\nx\n\n## Consequences\n\nx\n'
  } | page "$file" adr "id: $id" "status: accepted" "date: 2026-01-01" "deciders: [owner]" "$@"
}

incident_body() {
  local s
  for s in "Overview" "Impact and scope" "Timeline" "Technical findings" "Root cause analysis" \
           "Resolution and recovery" "Corrective and preventive actions" "Lessons learned" \
           "Monitoring plan" "Open questions" "Appendix: evidence" \
           "Appendix: investigation walkthrough"; do
    printf '## %s\n\nNothing here.\n\n' "$s"
  done
}

echo "the vendor exclusion is this repository's docs/prose/vendor/, nothing else"
tree; mkdir -p "$tree/team/vendor"; printf '# Notes\n' >"$tree/team/vendor/notes.md"
expect "a page under another vendor/ directory is checked" 1 "no front matter"
tree="$root/docs"
expect "this repository's docs/prose/vendor/ is still skipped" 0
tree; consumer="$tree"
mkdir -p "$consumer/.standards/tools" "$consumer/docs/prose/vendor"
cp "$checker" "$consumer/.standards/tools/"
printf '# Pasted\n' >"$consumer/docs/prose/vendor/pasted.md"
checker_override="$consumer/.standards/tools/check-docs.py"; tree="$consumer/docs"
expect "a vendored copy checks the consumer's own docs/prose/vendor/" 1 "no front matter"
checker_override=""

echo "a tree with nothing to check is an error"
tree
expect "an empty directory" 2 "no Markdown pages to check"
tree; echo "not a page" >"$tree/notes.txt"
expect "a directory with no Markdown" 2 "no Markdown pages to check"

echo "ADRs: required sections, and supersedes naming an ADR that exists"
tree; adr "$tree/adr/0001-probe.md" ADR-0001 "supersedes: null" </dev/null
expect "a complete ADR" 0
tree; printf '## Context and problem statement\n\nx\n\n## Decision drivers\n\nx\n\n## Considered options\n\nx\n\n## Decision outcome\n\nx\n\n### Consequences\n\nx\n' \
  | page "$tree/adr/0001-probe.md" adr "id: ADR-0001" "status: accepted" "date: 2026-01-01" "deciders: [owner]"
expect "MADR's layout, Consequences under Decision outcome" 0
tree; printf '## Context and problem statement\n\nx\n\n## Considered options\n\nx\n\n## Decision outcome\n\nx\n\n## Consequences\n\nx\n' \
  | page "$tree/adr/0001-probe.md" adr "id: ADR-0001" "status: accepted" "date: 2026-01-01" "deciders: [owner]"
expect "an ADR without Decision drivers" 1 "ADR missing required section: decision drivers"
tree; printf '```markdown\n## Decision drivers\n```\n\n## Context and problem statement\n\nx\n\n## Considered options\n\nx\n\n## Decision outcome\n\nx\n\n## Consequences\n\nx\n' \
  | page "$tree/adr/0001-probe.md" adr "id: ADR-0001" "status: accepted" "date: 2026-01-01" "deciders: [owner]"
expect "a section heading inside a code fence doesn't count" 1 "ADR missing required section: decision drivers"
tree
adr "$tree/adr/0001-probe.md" ADR-0001 "status: superseded" "superseded_by: ADR-0002" </dev/null
adr "$tree/adr/0002-probe.md" ADR-0002 "supersedes: ADR-0001" </dev/null
expect "supersedes naming an ADR that exists" 0
tree; adr "$tree/adr/0001-probe.md" ADR-0001 "supersedes: ADR-0042" </dev/null
expect "supersedes naming no ADR" 1 "supersedes 'ADR-0042' names no ADR in this tree"

echo "severity_ui: an incident, a how-to tagged runbook, a reference page tagged status"
tree; incident_body | page "$tree/probe.md" incident "services: [service-a]" "severity: low" \
  "window: 2026-01-01" "data_loss: false" "severity_ui: true"
expect "on an incident" 0
tree; page "$tree/probe.md" how-to "tags: [backup, runbook]" "severity_ui: true" </dev/null
expect "on a how-to tagged runbook" 0
tree; page "$tree/probe.md" how-to "tags:" "  - backup" "  - runbook" "severity_ui: true" </dev/null
expect "on a how-to tagged runbook in a block list" 0
tree; page "$tree/probe.md" how-to "tags:" "- runbook" "severity_ui: true" </dev/null
expect "on a how-to tagged runbook in an unindented block list" 0
tree; page "$tree/probe.md" how-to "tags: [backup]" "severity_ui: true" </dev/null
expect "on a how-to not tagged runbook" 1 \
  "severity_ui on a how-to page requires \`runbook\` in tags; add it if this is a runbook, or remove severity_ui"
tree; page "$tree/probe.md" reference "tags: [status]" "severity_ui: true" </dev/null
expect "on a reference page tagged status" 0
tree; page "$tree/probe.md" reference "severity_ui: true" </dev/null
expect "on a reference page not tagged status" 1 \
  "severity_ui on a reference page requires \`status\` in tags; add it if this is a status page, or remove severity_ui"
tree; page "$tree/probe.md" explanation "tags: [runbook, status]" "severity_ui: true" </dev/null
expect "on an explanation, whatever its tags" 1 "not on 'explanation'; remove severity_ui"
tree; page "$tree/probe.md" reference "severity_ui: yes" </dev/null
expect "set to yes" 1 "severity_ui 'yes' must be true or false"
tree; page "$tree/probe.md" reference "tags: [status]" "severity_ui: false" </dev/null
expect "set to false" 0
tree; printf '<div data-severity-ui>Degraded</div>\n' | page "$tree/probe.md" reference
expect "data-severity-ui in the body without the flag" 1 "data-severity-ui in the page needs severity_ui: true"
tree; printf 'The attribute is `data-severity-ui`.\n' | page "$tree/probe.md" reference
expect "data-severity-ui in a code span" 0

exit $status
