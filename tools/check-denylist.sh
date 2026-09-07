#!/usr/bin/env bash
# Fails when a denied pattern appears in tracked files. Runs in CI and as a
# pre-commit hook; the hook is the one that matters, because a public git
# history cannot be un-pushed.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
denylist="$root/tools/denylist.txt"
status=0

# The denylist and this script both contain the patterns by necessity.
mapfile -t files < <(git -C "$root" ls-files \
  | grep -vE '^tools/(denylist\.txt|check-denylist\.sh)$')

while IFS= read -r pattern; do
  [[ -z "$pattern" || "$pattern" == \#* ]] && continue
  if hits=$(grep -nEI "$pattern" "${files[@]}" 2>/dev/null); then
    echo "DENIED pattern: $pattern"
    echo "$hits" | sed 's/^/  /'
    status=1
  fi
done < "$denylist"

if [[ $status -ne 0 ]]; then
  cat <<'MSG'

A denied value reached a tracked file in a public repository.

Do not commit and force-push over it: by the time CI reports this, anything
already pushed has been cloneable. If this has been pushed, rotate whatever the
value protects and treat the history as public.

Use a placeholder instead: example.internal, service-a, 10.0.0.0/8,
192.0.2.0/24, /srv/appdata/<service>.
MSG
  exit 1
fi

echo "denylist: ${#files[@]} tracked files clean"
