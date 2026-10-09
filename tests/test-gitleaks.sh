#!/usr/bin/env bash
# Exercises both directions of .gitleaks.toml, and holds the places that name a
# gitleaks release to one.
#
# The fixture token was a run of one repeated character, which gitleaks' entropy
# floor never flagged, so the config's "gitleaks correctly flagged it" was true
# of no version in use. And CI and the pre-commit hook ran different releases.
# Each was a claim nothing checked.
#
# Needs a gitleaks binary: $GITLEAKS, or `gitleaks` on PATH. self-check.yml
# installs the pinned release and verifies its checksum first.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
gitleaks="${GITLEAKS:-gitleaks}"
fixture="tests/fixtures/leakage/leaks.md"
status=0

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Files flagged in a JSON report, one per line.
flagged() { python3 -c 'import json,sys; [print(f["File"]) for f in json.load(open(sys.argv[1]))]' "$1"; }

echo "CI, the hook and this test run one gitleaks release"
ci=$(sed -nE "s/^ *GITLEAKS_VERSION: *'?([0-9.]+)'?.*/\1/p" "$root/.github/workflows/secret-scan.yml")
hook=$(sed -nE 's/.*# frozen: v([0-9.]+).*/\1/p' "$root/.pre-commit-config.yaml")
binary=$("$gitleaks" version)
if [[ -n "$ci" && "$ci" == "$hook" && "$ci" == "$binary" ]]; then
  echo "  ok: $ci"
else
  echo "  FAIL: secret-scan.yml '$ci', pre-commit hook '$hook', binary '$binary'"
  status=1
fi

echo "gitleaks' default rules flag the fixture's token"
printf '[extend]\nuseDefault = true\n' >"$work/default.toml"
rc=0
(cd "$root" && "$gitleaks" dir "$fixture" --config "$work/default.toml" --no-banner \
  --report-format json --report-path "$work/default.json") >/dev/null 2>&1 || rc=$?
if [[ $rc -ne 1 ]]; then
  echo "  FAIL: expected exit 1 (a finding), got $rc"
  status=1
elif ! grep -q '"RuleID": "github-pat"' "$work/default.json"; then
  echo "  FAIL: a finding, but not the github-pat rule"
  status=1
else
  echo "  ok"
fi

# A repository with the fixture in its own directory and at a path that merely
# contains it. The repo's config must exclude the first and report the second.
echo "the repo's config excludes the fixture directory, and nothing that only contains its path"
repo="$work/repo"
mkdir -p "$repo/tests/fixtures/leakage" "$repo/notes/tests/fixtures/leakage"
cp "$root/.gitleaks.toml" "$repo/"
cp "$root/$fixture" "$repo/$fixture"
cp "$root/$fixture" "$repo/notes/$fixture"
git -C "$repo" init -q
git -C "$repo" add -A
git -C "$repo" -c user.name=test -c user.email=test@example.com commit -qm fixture
rc=0
(cd "$repo" && "$gitleaks" git . --config .gitleaks.toml --no-banner \
  --report-format json --report-path "$work/repo.json") >/dev/null 2>&1 || rc=$?
files=$(flagged "$work/repo.json" | sort -u)
if [[ $rc -ne 1 ]]; then
  echo "  FAIL: expected exit 1, got $rc"
  status=1
elif [[ "$files" != "notes/$fixture" ]]; then
  echo "  FAIL: expected only notes/$fixture, got: $(tr '\n' ' ' <<<"$files")"
  status=1
else
  echo "  ok"
fi

# The copy a consumer receives must not carry this repository's exclusion. The
# review that warrants it covers this repository only, and root-anchored in a
# consumer it would exempt that consumer's own tests/fixtures/leakage/. So a
# real sync writes the copy, and a token in the consumer's own fixture directory
# must be reported by it.
echo "the consumer's copy has no path exclusion, so the consumer's own fixture directory is scanned"
consumer="$work/consumer"
mkdir -p "$consumer"
git -C "$consumer" init -q
printf 'version: 1\nsync:\n  adopted: true\n' >"$consumer/.standards.yml"
git -C "$consumer" add -A
git -C "$consumer" -c user.name=test -c user.email=test@example.com commit -qm init
rc=0
python3 "$root/tools/sync-standards.py" --target "$consumer" >"$work/sync.out" 2>&1 || rc=$?
if [[ $rc -ne 0 ]]; then
  echo "  FAIL: the sync exited $rc"
  sed 's/^/    /' "$work/sync.out"
  status=1
else
  mkdir -p "$consumer/tests/fixtures/leakage"
  cp "$root/$fixture" "$consumer/$fixture"
  git -C "$consumer" add -A
  git -C "$consumer" -c user.name=test -c user.email=test@example.com commit -qm fixture
  rc=0
  (cd "$consumer" && "$gitleaks" git . --config .standards/.gitleaks.toml --no-banner \
    --report-format json --report-path "$work/consumer.json") >/dev/null 2>&1 || rc=$?
  if grep -q '^\[allowlist' "$consumer/.standards/.gitleaks.toml"; then
    echo "  FAIL: the consumer's copy has an [allowlist]"
    status=1
  elif [[ $rc -ne 1 || "$(flagged "$work/consumer.json" | sort -u)" != "$fixture" ]]; then
    echo "  FAIL: expected exit 1 and only $fixture reported, got exit $rc"
    status=1
  else
    echo "  ok"
  fi
fi

# A regex or stopword allowlist changes what the rules report, so the sync must
# refuse one rather than silently keep or drop it for every consumer.
echo "the sync refuses an allowlist that holds more than path exclusions"
# Exit 0 only when both are refused, so a missing function or any other error
# fails the check instead of passing as a refusal.
rc=0
python3 - "$root/tools/sync-standards.py" <<'PY' >"$work/refuse.out" 2>&1 || rc=$?
import importlib.util, sys
spec = importlib.util.spec_from_file_location("sync", sys.argv[1])
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)
for config in ("[allowlist]\nregexes = ['x']\n", "[[allowlists]]\npaths = ['^a/']\n"):
    try:
        sync.vendored_gitleaks_config("[extend]\nuseDefault = true\n" + config)
    except SystemExit:
        continue
    print("accepted:", config.splitlines()[0])
    sys.exit(3)
PY
if [[ $rc -eq 0 ]]; then
  echo "  ok"
else
  echo "  FAIL: exit $rc"
  sed 's/^/    /' "$work/refuse.out"
  status=1
fi

exit $status
