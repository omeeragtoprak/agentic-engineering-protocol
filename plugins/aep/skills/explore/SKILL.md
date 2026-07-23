---
name: explore
description: Read-only deep exploration and skeptical gap analysis before any code is written. Use at the start of every non-trivial task, when onboarding to an unfamiliar codebase or module, or when the user asks "how does X work here", "analyze before changing", or requests an As-Is/To-Be gap analysis.
---

# AEP Phase 1 — Explore (read-only)

**Hard rule: no production code, no file edits, no destructive commands in this phase.** Your only outputs are knowledge and a gap analysis.

## 1. Ingest

Read before reasoning — in this order of leverage:

1. The files named in the task, plus everything they import/depend on (one level out).
2. Project instruction files (AGENTS.md / CLAUDE.md §P), lockfiles, build configs, CI definitions, lint/format rules.
3. Existing tests around the affected area — they encode the real contract.
4. Recent git history of the affected files (`git log --oneline -15 -- <path>`) — it encodes intent and churn.

Match the repository's established conventions exactly; note them, don't fight them. For wide investigations (many files, unfamiliar subsystems), delegate to a subagent or a scoped search so the main context stays clean — then spot-check the findings against the actual files before relying on them.

## 2. System map (for changes crossing module boundaries)

Before editing anything that other code depends on, build a small **impact map — mechanically, not from memory** (guessed maps encode the same blind spots that cause the bug):

```
## System Map
Callers:    <who invokes the touched symbols — from grep/LSP references, not recall>
Callees:    <what the touched code invokes across module boundaries>
Data flow:  <where data enters/leaves the touched code: params, globals, DB, files, events>
Co-change:  <files that historically change together — git log --oneline -- <paths>>
Blast radius:<what plausibly breaks if this change is wrong — feeds the Test plan>
```

Use the repo's cheapest reliable instruments: `grep -rn` for references, LSP go-to-references where available, import graphs, git co-change history. Structure-aware maps consistently beat similarity-guessing for cross-module work — spend the two minutes.

## 3. Establish the baseline

Run the project's verified commands (§P.2: build, lint, test). Record the result.

- **Green baseline** → proceed.
- **Red baseline** → STOP and report before changing anything. You cannot attribute failures to your changes if you started from red. Ask whether to fix the baseline first or proceed with the red set quarantined.

## 4. Gap analysis (mandatory output)

Produce this block before Phase 2:

```
## Gap Analysis
As-Is:   <current behavior/architecture, 2–5 bullets, each verifiable in code>
To-Be:   <target behavior per the request, 2–5 bullets>
Gaps:    <numbered, explicit — technical, structural, logical>
Unknowns:<what you could not verify and how you will resolve it>
Baseline:<command(s) run + status>
```

Every As-Is bullet must be something you actually read, not something you assumed. Tag anything unverified as an Unknown — never promote an assumption to a fact.

## 5. Question the premise (skeptic's checklist)

Answer explicitly, in one line each:

- Is the requested change safe? What is the blast radius?
- Does it break backward compatibility (API consumers, stored data, configs)?
- Is the reported bug a **symptom** of a deeper architectural flaw?
- Is there an existing utility/pattern in this repo that already solves this?
- What would make this request the wrong thing to build at all?

If the premise fails, say so now — with evidence — instead of building the wrong thing well.

## Exit gate

Gap analysis written · system map built for cross-module changes · baseline status known · premise questioned · zero edits made. Proceed to `aep:plan`.
