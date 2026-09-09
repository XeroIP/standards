# standards

Engineering standards for every `XeroIP` repository, written once and consumed everywhere.

These exist because the standards already existed — scattered across six repos and locked to
one vendor each. A coding standard lived in a Copilot memory file, an evidence-backed prose
standard lived in a research repo, documentation conventions lived in a project's `docs/`.
None of them could reach the other twenty-nine repos. This repo is where they live now.

## What's here

| Area | State | Source |
|---|---|---|
| [Documentation](docs/documentation/) | **v1, complete** | Written here, plus `ideavault` conventions and the incident standard from `my-unraid-notes` |
| [Prose](docs/prose/) | Imported, Vale generated from it | `english-ai-rule` — five multi-vendor research runs |
| [Coding](docs/coding/) | Imported, split per stack | `claude-memory/copilot-instructions.md` |
| [Design](docs/design/) | **v1, complete** | Console Editorial, built and contrast-verified |
| [Diagrams](docs/diagrams/) | Imported | `documentation/diagram-generation-patterns.md` and `diagram-qa` |
| [Observability](docs/observability/) | Stub | Not yet written |

## Using these in a repo

Add a `.standards.yml` declaring the repo's profile, then call the reusable workflows:

```yaml
# .github/workflows/standards.yml in the consuming repo
jobs:
  docs:
    uses: XeroIP/standards/.github/workflows/docs-ci.yml@v1
```

The sync bot then opens a PR in that repo on each release, refreshing a vendored
`.standards/` directory and regenerating `AGENTS.md`, `CLAUDE.md`, and
`.github/copilot-instructions.md`. Vendoring is deliberate: it puts the rules in the working
tree an agent already has, with no network fetch and no submodule to go stale.

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
