#!/usr/bin/env bash
# Exercises both directions of tools/check-leakage.py.
#
# The negative case matters more than the positive one. The scanner this
# replaced was never tested against a real leak, and the version before this
# reported 300+ false positives on its first run — both failures a fixture
# would have caught immediately.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
checker="$root/tools/check-leakage.py"
fixtures="$root/tests/fixtures/leakage"
status=0

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Each finding line reads `path:line: value  — class`. Counting anything else
# counted the help text, which also contains a dash.
findings() { grep -E '^[^ ]+:[0-9]+: ' || true; }

echo "leaks.md must be reported, every line and every class"
rc=0
python3 "$checker" --paths "$fixtures/leaks.md" >"$work/leaks.out" 2>&1 || rc=$?
if [[ $rc -ne 1 ]]; then
  echo "  FAIL: expected exit 1, got $rc"
  status=1
else
  # A total can hide a dead class behind a live one: six domain findings and no
  # CIDR finding still counts to six. So every value line is checked by number,
  # and every class by name.
  before=$status
  want=$(awk '/-->/ { body = 1; next } body && NF { print NR }' "$fixtures/leaks.md")
  got=$(findings <"$work/leaks.out" | cut -d: -f2 | sort -nu)
  missing=$(comm -23 <(sort <<<"$want") <(sort <<<"$got"))
  if [[ -n "$missing" ]]; then
    echo "  FAIL: lines not reported: $(tr '\n' ' ' <<<"$missing")"
    status=1
  fi
  for class in "host address outside" "CIDR not in" "domain not in" "credential shape"; do
    if ! findings <"$work/leaks.out" | grep -q -- "— $class"; then
      echo "  FAIL: no finding of class '$class'"
      status=1
    fi
  done
  if [[ $status -eq $before ]]; then
    echo "  ok: $(findings <"$work/leaks.out" | wc -l) findings on $(wc -l <<<"$want") lines"
  fi
fi

echo "clean.md must not be reported"
if python3 "$checker" --paths "$fixtures/clean.md" >/dev/null 2>&1; then
  echo "  ok"
else
  echo "  FAIL: false positives on the clean fixture:"
  python3 "$checker" --paths "$fixtures/clean.md" 2>&1 | sed 's/^/    /'
  status=1
fi

# --allowlist-extra is additive, not a replacement. A repo pointing --allowlist
# at its own file would drop every shared entry, so a repo could weaken the
# common rules by declaring one of its own. Both directions are asserted here
# because the additive half passing says nothing about the shared half
# surviving. (--private is the opposite mechanism: values to report, not permit.)
echo "--allowlist-extra permits its own values and keeps the shared ones"
# The values live in tests/fixtures/, which the repo-wide scan skips, so this
# script does not itself carry leak-shaped strings that the scanner then reports.
extra="$root/tests/fixtures/allowlist-extra"
if python3 "$checker" --paths "$extra/own.md" >/dev/null 2>&1; then
  echo "  FAIL: the value was not reported without the supplement"
  status=1
elif ! python3 "$checker" --paths "$extra/own.md" \
       --allowlist-extra "$extra/allow.txt" >/dev/null 2>&1; then
  echo "  FAIL: the supplement did not permit its own value"
  status=1
elif python3 "$checker" --paths "$extra/other.md" \
       --allowlist-extra "$extra/allow.txt" >/dev/null 2>&1; then
  echo "  FAIL: the supplement suppressed an unrelated value"
  status=1
else
  echo "  ok"
fi

# An entry permits itself and the hosts under it, never its siblings. The rule
# this replaced compared the last two labels, so listing one host under a
# shared suffix permitted every other host under it.
echo "an allowlisted host permits its subdomains, not its siblings"
if ! python3 "$checker" --paths "$extra/subdomain.md" \
       --allowlist-extra "$extra/allow.txt" >/dev/null 2>&1; then
  echo "  FAIL: a subdomain of the permitted host was reported"
  status=1
elif python3 "$checker" --paths "$extra/sibling.md" \
       --allowlist-extra "$extra/allow.txt" >/dev/null 2>&1; then
  echo "  FAIL: a sibling of the permitted host was allowed"
  status=1
else
  echo "  ok"
fi

# A consuming repository runs the vendored copy at .standards/tools/. The scan
# must cover that repository's own files; resolving it from the script's
# location read only .standards/ and passed whatever sat beside it.
#
# The same repository checks the fixture exclusion, which is a path prefix from
# the root. A substring match also skipped any path that merely contained it.
echo "a vendored copy scans the consuming repository, and skips only the fixture prefix"
consumer="$work/consumer"
mkdir -p "$consumer/.standards/tools" "$consumer/notes/tests/fixtures-old" \
  "$consumer/tests/fixtures/leakage"
cp "$checker" "$root/tools/allowlist.txt" "$root/tools/iana-tlds.txt" \
  "$consumer/.standards/tools/"
cp "$fixtures/leaks.md" "$consumer/probe.md"
cp "$fixtures/leaks.md" "$consumer/notes/tests/fixtures-old/probe.md"
cp "$fixtures/leaks.md" "$consumer/tests/fixtures/leakage/probe.md"
git -C "$consumer" init -q
git -C "$consumer" add -A
rc=0
(cd "$consumer" && python3 .standards/tools/check-leakage.py) >"$work/consumer.out" 2>&1 || rc=$?
reported() { findings <"$work/consumer.out" | grep -q "^$1:"; }
if [[ $rc -ne 1 ]]; then
  echo "  FAIL: expected exit 1, got $rc"
  sed 's/^/    /' "$work/consumer.out"
  status=1
elif ! reported "probe.md"; then
  echo "  FAIL: the consuming repository's own file was not scanned"
  status=1
elif ! reported "notes/tests/fixtures-old/probe.md"; then
  echo "  FAIL: a path containing the fixture directory was skipped"
  status=1
elif reported "tests/fixtures/leakage/probe.md"; then
  echo "  FAIL: the fixture directory was scanned"
  status=1
elif findings <"$work/consumer.out" | grep -v -e '^probe\.md:' -e '^notes/' | grep -q .; then
  echo "  FAIL: the vendored files reported themselves:"
  findings <"$work/consumer.out" | grep -v -e '^probe\.md:' -e '^notes/' | sed 's/^/    /'
  status=1
else
  echo "  ok"
fi

# The prose check reads IANA's suffix list from beside the scanner. Without it
# the scan must stop, not fall back to the short list and report clean.
echo "a missing suffix list is an error"
rm "$consumer/.standards/tools/iana-tlds.txt"
rc=0
(cd "$consumer" && python3 .standards/tools/check-leakage.py) >/dev/null 2>&1 || rc=$?
if [[ $rc -eq 2 ]]; then
  echo "  ok"
else
  echo "  FAIL: expected exit 2, got $rc"
  status=1
fi

echo "outside a git repository, with no paths, the scan is an error"
outside="$work/outside"
mkdir -p "$outside"
rc=0
(cd "$outside" && GIT_CEILING_DIRECTORIES="$work" python3 "$checker") >/dev/null 2>&1 || rc=$?
if [[ $rc -eq 2 ]]; then
  echo "  ok"
else
  echo "  FAIL: expected exit 2, got $rc"
  status=1
fi

exit $status
