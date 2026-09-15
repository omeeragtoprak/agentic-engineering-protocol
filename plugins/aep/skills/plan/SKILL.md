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
Acceptance: <numbered, independently checkable criteria — the contract Phase 4 walks one by one;
             give each one a requirement ID (R7, R8, …) and add it to `.claude/requirements.md` as `open`>
Risks:      <what could still go wrong + mitigation>
Out of scope:<what you are deliberately NOT touching>
```

The spec must be checkable: Phase 4 verifies the diff *against this spec*, so vague specs produce unverifiable work.

**Red-first on a green baseline.** If the baseline check already passes, it cannot
distinguish your finished work from an untouched repo — write the acceptance
criteria as executable checks, wire them into the project check, and watch it fail
before you implement. Confirming the check fails is part of the plan's exit gate,
not an optional flourish.

**Do not write those checks yourself.** One trajectory writing both the tests and the
code produces tests that agree with the code's mistakes — measured on SWE-bench
Verified as *worse than having no tests at all* (57.3% against a 61.2% no-test
baseline), while independently written ones raised it to 65.3%
([arXiv:2609.09133](https://arxiv.org/abs/2609.09133)). On Claude Code, delegate to
`aep:acceptance-author`: it gets the spec's numbered criteria and the repository, never
your plan's code or reasoning, and hands back checks that **fail now** with the command
to run them. Elsewhere, write them in a separate session with the spec alone. Commit
them before implementing, so the tests are frozen and any later edit to them shows up
in the diff and in the gate's tamper report.

**Spec-anchored persistence.** For non-trivial or multi-session work, save the spec to `.claude/specs/<task-slug>.md` and keep it updated as the source of truth: the diff converges to the spec, not the other way around. Create the directory if it is absent — a repo without a docs folder is not a reason to skip persistence. Where acceptance criteria are machine-checkable, mirror them in an executable checker (see `templates/spec_check.py.example`) and wire it into `.claude/aep-check.sh` so the verify gate enforces the spec itself, not just the test suite. Prefer behavioral checks (run the artifact, assert observable behavior) over keyword greps — greps false-fail on renamed concepts and false-pass on keyword stuffing.

## 3. Approval gate (IMPORTANT)

Present the spec and **wait for explicit approval before implementing** when the change involves any of: schema migrations · public API breaks · deletions of code, data, or files · major dependency bumps · auth/security changes · anything irreversible. For routine changes, state the spec in your response and proceed.

## Exit gate

One approach selected via the loop · spec written with a numbered Acceptance list · on a green baseline, the check made red first **by a context that is not the one about to implement**, and confirmed failing · high-risk changes approved. Proceed to `aep:implement`.
