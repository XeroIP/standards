#!/usr/bin/env bash
# Exercises both directions of tools/check-leakage.py.
#
# The negative case matters more than the positive one. The scanner this
# replaced was never tested against a real leak, and the version before this
# reported 300+ false positives on its first run — both failures a fixture
# would have caught immediately.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
fixtures="$root/tests/fixtures/leakage"
status=0

echo "leaks.md must be reported"
if python3 "$root/tools/check-leakage.py" --paths "$fixtures/leaks.md" >/dev/null 2>&1; then
  echo "  FAIL: the scanner passed a file full of leaks"
  status=1
else
  found=$(python3 "$root/tools/check-leakage.py" --paths "$fixtures/leaks.md" 2>/dev/null | grep -c ' — ' || true)
  if [[ "$found" -lt 6 ]]; then
    echo "  FAIL: expected at least 6 findings, got $found"
    status=1
  else
    echo "  ok: $found findings"
  fi
fi

echo "clean.md must not be reported"
if python3 "$root/tools/check-leakage.py" --paths "$fixtures/clean.md" >/dev/null 2>&1; then
  echo "  ok"
else
  echo "  FAIL: false positives on the clean fixture:"
  python3 "$root/tools/check-leakage.py" --paths "$fixtures/clean.md" 2>&1 | sed 's/^/    /'
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
if python3 "$root/tools/check-leakage.py" --paths "$extra/own.md" >/dev/null 2>&1; then
  echo "  FAIL: the value was not reported without the supplement"
  status=1
elif ! python3 "$root/tools/check-leakage.py" --paths "$extra/own.md" \
       --allowlist-extra "$extra/allow.txt" >/dev/null 2>&1; then
  echo "  FAIL: the supplement did not permit its own value"
  status=1
elif python3 "$root/tools/check-leakage.py" --paths "$extra/other.md" \
       --allowlist-extra "$extra/allow.txt" >/dev/null 2>&1; then
  echo "  FAIL: the supplement suppressed an unrelated value"
  status=1
else
  echo "  ok"
fi

exit $status
