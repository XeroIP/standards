---
title: File naming and links
type: reference
status: active
updated: 2026-09-07
summary: Filenames, why ordinal prefixes are banned, and how links and redirects are kept honest.
---

# File naming and links

## Rules

1. **Lowercase, hyphenated, `.md`.** `disaster-recovery.md`, not `Disaster_Recovery.md`.
2. **No ordinal prefixes.** Never `00-overview.md`.
3. **The slug describes the content, not its position.** `cloudflare-boundary.md` survives a
   reorganisation; `03-networking.md` does not.
4. **Type lives in the directory, not the filename.** `how-to/verify-stack.md`, never
   `howto-verify-stack.md`.
5. **Dated pages lead with the date.** `ops-log/2026-08-30-disk-space-check.md`,
   `incidents/2026-08-13-overseerr.md`. ISO order sorts correctly and reads unambiguously.
6. **ADRs keep their number.** `adr/0007-no-forward-auth-on-jellyfin.md`. The number is an
   identifier, not a sort position, and it never changes.

## Why ordinal prefixes are banned

They encode ordering in the path, so ordering cannot change without renaming files — and
renaming a file breaks every inbound link, every bookmark, and every reference in a commit
message or an issue. One repo reached `19-` before this became obvious, and inserting a page
between `07` and `08` meant renaming twelve files.

Ordering belongs in the site's navigation config, where changing it costs one line and breaks
nothing. Every generator supports this.

Rule 6 is the deliberate exception. An ADR's number is part of its identity — "superseded by
ADR-0012" has to keep meaning — so it is not a position and never gets renumbered.

## Links

**Link to files, not to URLs.** Write ``[the runbook](../how-to/deploy-stack.md)`` — a
relative path from the current file. The build resolves these, so a broken one fails CI rather than reaching a
reader; a hand-written URL is unverifiable and silently rots.

**Never link to a heading in another document by anchor** unless that heading is stable. Link
to the page and name the section in the sentence. Anchors are generated from heading text, so
editing a heading breaks every inbound anchor without warning.

**External links get checked on a schedule, not on every push.** Lychee runs weekly and on
changes to the docs tree. External sites go down for reasons that have nothing to do with the
change under review, so a dead third-party link must not block an unrelated PR.

## Redirects

Any moved page leaves a redirect behind. Old paths are in commit messages, issues, browser
bookmarks, and other people's notes, none of which get updated.

A redirect is cheap and permanent. Removing one to tidy up breaks links that were working; the
tidying is not worth it.

## Enforcement

`docs-ci.yml` fails on a filename that violates rules 1–5, on an ordinal prefix outside
`adr/`, and on any unresolved internal link. Internal link resolution runs at build time in
under a second and needs no network, which is why it gates every push while lychee does not.
