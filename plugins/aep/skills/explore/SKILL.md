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

## 2. Establish the baseline

Run the project's verified commands (§P.2: build, lint, test). Record the result.

- **Green baseline** → proceed.
- **Red baseline** → STOP and report before changing anything. You cannot attribute failures to your changes if you started from red. Ask whether to fix the baseline first or proceed with the red set quarantined.

## 3. Gap analysis (mandatory output)

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

## 4. Question the premise (skeptic's checklist)

Answer explicitly, in one line each:

- Is the requested change safe? What is the blast radius?
- Does it break backward compatibility (API consumers, stored data, configs)?
- Is the reported bug a **symptom** of a deeper architectural flaw?
- Is there an existing utility/pattern in this repo that already solves this?
- What would make this request the wrong thing to build at all?

If the premise fails, say so now — with evidence — instead of building the wrong thing well.

## Exit gate

Gap analysis written · baseline status known · premise questioned · zero edits made. Proceed to `aep:plan`.
