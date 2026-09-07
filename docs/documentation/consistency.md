---
title: Documentation consistency tests
type: reference
status: active
updated: 2026-09-07
summary: Tests that fail when a documented value stops matching the code it describes, generalised from a Flutter project where it already works.
---

# Documentation consistency tests

A linter checks that documentation is well-formed. It cannot check that documentation is
*true*. This standard covers the gap.

## The problem, from a real case

`rolling-text` shipped a character-limit ceiling of 25,000. Its documentation and one of its
own UI sheets still advertised 1,000,000 — the earlier value — because the number was written
in four places and only one of them was the constant. The docs were valid Markdown, passed
every lint, and were wrong.

That repo's answer was `test/documentation_consistency_test.dart`: a test in the normal suite
that reads the documentation, extracts the values it claims, compares them to the constants
those values are supposed to describe, and fails when they diverge. It has caught the feature
list advertising a stale limit and a stale theme count.

This generalises. Any repo where documentation states a value that also exists in code should
have one.

## The rule

**A value stated in documentation must have exactly one source of truth, and a test must
enforce the link.**

Where a doc states a number, an enum, a default, a port, a path, or a version that also exists
in code or config, one of these must hold:

1. The doc is generated from the source, or
2. A test reads both and fails when they disagree.

Restating a value with no mechanism binding it to its source is the defect. It will be wrong
eventually, and the reader has no way to know.

## What to guard

Worth a test:

- Limits, thresholds, and ceilings
- Enumerated sets — supported themes, valid states, available modes
- Defaults presented to a user
- Version pins that appear both in docs and in a manifest
- Ports, paths, and hostnames stated in a runbook and set in config
- Any value a reader would act on

Not worth a test: prose descriptions, rationale, anything with no single machine-readable
source.

## Shape

The test lives in the repo's normal suite so it runs with everything else. It reads the doc
file as text, extracts claims by pattern, and asserts against the imported constant.

```
test: documentation states the current character ceiling
  read docs/user-guide.md
  find the claimed maximum
  assert it equals AppSettings.maxMaxChars
```

Two properties matter:

**Fail toward the doc.** When the test fails, the code changed and the doc did not. Fix the
doc. The test asserting the doc's claim against the constant — rather than the reverse — is
what makes that unambiguous.

**Never delete the test to make it pass.** A failing consistency test is doing its job. This
holds for tripwire tests generally: `rolling-text` also carries a test asserting framework
defaults it deliberately does not reimplement, so an SDK upgrade that silently removes one
fails loudly. Deleting it would restore green and lose the behaviour.

## Where it does not apply

A repo with no code has nothing to be inconsistent with. `docs-only` repos skip this; their
equivalent is the link check and the front-matter schema.

For infrastructure repos, the analogue is a verification script — something like
`verify-stack.sh` — asserting that what the runbook claims about a running system is true.
That is the same idea against a live system rather than a constant.

## Enforcement

Per-repo, in that repo's own test suite; it cannot be centralised because it depends on that
repo's code. What is centralised is the requirement: `.standards.yml` with a `code` or `mixed`
profile, and documentation that states values, means this test should exist. Its absence is a
review finding, not a build failure.
