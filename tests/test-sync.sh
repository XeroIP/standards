#!/usr/bin/env bash
# Exercises tools/sync-standards.py through real syncs into scratch consumers.
#
# A consumer-path test has to start from the sync's own output: the earlier
# check copied .standards/ into a tree by hand, and missed that the AGENTS.md
# the sync writes failed the docs gate the sync also ships. Each case below
# builds a consumer repository, syncs it, changes one thing, and asserts the
# exit status and the message.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
tool="$root/tools/sync-standards.py"
lint="$root/node_modules/.bin/markdownlint-cli2"
if [[ ! -x "$lint" ]]; then
  echo "error: $lint is missing. Run npm ci first." >&2
  exit 2
fi
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
status=0

# consumer NAME [SYNC-LINES...]: a git repository with a .standards.yml pinned
# to an old version, consent given, and any extra lines under `sync:`.
consumer() {
  local dir="$work/$1" line
  shift
  mkdir -p "$dir"
  git -C "$dir" init -q
  {
    echo "profile: docs-only"
    echo "standards_version: v0.0.1   # the pin, rewritten by the sync"
    echo "sync:"
    echo "  adopted: true"
    for line in "$@"; do echo "  $line"; done
  } >"$dir/.standards.yml"
  echo "$dir"
}

sync() { python3 "$tool" --target "$@" >"$work/out" 2>&1; }

# expect NAME EXIT [MESSAGE] COMMAND...
expect() {
  local name="$1" want="$2" msg="$3" rc=0
  shift 3
  "$@" || rc=$?
  if [[ $rc -eq $want ]] && { [[ -z "$msg" ]] || grep -qF -- "$msg" "$work/out"; }; then
    echo "  ok: $name"
  else
    echo "  FAIL: $name: expected exit $want${msg:+ and \"$msg\"}, got exit $rc"
    sed 's/^/    /' "$work/out"
    status=1
  fi
}

check() { # check NAME CONDITION...: a plain assertion
  local name="$1"
  shift
  if "$@"; then echo "  ok: $name"; else echo "  FAIL: $name"; status=1; fi
}

echo "the synced AGENTS.md has one H1, and the vendored markdownlint passes it"
c=$(consumer lint)
expect "a fresh sync" 0 "synced lint" sync "$c"
check "one H1 in AGENTS.md" test "$(grep -c '^# ' "$c/AGENTS.md")" -eq 1
expect "markdownlint with the vendored config" 0 "Summary: 0 issues" \
  bash -c "cd '$c' && '$lint' --config .standards/.markdownlint-cli2.jsonc >'$work/out' 2>&1"

echo "--check counts every change the next sync would make"
expect "right after a sync" 0 "is up to date" sync "$c" --check
echo "stray" >"$c/.standards/extra.md"
expect "a file under .standards/ the sync would delete" 1 "extra.md (not vendored: the next sync deletes it)" sync "$c" --check
sync "$c"
check "the sync deleted it" test ! -e "$c/.standards/extra.md"
echo "v9" >"$c/.standards/VERSION"
expect "an edited VERSION" 1 ".standards/VERSION" sync "$c" --check

echo "standards_version records the version vendored"
c=$(consumer pin)
grep -v '^standards_version:' "$c/.standards.yml" >"$work/pin-before"
sync "$c"
pinned=$(sed -n 's/^standards_version: *\([^ #]*\).*/\1/p' "$c/.standards.yml")
check "it equals .standards/VERSION" test "$pinned" = "$(cat "$c/.standards/VERSION")"
check "its comment is kept" grep -q '^standards_version: [^ ]*   # the pin, rewritten by the sync$' "$c/.standards.yml"
check "nothing else in the file changed" bash -c "grep -v '^standards_version:' '$c/.standards.yml' | cmp -s - '$work/pin-before'"
c=$(consumer unpinned)
sed -i.bak '/^standards_version:/d' "$c/.standards.yml"
sync "$c"
check "a missing line is appended" test "$(tail -n 1 "$c/.standards.yml")" = "standards_version: $(cat "$c/.standards/VERSION")"

echo "sync.protect keeps a path under .standards/ as it is"
c=$(consumer protect "protect: [docs/coding/bash.md]")
sync "$c"
echo "local note" >>"$c/.standards/docs/coding/bash.md"
expect "a re-sync names it" 0 ".standards/docs/coding/bash.md: sync.protect, kept as it is" sync "$c"
check "and keeps the edit" grep -q '^local note$' "$c/.standards/docs/coding/bash.md"
expect "--check doesn't count it" 0 "is up to date" sync "$c" --check
c=$(consumer escape "protect:" "  - ../outside")
expect "a path outside .standards/ is refused" 2 "must be a path inside .standards/" sync "$c"

region() { printf '\n<!-- shift-change:start %s -->\n## Project status\n\n%s\n<!-- shift-change:end -->\n' "$1" "$2"; }

echo "a generated file edited since the last sync is refused, outside declared regions"
c=$(consumer hash)
sync "$c"
check "the file carries its hash" grep -q '^<!-- sync-hash: sha256:[0-9a-f]\{64\} -->$' "$c/CLAUDE.md"
expect "unchanged, it re-syncs" 0 "synced hash" sync "$c"
echo "A note someone added." >>"$c/CLAUDE.md"
expect "an edit, no region declared" 3 "CLAUDE.md was edited outside the regions declared" sync "$c"

c=$(consumer undeclared)
sync "$c"
region v2 "The handoff lives in STATUS.md." >>"$c/CLAUDE.md"
expect "a region nobody declared" 3 "CLAUDE.md was edited outside the regions declared" sync "$c"

c=$(consumer declared "managed_regions: [shift-change]")
sync "$c"
expect "declared, not present" 0 "CLAUDE.md: managed region 'shift-change' declared but not present; whole-file hash applies" sync "$c"
region v2 "The handoff lives in STATUS.md." >>"$c/CLAUDE.md"
expect "declared, appended" 0 "CLAUDE.md: skipping managed region 'shift-change' at lines" sync "$c"
check "the report gives its coverage" grep -qE "at lines [0-9]+-[0-9]+ \(5 of [0-9]+ lines, [0-9]+%\)" "$work/out"
region v3 "Rewritten by a newer installer." >>"$c/CLAUDE.md"
expect "declared, refreshed to v3 with new text" 0 "skipping managed region 'shift-change'" sync "$c"
region v2 "The handoff lives in STATUS.md." >>"$c/CLAUDE.md"
echo "A note someone added." >>"$c/CLAUDE.md"
expect "declared, plus an edit outside it" 3 "CLAUDE.md was edited outside the regions declared" sync "$c" --check
sync "$c" --adopt
printf '\n<!-- shift-change:start v2 -->\n## Project status\n' >>"$c/CLAUDE.md"
expect "declared, never closed" 3 "CLAUDE.md was edited outside the regions declared" sync "$c"
sync "$c" --adopt
python3 - "$c/CLAUDE.md" <<'EOF'
import sys
path = sys.argv[1]
lines = open(path, encoding="utf-8").read().split("\n")
i = next(n for n, line in enumerate(lines) if line.startswith("Stacks:"))
region = ["", "<!-- shift-change:start v2 -->", "## Project status", "<!-- shift-change:end -->", ""]
lines[i:i] = region  # inside the header paragraph, with blank lines around it
open(path, "w", encoding="utf-8").write("\n".join(lines))
EOF
expect "declared, spliced into a paragraph" 3 "CLAUDE.md was edited outside the regions declared" sync "$c"

c=$(consumer tail "managed_regions: [shift-change]")
region v2 "The handoff lives in STATUS.md." >"$c/.standards-tail.md"
sync "$c"
expect "a declared region in the tail is generated text, and re-syncs" 0 "synced tail" sync "$c"

echo "a generated file from before the hash is refused once, then hashed"
c=$(consumer legacy)
sync "$c"
sed -i.bak '/^<!-- sync-hash: /d' "$c/CLAUDE.md"
expect "no hash line" 3 "carries the banner but no content hash" sync "$c"
expect "--adopt writes it" 0 "synced legacy" sync "$c" --adopt
check "and the file has one now" grep -q '^<!-- sync-hash: ' "$c/CLAUDE.md"

exit $status
