---
title: Documentation standard
type: reference
status: active
updated: 2026-09-07
summary: How documentation is structured, named, written, and enforced across every repo.
---

# Documentation standard

| Page | Covers |
|---|---|
| [Structure](structure.md) | Diátaxis, plus ADRs, incidents, and the ops log. Profiles. |
| [Front matter](front-matter.md) | The required schema, and the severity opt-in. |
| [Naming and links](naming.md) | Filenames, why ordinal prefixes are banned, redirects. |
| [Page anatomy](page-anatomy.md) | Headings, tables, code, admonitions, accessibility. |
| [Incident reviews](incident-reviews.md) | The required structure, and separating evidence from inference. |
| [ADRs](adr.md) | MADR format and the immutability rule. |
| [Consistency tests](consistency.md) | Making a documented value fail the build when it stops being true. |

Two rules carry most of the weight:

**Ordering lives in configuration, never in a filename.** A path that encodes position cannot
be reordered without breaking every inbound link.

**A standard names its enforcement.** Anything here that a tool checks says which tool. Anything
it cannot check says so, and lives on a review checklist rather than pretending to be automated.
