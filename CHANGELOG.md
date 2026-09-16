# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Consuming repositories pin the reusable workflows to a commit SHA rather than a tag, so a
release here does not change any repository until that repository bumps its pin. Entries under
**Changed** and **Removed** are the ones to read before bumping: they are what alters a gate's
behaviour.

## [Unreleased]

Nothing yet.

## [0.1.0] — 2026-09-16

First tagged release. `0.x` deliberately: one consumer, an observability standard still a
stub, and several decisions recorded as open. The version says so rather than implying a
stability the repository has not earned.

### Added

- `LICENSE` (MIT) for the code and `LICENSE-docs` (CC BY 4.0) for the prose, with the split
  stated in `README.md`. Until now nothing here was reusable: with no licence, default
  copyright applies and a reader has no basis to copy a single rule.
- `SECURITY.md`, naming the real risk — a leaked infrastructure value — and a private
  reporting channel that does not republish the value being reported.
- `CONTRIBUTING.md`, including the distinction between fixing a rule and changing one.
- `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1).
- This changelog.
- A statement in `docs/documentation/structure.md` of when these standards do not apply. A
  one-off site or an afternoon experiment needs no profile, gate, or justification.
- ADR-0001, accepting MkDocs + Material as the documentation toolchain, decided across seven
  candidates building the same pages.

### Changed

- **The sync bot now vendors the enforcers alongside the rules.** `tools/`, `styles/`,
  `.vale.ini` and `.markdownlint-cli2.jsonc` ship into `.standards/` with `docs/`, from the
  same commit.
- **`docs-ci.yml` runs that vendored copy and no longer fetches this repository.** The
  `standards-ref` input is removed. Previously a repository's rules were pinned by its own
  commit while the gate enforcing them was fetched from a mutable ref, so the two could
  disagree about what the rules were.
- **Consuming repositories pin the workflow by commit SHA rather than `@v1`.** A tag is
  mutable; moving one changed what the gate accepted everywhere with no pull request anywhere.
- The prose rule loader uses `js-yaml` rather than a hand-rolled parser, which silently
  dropped a misindented rule and mis-parsed a trailing comment.

### Fixed

- **`policy-pinned-actions.yml` had never passed.** It stripped whitespace before dropping the
  trailing version comment, turning `@<sha> # v4.2.2` into `@<sha>#v4.2.2`, which never matched
  the anchored SHA pattern. Every correctly pinned action was reported as unpinned, including
  the format the job's own error message recommends.
- **The markdown gate had never run.** `globs` and `ignores` are honoured only in a
  `markdownlint-cli2`-named config file, and rule settings must sit under a `config` key. The
  rename exposed 308 previously suppressed findings.
- **The leak guard published what it protected.** A denylist in a public repository has to name
  the values it excludes. Replaced with an allowlist, which leaks nothing and fails unfamiliar
  values by default.

### Security

- `tools/check-leakage.py` reports anything infrastructure-shaped not on `tools/allowlist.txt`,
  and runs as a pre-commit hook as well as in CI. It cannot see text inside images; that limit
  is stated in `SECURITY.md` rather than left implied.

[Unreleased]: https://github.com/XeroIP/standards/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/XeroIP/standards/releases/tag/v0.1.0
