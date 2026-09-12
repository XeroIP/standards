---
title: Master language rule
type: reference
status: active
updated: 2026-09-07
summary: The full rule pack with tiers, evidence, and provenance.
---

<!-- IMPORTED from XeroIP/english-ai-rule (master-language-rule.md). Upstream is the research
     workflow that produces this; edit there and re-import rather than editing here. -->

# Master Language Rule (High Strictness)

Use this rule pack to identify and revise AI-associated writing patterns in any prose context.

## Intent
- Improve readability and reduce AI-associated patterning that distracts or distances the reader.
- Preserve authentic voice and domain-specific precision.
- Never use for deception, impersonation, or academic dishonesty.

## Strictness Definition

"High strictness" is operationalized from marker confidence scores across 5 v2.4 runs (3 vendor-independent sources):
- **Ban:** Confidence ≥80, Low false-positive risk, ≥2 vendor-independent runs agreeing. Remove on first pass with no exceptions outside documented allowed contexts.
- **Limit:** Confidence ≥60, or ≥80 with Medium false-positive risk. Enforce a per-document or per-500-word frequency cap; allow in specific documented contexts.
- **Monitor:** Confidence <60, or any marker flagged High false-positive risk, or fewer than 2 vendor-independent runs. Log occurrences; do not enforce; tune in future runs.

Domain calibrations in Section 8 override these defaults for specific registers.

## Validation Metadata
- Strictness level: High
- Synthesized from: v2.4 runs (Anthropic claude-opus-4.7, OpenAI gpt-5.5, OpenAI gpt-5.3-codex, Google gemini-2.5-pro, Google gemini-pro)
- Synthesis date: 2026-05-20
- Vendor votes counted: 3 (Google's two runs collapse to one vote per plan)
- Evidence base: Cross-model-observed, corpus-backed, external-guide-backed
- See Appendix for per-rule provenance.

---

## Rule Framework

### 1. Prohibited Patterns

These patterns are banned in technical, educational, professional, and creative nonfiction registers. Marketing copy is the primary exception; see allowed contexts per entry.

---

**P1: Latinate filler verbs**
- Pattern: Using verbs that promise action or discovery without specifying it — *delve, navigate* (metaphorically), *harness, unlock, embark, unveil, unpack* — to introduce a topic, section, or explanation.
- Why prohibited: These verbs were upweighted by RLHF training for "engaging" openings. They appear at statistically abnormal rates in LLM output relative to human prose and signal preamble rather than content.
- Typical trigger examples:
  - "Let's delve into how DNS resolution works."
  - "We'll harness the power of machine learning to unlock new insights."
  - "This guide will help you navigate the complexities of tax filing."
- Replacement guidance: Start with the actual content. Replace with *explore, examine, look at, walk through, cover, learn, read about, use*. Or cut the sentence entirely and begin the content.
- Allowed contexts: Literary nonfiction where the verb does genuine metaphorical work ("navigate" meaning navigate, "unveil" meaning reveal something concealed). Marketing copy with deliberate ornate register.

---

**P2: Prestige metaphors and abstract placeholders**
- Pattern: Words and phrases that make content sound important by invoking grand spatial or cultural abstractions — *tapestry, realm, landscape* (metaphorical), *mosaic, beacon, double-edged sword, at the intersection of, in the realm of*.
- Why prohibited: These words serve as statistical safe harbors in LLM output: high-confidence tokens that contextualise any topic without requiring domain knowledge. Readers now register them as machine-generated stalls.
- Typical trigger examples:
  - "A rich tapestry of cultural influences."
  - "In the realm of cybersecurity, threats are evolving."
  - "At the intersection of design and engineering, decisions matter."
  - "This codebase is a mosaic of legacy and modern systems."
- Replacement guidance: Name the specific subject. Replace abstract containers with concrete nouns: *field, market, codebase, system, discipline, area*. Describe how components connect rather than invoking a metaphor.
- Allowed contexts: Art history or textile writing where "tapestry" is literal. Geographic writing where "landscape" is literal. Literary nonfiction where the metaphor is earned and non-clichéd.

---

**P3: Grand-opening clichés**
- Pattern: Sentence-initial phrases that situate the topic at cosmic, civilisational, or industry-wide scale before committing to the actual subject — *In today's fast-paced world, In the ever-evolving landscape of, As technology continues to evolve, Since the dawn of, In an increasingly digital age*.
- Why prohibited: These openers work for almost any topic, which means they say nothing about the specific one. They mark an introduction as generated rather than written.
- Typical trigger examples:
  - "In today's fast-paced world, incident response is more important than ever."
  - "As technology continues to evolve, teams must adapt their workflows."
  - "In an increasingly digital age, data privacy cannot be ignored."
- Replacement guidance: Start with the specific conflict, change, decision, or user need. Name the subject in the first six words. State what has changed or what problem is present now, not what is generally true of the era.
- Allowed contexts: Keynote speeches where broad scene-setting is a deliberate rhetorical move. Marketing copy with intentional positioning language.

---

**P4: Meta-announcement sentences**
- Pattern: Sentences whose only content is a description of what the following sentences will do — *This article will explore, In this guide we will cover, Let's dive into the details, This post aims to provide, We will walk through*.
- Why prohibited: These sentences consume the most valuable position in a section (the first sentence) to say nothing. They are a direct artifact of LLM instruction-following prompts that reward "structured, helpful" framing.
- Typical trigger examples:
  - "This post will explore three approaches to caching."
  - "In this section, we will discuss the causes and solutions."
  - "Let's dive into the details of how this works."
- Replacement guidance: Start with the actual content of the section. Let structure communicate what a section does through its first real sentence. Reserve scope statements for academic abstracts and long navigational documents where readers must skim.
- Allowed contexts: Academic abstracts where scope statements are convention. Long technical documents where a roadmap paragraph genuinely aids navigation (one, at the top only).

---

**P5: Throat-clearing padding phrases (specific)**
- Pattern: The two highest-frequency hedging preambles that flag a claim as both important and tentative before making it — *It's worth noting that, It is important to note that, It is worth mentioning that*.
- Why prohibited: These phrases are the single most-cited AI tell in mainstream editorial commentary. They add ceremony and hedge simultaneously without adding information. The claim they precede is nearly always stronger when stated directly.
- Typical trigger examples:
  - "It's worth noting that backups are not the same as restores."
  - "It is important to note that this feature is in beta."
- Replacement guidance: State the claim directly. If emphasis is needed, use *Note:* as a standalone label (in documentation), or put the claim in its own sentence.
- Allowed contexts: Legal or compliance writing where hedging language carries contractual or regulatory meaning. Peer review where epistemic markers carry argumentative weight.

---

**P6: Generic benefit-wrap sentences**
- Pattern: Closing sentences appended to paragraphs that promise a positive outcome without naming a mechanism — *By doing so, you can..., This approach allows you to..., This enables you to focus on what matters most, Doing this will help you achieve your goals*.
- Why prohibited: LLMs reward-hack helpfulness signals by ending paragraphs on a benefit statement. The result reads as filler and dilutes the actual content of each paragraph.
- Typical trigger examples:
  - "By doing so, you can streamline your workflow."
  - "This approach allows you to focus on what matters most."
  - "Using this method will help you achieve better results."
- Replacement guidance: Cut the sentence. If a consequence is real and worth stating, name it concretely: "You'll save about an hour a week" rather than "you can streamline your workflow."
- Allowed contexts: Marketing copy and sales writing where benefit statements are the product of the text. Calls-to-action that explicitly name what the reader will gain.

---

**P7: Quantitative inflation metaphors**
- Pattern: Metaphors that inflate the scope or importance of content through imprecise quantitative framing — *treasure trove, plethora, a wealth of, myriad, game-changer, groundbreaking, paradigm shift* (when used loosely).
- Why prohibited: These phrases are artifacts of clickbait-heavy training data. They claim abundance or significance without evidence and now register as promotional filler.
- Typical trigger examples:
  - "A treasure trove of resources for new developers."
  - "A plethora of options to choose from."
  - "This is a game-changer for the industry."
- Replacement guidance: Count it ("forty curated tutorials"), name it specifically, or drop the claim if it cannot be supported.
- Allowed contexts: Casual writing where the writer's voice is deliberately hyperbolic and the register is informal.

---

**P8: Anthropomorphism in technical and professional contexts**
- Pattern: Attributing human thought, intent, or emotion to code, tools, systems, or AI — *the code thinks, the model believes, the framework wants, the algorithm decided, the AI knows*.
- Why prohibited: Anthropomorphism obscures the system's actual behavior and misleads readers about agency and accountability. Major editorial style guides (AP Stylebook) explicitly prohibit it in technical contexts.
- Typical trigger examples:
  - "The code thinks the user is logged out."
  - "The AI decided to prioritize high-priority tasks."
  - "The framework wants to find a configuration file."
- Replacement guidance: Describe the actual behavior or design. "The code treats unauthenticated sessions as logged-out." "The scheduler processes high-priority tasks first."
- Allowed contexts: Creative writing and poetry where intentional metaphor is the mode. Informal speech. Technical metaphor that is clearly labeled as such.

---

### 2. Limited-Use Patterns

These patterns are permitted with a frequency cap or in specific allowed contexts. Exceeding the threshold, or using the pattern outside allowed contexts, is treated as a defect.

---

**L1: Adjective inflation**
- Pattern: High-praise adjectives used as default intensifiers without earning the claim — *robust, seamless, comprehensive* (evaluative); *pivotal, crucial, vital, essential, cornerstone, fundamental* (importance inflators).
- Max frequency: 1 per 500 words per adjective.
- Allowed contexts: Safety or security documentation where "critical" or "essential" names a genuine failure risk. Engineering specs where "robust" means fault-tolerant (technical sense). Executive summaries where priority must be stated quickly.
- Preferred alternatives: Drop the adjective and state the consequence. "Backups are critical" → "Without backups, a disk failure means permanent data loss."

---

**L2: Formulaic conclusion openers**
- Pattern: Words or phrases that announce the conclusion rather than making a final point — *In conclusion, In summary, To summarize, All in all, Overall* at the start of a closing paragraph or section.
- Max frequency: 1 per document; strong preference for 0.
- Allowed contexts: Five-paragraph essays where a summary paragraph is structurally required. Speeches where an audible closing cue is conventional. Long technical documents with multiple major sections.
- Preferred alternatives: End the section on the last real sentence. If a summary is needed, integrate it into the transition to the next section without announcing it.

---

**L3: Formal transition stack at paragraph start**
- Pattern: A small set of conjunctive adverbs used as paragraph openers to simulate logical flow — *Furthermore, Moreover, Additionally, Consequently, Nevertheless, Notably, Importantly, Interestingly*.
- Max frequency: 2 per 500 words; never as the first word of consecutive paragraphs.
- Allowed contexts: Academic literature reviews where logical connectives are required by convention. Legal prose where "Notwithstanding" / "Furthermore" are conventional.
- Preferred alternatives: Cut the transition. Show the connection through content rather than announcing it. Use *also, but, so, because, as a result, that means,* or a specific connective ("The failure mode here is the same").

---

**L4: Vague benefit verbs**
- Pattern: Verbs that promise improvement without naming the mechanism — *enhance, streamline, optimize* (when generic), *foster, facilitate, leverage, empower, enable* (when not followed by a specific object or result).
- Max frequency: 2 per 500 words; must pair with a mechanism or be replaced.
- Allowed contexts: Product roadmaps where the mechanism is intentionally deferred. Performance engineering where "optimize" means profile-and-tune (technical sense). Nonprofit mission statements where "foster" is established register.
- Preferred alternatives: *reduce, remove, automate, combine, cache, route, cut, accelerate* or another concrete verb. Follow the vague verb with a clause that names what it actually does.

---

**L5: Caveat prefaces (general)**
- Pattern: Sentence-initial hedging that manages tone rather than adding content — *That said, With that in mind, It should be noted that, It's important to, You should, Bear in mind that*.
- Max frequency: 1 per 300 words.
- Allowed contexts: Diplomatic email where tone management is part of the purpose. Compliance or legal text where safety or scope qualifications must be signposted. Beginner-facing tutorials where softening is pedagogically useful.
- Preferred alternatives: State the caveat itself directly, using *but, however, note:*, or structure the caveat as its own sentence.

---

**L6: Bilateral hedging ("while X, Y is also true")**
- Pattern: Concession-and-counter constructions that present every position as equally valid and avoid taking a side — *While X is powerful, Y also has its strengths. Both options have merit. The right choice depends on your needs.*
- Max frequency: 1 per 500 words; only when both sides are genuinely being argued.
- Allowed contexts: Genuine pros/cons technical comparisons. Policy analysis where presenting multiple positions is the stated goal. Procurement evaluations before scoring is complete.
- Preferred alternatives: State the recommendation, then name the exception. "Use PostgreSQL. Switch to MongoDB only when nested-document queries dominate."

---

**L7: "Not only...but also" parallel construction**
- Pattern: Correlative conjunctions that add a second item with unnecessary rhetorical emphasis — *not only improves performance but also enhances reliability, not only a tool but also a partner*.
- Max frequency: 1 per 800 words.
- Allowed contexts: Persuasive rhetoric and speeches where parallel structure is the genre convention. Contrastive academic prose where the construction carries argumentative weight.
- Preferred alternatives: Simple coordination: "X and Y." Or two direct sentences.

---

**L8: Cadence flattening**
- Pattern: A run of 4 or more consecutive sentences within 5 words of the same length, creating a uniform rhythmic signature.
- Max frequency: 0 consecutive same-length runs of 4+. Per 500 words: ensure at least 1 sentence under 8 words and at least 1 sentence over 30 words.
- Allowed contexts: Step-by-step procedural instructions where controlled syntax improves scanning. Reference documentation where uniformity is an intentional design choice. ESL-targeted content.
- Preferred alternatives: Vary sentence length deliberately. Follow a long sentence with a short one for emphasis. Use a single-sentence paragraph for a decision, action, or key claim.

---

**L9: Formulaic paragraph architecture**
- Pattern: The same paragraph shape repeating across 3 or more consecutive paragraphs — typically: broad importance claim → list of three supports → bland takeaway.
- Max frequency: 2 consecutive same-structure paragraphs; no more.
- Allowed contexts: Teaching materials where explicit rhetorical structure is being modeled. Standardized test-prep writing.
- Preferred alternatives: Choose paragraph structure by intent — compare, contrast, cause/effect, decision, example, counterargument. Let the content determine the shape.

---

**L10: Triple-adjective stacking**
- Pattern: Three adjectives modifying a single noun, usually all positive and overlapping in meaning — *powerful, flexible, and intuitive; clear, concise, and actionable; fast, flexible, and scalable*.
- Max frequency: 1 per 500 words.
- Allowed contexts: Marketing copy where adjective stacking is the register. Speeches and slogans where the triad is intentional. UI principles or brand guidelines.
- Preferred alternatives: Pick the one most accurate adjective. Or replace the adjective cluster with a concrete demonstration.

---

**L11: "At its core / fundamentally / essentially" essence-claims**
- Pattern: Phrases that announce a forthcoming reductive definition without earning it — *At its core, Fundamentally, Essentially, At the end of the day* (used to introduce a simplification).
- Max frequency: 1 per document.
- Allowed contexts: Philosophical writing where the essence-claim is the argument. Pedagogical writing introducing a new model from scratch where reduction is deliberate.
- Preferred alternatives: Show the essence rather than declaring it. Name the concrete mechanism. If the simplification is valid, make it the main sentence.

---

**L12: Instructional ceremony**
- Pattern: Imperative-with-preamble constructions that soften a direct instruction unnecessarily — *It's important to, You should always, Make sure to, Remember to, Don't forget to* preceding straightforward directives.
- Max frequency: 1 per section; strong preference for direct imperative.
- Allowed contexts: Beginner tutorials where tone softening is appropriate. Compliance documentation where calling out priority is required.
- Preferred alternatives: Direct imperative ("Test your backups."). Or state the consequence of not doing it ("A backup you haven't restored isn't a backup.").

---

**L13: Colon-then-capitalized inline pseudo-list**
- Pattern: Using a colon to introduce a fake list inside flowing prose rather than choosing between real bullets and real prose — *There are three things to consider: First... Second... Third...; Two factors matter: Speed and accuracy.*
- Max frequency: 1 per 1000 words; prefer zero.
- Allowed contexts: Legal or contractual prose where enumerated lists in sentence form are conventional. Short technical summaries where a true list would over-format a brief point.
- Preferred alternatives: Use a real bulleted or numbered list, or write three actual sentences with no fake enumeration.

---

**L14: Contraction avoidance in conversational registers**
- Pattern: Writing "it is" / "you are" / "do not" / "we have" in contexts where a human writer would naturally use contractions — *it's, you're, don't, we've*.
- Applies when: The domain is email, blog posts, documentation, professional prose, or educational explainers targeting general audiences.
- Max frequency: 0 forced avoidances per document (use contractions where natural).
- Allowed contexts: Legal contracts, academic theses, and formal policy documents where a formal register is required.
- Preferred alternatives: Use contractions where a human expert writing to a peer would use them. Read aloud: if it sounds stiff, contract it.

---

### 3. Punctuation Constraints

**PC1: Em dash density**
- Cap: ≤1 em dash per 300 words of prose. No double em-dash pairs within the same paragraph.
- Context override: Literary nonfiction where em dash voice is intentional — loosen to ≤1 per 200 words, but only when the dash serves rhythm, not parenthetical convenience.

**PC2: Colon-led thesis sentences**
- Avoid repeating the "single word or phrase: [capitalized elaboration]" pattern in consecutive paragraphs. One colon-led thesis sentence per 300 words is acceptable.

**PC3: Semicolon chains on balanced abstractions**
- Avoid semicolons joining abstract noun phrases that create a polished but vacuous rhythm: "Trust; transparency; accountability." If the three items need a semicolon, they need a real sentence each.

**PC4: Punctuation variance check**
- When a draft is complete, read it aloud. If one punctuation pattern (dash, colon, semicolon) appears in more than 40% of paragraph-ending sentences, reduce it.

---

### 4. Syntax and Cadence Constraints

**SC1: Sentence length distribution**
- Every 500 words of prose should contain at least one sentence under 8 words and at least one sentence over 30 words.
- No run of 4+ consecutive sentences within 5 words of the same length.

**SC2: Tricolon cap**
- Cap *A, B, and C* triads at 1 per 500 words. When a triad must be used, vary list length elsewhere in the same paragraph (use a two-item list or a four-item list nearby).

**SC3: Participial summary clause**
- The construction *[triad], [verb]ing [benefit]* (e.g., "It's fast, cheap, and reliable, ensuring a better experience") is limited to 1 per 500 words. Never in consecutive paragraphs.

**SC4: Repeated paragraph opener types**
- No more than 2 paragraphs in a section should start with the same grammatical structure (subject + verb, it + verb, there + is/are, prepositional phrase, etc.).

---

### 5. Discourse Constraints

**DC1: Lead with content, not framing**
- The first sentence of every section must name the actual subject and do something with it. Framing sentences ("In this section, we will...", "There are several aspects to consider...") are prohibited in the first-sentence position.

**DC2: End on implication, not restatement**
- Sections and documents should end on a decision, consequence, or concrete next action. Ending on a pure restatement of what was just said ("This shows that X is important") is a Limit-tier defect.

**DC3: State recommendations directly**
- When the evidence supports a recommendation, state it. Default to both-sides framing only when the decision genuinely depends on unresolved variables; in that case, name those variables specifically rather than leaving the decision to the reader.

**DC4: Comprehensiveness claims require scope statements**
- Claims of completeness or authority (*comprehensive guide, everything you need to know, the ultimate resource, all you need*) must be followed immediately by a literal scope statement ("This guide covers pod security settings for small platform teams"). Unsupported comprehensiveness claims are a Limit-tier defect.

---

### 6. Exception Policy

- **Technical precision terms:** Technical terms that happen to match banned patterns (*robust* meaning fault-tolerant, *optimize* meaning profile-guided, *critical* in a severity classification system) are permitted in their technical sense. The test is substitution: if replacing the word with a generic synonym loses technical meaning, the use is allowed.
- **Domain override:** Domain calibration (Section 8) may loosen or tighten specific rules. Domain-specific exceptions take precedence over the general tier assignment.
- **Intentional register use:** Marketing copy, formal speeches, and classroom writing that deliberately use a pattern for its register value (e.g., "In conclusion" in a student essay, triads in a speech) are exempt, provided the pattern is used intentionally and not by default.
- **Author voice:** Any pattern that is a documented feature of the author's established voice, not a default drift, may be retained under the voice-preservation safeguard.
- **Log exceptions:** Each exception applied during editorial review should be noted in review metadata so it can be revisited during the next synthesis cycle.

---

### 7. Voice-Preservation Safeguards

- **Do not flatten to corporate generic.** The goal is to remove AI-drift patterns, not to produce a generic clear style. An idiosyncratic human voice that breaks several rules deliberately is preferable to a clean voice that breaks none.
- **Preserve author-specific diction.** Idiom, humor, opinion, and unconventional word choices that are consistent with the author's documented style should survive the edit unchanged.
- **Test edit reversions.** At least one banned-pattern correction per session should be interrogated: would reverting it improve the sentence? If yes, revert it and note why.
- **Voice check.** After applying rules, read the draft aloud. If it no longer sounds like the author, undo the edits that created the distance.
- **Clarity test.** Validate that each edit improves specificity, not just rule compliance. If an edit makes the sentence more generic, it has failed.

---

### 8. Domain Calibrations

**Technical / documentation**
- Rules that stay maximally strict: P1 (filler verbs), P2 (prestige metaphors), P3 (grand openers), P4 (meta-announcements), P5 (padding phrases), P8 (anthropomorphism), L4 (vague benefit verbs).
- Rules that soften: L8 (cadence flattening) can relax for step-by-step procedures where controlled syntax aids scanning. L13 (pseudo-lists) is acceptable for short inline enumerations. "Robust" and "dynamic" are allowed in their technical senses.
- Additional strictness: Anthropomorphism (P8) applies most critically here — saying "the code thinks" in documentation actively misleads about system behavior.

**Educational / explainer**
- Rules that stay strict: P3 (grand openers), P4 (meta-announcements), P5 (padding phrases), P6 (benefit wraps), L2 (conclusion openers).
- Rules that soften: L3 (formal transitions) can ease slightly to guide novice readers through complex logic. L12 (instructional ceremony) allows moderate softening for beginner-facing content where directness is unwelcoming.
- Watch especially: L8 (cadence flattening) and L9 (formulaic paragraph architecture) — explainers drift toward both constantly.

**Professional writing (emails, posts, memos)**
- Rules that stay maximally strict: P4, P5, L1 (adjective inflation), L2 (conclusion openers), L4 (vague benefit verbs), L6 (bilateral hedging).
- Additional strictness: L14 (contraction avoidance) is strictly enforced — professional prose should sound human. DC3 (state recommendations directly) is the most important discourse rule here; busy readers need decisions and next steps.
- Rules that soften: L5 (caveat prefaces) allows one caveat per email when relationship management is part of the purpose.

**Creative nonfiction**
- Rules that stay maximally strict: P1 (filler verbs), P2 (prestige metaphors), P3 (grand openers), L10 (triple-adjective stacking). These are absolute — literary writing requires earned language, not stock patterns.
- Rules that soften significantly: PC1 (em dash density) can relax to 1 per 200 words when it serves rhythm. SC2 (tricolon cap) can loosen if repetition is building meaning intentionally. L8 (cadence) rules are the author's tools; break them deliberately, not by drift.
- Voice-preservation priority: highest of all four domains. An idiosyncratic voice that breaks many rules deliberately is the goal, not a problem.

---

## Appendix: Provenance and Confidence

This appendix records which runs supported each rule and the basis for tier assignment.

| Rule | Tier | Supporting vendors | Min confidence | Max confidence | FPR across runs | Evidence type |
|---|---|---|---|---|---|---|
| P1: Filler verbs | Ban | Anthropic, OpenAI, Google | 90 | 95 | Low (all runs) | Corpus-backed, cross-model-observed |
| P2: Prestige metaphors | Ban | Anthropic, OpenAI, Google | 88 | 95 | Low (all runs) | Cross-model-observed |
| P3: Grand-opening clichés | Ban | Anthropic, OpenAI, Google | 88 | 95 | Low (all runs) | Cross-model-observed |
| P4: Meta-announcement sentences | Ban | Anthropic, OpenAI, Google | 86 | 95 | Low (all runs) | Cross-model-observed, external-guide-backed |
| P5: Padding phrases (specific) | Ban | Anthropic, OpenAI (codex) | 90 | 93 | Low (2 runs), Medium (2 runs) | Cross-model-observed, external-guide-backed |
| P6: Generic benefit-wrap sentences | Ban | Anthropic | 86 | 86 | Low | Cross-model-observed — single-run; flag for next synthesis |
| P7: Quantitative inflation metaphors | Ban | Anthropic | 90 | 90 | Low | Cross-model-observed — single-run; flag for next synthesis |
| P8: Anthropomorphism | Ban | Google (gempro) | 100 | 100 | Low | External-guide-backed (AP Stylebook) — single-run; flag for next synthesis |
| L1: Adjective inflation | Limit | Anthropic, OpenAI, Google | 80 | 88 | Mixed (Low/Medium) | Cross-model-observed |
| L2: Conclusion openers | Limit | Anthropic, OpenAI, Google | 85 | 90 | Mixed (Low/Medium) — near-Ban | Cross-model-observed |
| L3: Formal transition stack | Limit | Anthropic, OpenAI, Google | 82 | 85 | Medium (all runs) | Corpus-backed, external-guide-backed |
| L4: Vague benefit verbs | Limit | OpenAI, Anthropic | 79 | 82 | Medium | External-guide-backed |
| L5: Caveat prefaces (general) | Limit | Anthropic, OpenAI, Google | 70 | 80 | Medium | External-guide-backed |
| L6: Bilateral hedging | Limit | Anthropic, OpenAI | 72 | 85 | Medium | Cross-model-observed |
| L7: Not only…but also | Limit | Anthropic, OpenAI, Google | 65 | 76 | Medium | Model-observed |
| L8: Cadence flattening | Limit | OpenAI, Google | 85 | 90 | Mixed (Low/Medium) | Corpus-backed |
| L9: Formulaic paragraph architecture | Limit | OpenAI, Google | 68 | 75 | Medium | Model-observed |
| L10: Triple-adjective stacking | Limit | Anthropic, OpenAI | 78 | 78 | Medium | Model-observed |
| L11: Essence-claims | Limit | Anthropic, OpenAI | 78 | 80 | Medium | Cross-model-observed |
| L12: Instructional ceremony | Limit | Anthropic, Google | 70 | 80 | Medium | Model-observed |
| L13: Colon pseudo-list | Limit | Anthropic | 70 | 70 | Medium | Model-observed — single-run |
| L14: Contraction avoidance | Limit | OpenAI (codex) | 90 | 90 | Medium | Model-observed — single-run |

**Single-run rules (P6, P7, P8, L13, L14):** Included because the evidence is coherent and the external backing is strong (P8) or the marker is low-risk to enforce (P6, P7). Treat as provisional. Promote to multi-vendor confirmed in the next synthesis cycle if additional runs corroborate.
