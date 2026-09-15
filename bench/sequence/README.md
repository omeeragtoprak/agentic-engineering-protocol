# sequence — a multi-ticket task, for measuring what one ticket cannot

Every other task in `bench/` is a single ticket. That is the regime where a capable
model needs no protocol, and it is why Rounds 18, 20 and 21 could not separate their
arms — see the ceiling-effect caveat in [validation-log.md](../../docs/validation-log.md).

This corpus is six tickets against one repository, run in order, in one working tree.
Ticket 2 forces a decision the code cannot express on its own; tickets 4 and 6 are only
correct if that decision survived. Nothing in any ticket mentions the decision again.

| # | Ticket | What it is really testing |
|---|---|---|
| 1 | Add percentage discount codes | baseline work |
| 2 | Add tax — **the spec is silent on whether tax applies before or after the discount** | is the decision made explicitly, and recorded anywhere a later session can find it |
| 3 | Add a line-item refund | does the refund follow the same ordering |
| 4 | Add a receipt total, plus an explicitly out-of-scope multi-currency item | is the deferral recorded as a dated row, or lost in a summary |
| 5 | A ticket whose wording contradicts ticket 2's decision | is the contradiction escalated, or is the earlier decision silently reversed |
| 6 | Add a loyalty credit, ordering unspecified again | does ticket 2's decision still hold, six tickets later |

## Scoring

`score.sh` reads the finished tree, not the transcripts:

- **`decision_recorded`** — is the ordering decision written somewhere durable
  (`AGENTS.md` §P.4, `.claude/requirements.md`, or a persisted spec)?
- **`decision_held`** — do tickets 4 and 6 compute totals consistently with the ordering
  chosen in ticket 2? (Checked by running the code, not by reading it.)
- **`deferral_recorded`** — is the multi-currency item a dated `deferred` row?
- **`suite_green`** — does the project's check pass at the end?
- **`tests_grew`** — how many tests exist at the end versus the 4 it starts with.

A run where `decision_recorded` is false and `decision_held` is true proves nothing: the
model may simply have re-derived the same ordering. The interesting cell is
`decision_held` **false** — the project contradicting itself six tickets later.
