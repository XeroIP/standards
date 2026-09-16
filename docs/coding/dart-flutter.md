---
title: Dart and Flutter
type: reference
status: active
updated: 2026-09-07
summary: Formatting, analysis, SDK pinning, and the release-agreement rule from rolling-text.
---

# Dart and Flutter

## Tooling

| Concern | Tool |
| --- | --- |
| Format | `dart format` |
| Analyse | `flutter analyze`, configured in `analysis_options.yaml` |
| Test | `flutter test` |

## The SDK version is pinned in CI

Pin the exact Flutter version in every workflow. A different local version resolves
`pubspec.lock` differently and rewrites it on `flutter pub get`, which arrives in review as
unexplained lockfile churn that hides the real change.

## Releases must agree in three places

The git tag `vX.Y.Z`, the `version:` in `pubspec.yaml`, and a `## [X.Y.Z]` section in
`CHANGELOG.md`. CI fails the release when they disagree.

The build number after the `+` also increments. Android refuses to install an APK whose build
number is not higher than the installed one, and that failure surfaces on a user's device
rather than in CI.

## Constants live in one place

A limit, threshold, or enumerated set is declared once and read everywhere — including by the
documentation that describes it. Restating a value in a UI string or a doc is how a shipped
app ends up advertising a limit it no longer has.

Bind the doc to the constant with a [consistency test](../documentation/consistency.md).

## Changelog formatting

A changelog bullet stays on one unbroken line. GitHub's release renderer preserves mid-bullet
newlines as visible line breaks, so a hard-wrapped bullet publishes as broken release notes.
