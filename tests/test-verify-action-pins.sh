#!/usr/bin/env bash
# Exercises tools/verify-action-pins.sh against workflows it should fail.
#
# The repository's own pins all resolve, so running the verifier on this tree
# shows only the passing half. Each case below is a scratch repository with one
# workflow line, and asserts the exit status and the message. Needs network to
# github.com, as the verifier does.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
verifier="$root/tools/verify-action-pins.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
status=0

# v7.0.1 of actions/checkout, the release this repository pins.
sha=3d3c42e5aac5ba805825da76410c181273ba90b1

# expect NAME EXIT MESSAGE USES-LINE: a scratch repository whose one workflow
# carries USES-LINE, verified.
expect() {
  local name="$1" want="$2" msg="$3" line="$4" dir rc=0
  dir="$work/$(echo "$name" | tr -c 'a-z0-9' '-')"
  mkdir -p "$dir/.github/workflows"
  git -C "$dir" init -q
  printf 'jobs:\n  a:\n    steps:\n      - %s\n' "$line" >"$dir/.github/workflows/a.yml"
  (cd "$dir" && bash "$verifier") >"$work/out" 2>&1 || rc=$?
  if [[ $rc -eq $want ]] && grep -qF -- "$msg" "$work/out"; then
    echo "  ok: $name"
  else
    echo "  FAIL: $name: expected exit $want and \"$msg\", got exit $rc"
    sed 's/^/    /' "$work/out"
    status=1
  fi
}

echo "a pin passes only when its SHA is the commit its version comment names"
expect "the right SHA" 0 "ok    actions/checkout v7.0.1" \
  "uses: actions/checkout@$sha # v7.0.1"
# The Dependabot echo gap: one release's SHA under another release's comment.
expect "another release's SHA" 1 "WRONG actions/checkout v4.2.2" \
  "uses: actions/checkout@$sha # v4.2.2"
expect "a tag that doesn't exist" 1 "actual: <tag not found>" \
  "uses: actions/checkout@$sha # v99.0.0"
expect "no version comment" 1 "no version comment, cannot verify" \
  "uses: actions/checkout@$sha"
expect "a tag, not a SHA" 1 "not a SHA: actions/checkout@v7" \
  "uses: actions/checkout@v7 # v7.0.1"

echo "a repository it can't read fails as unchecked, not as a wrong pin"
expect "no such repository" 2 "could not read github.com/XeroIP/no-such-action" \
  "uses: XeroIP/no-such-action@$sha # v1.0.0"

exit $status
