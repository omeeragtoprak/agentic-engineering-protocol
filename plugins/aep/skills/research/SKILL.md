---
name: research
description: Deep, source-triangulated web research inside engineering work — decompose the topic into sub-branches, search from multiple angles, require independent sources, check recency and versions, and label everything unverified. Use before choosing a library/API/architecture, when working with fast-moving or unfamiliar technology, for security advisories, or whenever a decision rests on a claim not proven in this repository.
---

# AEP — Research Protocol

**Hard rule: memory is a hypothesis, the web is evidence, and one source is an anecdote.** Anything version-specific, fast-moving, or decision-critical gets researched, not recalled.

## 1. Decompose before searching

State the research question in one line, then split it into its **sub-branches** — the questions that must each be answered for the main answer to stand (mechanism, alternatives, limits, security posture, maturity/maintenance, version compatibility with §P.1). A topic is not researched until its load-bearing sub-branches are.

Gate yourself Self-Ask style: *"What must be true for my current belief to hold — and which of those have I actually checked?"* Unchecked items are the search queries.

## 2. Search from multiple angles

One phrasing finds one community's answer. For each sub-branch, vary the angle: official docs/changelog · the source itself (repository code, issues, release notes) · academic (arXiv/ACL/conference) where the claim is scientific · practitioner reports (postmortems, benchmarks, discussions) · **the negative angle** ("X problems", "X vs Y", "migrating away from X"). If every result agrees suspiciously, you searched one angle.

## 3. Triangulate or label

- A claim used for a decision requires **≥2 independent sources** — independent means not citing each other and not the same author/vendor. Vendor claims about the vendor's product count once, at half weight.
- Separate **claim / evidence / opinion** while reading. Benchmarks and reproduction steps are evidence; blog assertions are claims; "best practice" without a mechanism is opinion.
- Decompose big claims into individually checkable questions and check them separately — short, targeted questions get more accurate answers than one sweeping one.
- Anything that fails triangulation ships with an explicit **(unverified)** label, exactly like §P discipline. Never silently promote an unverified claim into a decision.

## 4. Recency & version discipline

- Date every source; prefer primary and current. A 2023 answer about a 2026 API is a hypothesis, not an answer.
- Pin claims to versions: "X supports Y" is meaningless — "X ≥ 2.3 supports Y, we run 2.1 (§P.1)" is actionable.
- Deprecations, CVEs, and license changes are checked against the official source, not a summary of it.

## 5. Research output (mandatory format)

```
## Research: <question>
Answer:     <one line>
Evidence:   <finding → source(s) + date; evidence BEFORE confidence>
Unverified: <claims that failed triangulation, labeled>
Impacts:    <what this changes in the plan/spec; version pins for §P>
```

State supporting evidence **before** stating any confidence — confidence claimed without evidence first is systematically inflated. Durable findings (version pins, chosen-over rationale) go to §P.4 as a dated line.

## Exit gate

Sub-branches enumerated and covered · decision-bearing claims triangulated or labeled unverified · sources dated and versioned · output block written.
