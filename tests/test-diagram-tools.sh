#!/usr/bin/env bash
# The diagram checkers fail on any finding, and the shipped example runs here.
#
# Both exited with their finding count, which an exit status wraps at 256, so
# 256 findings exited 0 while the output reported 256. The example config
# named three files in another repository and crashed here. Every input below
# is built in a temporary directory, except the example, which is run from
# its own directory as its docstring says.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
tools="$root/docs/diagrams/tools"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
status=0

# expect NAME EXIT MESSAGE COMMAND...: the exit status, and MESSAGE in the output.
expect() {
  local name="$1" want="$2" msg="$3" rc=0
  shift 3
  "$@" >"$work/out" 2>&1 || rc=$?
  if [[ $rc -eq $want ]] && grep -qF -- "$msg" "$work/out"; then
    echo "  ok: $name"
  else
    echo "  FAIL: $name: expected exit $want and \"$msg\", got exit $rc"
    tail -n 5 "$work/out" | sed 's/^/    /'
    status=1
  fi
}

# svg N: one wide label crossed by N vertical lines, so exactly N findings.
svg() {
  local i
  {
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 4000 100">'
    printf '<text x="10" y="50" font-size="10">%s</text>\n' "$(printf 'x%.0s' $(seq 400))"
    for ((i = 0; i < $1; i++)); do
      printf '<line x1="%d" y1="0" x2="%d" y2="100"/>\n' $((20 + 4 * i)) $((20 + 4 * i))
    done
    echo '</svg>'
  } >"$work/lines-$1.svg"
  echo "$work/lines-$1.svg"
}

echo "check_overlaps.py: 0 when clean, 1 on any finding"
expect "no findings" 0 "0 findings" python3 "$tools/check_overlaps.py" "$(svg 0)"
expect "one finding" 1 "1 finding(s)" python3 "$tools/check_overlaps.py" "$(svg 1)"
expect "256 findings" 1 "256 finding(s)" python3 "$tools/check_overlaps.py" "$(svg 256)"

# config N: two sources that disagree on N keys.
config() {
  local i
  for ((i = 0; i < $1; i++)); do echo "k$i=1"; done >"$work/a.txt"
  for ((i = 0; i < $1; i++)); do echo "k$i=2"; done >"$work/b.txt"
  echo "k=1" >>"$work/a.txt"; echo "k=1" >>"$work/b.txt"
  cat >"$work/config-$1.json" <<EOF
{"join_key": "key", "compare_fields": ["value"], "sources": [
  {"name": "a", "path": "$work/a.txt", "pattern": "(?P<key>k\\\\d*)=(?P<value>\\\\d+)"},
  {"name": "b", "path": "$work/b.txt", "pattern": "(?P<key>k\\\\d*)=(?P<value>\\\\d+)"}]}
EOF
  echo "$work/config-$1.json"
}

echo "check_cross_reference.py: 0 when clean, 1 on any mismatch"
expect "no mismatches" 0 "0 mismatches" python3 "$tools/check_cross_reference.py" "$(config 0)"
expect "256 mismatches" 1 "256 mismatch(es) found" python3 "$tools/check_cross_reference.py" "$(config 256)"

echo "the shipped example runs here, and catches a disagreement"
expect "examples/cross-ref.json is clean" 0 "3 distinct 'service' value(s) checked across 3 source(s), 0 mismatches" \
  bash -c "cd '$tools/examples' && python3 ../check_cross_reference.py cross-ref.json"
cp -r "$tools/examples" "$work/examples"
sed -i.bak 's/"service-b": 8081/"service-b": 9081/' "$work/examples/cross-ref/ports.py"
expect "one port changed in one source" 1 "service=service-b: MISMATCH on 'port'" \
  bash -c "cd '$work/examples' && python3 '$tools/check_cross_reference.py' cross-ref.json"

exit $status
