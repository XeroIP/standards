# standards

Engineering standards for every `XeroIP` repository, written once and consumed everywhere.

These exist because the standards already existed — scattered across six repos and locked to
one vendor each. A coding standard lived in a Copilot memory file, an evidence-backed prose
standard lived in a research repo, documentation conventions lived in a project's `docs/`.
None of them could reach the other twenty-nine repos. This repo is where they live now.

## What's here

| Area | State | Source |
| --- | --- | --- |
| [Documentation](docs/documentation/) | **Complete** | Written here, plus `ideavault` conventions and the incident standard from `my-unraid-notes` |
| [Prose](docs/prose/) | Imported, Vale generated from it | `english-ai-rule` — five multi-vendor research runs |
| [Coding](docs/coding/) | Imported, split per stack | `claude-memory/copilot-instructions.md` |
| [Design](docs/design/) | **Complete** | Console Editorial, built and contrast-verified |
| [Diagrams](docs/diagrams/) | Imported | `documentation/diagram-generation-patterns.md` and `diagram-qa` |
| [Observability](docs/observability/) | Stub | Not yet written |
| [Decision records](docs/adr/) | ADR-0001 accepted | Written here |

The documentation toolchain is **MkDocs + Material**, accepted as
[ADR-0001](docs/adr/0001-mkdocs-material-as-the-documentation-toolchain.md) on measured
evidence from a seven-way build of the same pages. Hugo tied it on score and the ADR records
what would have to change for that to be the right answer instead. Eleventy is the recorded
fallback if the design work ever exceeds what Material can express.

## Using these in a repo

Add a `.standards.yml` declaring the repo's profile, then call the reusable workflows:

```yaml
# .github/workflows/standards.yml in the consuming repo
jobs:
  docs:
    uses: XeroIP/standards/.github/workflows/docs-ci.yml@<40-char-sha>  # v0.1.0
```

Pinned to a SHA, not a tag. A tag is mutable, so moving it would change what the gate accepts
in every repo that calls it with no pull request anywhere — the same argument this repo makes
for third-party actions, applied to itself. `policy-pinned-actions.yml` enforces it, including
on this line: a `@v1` here fails it.

Nothing bumps that pin automatically. Bump it by hand when the workflow file changes, which is
rare — the rules it runs move independently of it. `AGENTS.md` records why per-repo Dependabot
was rejected for this and what is intended instead.

The sync bot then refreshes a vendored `.standards/` directory and regenerates `AGENTS.md`,
`CLAUDE.md`, and `.github/copilot-instructions.md`. Vendoring is deliberate: it puts the rules
in the working tree an agent already has, with no network fetch and no submodule to go stale.

**It reports by default and writes nothing.** Opening a pull request in someone else's
repository needs consent at both ends: the repo is listed in `standards-sync.yml`, and its own
`.standards.yml` sets `sync.adopted: true`. Carrying a `.standards.yml` is not consent on its
own — a repo can declare a profile long before anyone agrees to have three top-level files
replaced. The sync also refuses outright when any of those files exists without the generated
banner, because a file a person wrote is not the bot's to overwrite. `--adopt` overrides that,
deliberately by hand.

A release syncs that released tag, and `standards_version` in the consuming repo records which
one it holds. The weekly run only reports: no repo should be handed whatever happens to be on
`main` at 09:00 on a Monday.

### The sync token

The bot needs a `STANDARDS_SYNC_TOKEN` with `contents: write` and `pull-requests: write` on
each listed repository, and nothing else. A fine-grained PAT scoped to exactly those
repositories is the least-privilege option to start with. **It does not exist yet, so the
write path has never run.**

It is stored as an **environment secret on the `sync` environment**, not as a repository or
organization secret. The tiers are not interchangeable:

| Where | Reach | Why not |
| --- | --- | --- |
| Repository | Every workflow in this repo | This repo is public. A future workflow running on `pull_request` would hand a fork a token with write access to other repositories. |
| Organization | Every repo in the org | The token is deliberately scoped to a listed set; an org secret widens it to all of them. |
| **Environment** | **The `sync` job only** | **Chosen.** Adding a required reviewer means the token is released only when a person approves the run. |

That last point is the reason it is worth the extra setup. The workflow already reports by
default and writes only when `apply` is asked for; the environment gate enforces the same
decision in a second place, where one says write and the other hands over the means to.

Put a required reviewer on the `sync` environment. Without one the gate stores the secret
correctly but approves every run, which is the configuration that looks protected and is not.

**Rotation.** A fine-grained PAT expires — a year at most — and it is tied to one person. The
failure is quiet: the sync starts failing when it checks out a target, and nothing currently
alerts on that. A GitHub App installation has neither problem and is the right migration once
more than a couple of repositories are listed.

**The gate runs that vendored copy.** `.standards/` carries the enforcers — `tools/`,
`styles/`, `.vale.ini`, `.markdownlint-cli2.jsonc` — from the same commit as the rules, and
`docs-ci.yml` never fetches this repository. Vendoring the rules while fetching the enforcer
from a mutable ref meant a repo could be failed by rules that differed from the ones in its own
tree; shipping both together removes that by construction. It also means the gate runs
locally:

```bash
python3 .standards/tools/check-docs.py docs
vale --config=.standards/.vale.ini docs
npx markdownlint-cli2 --config .standards/.markdownlint-cli2.jsonc
```

Profiles let repos differ on purpose. `docs-only` skips the language gates entirely, and
`workflow.require_issue` / `workflow.allow_direct_to_main` are per-repo facts rather than a
house rule with exceptions.

## For agents

`AGENTS.md` is the source of truth. `CLAUDE.md` and `.github/copilot-instructions.md` are
generated from it by `tools/build-agent-files.js` and fail CI if they drift. Edit `AGENTS.md`
and re-run the generator; never edit a generated file.

## Nothing real goes in here

Standards use placeholders — `example.internal`, `192.0.2.10`, `service-a`. This repo is
public and the nearest source of examples is a private homelab, so `tools/check-leakage.py`
reports anything infrastructure-shaped that is not on `tools/allowlist.txt`.

The allowlist, not a denylist: a denylist would have to name the values it protects, and
publishing it would defeat it. It also only catches what someone thought to add, where an
allowlist catches unfamiliar values by default. The check runs pre-commit as well as in CI,
because a public git history cannot be un-pushed.

## Verifying

```bash
npm ci                            # one pinned dependency: js-yaml, for the rule loader
node tools/build-vale.js          # regenerate .vale.ini and styles from docs/prose/rules.yml
node tools/build-agent-files.js   # regenerate CLAUDE.md and copilot-instructions.md
node tools/build-llms-txt.js      # regenerate llms.txt
node docs/design/check-contrast.js  # 30/30 WCAG AA pairs, both themes
```

Every one of these is idempotent and checked in CI: if regenerating changes a tracked file,
the build fails.

## Licensing

Two licences, split by what the thing is rather than where it sits.

| What | Licence | Covers |
| --- | --- | --- |
| Code | [MIT](LICENSE) | `tools/`, `tests/`, `.github/`, and the build scripts under `docs/design/` and `docs/diagrams/tools/` |
| Prose | [CC BY 4.0](LICENSE-docs) | `docs/`, plus `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md` and `CHANGELOG.md` |

The split is the convention public handbooks use, and it reflects how each part is reused:
code gets copied into a build, prose gets adapted and republished. CC BY asks for attribution
where MIT asks for the notice to travel; both permit commercial use and adaptation.

GitHub reports the root `LICENSE`, so it will describe this repository as MIT. That is the
detector working as designed on a repository that is mostly prose — this section is the
authority on which licence applies where.

`CODE_OF_CONDUCT.md` is the Contributor Covenant 2.1, which carries its own terms and is
reproduced rather than licensed by us.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). To report a leaked value or a flaw in a gate, see
[SECURITY.md](SECURITY.md) — privately, because a public issue quoting a leaked value
republishes it.
