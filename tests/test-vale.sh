#!/usr/bin/env bash
# Every frequency cap counts across the whole page.
#
# The caps used Vale's `text` scope, which counts each block on its own: a
# capped term once in each of three paragraphs never reached a cap of two, and
# the prose README's "Vale counts per file" was false with nothing to show it.
# This runs the committed .vale.ini and styles on pages built here, so the test
# keeps no Markdown of its own for the repository-wide lint to report.
#
# VALE names the binary. CI points it at the one vale-action installed for the
# Prose step, so a Vale release that changes how a scope counts fails here.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
vale="${VALE:-vale}"
if ! command -v "$vale" >/dev/null 2>&1; then
  echo "error: no Vale binary at '$vale'. Set VALE, or put vale on PATH." >&2
  exit 2
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
status=0

# A paragraph opener for each cap rule. A cap rule with no sample fails below,
# so a new cap can't arrive untested. A case, not an associative array, so the
# bash 3.2 that macOS ships runs it.
sample() {
  case "$1" in
    L2) echo "In summary, this is paragraph" ;;
    L3) echo "Moreover, this is paragraph" ;;
    L4) echo "We leverage paragraph" ;;
    L7) echo "It is not only one thing but also paragraph" ;;
    L11) echo "Fundamentally, this is paragraph" ;;
    *) return 1 ;;
  esac
}

# A page holding the rule's sample once in each of $2 paragraphs.
page() {
  local out="$work/$1-$2.md" opener i
  opener="$(sample "$1")"
  { echo "# Cap"; for ((i = 1; i <= $2; i++)); do printf '\n%s %d.\n' "$opener" "$i"; done; } >"$out"
  echo "$out"
}

# Vale's findings for a page. Exit 1 only means it found an error-level rule;
# exit 2 means it didn't run, and an empty result would then pass as clean.
# Call it outside a pipeline, or its exit leaves only the subshell.
lint() {
  local rc=0
  "$vale" --config="$root/.vale.ini" --output=line "$1" >"$work/out" 2>&1 || rc=$?
  if [[ $rc -gt 1 ]]; then
    echo "error: vale exited $rc on $1:" >&2
    sed 's/^/    /' "$work/out" >&2
    exit 2
  fi
  cat "$work/out"
}

caps=$(grep -l '^extends: occurrence' "$root"/styles/XeroIP/*.yml | sed 's|.*/||; s/\.yml$//' | sort || true)
if [[ -z "$caps" ]]; then
  echo "error: no cap rules in styles/XeroIP/" >&2
  exit 2
fi

for id in $caps; do
  echo "$id: at the cap passes, one paragraph over it is reported"
  if ! sample "$id" >/dev/null; then
    echo "  FAIL: no sample for $id in this test"
    status=1
    continue
  fi
  max=$(sed -n 's/^max: *//p' "$root/styles/XeroIP/$id.yml")
  if ! [[ "$max" =~ ^[0-9]+$ ]]; then
    echo "error: styles/XeroIP/$id.yml has no numeric max:" >&2
    exit 2
  fi
  lint "$(page "$id" "$max")" >"$work/at.out"
  lint "$(page "$id" $((max + 1)))" >"$work/over.out"
  if grep -q "XeroIP\.$id:" "$work/at.out"; then
    echo "  FAIL: $max paragraphs, one use each, were reported at a cap of $max"
    status=1
  elif ! grep -q "XeroIP\.$id:" "$work/over.out"; then
    echo "  FAIL: $((max + 1)) paragraphs, one use each, passed a cap of $max"
    status=1
  else
    echo "  ok"
  fi
done

exit $status
