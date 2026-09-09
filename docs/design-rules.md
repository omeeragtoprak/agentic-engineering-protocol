# Writing rules an agent will actually follow

Eight measured rounds of running AEP against real tasks produced something more
reusable than the protocol itself: evidence about **which rule shapes get
followed and which get quietly dropped**. Same model, same layer, same wording
budget — opposite adherence, decided by shape alone.

These findings apply to any `AGENTS.md`, `CLAUDE.md`, or skill file, not just to
AEP. Each one carries the measurement that produced it; where the evidence is
thin, it says so. Full transcripts and per-round detail: [validation-log.md](validation-log.md).

---

## 1. Unconditional positives are followed. Conditional negatives are dropped.

> "Always name who graded the diff" beats "if you could not get a fresh-context
> reviewer, say so."

**Evidence.** The same requirement was shipped twice in the same layer with the
same word count. As a conditional negative — *if X was impossible, disclose it* —
it was ignored in 2 of 2 sessions. Rewritten as an unconditional positive —
*every delivery names the reviewer, one of three values* — it was followed in 2
of 2, both sessions volunteering `authoring context — weaker` without being
asked. Spec persistence shows the same pattern from the other side: *write the
file* is unconditional, and it flipped 0/2 → 2/2 as soon as it was visible.

**Why.** A conditional rule competes with the summarizing instinct at exactly the
moment the agent is compressing its report. An unconditional one is a slot in
that report; a slot gets filled.

**How to write it.** Remove the `if`. If the rule only matters in an exception,
invert it: make the *normal* case state its value, so the exception is one of the
values rather than a branch to remember.

## 2. Load-bearing rules belong in the always-visible layer.

**Evidence.** The rule "persist the spec to `.claude/specs/`" lived in the `plan`
skill body. Agents that ran the loop inline — never invoking the phase skill —
never loaded that body, and 0 of 2 sessions persisted anything. One even
rationalized the omission ("the repo has no docs directory") rather than
violating a rule it had never seen. Moved into the orchestrator's Plan exit gate,
it went to 2 of 2.

**How to write it.** Ask where the rule is *readable* in the worst case, not the
best. Progressive disclosure is right for depth and wrong for anything the task
cannot be completed without.

## 3. Discrete actions survive. Continuous properties do not.

**Evidence.** "Leave a committable green state at every phase boundary" sounds
disciplined and is unenforceable: a hard interrupt lands wherever it lands, and
two measured cutoffs — one before this rule, one after — both left a red suite.
The rules that worked in the same rounds were all *acts*: write this file, name
this value, run this command.

**How to write it.** Prefer "do X at moment M" to "be in state S". If the desired
state cannot be reduced to an action the agent performs at a nameable moment,
you are writing a wish, and the honest move is to document it as a limit.

## 4. A gate that cannot fail is not a gate.

**Evidence.** Two sessions produced no code at all — no file touched, clean tree —
and both were allowed to finish, because the task's baseline suite was already
green and the completion gate only asks whether the check passes. The harness
reported success for both. Separately, a suite carrying a knowingly-broken
contract test exited 0 (via `@unittest.expectedFailure`) and the gate passed that
too.

**How to write it.** Before trusting a check as a completion signal, ask what it
does when nothing was done, and what it does when a real assertion is suppressed.
On a green baseline, make the check red *first* — turn acceptance criteria into
executable checks and confirm they fail before implementing.

## 5. Agents reproduce substance, not format.

**Evidence.** Given a template with named rows, sessions produced an `## Evidence`
section every time and the `Review:` row never. One run satisfied the reviewer
rule perfectly while writing "Graded by a fresh-context subagent" — the template
said `Reviewer:`. The information was there; the shape was not.

**How to write it.** Never let a load-bearing requirement exist *only* as a
template row. Put it in an exit gate as an action, and treat the template as a
convenience. Corollary for tooling: anything that greps agent output for exact
headings will produce false failures.

## 6. A phase report reads like a finished answer.

**Evidence.** Across two rounds, 4 of 4 small-model sessions ended cleanly — no
error, no turn-limit hit, well under budget — immediately after writing
"proceeding to Phase 3: Implement", having written no code. Structured protocols
invite this: the phase report *is* a complete-looking reply.

**How to write it.** Say explicitly that a phase boundary is not a stopping
point, and give a closed list of the places where stopping is legitimate.
Structure that organizes work also creates places to stop; name them before the
model picks its own.

## 7. Never score agent behavior by string matching.

**Evidence (methodological).** Five times across four rounds, a string-matching
metric produced a false result on agent output: `retries=1` missed because the
code used a dict key; "no tests added" because tests went to a new file; "retry
broken" because the API took a policy object rather than kwargs; "zero web
searches" from a harness counter that reads 0 for sessions that demonstrably ran
several; "reviewer not named" for a run that named it in a heading. Every one of
these was caught only by reading the artifact.

**How to measure instead.** Drive the interface and assert behavior. Count
`tool_use` entries in the session transcript rather than trusting summary
counters. When a metric says an agent failed, read the artifact before believing
it — including, especially, when the result is the one you were hoping for.

---

## What this evidence is and is not

Rounds are `n=1` or `n=2` per arm — signals, not statistics. A finding is
reported as confirmed only when a targeted change flipped a metric 0/2 → 2/2;
anything narrower is labeled a hint, and refutations are published in the same
place as confirmations. Two rules in this document were shipped, measured,
and **withdrawn or rewritten** because the evidence went against them.
