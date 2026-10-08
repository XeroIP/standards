# humanize-instructions

Generative writing instructions for making LLM output read like a person wrote it. Drop the right file into a system prompt, custom-instructions field, or rules file and the model will lean against the patterns that signal "machine wrote this."

These are distilled from `../master-language-rule.md` (v2.4). The master rule is the full reference with sources and confidence scores; the files here are what you actually paste.

## Files

| File | Use it when... |
|---|---|
| `portable.md` | You want one file that works anywhere. Source of truth for all variants. |
| `claude.md` | Pasting into a Claude Project, the `system` parameter, or a `CLAUDE.md`. |
| `chatgpt.md` | Using a Custom GPT Instructions box or the Custom Instructions field. Includes a compressed block for the tighter field. |
| `cursor-copilot.md` | Setting up `.cursorrules`, `.github/copilot-instructions.md`, or `AGENTS.md`. Terse bullets, emphasis on docs and comments. |

## Design choices

**Soft defaults, not hard bans.** Naturalness and voice win ties. The failure mode these instructions are designed to avoid is over-correction: mechanically dodging every flagged word until the prose turns stilted. That's a different machine tell.

**Positive moves first.** Each file leads with what to *do* (lead with subject, use contractions, vary cadence, commit to a stance) before listing what to avoid. This shapes generation rather than just flagging problems.

**Voice-preservation is load-bearing.** Idiom, humor, opinion, and quirks should survive. An idiosyncratic voice that breaks these rules deliberately is the goal, not a problem.

## Keeping variants in sync

`portable.md` is the source of truth. If you update the rules, edit that file first. The platform variants are condensed adaptations — resync them when the canonical changes.

## What these are not

These files are for writing *more like a human*, not for evading AI-detection tools, academic integrity checks, or misrepresenting authorship. See `../README.md` for the project's stated non-goals.
