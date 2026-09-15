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

Plus one task of a different kind:

| Task | Module | What it plants |
|---|---|---|
| [`retry-crossmodule`](retry-crossmodule/) | HTTP helper with two callers | no bug — a **design tension**: one shared helper, two callers with opposite latency budgets, and a correctness question (which failures are transient?) that cannot be answered from the repo. Baseline is green; see its README for the separate scoring guide. |
| [`sequence`](sequence/) | order pricing, **six tickets in a row** | no bug either — a **decision that has to survive**. Ticket 2's spec is silent on whether tax applies before or after a discount; ticket 6 adds a fixed credit whose total differs by ordering ($75.60 against $76.40), and says nothing about it. The scorer runs the finished code and reports which ordering it produced, whether the decision was written down anywhere durable, and whether ticket 4's out-of-scope item became a dated deferral. Built because every other task here is a single ticket, and single tickets stopped separating the arms. |

## Protocol

1. Copy a task directory to a scratch location; `git init && git add -A && git commit`.
2. Give the agent under test **only** the text of `TICKET.txt` (both arms get identical prompts; for the AEP arm, initialize the repo with `/aep:init` first and run via `/aep:protocol`).
3. When the session ends, score with `./score.sh <scratch-dir> <task>`.

`score.sh` reports: suite state at exit · **original assertions intact** (the
pristine tests from this directory re-run against the fixed code — catches
gate-gaming by test-weakening) · tests added.

## Measuring a run

Count behaviors from the **session transcript** (`~/.claude/projects/<slug>/<session>.jsonl`, one JSON object per line — count `tool_use` entries by name), not from the harness result JSON: its `usage.server_tool_use.web_search_requests` counter reads 0 even for sessions that ran several searches, and a single unreliable instrument produces confident wrong findings.

## Method notes & honesty

- Single-run comparisons, not statistical benchmarks. Report per-arm scores; never mix arms across rounds.
- In AEP's own 26-session bug-fix campaign (2 models × arms, tasks incl. these), **both** arms went green on every task; the measured differences were enforced verification (13/13 vs 0/13 sessions), regression tests added (+6 vs +0), and integration-test depth on build tasks (13 vs 8). Publish what you measure — including ties.
