#!/usr/bin/env bash
# Resolves every pinned action SHA against its upstream tag and reports any that
# disagree.
#
# Pinning to a SHA is worthless if the SHA is wrong: the workflow fails at run
# time, in whichever repo consumes it, with an error that does not name the
# cause. Eight pins were written for this repo and one was wrong, which is the
# reason this script exists rather than a note asking people to be careful.
#
# Needs network. The pins job in self-check.yml runs it on every push and pull
# request, so a Dependabot bump is checked against its tag rather than read by
# eye. When GitHub can't be reached it exits 2 and says so: a check that can't
# run fails, and doesn't report a wrong pin it never looked up.
set -euo pipefail

# No credential prompt: a repository that doesn't exist, or a private one,
# fails here instead of waiting for a username on a runner with no terminal.
export GIT_TERMINAL_PROMPT=0

root="$(git rev-parse --show-toplevel)"
status=0
unreachable=0
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

  # The peeled ref is the commit an annotated tag points at; a lightweight tag
  # has none, and its own ref is the commit. git ls-remote exits 0 with no
  # output for a tag that doesn't exist, and non-zero only when it couldn't
  # read the repository at all.
  if ! refs="$(git ls-remote "https://github.com/$repo" "refs/tags/$tag" "refs/tags/$tag^{}" 2>&1)"; then
    echo "could not read github.com/$repo (network, or no such public repository):"
    while IFS= read -r err; do echo "        $err"; done <<<"$refs"
    unreachable=1
    continue
  fi
  actual="$(echo "$refs" | awk -v t="refs/tags/$tag^{}" '$2 == t {print $1}')"
  [[ -z "$actual" ]] && actual="$(echo "$refs" | awk -v t="refs/tags/$tag" '$2 == t {print $1}')"

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
if [[ $unreachable -ne 0 ]]; then
  echo "some pins weren't checked: see above"
  exit 2
fi
exit $status
