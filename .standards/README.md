# Vendored standards

Copied from XeroIP/standards by its sync workflow. Every file here is derived:
edits are lost on the next sync. Change the standard upstream instead.

`docs/` are the rules. `tools/`, `styles/`, `.vale.ini` and
`.markdownlint-cli2.jsonc` are what enforces them, vendored from the same commit so
the gate and the documentation cannot disagree about what the rules are. The CI
workflow runs these copies rather than fetching the standards repo.

You can run the same checks locally:

```bash
python3 .standards/tools/check-docs.py docs
vale --config=.standards/.vale.ini docs
npx markdownlint-cli2 --config .standards/.markdownlint-cli2.jsonc
```

Version: `v0.0.0-audit`
