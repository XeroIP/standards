---
title: Coding standard
type: reference
status: active
updated: 2026-10-13
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
[Global](global.md) is that file, reorganised. The per-stack pages name the tooling that would
enforce it. This repository ships no stack tooling, meaning no formatter or linter configuration
and no hooks for stacks, so a repo wires up what its stack pages name.

## What a stack page contains

Formatter, linter, and their configuration; naming conventions; error handling; and testing
expectations. No page carries hook configuration, because none ships. Nothing about a stack that
is really a global rule — those live in [Global](global.md) and are not repeated.

Declare your stacks in `.standards.yml`. The sync prints them in the generated agent file, but
no reusable workflow selects gates from them yet, because there are no stack gates to select.
That selection is planned in [#44](https://github.com/XeroIP/standards/issues/44); once it
lands, a Python repo won't wait on a Kotlin toolchain. Until then, whether a repo runs a stack's
formatter and linter, and as a hook or in CI, is that repo's decision.

## Status

[Global](global.md) is complete and in force. The stack pages carry their tooling choices and
the rules already in evidence across the repos; several are thinner than they will end up. A
thin page still ships, because the bar is that it names the right formatter and linter.
