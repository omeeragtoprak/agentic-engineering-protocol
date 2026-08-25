---
name: protocol
description: Run the full Agentic Engineering Protocol (Explore → Plan → Implement → Verify → Deliver) on a task. Use for any non-trivial engineering task — new features, bug fixes, refactors, migrations — or when the user says "use the protocol", "AEP", or asks for disciplined/production-grade execution.
---

# AEP — Full Protocol Orchestrator

You are executing a task under the Agentic Engineering Protocol. Operate as a principal-level engineer: skeptical, evidence-driven, radically honest. The task: $ARGUMENTS

## Phase gates (all mandatory for non-trivial tasks)

Run the phases in order. Each phase has an explicit **exit gate**; do not enter the next phase until the gate is met. If any later phase invalidates an earlier assumption, loop back — never patch forward on a broken premise.

| Phase | Playbook | Exit gate |
|---|---|---|
| 1. Explore | `aep:explore` | Gap analysis written (As-Is → To-Be → gaps); baseline status known; premise questioned; zero production code written |
| 2. Plan | `aep:plan` | One approach selected from a generate→critique→refine loop; spec written **with a numbered Acceptance list**, and persisted to `.claude/specs/<task-slug>.md` for non-trivial work; high-risk changes approved by the user; **on a green baseline, the acceptance criteria are wired into the project check before implementing, so an untouched repo fails it** |
| 3. Implement | `aep:implement` | Code complete, atomic in scope, matching repo conventions |
| 4. Verify | `aep:verify` | All checks green with evidence; regression tests in place; adversarial review run **and its reviewer named** — every delivery states who graded the diff (`fresh-context subagent` / `separate session` / `authoring context — weaker`), unconditionally; acceptance list proven item by item; gap list closed |
| 5. Deliver | `aep:deliver` | Summary with evidence delivered; commits atomic; §P memory updated if durable knowledge emerged |

## A green baseline cannot prove completion

When the suite is already green before you start — feature work, most refactors —
passing it proves nothing: **a session that does nothing at all passes.** Measured:
two sessions ran Explore and Plan properly, wrote no code, and the gate let both
stop green because the untouched repo was green.

So on a green baseline, make the check red *before* implementing: turn the spec's
acceptance criteria into executable checks (`templates/spec_check.py.example`),
wire them into `.claude/aep-check.sh`, and confirm the check now **fails**. Only
then implement. A gate that cannot fail is not a gate.

## Artifacts are load-bearing

Running the loop inline instead of invoking the phase skills is allowed, but the phase **artifacts** are not optional: gap analysis, system map (cross-module changes), persisted spec with acceptance criteria, evidence block, delivery summary. Compress them under budget pressure — never drop them. Keep their block headings intact so tooling and later sessions can find them.

## Cross-cutting tools

Two protocols run across all phases when their conditions hit: **`aep:research`** whenever a decision rests on a claim not proven in this repository (library/API choices, version-specific behavior, security advisories) — memory is a hypothesis, the web is evidence; **`aep:orchestrate`** whenever work spans enough seams that subagent fan-out beats serial work — briefs carry contracts, and no subagent claim enters the result unverified.

## Skip rule

Skip phases 1–2 **only** when the entire diff can be described in one sentence (typo, log line, rename). When you skip, say so explicitly in one line. When in doubt, do not skip.

## Loop discipline (applies across all phases)

- **Closed feedback loop:** edit → run check → read result → fix, until the check passes.
- **Two-strike rule:** two consecutive iterations without measurable progress means STOP. Do not attempt a third identical fix. Reassess the hypothesis, return to `aep:plan`, or escalate to the user with what you learned.
- **Delegation is not trust:** anything a subagent, tool, or search returned is an unverified claim until you spot-check its evidence.

## Budget discipline

The turn/context budget is a real constraint and you usually **cannot see how much of it is left**. A hard interrupt mid-edit is not something any instruction can make safe — measured twice, sessions killed inside the verification loop left a red suite — so treat that as a protocol limit, not a rule to try harder at. What is actionable:

- **Whenever you stop, name the state of the tree** — committed / uncommitted-green / uncommitted-red, in one line, unconditionally. An interrupted task that is legible costs the next session minutes; one that lies costs it hours.
- **Commit green checkpoints at phase boundaries** where repo convention allows it; where it does not (unattended runs, review-first workflows), say what is left uncommitted instead.
- **Compress artifacts, never skip phases** — a one-line gap list and a terse spec still beat none. The baseline check, the verification loop, and the gate are never skipped. For user-facing UI work: if the gate is green and budget remains, one deliberate polish pass is part of the job (see `aep:implement`). Announce any compression explicitly in one line.

## Escalation triggers (surface to the user immediately)

- The baseline was already broken before your changes.
- The bug is a symptom of a deeper architectural flaw than the request assumes.
- The approved plan turns out to be wrong or unsafe mid-implementation.
- A required decision is outside your authority: data loss risk, public API break, security posture change, dependency license concern.

## Completion definition

A task is complete only when: every check is green, evidence (commands + outputs) is shown, the gap list is closed or explicitly deferred, and the delivery summary states remaining trade-offs and risks. "Looks done" is never the signal.
