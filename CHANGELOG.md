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

- **The changelog says what each new test covers.** `tests/test-check-docs.sh` covers six
  groups of checks, not every check `check-docs.py` makes. `tests/test-diagram-tools.sh` has
  no single-mismatch case for the cross-reference checker. `tests/test-sync.sh` covers the
  sync tool, not the workflow file. The shift-change installer's v3 writes `CLAUDE.md` once,
  to remove its old block.
- **Three enforcement sentences say what is checked.** `docs/documentation/naming.md` listed
  rules 1–5 as failing in `docs-ci.yml`; rules 3 and 4 (the slug names content, type stays out
  of the filename) are review items. The README said the sync workflow writes only when
  `apply` is asked for, where a published release writes too. `docs/prose/README.md` said
  editing an imported file loses its provenance without saying that nothing detects the edit
  ([#65](https://github.com/XeroIP/standards/issues/65)).
- **The leakage claims say what the scanner reports.** `AGENTS.md`, `CONTRIBUTING.md`, the
  README, the `[domain]` header in `tools/allowlist.txt` and the 0.1.0 notes said it reports
  anything infrastructure-shaped. It reports addresses, CIDRs and hostnames on the suffixes in
  its lists; a host on an unusual suffix in code is a documented gap, and container names and
  live file paths are review items. `docs/coding/global.md` now says the leakage scan runs only
  in public repositories. The rule itself is unchanged.
- **`check-docs.py` fails a front-matter value that still holds `<fill in>`.** The incident
  starter's `updated` would fail the date check, but nothing failed an unfilled `title`,
  `severity` or `window`, so a copy could be committed with the placeholders in them. Each
  unfilled field is now one error naming the field, whether the marker is a scalar, in a list
  or nested. The starter itself is the one file skipped, by its exact path from the script's
  own location, as `docs/prose/vendor/` is; `build-llms-txt.js` skips the same file. A file
  named `templates/incident.md` anywhere else is still checked. A consuming repo with a page
  that carries the marker in its front matter starts failing when it bumps its pin.
- **The shift-change handoff instructions live in `.claude/rules/shift-change.md`.** They were
  a marked block in `AGENTS.md`, copied there so `CLAUDE.md` could be generated around it, and
  re-running the shift-change installer broke the agent-file parity check. Its v3 writes its
  own rules file, which Claude Code loads alongside `CLAUDE.md`. It writes `CLAUDE.md` only to
  remove its own pre-v3 block from a hand-written one, and deletes the file if nothing else is
  left in it.
- **Vale is pinned to 3.24.0 in both Prose steps.** `docs-ci.yml` and `self-check.yml`
  installed whatever Vale release was newest, so a release could change what the gate accepts
  in every consuming repo with no commit anywhere. Both now set `VALE_VERSION`, the cap test
  checks the installed binary reports it, and `self-check.yml` fails if the two pins differ.
  Consuming repos get the pin when they bump their `docs-ci.yml` pin.
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
- **The synced AGENTS.md has one H1.** The sync kept the shared base's own H1 under the
  file's, so every freshly synced repository failed MD025 in its docs gate, on a file it
  can't edit. The base's H1 is now an H2.
- **The sync refuses a generated agent file edited since the last sync.** The banner check
  caught a file a person wrote, not a section added to a generated one, which the next sync
  deleted with exit 0. Each generated file now carries a content hash, and a mismatch exits 3.
  A region another tool maintains can be declared in `sync.managed_regions`: it's left out of
  the hash, and every run prints where it is and how much of the file it covers. A file
  written before the hash existed is refused once; `--adopt` writes the hash.
- **The sync writes `standards_version`** in the consumer's `.standards.yml` to the version it
  vendored, changing only that line. It was only ever read, so a sync left a stale pin.
- **`sync.protect` is honoured.** A listed path under `.standards/` that exists is kept as it
  is, and each run says so. Nothing read the key, so a protected edit was replaced.
- **`--check` counts every change the next sync would make.** A file under `.standards/` that
  the sync would delete, an edited `VERSION` or `README.md`, and a stale `standards_version`
  all reported up to date.
- **A published release syncs and opens the pull requests.** The Sync and PR steps in
  `standards-sync.yml` were gated on `apply`, which only a manual run carries, so a release
  previewed and wrote nothing. Both steps still wait for the `sync` environment's reviewer.
- **The sync has no schedule.** The weekly run waited at that reviewer gate and reported
  nothing: three runs queued unapproved for three weeks.
- **`repos` narrows a manual sync run to the repos it names.** Nothing read the input, so a
  run asked for one repo ran for every listed one, and with `apply` would have written to all
  of them.
- **Every action pin is checked against its tag in CI.** `tools/verify-action-pins.sh` ran in
  no workflow, so CONTRIBUTING's "All of it runs in CI too" was false for it, and a Dependabot
  bump's SHA was checked against its version comment only by eye. The `pins` job in
  `self-check.yml` runs it, and `tests/test-verify-action-pins.sh` shows it failing a wrong SHA,
  a missing comment and a repository it can't read.
- **The pin example in `policy-pinned-actions.yml` is a placeholder.** It was a real SHA,
  which Dependabot rewrote to v7.0.1's commit while the comment beside it still said v4.2.2.
- **AGENTS.md no longer says CI doesn't resolve tags.** A published release's sync checks out
  its tag. It now says what the tag ruleset blocks, and that no gate resolves a tag to decide
  what it accepts.
- **The coding pages state each tooling practice as an instruction and say this repository ships
  no stack tooling or hooks**, with gate selection by stack planned in
  [#44](https://github.com/XeroIP/standards/issues/44); `global.md`, which the sync copies into
  every consumer's agent files, says the same in its Enforcement section.
- **`.standards.yml`, `structure.md` and the README say that `visibility` is the only key that
  changes a gate today**, that the sync prints `profile` and `stacks` without selecting gates
  from them ([#44](https://github.com/XeroIP/standards/issues/44)), that nothing reads the
  `workflow` keys, and that a sync from a version other than `standards_version` warns and still
  vendors it ([#45](https://github.com/XeroIP/standards/issues/45)).
- **The incident review standard describes the rendered site as planned**
  ([#46](https://github.com/XeroIP/standards/issues/46)) and the timeline and corrective-action
  table rules as review items until their checks exist
  ([#43](https://github.com/XeroIP/standards/issues/43)), and the observability page says the
  same.
- **The documentation standard scopes front matter to `docs/`**, names MD045 as the alt-text
  check, marks diagram sources as a review item, and lets a record take a proportionate, marked
  correction.
- **Examples and two project records use placeholders**, in place of specific services, a dated
  outage and deployment detail, under the correction rule in `structure.md`.
- **`docs/prose/README.md` records that L14, contraction avoidance, is not enforced here**,
  though the imported master rule calls it strictly enforced.
- **AGENTS.md, the README and the Dependabot comment count two npm dependencies**, the allowlist
  points at the written rationale and says no ADR records it yet
  ([#4](https://github.com/XeroIP/standards/issues/4)), and `check-rendered-design.js` lists its
  tokens path once.
- **The README says the sync token exists**, that a release run has used it, that a rejected run
  shows as failed in the Actions UI, and that the sync's pull requests are authored by the
  token's owner ([#32](https://github.com/XeroIP/standards/issues/32)).

### Fixed

- **Generator parity catches a generated file that was never committed.** The Vale-styles and
  design-adapter checks in `self-check.yml` used `git diff`, which ignores untracked files, so
  a new rule's style or a new adapter that the generator produced but nobody committed passed.
  They now use `git status --porcelain`.
- **The marker count in `docs/prose/README.md` is generated.** It said 21 markers and 11
  errors while `rules.yml` held 22 and 12. `tools/build-vale.js` now writes the line, and the
  parity check covers it.
- **`verify-action-pins.sh` says when it can't read a repository.** An unreachable or
  missing repository made `git ls-remote` fail inside an assignment, and `set -e` ended the
  script with git's exit code and no message. It now names the repository and exits 2, apart
  from a wrong pin's 1.
- **`self-check.yml` reads the Node major version from a new `.nvmrc`**, as
  `javascript-typescript.md` already said CI does.

### Added

- **Incident reviews have a starter to copy, generated from `INCIDENT_SECTIONS`.**
  `structure.md` said reviews were "generated from the template", and no template existed.
  `tools/build-incident-starter.py` now writes `docs/documentation/templates/incident.md` from
  the section list `check-docs.py` enforces: the front-matter fields an incident requires, one
  heading per section with a hint, and `<fill in>` wherever an author supplies a value. A
  section added to the list without a hint stops the generator. `self-check.yml` runs it with
  `--check`, which fails when the file is missing or differs, and
  `tests/test-incident-starter.sh` runs that check on a missing, a stale and a fresh starter.
- `tools/build-leakage-gaps.py`, which measures the counts behind the scanner's accepted gaps
  and writes them into its docstring. `self-check.yml` fails when they drift from the tree.
- `tools/iana-tlds.txt`, IANA's list of delegated suffixes, fetched by `tools/update-tlds.py`.
  `refresh-tld-list.yml` refreshes it weekly and opens a pull request when the set changes,
  with the leakage checks' results in its body.
- `tests/test-vale.sh`, which runs the committed Vale config on pages built at the cap and one
  paragraph over it, for every cap rule. CI runs it on the Vale binary the Prose step
  installed.
- `tests/test-check-docs.sh`, which builds pages for six groups of `check-docs.py`'s checks
  (the vendor exclusion, an empty tree, ADR sections and `supersedes`, `severity_ui`, the
  incident starter and the placeholder markers) and asserts the exit status and the message.
  The other checks, such as required keys, dates, naming and links, have no test yet.
- `tests/test-llms-txt.sh`, which runs the `llms.txt` generator on a copy of the tree with a
  made-up `mkdocs.yml` and checks that entries follow its `site_url`.
- `tests/test-diagram-tools.sh`, which runs `check_overlaps.py` at 0, 1 and 256 findings and
  `check_cross_reference.py` at 0 and 256 mismatches (there's no single-mismatch case), then
  runs the shipped example, clean and with one port changed.
- `tests/test-sync.sh`, which syncs scratch consumers and checks the sync tool's behaviour,
  starting with the vendored markdownlint run on the sync's own output. It doesn't cover the
  workflow file: that a release applies, that nothing is scheduled, and the `repos` input.

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
  addresses and hostnames by default (a host on an unusual suffix in code is a documented gap).

### Security

- `tools/check-leakage.py` reports any address, CIDR or hostname on its suffix lists that isn't
  on `tools/allowlist.txt`, and runs as a pre-commit hook as well as in CI. It cannot see text
  inside images; that limit is stated in `SECURITY.md` rather than left implied.

[Unreleased]: https://github.com/XeroIP/standards/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/XeroIP/standards/releases/tag/v0.1.0
