#!/usr/bin/env bash
# llms.txt points at the page Markdown until the site exists, and at the site
# from the build that creates it.
#
# The switch happens when mkdocs.yml appears, so nobody has to remember it. That
# can't be watched happen before the site exists, so this runs the generator on
# a copy of the tree with a made-up mkdocs.yml and checks what it writes.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
status=0
raw="https://raw.githubusercontent.com/XeroIP/standards/main/"
site="https://docs.example.org/standards"

copy() {
  rm -rf "$work/tree"
  mkdir -p "$work/tree/tools"
  cp "$root/tools/build-llms-txt.js" "$work/tree/tools/"
  cp -r "$root/docs" "$root/AGENTS.md" "$root/llms.txt" "$work/tree/"
}
gen() { node "$work/tree/tools/build-llms-txt.js" "$@" >"$work/out" 2>&1; }
urls() { grep -o 'https://[^)]*' "$work/tree/llms.txt"; }
check() { # check NAME CONDITION...: report ok or FAIL
  local name="$1"; shift
  if "$@"; then echo "  ok: $name"; else echo "  FAIL: $name"; sed 's/^/    /' "$work/out"; status=1; fi
}

echo "without mkdocs.yml, every entry is a file on main"
copy
gen
check "the committed llms.txt is what the generator writes" cmp -s "$root/llms.txt" "$work/tree/llms.txt"
check "every URL is a raw URL on main" bash -c "! grep -o 'https://[^)]*' '$work/tree/llms.txt' | grep -v '^$raw'"
missing=$(urls | sed "s|^$raw||" | while read -r f; do [ -e "$root/$f" ] || echo "$f"; done)
check "every URL names a file in the tree" test -z "$missing"
[ -z "$missing" ] || echo "    missing: $missing"

echo "with mkdocs.yml, entries follow its site_url"
copy
printf 'site_name: Standards\nsite_url: %s/  # trailing slash and comment\nmarkdown_extensions:\n  - pymdownx.emoji:\n      emoji_generator: !!python/name:material.extensions.emoji.to_svg\n' \
  "$site" >"$work/tree/mkdocs.yml"
rc=0; gen --check || rc=$?
check "--check fails until llms.txt is regenerated" test "$rc" -eq 1
gen
check "a README is its directory" grep -qF "($site/documentation/)" "$work/tree/llms.txt"
check "a page is a directory URL" grep -qF "($site/documentation/front-matter/)" "$work/tree/llms.txt"
check "a data file under docs/ is on the site" grep -qF "($site/prose/rules.yml)" "$work/tree/llms.txt"
check "AGENTS.md, outside docs/, stays on main" grep -qF "(${raw}AGENTS.md)" "$work/tree/llms.txt"
check "nothing else stays on main" test "$(urls | grep -c "^$raw")" -eq 1

echo "use_directory_urls: false gives .html pages"
copy
printf 'site_url: %s\nuse_directory_urls: false\n' "$site" >"$work/tree/mkdocs.yml"
gen
check "a page is a .html URL" grep -qF "($site/documentation/front-matter.html)" "$work/tree/llms.txt"

echo "mkdocs.yml without site_url is an error"
copy
printf 'site_name: Standards\n' >"$work/tree/mkdocs.yml"
rc=0; gen || rc=$?
check "exit 1, naming site_url" bash -c "test $rc -eq 1 && grep -q 'site_url' '$work/out'"
check "llms.txt is left alone" cmp -s "$root/llms.txt" "$work/tree/llms.txt"

exit $status
