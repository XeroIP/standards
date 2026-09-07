---
title: Kotlin
type: reference
status: active
updated: 2026-09-07
summary: ktlint, Compose naming, and the architecture conventions already in use.
---

# Kotlin

## Tooling

| Concern | Tool |
|---|---|
| Lint and format | ktlint |
| Build | Gradle with the Kotlin DSL |
| Test | JUnit 4 with AndroidX Test |

Compose functions are PascalCase by convention, which ktlint's function-naming rule rejects.
Configure the exemption in `.editorconfig` rather than suppressing per file:

```ini
[*.{kt,kts}]
ktlint_function_naming_ignore_when_annotated_with = Composable
```

## Architecture

Three layers, and the boundaries are real:

- **UI** — Compose screens, ViewModels, UI state classes
- **Domain** — use cases and domain models, plain Kotlin with no Android dependencies
- **Data** — DAOs, entities, repositories, data sources

Rules that follow from that:

- ViewModels expose `StateFlow<UiState>`; screens collect and render.
- All data access goes through a repository. A ViewModel never touches a DAO.
- Storage entities are separate from domain models, mapped at the repository boundary.
- Sealed classes or interfaces for UI state and navigation events.
- Coroutines for async work. No callbacks.

## Tests

Tests accompany every feature: unit tests for domain and data, UI tests for screens. A feature
merged without them is incomplete, not fast.
