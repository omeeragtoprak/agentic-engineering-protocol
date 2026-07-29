# retry-crossmodule — a feature task, not a bug hunt

The other `bench/` tasks plant bugs behind a hidden-intent suite. This one plants
a **design tension** instead: `fetch_helper.get_json` is shared by two callers
with opposite constraints —

- `sync_client.sync_account` — **interactive**, a user is blocked on the call;
- `report_job.nightly_totals` — **unattended batch**, where one transient blip
  currently aborts the whole run.

The ticket asks for retry with backoff "without breaking the two callers" and
"without slowing the interactive path". Baseline is **green** (3 tests): there is
no bug to find, so a suite-passing answer is trivially available and the
interesting differences show up elsewhere.

## What this task measures

| Signal | Why it separates |
|---|---|
| **System map before editing** | The helper has two callers with *conflicting* latency budgets. An agent that edits it without enumerating callers ships one policy for both. |
| **Research on external claims** | Correct transient-failure classification is not derivable from the repo. In observed runs the naive `except URLError` handler is wrong in ~4 ways (`HTTPError` subclasses `URLError`; read timeouts arrive as bare `TimeoutError`; some errnos stay bare `OSError`; TLS verification failures are permanent). |
| **Backward compatibility** | Existing callers and their tests must keep working; a default that silently starts retrying is a behavior change worth stating out loud. |
| **Spec + acceptance criteria** | "Only transient failures" and "interactive stays fast" are checkable claims — do they end up as numbered criteria, or as prose? |
| **Reviewer provenance** | Who graded the diff, and was that said out loud? |

## Running it

1. Copy this directory to a scratch location; `git init && git add -A && git commit -m baseline`.
2. Give the agent only the text of `TICKET.txt` (for the AEP arm, `/aep:init` first, then `/aep:protocol`).
3. Score behaviorally — do **not** grep the source. Observed implementations differ
   wildly in API shape (`attempts=` kwarg, `retry=POLICY` object, module presets),
   so a probe that assumes one shape false-fails on the others. Read the real
   signature first, then drive it:
   - permanent `HTTPError(404)` → exactly one attempt;
   - transient `HTTPError(503)` then success → retried and recovered;
   - bare `TimeoutError` then success → treated as transient;
   - interactive caller vs batch caller → measurably fewer attempts and less
     total backoff on the interactive side.

## Observed results

See [`../../docs/validation-log.md`](../../docs/validation-log.md) — six sessions
across three protocol versions, including the failures.
