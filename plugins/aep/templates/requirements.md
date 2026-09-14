# Requirements ledger

One row per requirement this repository has committed to. It is the answer to
"where does this project stand" for a session that has never seen it before —
and, unlike prose, it is checkable: `.claude/trace.py` fails when a row stops
being true.

**Status:** `open` (agreed, not built) · `done` (built, proof named) ·
`deferred` (decided not now — needs a date and a reason) · `dropped` (decided
never — the row stays, so the decision is not re-litigated every quarter).

**Proof** is required for `done` and must be checkable: a test name that exists
in the codebase, or `cmd: <command>` that exits 0. "It works" is not a proof.
A proof that disappears is a failure, not a cleanup — that is what keeps the
ledger honest as the code moves.

**Source** points at the spec the requirement came from (`.claude/specs/…`), or
`—` for requirements that predate it.

| ID | Requirement | Status | Proof | Source |
|----|-------------|--------|-------|--------|
| R1 | <one verifiable sentence — what must be true, not how> | open | — | — |
