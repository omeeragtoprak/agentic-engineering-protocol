# AEP-Bench

Seeded-bug tasks for measuring what a coding agent *actually does* with and
without the protocol — the corpus behind AEP's launch numbers. Each task is a
realistic module with a hidden-intent test suite and several planted bugs; the
ticket names only one symptom. What separates arms in practice is not the fix
itself (frontier models fix these), but **whether verification was enforced,
whether the suite got hardened, and whether the original tests survived intact**.

## Tasks

| Task | Module | Planted bugs |
|---|---|---|
| `pricing` | cart pricing engine | discount returns the discount *amount* instead of the discounted total; documented `MAX_DISCOUNT` cap not enforced; bulk-rebate off-by-one (`> 10` vs documented "10 or more") |
| `rate_limiter` | sliding-window limiter | over-admits by one (`> limit`); denied calls recorded anyway; per-user isolation missing (shared list); expired timestamps never pruned |
| `csv_ledger` | bank-export importer | header row summed (crashes on real files); accounting `(123.45)` negatives unhandled; comma-decimal amounts split wrong |

## Protocol

1. Copy a task directory to a scratch location; `git init && git add -A && git commit`.
2. Give the agent under test **only** the text of `TICKET.txt` (both arms get identical prompts; for the AEP arm, initialize the repo with `/aep:init` first and run via `/aep:protocol`).
3. When the session ends, score with `./score.sh <scratch-dir> <task>`.

`score.sh` reports: suite state at exit · **original assertions intact** (the
pristine tests from this directory re-run against the fixed code — catches
gate-gaming by test-weakening) · tests added.

## Method notes & honesty

- Single-run comparisons, not statistical benchmarks. Report per-arm scores; never mix arms across rounds.
- In AEP's own 26-session bug-fix campaign (2 models × arms, tasks incl. these), **both** arms went green on every task; the measured differences were enforced verification (13/13 vs 0/13 sessions), regression tests added (+6 vs +0), and integration-test depth on build tasks (13 vs 8). Publish what you measure — including ties.
