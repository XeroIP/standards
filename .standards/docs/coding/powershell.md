---
title: PowerShell
type: reference
status: active
updated: 2026-09-07
summary: Approved verbs, splatting, strict error handling, and dry-run modes for destructive scripts.
---

# PowerShell

PowerShell 7+ for scripts and automation. 5.1 only when a target genuinely has nothing else.

## Tooling

| Concern | Tool |
| --- | --- |
| Lint | PSScriptAnalyzer |
| Format | PSScriptAnalyzer formatting rules via `Invoke-Formatter` |
| Test | Pester |

## Naming and calling

- Approved verbs only: `Get-`, `Set-`, `New-`, `Remove-`, `Update-`. `Get-Verb` lists them.
- Full parameter names. Never aliases, never positional arguments.
- Splat at three or more parameters.

## Error handling

- Set `$ErrorActionPreference` explicitly at the top of every script. Override per-cmdlet with
  `-ErrorAction` where a specific call needs different behaviour.
- `try`/`catch` around anything external: files, network, APIs, the registry.
- `throw` for unrecoverable failures, `Write-Error` for recoverable ones.
- An error message states what failed, on what input, and what to try next.

## Destructive operations

Any script that deletes, overwrites, or mutates external state gets `-WhatIf` support through
`SupportsShouldProcess`, and it works — a `-WhatIf` that silently does nothing is worse than
none, because it teaches the operator to trust it.

## Input validation

Validate at the boundary: parameters, paths, and anything read from outside the script. Trust
internal code. Use parameter attributes (`[ValidateSet]`, `[ValidateNotNullOrEmpty]`,
`[ValidateScript]`) rather than hand-written checks in the body.
