# AGENTS.md

Source of truth for every agent working in this repository. `CLAUDE.md` and
`.github/copilot-instructions.md` are generated from this file by
`tools/build-agent-files.js`; editing either of them is a mistake CI will catch.

## What this repo is

Engineering standards shared across all `XeroIP` repositories. Most of the content was
harvested from repos where it was already working but unreachable — `claude-memory`,
`english-ai-rule`, `ideavault`, `copilot-memory`, `documentation`, `my-unraid-notes`. When you
change a standard here, you are changing it for thirty repositories.

## The rule that shapes everything else

**This repo is public. The nearest source of examples is a private homelab.**

Never write a real domain, hostname, IP, CIDR, container name, file path from a live host, or
anything resembling a credential. Use `example.internal`, `192.0.2.10` (RFC 5737 TEST-NET-1),
`10.0.0.0/8` when a range is meant, `service-a`, `/srv/appdata/<service>`.

`tools/check-leakage.py` enforces this from an **allowlist**: anything with the shape of
infrastructure that is not explicitly permitted in `tools/allowlist.txt` is a finding. That
catches values nobody thought to enumerate — a domain registered next year, a host stood up
next month — and it means the guard itself contains nothing sensitive. A denylist would have
to name the values it protects, which in a public repository publishes them.

It runs as a pre-commit hook as well as in CI. The hook is the one that counts: a public git
history cannot be un-pushed, so by the time CI reports a leak the value has been cloneable for
as long as the push took.

If a rule genuinely cannot be explained without a real value, the rule belongs in the private
repo it describes, not here.

## Generated files

Never edit these by hand. Change the source, run the generator:

| Generated | Source | Generator |
| --- | --- | --- |
| `CLAUDE.md` | `AGENTS.md` | `tools/build-agent-files.js` |
| `.github/copilot-instructions.md` | `AGENTS.md` | `tools/build-agent-files.js` |
| `.vale.ini`, `styles/XeroIP/*.yml` | `docs/prose/rules.yml` | `tools/build-vale.js` |
| `llms.txt` | the `docs/` tree | `tools/build-llms-txt.js` |
| `docs/design/adapters/*.css` | `docs/design/tokens.json` | `docs/design/build-adapters.js` |

CI re-runs every generator and fails if the result differs from what is committed. That check
is the only thing keeping a derived file honest.

Dependencies are pinned to exact versions and installed with `npm ci`, never `npm install` —
`npm ci` installs exactly the lockfile and fails when it disagrees with `package.json`, which
is what makes a generator's output reproducible. There is currently one: `js-yaml`, which
loads `docs/prose/rules.yml`.

## Writing standards

A standard states a rule, says why it exists, and names how it is enforced. A standard with no
enforcement mechanism is a preference; label it as one or make it enforceable.

Prefer a rule that a tool can check over a rule a person must remember. Where both are
possible, write the prose rule and generate the tool config from it — `docs/prose/rules.yml`
generating the Vale styles is the pattern to copy.

Follow the documentation standard in `docs/documentation/` when writing here. It applies to
this repo first.

## Prose

`docs/prose/` is the house style, and it applies to this repo's own writing.

The banned and capped terms are not restated here. They live in `docs/prose/rules.yml`, which
generates the Vale styles that enforce them — a second copy in this file would drift, and
would also make this file fail its own lint. Run `vale .` and read the findings; each one
names the marker id, and `docs/prose/master-language-rule.md` explains the reasoning behind
that id.

The habits worth carrying without looking anything up:

- Do not open a section by announcing what the section will do.
- State a recommendation directly when the evidence supports one, rather than presenting every
  option as equally valid.
- Use contractions where a person writing to a peer would.
- Prefer a concrete verb over one that promises improvement without naming a mechanism.

`docs/prose/validation-checklist.md` is the pass to run before publishing. It covers the
structural markers a linter cannot see — cadence, paragraph architecture, adjective stacking.

## Commits and branches

- Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`). The body explains why, not what.
- Branch first. This repo is documentation-primary but it is consumed by CI in thirty repos,
  so changes land through a PR rather than straight to `main`.
- Reference issues as `Closes #N` only when fully resolved, otherwise `Refs #N`.

## Versioning

Consuming repos pin reusable workflows to a **full commit SHA**, not a tag, with the version
in a trailing comment. Tags are mutable: moving one changes what a gate accepts in every repo
that calls it, with no pull request anywhere and nothing to review. This repo already refuses
to trust third-party tags for that reason, and the reasoning does not stop at the boundary of
who owns the repository. `policy-pinned-actions.yml` enforces it on first-party references
too.

A change can travel one of two paths, and both now require a commit in the consuming repo:

| What changes | How it arrives | Review |
| --- | --- | --- |
| `docs/` and the enforcers | vendored into `.standards/` by the sync bot | a PR per repo |
| the workflow file | the pinned SHA in that repo's caller | a PR per repo |

Earlier the rules were vendored while the enforcer was fetched at a mutable ref. A tag move
then changed thirty repos' behaviour with no commit anywhere, and could fail a repo against
rules that differed from the ones in its own tree.

Tags still exist, for humans to read and for release notes. They are not what CI resolves.

## When you are unsure

Ask one focused question rather than guessing. A standard adopted across thirty repos on a
wrong assumption is expensive to walk back.
