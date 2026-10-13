#!/usr/bin/env bash
# Exercises tools/build-incident-starter.py in a scratch tree.
#
# The starter claims to be generated from INCIDENT_SECTIONS, and --check claims to
# fail when it isn't. This runs the generator on a copy of the two tools, so the
# starter it writes and checks is the scratch tree's, never the committed one. Each
# case asserts the exit status and the message, so a run failing for some other
# reason can't pass as the check working.
set -euo pipefail

# The cases below edit a copy of check-docs.py without changing its size, inside one
# second. Python would reuse the bytecode it cached from the unedited file.
export PYTHONDONTWRITEBYTECODE=1

root="$(git rev-parse --show-toplevel)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
status=0
committed="$root/docs/documentation/templates/incident.md"

# A fresh tree holding the generator and the checker it imports. Both resolve the
# starter from their own location, so it lands inside this tree.
fresh() {
  rm -rf "$work/tree"
  mkdir -p "$work/tree/tools"
  cp "$root/tools/build-incident-starter.py" "$root/tools/check-docs.py" "$work/tree/tools/"
  starter="$work/tree/docs/documentation/templates/incident.md"
}
gen() { python3 "$work/tree/tools/build-incident-starter.py" "$@" >"$work/out" 2>&1; }

# expect NAME EXIT MESSAGE ARG...: run the generator with ARG...
expect() {
  local name="$1" want="$2" msg="$3" rc=0
  shift 3
  gen "$@" || rc=$?
  if [[ $rc -ne $want ]]; then
    echo "  FAIL: $name: expected exit $want, got $rc"
  elif [[ -n "$msg" ]] && ! grep -qF -- "$msg" "$work/out"; then
    echo "  FAIL: $name: no \"$msg\" in the output"
  else
    echo "  ok: $name"
    return 0
  fi
  sed 's/^/    /' "$work/out"
  status=1
}

check() { # check NAME CONDITION...: a plain assertion
  local name="$1"
  shift
  if "$@"; then echo "  ok: $name"; else echo "  FAIL: $name"; status=1; fi
}

echo "--check on a missing file, a stale one and a fresh one"
fresh
expect "a missing starter fails" 1 "incident.md is missing" --check
check "--check writes nothing" test ! -e "$starter"
expect "writing creates it" 0 "wrote docs/documentation/templates/incident.md"
check "what it writes is the committed starter" cmp -s "$starter" "$committed"
expect "a fresh starter passes" 0 "matches INCIDENT_SECTIONS" --check
printf 'An extra line.\n' >>"$starter"
expect "a starter with an added line fails" 1 "differs from what INCIDENT_SECTIONS" --check
expect "rewriting repairs it" 0 "wrote"
expect "and it passes again" 0 "matches INCIDENT_SECTIONS" --check
sed 's/^## Timeline$/## Chronology/' "$starter" >"$work/edited"
cp "$work/edited" "$starter"
expect "a starter with an edited heading fails" 1 "differs from what INCIDENT_SECTIONS" --check
check "a failed --check leaves the edit alone" grep -q '^## Chronology$' "$starter"
: >"$starter"
expect "an empty starter fails" 1 "differs from what INCIDENT_SECTIONS" --check

echo "the list in check-docs.py is the only source"
fresh
gen
sed 's/"timeline", "technical findings",/"technical findings", "timeline",/' \
  "$work/tree/tools/check-docs.py" >"$work/edited"
cp "$work/edited" "$work/tree/tools/check-docs.py"
expect "reordering the list makes the committed starter stale" 1 "differs from what INCIDENT_SECTIONS" --check
expect "and regenerating follows the new order" 0 "wrote"
check "the starter now has Technical findings before Timeline" bash -c \
  "grep -n '^## ' '$starter' | grep -A1 'Technical findings' | grep -q 'Timeline'"

echo "a section and its hint have to appear together"
fresh
sed 's/"overview", "impact and scope",/"overview", "a new section", "impact and scope",/' \
  "$work/tree/tools/check-docs.py" >"$work/edited"
cp "$work/edited" "$work/tree/tools/check-docs.py"
expect "a section with no hint stops the generator" 2 "has 'a new section', and HINTS"
check "and writes nothing" test ! -e "$starter"
fresh
sed 's/"monitoring plan", //' "$work/tree/tools/check-docs.py" >"$work/edited"
cp "$work/edited" "$work/tree/tools/check-docs.py"
expect "a hint for a removed section stops it too" 2 "has 'monitoring plan', which is not in INCIDENT_SECTIONS"

exit $status
