---
title: JavaScript and TypeScript
type: reference
status: active
updated: 2026-09-07
summary: ESLint and Prettier, the tsconfig baseline, and dependency discipline.
---

# JavaScript and TypeScript

## Tooling

| Concern | Tool | Config |
|---|---|---|
| Lint | ESLint (flat config) | `eslint.config.js` |
| Format | Prettier | `.prettierrc` |
| Types | TypeScript | `tsconfig.json` |
| Test | Node's built-in runner, or Vitest | — |

Prettier owns formatting; ESLint owns correctness. Do not configure ESLint formatting rules —
the two fight, and the fight surfaces as CI failures nobody can reproduce locally.

## tsconfig baseline

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext"
  }
}
```

`strict` is not negotiable on new code. `noUncheckedIndexedAccess` is the one people disable
first and the one that catches the most: without it, `arr[i]` is typed as present when it may
not be.

## Rules

- No `any`. `unknown` plus a narrowing check where the type is genuinely not known.
- No default exports. Named exports survive renaming and are greppable.
- `const` by default, `let` when reassignment is real, never `var`.
- Handle promise rejection. A floating promise is an unhandled rejection waiting for
  production; ESLint's `no-floating-promises` catches it.
- Node's version is pinned in `.nvmrc` and read from that file in CI, never restated.

## Dependencies

Pin exact versions in `package.json` — no `^`, no `~`. A caret range means the tree that
built yesterday is not the tree that builds today, and the difference surfaces as a failure
in an unrelated PR.

Commit the lockfile. Install with `npm ci` in CI, never `npm install`.

Before adding a dependency, check whether the standard library or a few lines cover it. Every
dependency is a supply-chain surface and a future upgrade.
