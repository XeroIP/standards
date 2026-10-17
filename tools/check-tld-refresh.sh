#!/usr/bin/env bash
# The checks refresh-tld-list.yml runs on a refreshed suffix list, and the
# table of their results that goes into the pull request body.
#
# Usage: check-tld-refresh.sh [CHECK...]
#   Each CHECK is a command line, split on spaces and run from the current
#   directory. With none, the four checks the workflow names run. Reads
#   fetch.txt, writes body.md, and appends failed=0 or failed=1 to
#   $GITHUB_OUTPUT. It exits 0 whatever the checks did, so the pull request
#   step runs; the job fails afterwards, on failed=1.
set -uo pipefail
failed=0
{
  echo "Opened by \`.github/workflows/refresh-tld-list.yml\`, run ${GITHUB_RUN_ID}."
  echo
  echo '```'
  cat fetch.txt
  echo '```'
  echo
  echo "| check | result |"
  echo "| --- | --- |"
} > body.md
if [ $# -eq 0 ]; then
  set -- "python3 tools/update-tlds.py --check" \
         "python3 tools/build-leakage-gaps.py --check" \
         "bash tests/test-leakage.sh" \
         "python3 tools/check-leakage.py"
fi
for check in "$@"; do
  # `|| rc=$?`, not a bare `$?` after the command: the runner's shell is
  # `bash -e`, and the first failing check would end the step before it wrote
  # its row or set failed=1.
  rc=0
  $check > out.txt 2>&1 || rc=$?
  if [ $rc -eq 0 ]; then result="pass"; else result="**fail** (exit $rc)"; failed=1; fi
  echo "| \`$check\` | $result |" >> body.md
  echo "::group::$check (exit $rc)"; cat out.txt; echo "::endgroup::"
done
rm -f out.txt fetch.txt
echo "failed=$failed" >> "$GITHUB_OUTPUT"
