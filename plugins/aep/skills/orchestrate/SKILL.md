---
name: orchestrate
description: Lead-engineer delegation — decompose work into parallelizable contracts, brief subagents without leaking your conclusions, isolate contexts, and integrate results by verifying behavior rather than trusting reports. Use when a task spans many files/subsystems, when independent verification is needed, or when fan-out across subagents would beat serial work.
---

# AEP — Orchestration Protocol

**Hard rule: a subagent's report is a claim, not a result.** In multi-agent work the dominant failure mode is inter-agent misalignment — agents confidently relaying wrong findings and validating each other's errors into "shared truth". The lead verifies; it never just collects.

## 1. Decompose like a lead engineer

- Split by **seam, not by size**: independent modules, independent questions, independent verification lenses. Two subagents editing the same file is a decomposition failure.
- Each unit of work must be *independently completable and independently checkable* — if you cannot state how you will verify a unit without seeing the others, merge or re-cut the units.
- Keep for yourself what cannot be delegated: goal ownership, integration, final verification, and anything requiring cross-unit judgment.

## 2. Brief with a contract

Every delegation carries a written contract:

```
Goal:        <one line — what done means>
Inputs:      <files/paths/context the subagent needs — no more>
Acceptance:  <numbered, checkable criteria — the integration test for this unit>
Out of scope:<what it must NOT touch>
Return:      <exact format expected back: findings + evidence, diff, list>
```

Vague briefs produce confident garbage. If you cannot write the acceptance criteria, you do not understand the unit yet — return to `aep:explore`.

## 3. Isolate contexts deliberately

- Give each subagent what its contract needs and nothing else. Context isolation is a feature: reviewers and verifiers must **never see your draft, your reasoning, or your expected answer** — a verifier that reads your conclusion tends to repeat it instead of testing it.
- Never share one agent's unverified findings with another as if they were facts; that is how wrong conclusions become consensus.

## 4. Integrate by verifying behavior

- Check each returned unit **against its acceptance criteria, mechanically where possible**: run the named test, open the cited file at the cited line, re-run the claimed command. Spot-check at minimum; fully verify anything load-bearing.
- Two agents agreeing is not evidence — they may share the same blind spot. Independent verification means a different method (execution, fresh-context review), not a second opinion phrased the same way.
- Verifiers fail too: treat verification as risk reduction, not proof. The deterministic checks (build/tests/the gate) remain the floor beneath every judgment call.
- After integration, run the **whole-system check** — units that pass alone can fail together; the seams are yours to test.

## 5. Lead's ledger

Track: units issued · contract per unit · returned/verified/rejected status · what was re-cut and why. On completion, fold durable lessons (a decomposition that worked, a brief that failed) into §P.4/§P.5.

## Exit gate

Every unit verified against its contract · seams tested whole-system · no unverified subagent claim inside the final result · ledger reconciled.
