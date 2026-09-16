#!/usr/bin/env bash
# Resolves every pinned action SHA against its upstream tag and reports any that
# disagree.
#
# Pinning to a SHA is worthless if the SHA is wrong: the workflow fails at run
# time, in whichever repo consumes it, with an error that does not name the
# cause. Eight pins were written for this repo and one was wrong, which is the
# reason this script exists rather than a note asking people to be careful.
#
# Needs network. Not a CI gate — it would fail whenever GitHub is unreachable.
# Run it when adding or bumping a pin.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
status=0
checked=0

while IFS= read -r line; do
  ref="${line#*uses:}"
  ref="$(echo "$ref" | awk '{print $1}')"
  case "$ref" in ./*|.github/*) continue ;; esac
  [[ "$ref" == *@* ]] || continue

  repo="${ref%@*}"
  sha="${ref#*@}"
  [[ "$sha" =~ ^[0-9a-f]{40}$ ]] || { echo "not a SHA: $ref"; status=1; continue; }

  # The version comment after the pin is what the SHA is supposed to mean.
  tag="$(echo "$line" | sed -n 's/.*#\s*\(v[0-9][^ ]*\).*/\1/p')"
  if [[ -z "$tag" ]]; then
    echo "no version comment, cannot verify: $ref"
    status=1
    continue
  fi

  actual="$(git ls-remote "https://github.com/$repo" "refs/tags/$tag^{}" 2>/dev/null | cut -f1)"
  [[ -z "$actual" ]] && actual="$(git ls-remote "https://github.com/$repo" "refs/tags/$tag" 2>/dev/null | cut -f1)"

  checked=$((checked + 1))
  if [[ "$actual" == "$sha" ]]; then
    echo "ok    $repo $tag"
  else
    echo "WRONG $repo $tag"
    echo "        pinned: $sha"
    echo "        actual: ${actual:-<tag not found>}"
    status=1
  fi
done < <(grep -rhE '^\s*-?\s*uses:' "$root/.github/workflows" | sort -u)

echo
echo "$checked pin(s) verified"
exit $status
