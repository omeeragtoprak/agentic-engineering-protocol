---
name: plan
description: Structured planning with a generate→critique→refine brainstorming loop, a short tech spec, and approval gates for risky changes. Use after exploration on any multi-file, uncertain, or unfamiliar change, or when the user asks for options, alternatives, a design, or an implementation plan.
---

# AEP Phase 2 — Plan

Do not write production code in this phase. The output is a selected approach and a short spec.

## 1. Brainstorming loop: generate → critique → refine

**Generate.** Draft 2–3 genuinely distinct approaches (different architecture or mechanism — not the same idea with cosmetic variations).

**Critique.** Attack each approach skeptically against this matrix; one line per cell, no diplomacy:

| Approach | Failure modes | Hidden coupling | Scale limits | Migration/rollback | Maintenance cost |
|---|---|---|---|---|---|

Add a one-line **pre-mortem** per approach: "It is six months later and this approach failed — the most likely reason is ___."

**Refine or discard.** Fix what the critique exposed, or drop the approach. If no approach survives, loop again with what the critique taught you — do not proceed with a plan you just demonstrated is broken.

**Select.** Pick one and record *why it beat the others* in 1–2 sentences. That rationale goes into the spec and later into §P.4 (Decision Log) if the decision is durable.

## 2. Tech spec (short, mandatory)

```
## Spec: <task>
Approach:   <selected approach + why it won>
Files:      <files to create/modify>
Data/API:   <schema, contract, or endpoint changes; "none" if none>
Migration:  <forward path + rollback path; "n/a" if none>
Test plan:  <which tests prove which gaps closed — map to Gap Analysis numbers>
Risks:      <what could still go wrong + mitigation>
Out of scope:<what you are deliberately NOT touching>
```

The spec must be checkable: Phase 4 verifies the diff *against this spec*, so vague specs produce unverifiable work.

## 3. Approval gate (IMPORTANT)

Present the spec and **wait for explicit approval before implementing** when the change involves any of: schema migrations · public API breaks · deletions of code, data, or files · major dependency bumps · auth/security changes · anything irreversible. For routine changes, state the spec in your response and proceed.

## Exit gate

One approach selected via the loop · spec written · high-risk changes approved. Proceed to `aep:implement`.
