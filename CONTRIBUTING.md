# Contributing

This repository is consumed by every `XeroIP` repository, so a change here is a change
everywhere. That shapes most of what follows.

## Before anything else

**Nothing real goes in here.** This repository is public and the estate it documents is
private. Never write a real domain, hostname, IP address, CIDR, container name, file path from
a live host, or anything resembling a credential. Use `example.internal`, `192.0.2.10`
(RFC 5737), `10.0.0.0/8` when a range is meant, `service-a`, `/srv/appdata/<service>`.

`tools/check-leakage.py` enforces this from an allowlist and runs as a pre-commit hook as well
as in CI. The hook is the one that counts: a public git history cannot be un-pushed, so by the
time CI reports a leak the value has been cloneable for as long as the push took.

## Setting up

```bash
npm ci                     # pinned dependencies, never npm install
pip install pre-commit && pre-commit install
```

`npm ci` installs exactly the lockfile and fails when it disagrees with `package.json`, which
is what makes a generator's output reproducible.

## Generated files are never edited by hand

| Generated | Source | Generator |
| --- | --- | --- |
| `CLAUDE.md`, `.github/copilot-instructions.md` | `AGENTS.md` | `tools/build-agent-files.js` |
| `.vale.ini`, `styles/XeroIP/*.yml` | `docs/prose/rules.yml` | `tools/build-vale.js` |
| `llms.txt` | the `docs/` tree | `tools/build-llms-txt.js` |
| `docs/design/adapters/*.css` | `docs/design/tokens.json` | `docs/design/build-adapters.js` |

CI re-runs every generator and fails if the result differs from what is committed. Editing a
derived file is work that gets thrown away on the next build.

## Before pushing

```bash
npm run build                          # re-run the generators
python3 tools/check-docs.py docs       # structure, naming, front matter, links
python3 tools/check-leakage.py         # nothing real
vale .                                 # prose
npx markdownlint-cli2                  # markdown
node docs/design/check-contrast.js     # WCAG AA, both themes
bash tools/verify-action-pins.sh       # action SHAs
```

All of it runs in CI too. Running it first is faster than a round trip.

## Commits and branches

- Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`). The body explains why, not what.
- Branch first. Changes land through a pull request rather than straight to `main`.
- Reference issues as `Closes #N` only when fully resolved, otherwise `Refs #N`.

## Proposing a change to a standard

A fix and a change of rule are different things, and they are reviewed differently.

**A fix** — a broken link, a typo, a tool that misbehaves, a rule that contradicts itself — is
an ordinary pull request. Say what was wrong and how you know.

**A change of rule** alters what thirty repositories are held to. It needs:

1. **What the rule costs today.** A concrete case where it produced a bad outcome, not a
   preference. "This flagged correct prose in these three files" beats "this feels strict".
2. **What enforces the new rule.** A standard with no enforcement mechanism is a preference;
   label it as one or make it enforceable.
3. **An ADR when the decision closes off an alternative a reasonable person would try.** See
   [`docs/documentation/adr.md`](docs/documentation/adr.md). The reliable signal is that the
   same question keeps being re-explained.

Changing a gate's behaviour is breaking for every repository pinned to the current SHA. Say so
in the pull request, so the consuming repos' bumps are expected rather than surprising.

## Adding a rule to the prose standard

Edit `docs/prose/rules.yml` and run `node tools/build-vale.js`. Never edit `.vale.ini` or the
files under `styles/XeroIP/` — they are generated from it.

New markers land as `monitor` (suggestion) first. A marker that has never been observed in
real writing is a guess, and promoting it to `ban` without evidence turns the linter into
something people route around.

## Writing here

Follow [`docs/documentation/`](docs/documentation/). It applies to this repository first —
the standard that cannot be met by the repository publishing it is not a standard.

## When you are unsure

Ask one focused question rather than guessing. A standard adopted across thirty repositories
on a wrong assumption is expensive to walk back.
