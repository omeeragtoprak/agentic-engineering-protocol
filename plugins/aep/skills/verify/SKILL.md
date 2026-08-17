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
- **Name every suppressed test.** Skips, `expectedFailure`/`xfail`, and disabled cases satisfy a green exit code while the assertion behind them is not enforced — the gate cannot tell the difference. The evidence block names each one and why, unconditionally; a suppression nobody mentions is indistinguishable from a defect nobody found.
- **Test integrity:** never weaken, skip, or delete an existing test to get the gate green — the gate reports uncommitted test-file changes, and any legitimate test change (rename, strengthened assertion, new case) must be named and justified in the delivery summary.

## 3. Adversarial review (fresh context)

The agent that wrote the code does not grade it. For significant diffs:

- **Claude Code:** invoke the `aep:adversarial-reviewer` subagent with the diff and the spec.
- **Isolation matters:** give reviewers the diff and the spec — **never your reasoning, draft summary, or expected verdict**. A verifier that sees the author's conclusion tends to repeat it instead of testing it; that isolation is what makes fresh-context review work.
- **Other tools:** open a fresh session/context, paste only the diff + spec, and instruct: *"Try to refute this implementation against the spec. Report only gaps affecting correctness or stated requirements — not style preferences."*

**Name the reviewer, always.** Every delivery states who graded the diff — `fresh-context subagent`, `separate session`, or `authoring context (weaker: the context that wrote the code graded it)`. This is one line, unconditional: there is no case where the reviewer is unnamed. When no fresh context is available, run the review pass anyway and name the authoring context — an unavailable reviewer must never silently become no review.

Treat findings skeptically in both directions: verify each reported gap is real before fixing it (reviewers asked to find gaps will report some even in sound work), and do not dismiss a finding without evidence.

**Scale the panel with the surface.** Independent verifiers with distinct lenses catch what redundant ones cannot: for diffs touching auth, input handling, or anything user-reachable, also run `aep:security-auditor`; for diffs touching hot paths, queries, or data volume, also run `aep:performance-auditor`. Two reviewers is the floor for significant work, not the ceiling.

## 4. Gap-closure & spec-compliance audit

Re-run the Phase 1 gap list against the implemented state. Every gap is **demonstrably closed** (name the test/command that proves it) or **explicitly deferred** with a reason. "Mostly done" is not done. For large tasks, delegate this to the `aep:gap-auditor` agent.

Then walk the spec's **Acceptance list** (`.claude/specs/<task-slug>.md` if persisted) criterion by criterion — each one gets a named proof: a test, a command output, or a behavioral probe. Prefer probes that exercise the artifact (boot the server and hit the endpoint; load the page and read real pixels/console/FPS; run the CLI and assert exit codes) over static pattern-matching on the source.

## 5. Evidence block (mandatory output)

```
## Verification Evidence
Build:      <command> → <exit status / summary>
Lint/Types: <command> → <result>
Tests:      <command> → <X passed / Y failed / each skipped-or-xfail test named + why>
Spec:       <n/n acceptance criteria proven (checker or named probe)>
Regression: <test name> → fails on <pre-fix ref>, passes on HEAD
Review:     <reviewer: fresh-context subagent | separate session | authoring context (weaker)> → <findings count → resolved/rejected-with-reason>
Gaps:       <n/n closed; deferred: ...>
```

Paste real output snippets, not paraphrases. Evidence the user can re-run beats prose every time.

## Exit gate

All green · evidence block written · review findings resolved · gap list closed. Proceed to `aep:deliver`.
