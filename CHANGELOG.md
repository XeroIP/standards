# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Consuming repositories pin the reusable workflows to a commit SHA rather than a tag, so a
release here does not change any repository until that repository bumps its pin. Entries under
**Changed** and **Removed** are the ones to read before bumping: they are what alters a gate's
behaviour.

## [Unreleased]

### Changed

- **The leakage scan reads the repository it runs in.** The vendored copy at
  `.standards/tools/check-leakage.py` found the repository from its own location, so in a
  consuming repository it listed only `.standards/` and passed every file beside it. Outside
  a git repository it now exits 2 unless given `--paths`. A public consumer's next scan reads
  its own files for the first time, so expect findings there.
- **An allowlisted domain permits itself and its subdomains, not its siblings.** Matching
  compared the last two labels, so listing one host under a shared suffix permitted every
  other host under it: any Pages site, storage bucket or CDN host. The allowlist entries were
  already host-specific; only the matching changed.
- **A CIDR must match an `[ip-cidr]` block exactly, or sit inside a documentation range.**
  Containment against a list holding `0.0.0.0/0` permitted every CIDR, and a /24 inside a
  private block passed as its parent. An address written with a prefix, or as a /32, is now
  checked as a host against `[ip-host]`.
- **IPv6 addresses are detected.** No pattern matched them before. The RFC 3849
  documentation range, loopback and the unspecified address may be written as hosts;
  unique-local, link-local and `::/0` as blocks.
- **The fixture exclusion is a path prefix naming the two leakage fixture directories.** A
  substring match skipped any path containing `tests/fixtures`, including a consumer's own
  fixtures and a directory such as `notes/tests/fixtures-old/`.
- **Markdown prose counts every delegated suffix as a hostname.** A token was a hostname only
  on one of 16 listed suffixes, so a personal domain on `.nl`, `.eu`, `.dev` or `.home`
  written in a sentence passed. Prose outside code spans and fences now counts every suffix
  IANA has delegated, plus the private-use names `.home`, `.corp`, `.lan`, `.local`,
  `.internal`, `.localdomain`, `.private` and `.intranet`. Fourteen suffixes that are also
  common file extensions, such as `.md` and `.sh`, count only inside a URL or an address.
  Code and config files, and code spans and fences, keep the short list. An identifier
  written bare in prose on a delegated suffix, such as `h1.page`, is now reported: put it in
  a code span.
- **gitleaks finds a config in every consuming repository.** `secret-scan.yml` named the
  repository's root `.gitleaks.toml` unconditionally, and the sync never wrote one, so a
  freshly synced repository failed gitleaks on a missing file and the leakage scan was
  skipped behind it. The sync now writes `.standards/.gitleaks.toml`, and the workflow uses
  the root file, then that copy, then gitleaks' default rules. The copy has the same rules
  and none of this repository's path exclusions. A consumer that needs an exclusion writes
  its own root `.gitleaks.toml`, which the workflow prefers.
- **CI and the pre-commit hook run one gitleaks release, 8.30.0.** The action chose its own
  default (8.24.3) while the hook pinned 8.30.0. The hook is now pinned to the release's
  commit rather than its tag.
- **The fixture exclusion in `.gitleaks.toml` is anchored at the repository root.** Unanchored,
  it also excluded any path that contained `tests/fixtures/leakage/`.
- **A consuming repository's own fixture directories are scanned.** The vendored leakage
  scanner applied this repository's fixture skip to a consumer's `tests/fixtures/leakage/`
  and `tests/fixtures/allowlist-extra/`, directories nobody here reviews. The skip now applies
  only in the repository the scanner ships in.
- **In prose, an `@` before a host marks it again, except before `.md`.** Requiring a user
  part for every `@` stopped a bare `@` before a host on `.sh` being reported. Only `.md`, the
  suffix agent-file imports use, needs a user part now.
- **A finding in Markdown prose says it may be a missing code span.** An identifier such as
  `h1.page` written outside backticks is reported as a domain, and the message now names that
  cause.
- **`tokens.css` is generated from `tokens.json` with the adapters.** It was kept by hand,
  nothing checked it against `tokens.json`, and `check-contrast.js` never read it. It now has
  the same parity check as the adapters, so a hand edit fails CI. Its values are unchanged.
- **The severity opt-in works in every adapter, in both themes.** Measured in a browser, all
  seven adapters were wrong in 35 of 42 cases. Opting in gave black or ink, because each read
  `--dx-ok-raw`, which none defined. In dark mode, severity colour showed on every page with no
  opt-in, because the theme blocks set `--dx-ok` directly. Severity now resolves per element,
  so it follows the theme wherever the generator puts its theme marker.
- **`check-rendered-design.js` exits 2 when it could not run**, as its header says: no browser,
  a page that would not load or had nothing to measure, or any other error before a verdict.
  It exited 1, which reads as a failed assertion.
- **Frequency caps count across the whole file.** The cap rules counted each paragraph on its
  own, so a capped term once in each of three paragraphs passed a cap of two. They now count
  the raw file, code blocks, front matter and comments included. Caps are warnings, so this
  surfaces more findings and fails nothing.
- **A pull request's prose check reports every line, not only the lines it adds.** Vale's
  findings went through reviewdog's added-lines filter, so an error on an untouched line failed
  the push run and passed the pull request run on the same commit. Both Prose steps now pass
  `filter_mode: nofilter`. A sync pull request that brings a new rule fails on the text that
  rule catches, as the push after it would have.
- **check-docs checks a page under any `vendor/` directory but this repository's
  `docs/prose/vendor/`.** It skipped every path with a part named `vendor`, so a consumer's
  `docs/team/vendor/` passed unchecked. A consuming repository's own `docs/prose/vendor/` is
  checked too: the exclusion is found from the script's location and doesn't travel.
- **check-docs exits 2 when it finds no Markdown pages.** It printed "0 pages checked" and
  passed, so a `docs-path` pointing at an empty directory passed the gate.
- **ADRs must carry the required sections, and `supersedes` must name an ADR that exists.**
  `adr.md` said both failed the build; neither was checked. The sections are context and
  problem statement, decision drivers, considered options, decision outcome and consequences,
  as H2 or H3.
- **`severity_ui` needs a page type and tag that allow it.** It's allowed on an incident, a
  how-to tagged `runbook` and a reference page tagged `status`. Any reference or how-to page
  could set it before. It must be `true` or `false`, so `yes` no longer passes as unset, and a
  `data-severity-ui` attribute in a page body needs it.
- **The links job runs when a file lychee reads changes, and weekly.** It ran on every pull
  request, and on a push only when the commit message contained "docs", whatever the push
  changed. It now runs when the diff touches any Markdown file, `llms.txt`, `.lychee.toml` or
  its workflow, and on a weekly schedule, in its own workflow, `links.yml`.
- **`llms.txt` points at each page's Markdown on main, and lychee checks it.** Every entry
  pointed at a site that isn't built, so all 32 returned 404, and lychee never read the file.
  Entries point at `raw.githubusercontent.com` until a `mkdocs.yml` exists, then at its
  `site_url`. On a push or a pull request lychee skips those URLs, since a page a pull request
  adds isn't on main yet, and `tests/test-llms-txt.sh` checks that each names a file in the
  tree. The weekly run checks them live.
- **lychee no longer accepts 429.** An accepted 429 passed a link nobody checked. lychee
  retries a 429, waiting longer each time, and fails the link only when every attempt is
  rate-limited. Ten runs over `llms.txt`'s 32 URLs from a runner saw none.
- **The diagram checkers exit 1 on any finding.** `check_overlaps.py` and
  `check_cross_reference.py` exited with their finding count, which an exit status wraps at
  256, so 256 findings exited 0. They now exit 0 or 1 and print the count. The divergence
  from the imported copies is recorded in `docs/diagrams/tools/README.md` and in an import
  marker on each script.
- **The cross-reference example runs here.** It named three files in another repository and
  crashed with `FileNotFoundError`. `examples/cross-ref.json` checks a made-up fact across
  three files of its own.

### Fixed

- **Generator parity catches a generated file that was never committed.** The Vale-styles and
  design-adapter checks in `self-check.yml` used `git diff`, which ignores untracked files, so
  a new rule's style or a new adapter that the generator produced but nobody committed passed.
  They now use `git status --porcelain`.
- **The marker count in `docs/prose/README.md` is generated.** It said 21 markers and 11
  errors while `rules.yml` held 22 and 12. `tools/build-vale.js` now writes the line, and the
  parity check covers it.

### Added

- `tools/build-leakage-gaps.py`, which measures the counts behind the scanner's accepted gaps
  and writes them into its docstring. `self-check.yml` fails when they drift from the tree.
- `tools/iana-tlds.txt`, IANA's list of delegated suffixes, fetched by `tools/update-tlds.py`.
  `refresh-tld-list.yml` refreshes it weekly and opens a pull request when the set changes,
  with the leakage checks' results in its body.
- `tests/test-vale.sh`, which runs the committed Vale config on pages built at the cap and one
  paragraph over it, for every cap rule. CI runs it on the Vale binary the Prose step
  installed.
- `tests/test-check-docs.sh`, which builds a page that breaks each check `check-docs.py`
  claims and one that doesn't, and asserts the exit status and the message.
- `tests/test-llms-txt.sh`, which runs the `llms.txt` generator on a copy of the tree with a
  made-up `mkdocs.yml` and checks that entries follow its `site_url`.
- `tests/test-diagram-tools.sh`, which runs both diagram checkers at 0, 1 and 256 findings and
  runs the shipped example, clean and with one source changed.

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
