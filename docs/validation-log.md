# Validation log

AEP is tested the way it asks you to test: behaviorally, on real tasks, with the
failures published next to the wins. Each entry records what was measured, what
held, and what did not.

## How runs are measured

Count behaviors from the **session transcript**
(`~/.claude/projects/<slug>/<session>.jsonl`; one JSON object per line, count
`tool_use` entries by name), not from the harness result JSON — its
`usage.server_tool_use.web_search_requests` counter reads 0 for sessions that
demonstrably ran several searches. Verify implementations with **behavioral
probes against the real interface**, never by grepping source text: during these
rounds, source-grep probes produced three false failures in a row (`retries=1`
missed because the code used a dict key; "no tests added" because tests went to a
new file; "retry broken" because the API took a policy object, not kwargs).

## Round 1 — v1.3.0, cross-module retry task (n=2)

Task: add retry with backoff to a helper shared by an interactive caller and a
nightly batch caller, without breaking either. Same ticket, two independent
sessions.

**Held (2/2):** research reflex fired (7 searches + 6 fetches total, primary
sources incl. RFC 9110 and language docs, with empirical runtime verification
where sources were vague) · cross-module reasoning produced *opposite* per-caller
latency budgets (behaviorally measured: interactive 2 attempts / ≤0.1 s backoff
vs batch 5–7 attempts / 2–3.7 s) · suites hardened (3 → 37 and 3 → 33 tests,
green) · permanent failures not retried · backward compatibility preserved by
default · §P updated with dated decisions and empirically discovered gotchas.

**Failed (0/2):** the spec was never persisted to `.claude/specs/`.

**Diagnosis:** the persistence rule lived only in the `aep:plan` skill body. An
agent running the loop inline never loads a phase-skill body, so the rule was
invisible. One session rationalized the omission ("the repo has no docs
directory") rather than following a rule it had never seen.

**Fix (v1.4.0):** move load-bearing artifact rules into the always-visible
orchestrator exit gates.

## Round 2 — v1.4.0, same task (n=2)

**Held (2/2):** spec persisted to `.claude/specs/` with a numbered acceptance
list — the 0/2 → 2/2 change confirms the diagnosis · research reflex again (3
searches + 5–6 fetches each) · atomic commits, clean trees · behavioral probe
6/6 on both implementations (permanent 404 not retried; transient 503 and bare
`TimeoutError` retried and recovered; default call still single-attempt;
interactive path measurably cheaper than batch).

**Failed (0/2):** reviewer provenance was never disclosed. Neither session had
subagents available, neither ran a fresh-context review, and neither said so.

**Diagnosis:** the v1.4.0 rule sat in the right layer but had the wrong shape. A
*conditional negative* ("if you could not do X, say so") competes with the
summarizing instinct and gets dropped; the *unconditional positive* that landed
in the same round (write the spec file) stuck. Related observation: named
template fields are not reproduced verbatim — both sessions produced an
`## Evidence` section but neither emitted the `Review:` row, and neither used the
delivery-summary field names. Agents reproduce substance, not format.

**Fix (v1.4.1):** make reviewer provenance unconditional — every delivery names
who graded the diff (`fresh-context subagent` / `separate session` /
`authoring context (weaker)`), with no branch to forget.

**Open:** whether the unconditional form holds. Not yet re-measured; this entry
will be updated with the result rather than quietly dropped.

## Standing caveats

- n=2 per round is a signal, not statistics. A 0/2 → 2/2 flip after a targeted
  change is reported as a confirmed diagnosis; anything narrower is reported as
  a hint.
- Headless sessions do not use subagents by default, so fresh-context review is
  structurally unavailable there. Rounds 1–2 therefore say nothing about the
  quality of AEP's review subagents — only about disclosure behavior.
