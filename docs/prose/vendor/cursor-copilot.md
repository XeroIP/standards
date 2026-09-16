# Humanize Variant — Cursor / GitHub Copilot

**Where it goes:**
- **Cursor:** `.cursorrules` in the project root, or *Settings → Rules for AI.*
- **Copilot:** `.github/copilot-instructions.md`, or `AGENTS.md` alongside existing agent guidance.

This variant uses terse rule-style bullets to match how these tools parse instructions. It emphasizes docs, comments, commit messages, and inline prose — the written output that coding assistants produce most.

**Source of truth:** `portable.md`. Edit that first, then resync this.

---

## Writing rules

Naturalness wins. These are defaults to lean against, not hard bans. Over-correction — mechanically avoiding flagged words until prose turns stilted — is itself a machine tell.

**Do:**
- Lead with the subject in the first few words. No wind-up sentence before the point.
- Use contractions in prose, docs, and comments where a person would (*it's, you're, don't, we've*).
- Vary sentence length. Short sentences land decisions. Long sentences build reasoning. Never four sentences of the same length in a row.
- Commit to a position when evidence supports one. Don't hedge both sides equally.
- Name concrete consequences: not "streamlines the process" — "cuts the build time by ~30%."
- End paragraphs and doc sections on a decision, consequence, or next step — not a restatement.
- Describe what code and systems do. Not "the function thinks" — "the function returns."

**Avoid in all written output (docs, comments, commit messages, PR descriptions, README):**
- Filler verbs: *delve, harness, unlock, embark, unveil, unpack, navigate* (metaphorical).
- Prestige metaphors: *tapestry, realm, landscape, mosaic, beacon, "at the intersection of."*
- Grand openers: "In today's fast-paced world," "As technology continues to evolve," "In an increasingly digital age."
- Meta-announcements: "This document will explore," "Let's dive into," "This guide aims to."
- Throat-clearing: "It's worth noting that," "It is important to note that."
- Benefit-wrap closers: "By doing so you can," "This approach allows you to," "This enables you to focus on what matters most."
- Inflation phrases: *treasure trove, plethora, a wealth of, game-changer, paradigm shift.*

**Use sparingly** (once or twice per document; overuse is the tell):
- *Robust, seamless, comprehensive, pivotal, crucial, vital, essential* as default intensifiers.
- "In conclusion" or "In summary."
- Paragraph-opening *Furthermore, Moreover, Additionally* — cut most; never in consecutive paragraphs.
- *Enhance, streamline, optimize, leverage, foster, facilitate* without naming what they actually do.
- "That said," "With that in mind," caveat prefaces.
- "Not only… but also."
- Triple-adjective stacks ("powerful, flexible, and intuitive").
- "At its core," "fundamentally," "essentially" as preamble.
- Em dashes — occasional is fine; one per paragraph is not.

**Exceptions:**
- Technical terms in their real sense are always fine: *robust* (fault-tolerant), *optimize* (profile-and-tune), *critical* (severity level). If replacing a word loses technical meaning, keep it.
- Preserve the author's voice. Idiom, humor, and intentional phrasing should survive.
