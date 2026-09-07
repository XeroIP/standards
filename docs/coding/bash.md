---
title: Bash
type: reference
status: active
updated: 2026-09-07
summary: Strict mode, shellcheck, and where a shell script stops being the right tool.
---

# Bash

## Tooling

| Concern | Tool |
|---|---|
| Lint | shellcheck |
| Format | shfmt, two-space indent |

Both run pre-commit. shellcheck findings are fixed, not suppressed; a `# shellcheck disable`
carries a comment saying why on the same line.

## Every script starts with

```bash
#!/usr/bin/env bash
set -euo pipefail
```

`-e` exits on error, `-u` on an unset variable, and `-o pipefail` makes a failure anywhere in a
pipeline fail the pipeline. Without the third, `foo | tee log` reports success when `foo`
died — which is exactly the case a verification script must not get wrong.

## Rules

- Quote every expansion: `"$var"`, `"${arr[@]}"`. Unquoted is a bug waiting for a path with a
  space in it.
- `[[ ]]` over `[ ]`.
- `$(...)` over backticks.
- Check that a required command exists before using it, and fail with a message naming it.
- Trap and clean up temporary files: `trap 'rm -rf "$tmp"' EXIT`.

## When to stop

Past roughly 100 lines, or the first time the script needs a data structure, it wants to be
Python. Bash has no arrays worth the name, no error handling worth the name, and no test story.
A verification script that grows conditionals is the usual case.
