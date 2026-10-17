#!/usr/bin/env bash
# Exercises tools/check-tld-refresh.sh, the step of refresh-tld-list.yml that
# checks a refreshed suffix list and writes the results into the pull request
# body.
#
# The workflow's shell is `bash -e`, and the step's own comment says the pull
# request is opened first and the job fails afterwards. That only holds if a
# failing check still gets its row and the step still reaches the end, so the
# case here is a failing check in the middle of passing ones, run under the
# same shell the runner uses.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
script="$root/tools/check-tld-refresh.sh"
status=0

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

printf 'echo first\n' >"$work/ok1.sh"
printf 'echo second\n' >"$work/ok2.sh"
printf 'echo boom\nexit 3\n' >"$work/bad.sh"

# run NAME CHECK...: the step in a scratch directory, as the runner shell runs it
run() {
  local name="$1"
  shift
  rm -f "$work/body.md" "$work/gh-output" "$work/log"
  : >"$work/gh-output"
  printf 'Added 1 suffix.\n' >"$work/fetch.txt"
  rc=0
  (cd "$work" && GITHUB_RUN_ID=999 GITHUB_OUTPUT="$work/gh-output" \
    bash --noprofile --norc -e "$script" "$@") >"$work/log" 2>&1 || rc=$?
  echo "$name"
}

fail() { echo "  FAIL: $1"; sed 's/^/    /' "$work/log"; status=1; }

run "a failing check in the middle still gets its row, and the later checks still run" \
  "bash ok1.sh" "bash bad.sh" "bash ok2.sh"
if [[ $rc -ne 0 ]]; then
  fail "the step exited $rc; it has to reach the pull request step"
elif ! grep -qx 'failed=1' "$work/gh-output"; then
  fail "failed=1 was not written, so the job would not fail afterwards"
elif ! grep -qF "| \`bash bad.sh\` | **fail** (exit 3) |" "$work/body.md"; then
  fail "no failure row for the failing check"
elif ! grep -qF "| \`bash ok2.sh\` | pass |" "$work/body.md"; then
  fail "the check after the failing one did not run"
elif ! grep -qF '::group::bash bad.sh (exit 3)' "$work/log" || ! grep -qx 'boom' "$work/log"; then
  fail "the failing check's output is not in the log"
else
  echo "  ok"
fi

run "all checks passing writes failed=0 and no failure row" "bash ok1.sh" "bash ok2.sh"
if [[ $rc -ne 0 ]]; then
  fail "the step exited $rc"
elif ! grep -qx 'failed=0' "$work/gh-output"; then
  fail "failed=0 was not written"
elif grep -qF '**fail**' "$work/body.md"; then
  fail "a failure row for passing checks"
else
  echo "  ok"
fi

exit $status
