---
title: Coding standard
type: reference
status: active
updated: 2026-09-07
summary: Global engineering rules plus per-stack tooling, harvested from the Copilot instructions where they already worked.
---

# Coding standard

| Page | Covers |
| --- | --- |
| [Global](global.md) | Priorities, how to change code, git and GitHub, safety. Applies everywhere. |
| [PowerShell](powershell.md) | PSScriptAnalyzer, approved verbs, error handling |
| [Python](python.md) | ruff, black, packaging |
| [Bash](bash.md) | shellcheck, shfmt, strict mode |
| [Docker and Compose](docker.md) | hadolint, image pinning, secrets |
| [JavaScript and TypeScript](javascript-typescript.md) | ESLint, Prettier, tsconfig baseline |
| [YAML and GitHub Actions](yaml-actions.md) | yamllint, actionlint, SHA pinning |
| [Dart and Flutter](dart-flutter.md) | `dart format`, `flutter analyze`, version pinning |
| [Kotlin](kotlin.md) | ktlint, Compose naming |

## Where this came from

`claude-memory/copilot-instructions.md` — a complete set of engineering rules that had been
working for some time, loaded automatically by one vendor's CLI and reachable by nothing else.
[Global](global.md) is that file, reorganised. The per-stack pages add the tooling that
enforces it.

## What a stack page contains

Formatter, linter, and their configuration; naming conventions; error handling; testing
expectations; and the pre-commit hooks that run them. Nothing about a stack that is really a
global rule — those live in [Global](global.md) and are not repeated.

A repo declares its stacks in `.standards.yml`. The reusable workflow runs only the gates for
the stacks declared, so a Python repo never waits on a Kotlin toolchain.

## Status

[Global](global.md) is complete and in force. The stack pages carry their tooling choices and
the rules already in evidence across the repos; several are thinner than they will end up. A
thin page that names the right formatter and linter is still enforceable, which is the bar for
shipping one.
