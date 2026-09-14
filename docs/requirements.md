# Requirements that outlive the session

AEP's five phases manage **one task** well. This document is about the thing one
task cannot see: what the *project* has committed to, and what proves it.

## The failure mode

Run the protocol twenty times and you have twenty specs in `.claude/specs/`, each
correct on the day it was written, none of them aware of the others. Ask a fresh
session "where does this project stand" and it does the only thing it can — reads
the code and reports what the code says, which is a description of the present, not
of the commitments. Three specific things get lost at that boundary:

1. **Deferrals.** "Explicitly deferred with a reason" is one of AEP's own exit-gate
   requirements, and it is satisfied by a sentence in a delivery summary that is read
   once and then scrolls out of the world. Six weeks later nobody can say whether
   rate-limit backoff was decided against or forgotten.
2. **Proofs that decayed.** A requirement marked done in March was proven by
   `test_retry_gives_up_after_budget`. In May someone renames the module and the test
   goes with it, or a refactor quietly deletes it. The suite is still green — it is
   green about a smaller set of claims, and nothing says so.
3. **Re-litigation.** A requirement that was considered and rejected comes back every
   quarter, because "we decided not to" lives in a chat log.

None of that is a model weakness, and no instruction fixes it: it is missing state.

## The ledger

`/aep:init` creates `.claude/requirements.md`. One row per requirement:

| ID | Requirement | Status | Proof | Source |
|----|-------------|--------|-------|--------|
| R1 | Uploads over 10 MB are rejected with 413 | done | `test_upload_rejects_oversize` | `.claude/specs/upload-limits.md` |
| R2 | Retry budget is respected under partial failure | done | `cmd: pytest -k retry_budget` | `.claude/specs/retry.md` |
| R3 | Per-tenant rate limits | deferred 2026-09-14 — single tenant until the pilot closes; revisit when tenant #2 signs | — | `.claude/specs/rate-limit.md` |

Four statuses, and the distinctions are load-bearing:

- **`open`** — agreed, not built. Written during Plan, when acceptance criteria get IDs.
- **`done`** — built, with a **named, checkable proof**: a test that exists in the
  codebase, or `cmd: <command>` that exits 0. "It works" is not a proof.
- **`deferred`** — decided *not now*, and it needs a date and a reason. Without both
  it is indistinguishable from something that was dropped on the floor.
- **`dropped`** — decided *never*. The row stays, so the decision survives instead of
  being re-proposed each quarter.

## What the checker enforces

`.claude/trace.py` (from `templates/trace.py.example`) chains into
`.claude/aep-check.sh`, so the Stop hook already guarding your tests now also guards
the ledger. It exits non-zero when:

| Condition | Why it is a failure, not a warning |
|---|---|
| A `done` row's proof no longer exists in the tree | The ledger is now claiming something nothing checks |
| A `cmd:` proof does not exit 0 | Same, with the failure already in hand |
| A `deferred` row has no date, or no reason | An unauditable deferral is a forgotten one wearing a label |
| Duplicate ID, unknown status, missing source spec | The table has stopped being a table |
| `.claude/requirements.md` is missing while `trace.py` is wired in | Silent absence is how this kind of file dies |

Three implementation details matter more than they look, and each one is pinned by
a CI scenario because each was wrong at some point in this file's short life:

- **Proof matching is word-bounded, not substring.** A proof named `GATE_SENTINEL`
  is not satisfied by a variable someone renamed to `GATE_SENTINEL_RENAMED` — a
  rename is exactly the decay this exists to notice.
- **Markdown is excluded from the corpus, and so is the checker itself.** A proof
  that "exists" because a document mentions it proves nothing; neither does one that
  exists because `trace.py`'s own docstring names it. Proofs live in code, tests, CI
  definitions, or scripts.
- **Every `|`-row must be five cells.** An earlier version skipped malformed rows as
  noise, which meant a row missing one column took a stale `done` proof and a
  duplicate ID out of the count with no diagnostic. Escape a literal pipe as `\|`,
  or put the command in a script.

A ledger that cannot fail is decoration. This one fails when it stops being true —
which also means **a proof that disappears is a failure, not a cleanup**. If a test is
renamed, the ledger row is part of the rename; if a requirement genuinely no longer
applies, the row becomes `dropped` with a reason. Both take one line. Neither is
optional, because the alternative is a file that is quietly wrong and still trusted.

## Where it plugs into the loop

| Phase | What happens to the ledger |
|---|---|
| Plan | Each numbered acceptance criterion gets a requirement ID; the rows go in as `open` |
| Verify | The evidence block's `Reqs:` line names each ID closed and the proof that closes it |
| Deliver | No row is left `open` because the session ended — `done` with a proof, or `deferred`/`dropped` with a date and a reason; then `trace.py` runs and its result is reported |
| Any time | `/aep:status` reads check state, ledger, traceability, git state and open decisions, and reports them together |

## What this deliberately is not

It is not an issue tracker, and it should not grow into one. There are no assignees,
no estimates, no sprints, no priorities, no epics — those belong in the tool your team
already argues about, and duplicating them here produces two sources of truth, which
is worse than one imperfect one. The ledger answers exactly one question an issue
tracker cannot: *is this claim still true in this tree, right now?* Jira does not know
that your test was deleted. `trace.py` does.

It is also not a substitute for the specs. A row says what must be true; the spec says
how it was decided and what was rejected. The `Source` column is the link between them.

## Honest status

Wired in v1.7.0. The checker's behavior is pinned by eighteen scenarios in CI
(`.github/workflows/ci.yml`, step *Traceability checker behavior*), and four
deliberate mutations of the checker — naked-substring matching, skipping malformed
rows, accepting an empty `cmd:`, accepting a bare date as a deferral — were each
confirmed to turn that step red, so the test is a test.

Three of those scenarios exist because a fresh-context review of this very feature
refuted it before release: the deferral rule read its reason out of the requirement
text (so every deferral passed), a malformed row was skipped in silence, and `cmd:`
with an empty command was counted as proven. The
[worked example](worked-example.md) shows what that review pass looks like.

AEP's own repository runs this on itself: [`.claude/requirements.md`](../.claude/requirements.md)
tracks eleven of AEP's commitments, and `.claude/aep-check.sh` runs the CI suite plus
`trace.py` on every gate check. Each `done` row's proof is a script in
[`.claude/proofs/`](../.claude/proofs/) that exercises the behavior — the first
version of that table named CI *step names* as proofs, and the same review showed
that gutting a step's body left every row green while the requirement was false.
Four targeted mutations (version drift, removing the gate's tamper watch, disabling
suppressed-test detection, breaking a skill's frontmatter) each turn AEP's own ledger
red.

What is **not** yet measured is the part that matters more: whether agents running the
protocol actually maintain the ledger across tasks, or whether it decays the way every
other hand-maintained project file decays. That measurement is Round 10 in
[validation-log.md](validation-log.md), and the result will be published there
whichever way it goes — as the two withdrawn rules in
[design-rules.md](design-rules.md) were.
