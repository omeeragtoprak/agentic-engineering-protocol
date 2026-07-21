---
name: verify
description: Ruthless verification — closed feedback loop until green, regression tests, adversarial review in a fresh context, gap-closure audit, and an evidence block. Use after any implementation, before declaring any task done, or when the user asks "is this actually done/correct/tested".
---

# AEP Phase 4 — Verify

**The prime directive: YOU MUST NOT declare a task complete while any check is failing — and completion claims without evidence are void.**

## 1. The verification loop

Run, in order: **build/compile → linter + type-checker → affected tests → full suite when feasible.** Then iterate:

```
edit → run check → READ the output → fix root cause → re-run
```

- Every warning, type complaint, and failure is a blocker: fix it or explicitly justify it in the evidence block.
- **Two-strike rule:** two consecutive iterations without measurable progress = STOP. Reassess the hypothesis, return to `aep:plan`, or escalate. Never suppress an error to make the loop pass (no skipped tests, no lint-disable comments, no `catch {}`) — that is falsifying evidence.

## 2. Tests for new logic

- New logic requires new tests: happy path + boundaries + failure modes.
- Bug fixes require a **regression test that fails before the fix and passes after** — run it both ways and show it.
- Tests must be deterministic and order-agnostic; mock only at architectural boundaries; never mock the unit under test.
- **Test integrity:** never weaken, skip, or delete an existing test to get the gate green — the gate reports uncommitted test-file changes, and any legitimate test change (rename, strengthened assertion, new case) must be named and justified in the delivery summary.

## 3. Adversarial review (fresh context)

The agent that wrote the code does not grade it. For significant diffs:

- **Claude Code:** invoke the `aep:adversarial-reviewer` subagent with the diff and the spec.
- **Other tools:** open a fresh session/context, paste only the diff + spec, and instruct: *"Try to refute this implementation against the spec. Report only gaps affecting correctness or stated requirements — not style preferences."*

Treat findings skeptically in both directions: verify each reported gap is real before fixing it (reviewers asked to find gaps will report some even in sound work), and do not dismiss a finding without evidence.

## 4. Gap-closure audit

Re-run the Phase 1 gap list against the implemented state. Every gap is **demonstrably closed** (name the test/command that proves it) or **explicitly deferred** with a reason. "Mostly done" is not done. For large tasks, delegate this to the `aep:gap-auditor` agent.

## 5. Evidence block (mandatory output)

```
## Verification Evidence
Build:      <command> → <exit status / summary>
Lint/Types: <command> → <result>
Tests:      <command> → <X passed / Y failed / skipped+why>
Regression: <test name> → fails on <pre-fix ref>, passes on HEAD
Review:     <findings count → resolved/rejected-with-reason>
Gaps:       <n/n closed; deferred: ...>
```

Paste real output snippets, not paraphrases. Evidence the user can re-run beats prose every time.

## Exit gate

All green · evidence block written · review findings resolved · gap list closed. Proceed to `aep:deliver`.
