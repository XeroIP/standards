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

exit $status
