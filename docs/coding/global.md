---
title: Global engineering rules
type: reference
status: active
updated: 2026-09-07
summary: Priorities, change discipline, git conventions, and safety rules that apply in every repo regardless of language.
---

# Global engineering rules

## Priorities

When rules conflict, the highest wins:

1. Safety, privacy, and protection of user data
2. Correctness — verify the root cause before changing anything
3. The stated request and its scope
4. Surgical changes that leave unrelated code alone
5. A simple working solution over a polished one
6. Documentation and cleanup

When the right priority is unclear, ask one focused question rather than guessing.

## Changing code

- Diagnose exhaustively, change minimally. No speculative fixes and no fixes that address a
  symptom without establishing the cause.
- Make the smallest change that fully solves the stated problem. No unrelated edits, renames,
  refactors, or formatting churn.
- Notice nearby problems and say so plainly. Do not fix them uninvited.
- When a broader change is genuinely required, explain why and ask before starting.
- Never claim something works until it has been run and the output shown.
- Prefer built-ins and the standard library. Ask before adding a dependency.

For homelab and infrastructure work specifically: use standard, community-adopted tools
configured properly rather than writing a custom script. A custom script is a maintenance
liability that nobody else has debugged.

## Git and GitHub

- Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`). The body explains why, not what.
- Branch first. Never commit directly to `main` unless the repo's `.standards.yml` sets
  `workflow.allow_direct_to_main: true`.
- Track meaningful work in issues with a problem statement, expected versus actual behaviour,
  and acceptance criteria. Search for an existing issue first. Bundle tightly related fixes
  under one issue. No issue for cosmetic fixes or scratch work.
- Reference issues as `Closes #N` only when fully resolved, otherwise `Refs #N`.

Repos differ here on purpose. `.standards.yml` carries `workflow.require_issue` and
`workflow.allow_direct_to_main` per repo, because one repo genuinely requires an issue for
every change while another commits straight to `main` by design. Both are correct for their
context; neither is the house rule.

## Documentation

- Update documentation when a feature, config option, or setup step changes. No doc churn for
  a narrow bug fix.
- Keep documentation next to the code it describes.
- Use exact UI paths when naming one: `Settings > Network > Advanced > DNS`.
- Present research and comparisons as tables, not prose describing a table.
- Where a doc states a value that also exists in code, bind them with a test. See
  [consistency tests](../documentation/consistency.md).

## Safety

- Never commit credentials, tokens, `.env` files, or keys. Redact secrets from output and logs.
- Verify a redaction actually redacts before trusting it. A regex that looks right and a tool's
  default output format are both capable of printing the value anyway.
- Ask before installing global tools or changing system state outside the project.
- Treat production as read-only by default. Diagnostics first; ask before restarting a service,
  changing storage, or writing to a disk.
- Get explicit approval for each production-affecting step. Approval for one step is not
  approval for the next, and adjacent context is not consent.

## Reviews and disagreement

Push back when the evidence contradicts the person asking, and cite the evidence. Agreement
that is not warranted is worse than useless — it launders a bad assumption into a decision.

Never speculate from a single observation. One run is not a trend.

## Enforcement

Pre-commit hooks run formatters and linters for the declared stacks. `docs-ci.yml` runs the
documentation and prose gates. `secret-scan.yml` runs gitleaks plus a denylist. The rules on
this page that concern judgement — priorities, change scope, disagreement — are review items,
because no tool checks them and pretending otherwise would make the enforceable rules look
optional by association.
