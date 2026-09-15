# Validation log

AEP is tested the way it asks you to test: behaviorally, on real tasks, with the
failures published next to the wins. Each entry records what was measured, what
held, and what did not.

## Every round at a glance

Twenty-four rounds. **Nine** carry a negative or self-correcting verdict (rounds 5, 10,
13, 14, 15, 20, 21, 23, 24 — counted from the table below, not asserted), **five** made
the project withdraw or refuse to ship something, and **three** corrected a claim this log
itself had published. That distribution is the point: a log where everything confirms the
thesis is a marketing page.

| # | What was asked | Verdict |
|---|---|---|
| [1](#round-1--v130-cross-module-retry-task-n2) | Does the protocol survive a cross-module task? | baseline established |
| [2](#round-2--v140-same-task-n2) | Does spec persistence hold? | **confirmed** 0/2 → 2/2 |
| [3](#round-3--v141-same-task-n2) | Does naming the reviewer hold when made unconditional? | **confirmed** 0/2 → 2/2 |
| [4](#round-4--v142-cross-module-task-at-a-deliberately-tight-budget-n2) | What happens under a hard budget cut? | limit found, not fixable by wording |
| [5](#round-5--does-the-gate-add-anything-the-instructions-do-not-controlled-ab-n1-per-arm) | Does the gate add anything to the instructions? | **no** — it never blocked |
| [6](#round-6--the-gate-against-a-wider-project-check-controlled-ab-n1-per-arm) | Does a wider check change that? | no |
| [7](#round-7--a-weaker-model-and-the-gates-blind-spot-controlled-ab-n1-per-arm) | A weaker model, and what the gate misses | blind spot found: a green baseline proves nothing |
| [8](#round-8--testing-red-first-and-finding-why-the-small-model-rounds-produce-nothing-n2-both-gated) | Why do small-model rounds produce nothing? | phase boundaries diagnosed |
| [9](#round-9--the-phase-boundary-fix-measured-n2-same-weak-model-same-task) | Does one sentence fix it? | **confirmed** 0/4 → 2/2 |
| [10](#round-10--does-anyone-actually-keep-the-ledger-3-conditions-n2-two-sequential-tasks-each) | Do agents keep the requirements ledger? | **refuted** — 2 rows in 12, 0 dated deferrals |
| [11](#round-11--the-ledger-fix-measured-n3-same-model-same-two-tasks) | Does the fix work? | 2/3 on feature work, 0/3 on bug fixes |
| [12](#round-12--a-conflict-audit-that-measured-nothing-n2-per-arm-inconclusive) | Does "instruction files are advisory" reduce adherence? | **inconclusive** — metric at the floor |
| [13](#round-13--the-official-harness-and-a-result-that-goes-against-the-project) | What does the official eval harness say? | **against** — Δ 0.00 on planning; skills fire on phrasing, not tasks |
| [14](#round-14--the-ledger-rule-works-through-the-hook-not-through-the-prose-official-harness-n3-per-arm) | Prose or hook? | **corrected later** — the premise was false |
| [15](#round-15--a-feature-this-project-built-measured-and-did-not-ship-n3-per-arm) | Does a session-start brief help? | **no — built, measured, not shipped** |
| [16](#round-16--reading-the-traces-instead-of-the-scoreboard-and-a-round-the-usage-limit-ate) | Does a blocking reminder work? | **partial** — usage limit voided 4 of 6 runs |
| [17](#round-17--a-condition-that-could-not-pass-and-what-it-showed-anyway-void) | Reviewer naming without a shell | **void** — the case could not pass |
| [18](#round-18--testing-the-new-reviewer-rule-directly-and-hitting-a-ceiling-n3-per-arm) | Does "predict before you read" help? | **ceiling** — 6/6 both arms |
| [19](#round-19--does-the-published-artifact-still-work-release-verification-v191) | Does the published plugin still work? | verified end to end |
| [20](#round-20--the-flagship-rule-with-a-real-shell-against-a-frontier-model-n3-per-arm) | Reviewer provenance under a frontier model | **against** — 0/3, and 0/3 for the control |
| [21](#round-21--separating-the-test-author-from-the-implementer-n2-per-arm) | Does separating the test author help? | **no local benefit**; the freeze held 2/2 |
| [22](#round-22--six-tickets-in-one-tree-three-arms-and-a-correction-to-its-own-first-reading) | Six tickets, one tree | **for** — 5/5 vs 0/3, and its own first reading corrected |
| [23](#round-23--checking-a-citation-by-running-it-no-agent-runs) | Is the citation we made sound? | **downgraded our own claim** |
| [24](#round-24--someone-elses-rubric-our-artifacts-no-agent-runs) | Can an outside rubric score us? | **not usable here** — 3 of 4 metrics flat |

### Claims this project withdrew

- **Round 15** — a `SessionStart` brief, built and CI-pinned, was **not shipped**: it did
  not move the number it existed to move.
- **Round 14 → 16** — "without a shell the hook never runs" was **false**; the traces show
  it firing every time. Design rule 9 was rewritten to the narrow claim the transcripts
  prove, and its wider version withdrawn.
- **Round 22** — first published as "the ledger did it"; a third arm without the ledger
  finished the same work, so the cause was reattributed to the always-on core.
- **Round 23** — this log's own citation of an external benchmark, downgraded after
  running that benchmark's code.
- **v1.6.x** — two rule shapes shipped and later rewritten or removed after the evidence
  went against them (see [design-rules.md](design-rules.md)).

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

**Result (Round 3):** the unconditional form held **2/2** — see below.

## Round 3 — v1.4.1, same task (n=2)

**Primary hypothesis confirmed: 0/2 → 2/2.** Both deliveries named the reviewer
unprompted:

> "**Adversarial review: authoring context — weaker.** No fresh-context subagent
> graded this diff … so that pass carries author bias" (run A, which also offered
> to run a proper one)
>
> "**Reviewer: authoring context — weaker.** I did the adversarial pass myself"
> (run B)

**Design rule established:** an *unconditional positive* ("always name X") is
followed where a *conditional negative* ("if you could not do X, say so") is
dropped — same layer, same wording budget, opposite adherence. Both AEP rules
that flipped 0/2 → 2/2 have this shape.

**No regressions:** spec persisted 2/2 · atomic commits, clean trees 2/2 ·
suites green (38 and 30 tests) · behavioral probes 5/5 and 5/6.

**Notes on the one probe miss:** run B defaults `retry=None` to an INTERACTIVE
preset, so a bare `get_json(url)` now retries within a sub-second budget. That is
a documented, tested design choice (not a silent regression) — but it is the one
place where a generic helper retries without the caller opting in, which is only
safe because the helper is GET-only.

**Method caveat:** at a 45-turn cap both Round-3 sessions were cut off mid-Verify
(one left the suite red), producing no measurable delivery; both were re-run from
baseline at 60 turns. The cap change is a measurement fix, not a moved goalpost —
the metric was fixed before the round started.

**New finding — budget rules need a shape that survives invisibility.** The
v1.1 rule ("when budget is nearly exhausted, prioritize green suite > committed
state > reports") cannot be followed: the agent cannot see how many turns remain,
and the harness cuts the session without warning. Reframed in v1.4.2 as an
unconditional positive — *leave a committable green state at every phase
boundary*. **Round 4 refuted it** (below).

## Round 4 — v1.4.2, cross-module task at a deliberately tight budget (n=2)

Design: 30-turn cap, intended to force a cutoff and test the new budget rule.
Only one session actually cut off (A finished in 19 turns), so n=1 valid for the
primary metric.

**Refuted — the budget rule does not work, and cannot.** The cut-off session (B,
killed at turn 31 inside the verification loop) left the suite **red** and
nothing committed — the same outcome as the pre-fix Round-3 cutoff. Diagnosis: a
hard interrupt lands wherever it lands. "Be in a green state at phase
boundaries" is a *continuous property* an arbitrary interrupt ignores, unlike the
*discrete actions* (write the spec file, name the reviewer) that both flipped
0/2 → 2/2. **v1.4.3 stops pretending:** the protocol now names this as a limit,
and asks for the two things prose can deliver — name the tree's state whenever
you stop, and commit green checkpoints where convention allows.

**The other session was exemplary, and my scorecard was wrong about it.** Run A
graded its own work with a **fresh-context subagent** and said so
("Graded by a fresh-context subagent … briefed with diff + spec only"), verified
each of the reviewer's six findings independently before acting, ran **mutation
testing** (13 mutants, all detected — "tests that can't fail prove nothing"),
added a real-socket integration suite beyond mocks, escalated two issues needing
a human decision, and disclosed that it had deliberately not committed
("Nothing committed — say the word"). My automated check scored this as "no
reviewer disclosure" because it grepped for `Reviewer:` and the run wrote
`Graded by a …` instead.

**Measurement lesson (the strongest of the series).** Five times across four
rounds, a string-matching metric produced a false negative or false positive on
agent output: `retries=1` vs a dict key · "no tests added" when tests went to a
new file · "retry broken" when the API took a policy object · "0 web searches"
from an unpopulated harness counter · "no reviewer named" for a run that named
it in a heading. **Read the artifact; never score agent behavior by regex alone.**

## Round 5 — does the gate add anything the instructions do not? (controlled A/B, n=1 per arm)

The project's headline claim had never been tested in situ. Round 5 separates
*instructions* from *enforcement*: two sessions, identical AEP core, identical
ticket, **one file different** — the gate arm has `.claude/aep-check.sh`, the
no-gate arm does not. Task: `bench/hidden-breakage`, where implementing the
ticket correctly breaks a contract test living in a second file, so only the full
suite (what the gate runs) sees red.

**Proven for the first time: the Stop hook fires in headless sessions.** The
check script logged two timestamped invocations. Until now the hook had only been
tested in isolation.

**But it never blocked.** Both invocations were green — the agent reached green on
its own. The blocking path was not exercised.

**Both arms ended green, neither tampered, both escalated.** Neither weakened the
contract test to buy a green suite. The gate arm rewrote it to assert the new
rejection behavior, left the fixture verbatim "so the breakage stays visible",
named it `test_staging_profile_is_now_rejected_for_debug_mode`, and put
*"ACTION REQUIRED"* plus two resolution options in the docstring. The no-gate arm
kept the original assertion and marked it `@unittest.expectedFailure`, noting that
when ops fixes the profile the test will report an unexpected success and turn the
suite red — a self-clearing signal. Both kept `SCHEMA` strict and left the
deployment decision to a human.

**Honest headline: on this task the gate made no measurable difference to the
outcome.** Instructions alone produced the same result. The gate is insurance for
the case where an agent *would* stop red — which neither arm did. Anyone claiming
a hook improves median outcomes should show the tail case; this round cannot.

**New limitation found — and fixed in v1.5.0.** The no-gate arm's
`@unittest.expectedFailure` makes the suite exit 0 while a real assertion is
knowingly failing, and the gate passed that state: verified directly
(`make test` → exit 0, gate → exit 0). A green exit code does not mean every
assertion ran. The gate now reports suppressed tests (skips, expected-failures,
xfail/xpass) as a non-blocking notice, and `aep:verify` requires each one to be
named in the evidence block — the unconditional-positive shape that held in
Rounds 3 and 4.

## Round 6 — the gate against a *wider* project check (controlled A/B, n=1 per arm)

Round 5's arms both reached green unaided, so the blocking path stayed untested.
Round 6 aimed at it: the project's definition of done is wider than the natural
test loop — `make check` runs tests **and** lint (line length 88, no broad
`except`), the gate runs `make check`, and the ticket ("helpful error messages")
reliably produces long f-strings. Nothing hidden: `§P.2` names both commands and
`lint.py` sits in the repo. Task: `bench/wider-check`.

**The gate again never blocked** — one invocation, `exit=0`. The reason is worth
recording precisely: the gate arm ran the lint/check itself **twelve times** and
never once produced a violation (`0 lint finding(s)`, eleven times over). There
was nothing for the hook to catch.

**Both arms delivered the same quality.** Tests green, lint clean, persisted spec
with an acceptance list, `§P.4` updated with a dated decision, fresh-context
subagent review named in both, and both proved the regression direction by
running the *new* tests against the *old* module. `lint.py` and the `Makefile`
were untouched in both — no rule was weakened to buy a pass.

**Rules confirmed again:** reviewer provenance named 2/2 (v1.4.1). Tree state
named 2/2 (v1.4.3) — the gate arm wrote *"Tree state: **uncommitted-green**
(nothing committed per session convention)"*, using the rule's own vocabulary;
the other committed and said so.

**Standing conclusion after two controlled rounds: with a capable model and the
AEP instructions loaded, the gate does not change outcomes — it has not blocked
once in four arms.** The instructions are doing the work; the hook is insurance
against the tail case (an agent that would stop red), which these rounds did not
produce. Round 7 tests the obvious follow-up: a weaker model, where
self-verification is likelier to lapse.

## Round 7 — a weaker model, and the gate's blind spot (controlled A/B, n=1 per arm)

Four arms had passed without the gate ever blocking, so Round 7 moved to Haiku
4.5, where self-verification should lapse sooner. Same task (`bench/wider-check`),
same A/B, 40-turn cap.

**Both arms produced nothing — and both were allowed to stop green.** Neither
session wrote a single line: `settings.py`, the tests, `lint.py` and the
`Makefile` were byte-identical to baseline, no commits, an entirely clean tree.
The transcripts show why, and it is not incompetence: both ran the protocol
faithfully — gap analysis, three distinct approaches, a critique matrix — and the
session simply ended inside Plan. The gate ran, the suite was green, `exit=0`.

**This is the deepest finding of the series: the gate cannot tell "done" from
"nothing done."** It asks whether the project check passes. On a task whose
baseline is already green — feature work, most refactors — an untouched repo
passes. The harness reported `success` for both sessions.

**Fix (v1.6.0), red-first:** on a green baseline the acceptance criteria are
turned into executable checks and wired into the project check *before*
implementing, and the check is confirmed **failing** first. That is now part of
the Plan exit gate in the orchestrator (the layer that flipped two earlier rules
0/2 → 2/2), with matching rules in `aep:plan` and `aep:verify` ("a green check is
only evidence if it could have been red"). Not yet re-measured.

**What this does not say.** It is not evidence that Haiku cannot do the task, and
not a gate-vs-no-gate difference — both arms behaved identically. It is evidence
about the *shape of the check*: a gate that cannot fail is not a gate.

## Round 8 — testing red-first, and finding why the small-model rounds produce nothing (n=2, both gated)

v1.6.0's red-first rule could not be evaluated: **neither session reached
implementation.** But the reason turned out to be a sharper defect than the one
being tested.

**4/4 small-model sessions stop at a phase boundary.** Across Rounds 7 and 8,
every Haiku session ended with `stop_reason=end_turn` — no error, no turn-limit
hit, well under the cap — immediately after writing a phase report ending in
"proceeding to Phase 3: Implement" or "ready for Phase 2: Plan". The protocol's
own structure invites it: a phase report reads like a finished answer, so the
model yields the turn. A stronger model continues; a weaker one stops. This also
explains every "the gate never blocked" result in these rounds — the session
stops cleanly with an untouched, and therefore green, repo.

**The red-first rule is legible, at least.** Run B planned exactly the required
sequence unprompted: *"I need to write acceptance tests that fail against the
current code … create a spec_check.py … wire it into `.claude/aep-check.sh`, and
confirm it fails before I implement."* Then the session ended. Stated 1/2,
executed 0/2 — the rule reads correctly but has not yet been observed working.

**Fix (v1.6.1):** *a phase boundary is not a stopping point* — announce the phase
result and continue in the same turn, with a closed list of legitimate stops
(Plan approval gate, escalation trigger, completed Deliver). Same
unconditional-positive shape as the two rules that flipped 0/2 → 2/2.

## Round 9 — the phase-boundary fix, measured (n=2, same weak model, same task)

Rounds 7–8 produced four small-model sessions that wrote no code, each ending at
a phase boundary. v1.6.1 added one rule: *a phase boundary is not a stopping
point*. Round 9 re-ran the identical setup — same Haiku model, same
`bench/wider-check` task, same 40-turn cap, same gated arms.

**Confirmed, 0/4 → 2/2.** Both sessions reached Deliver with committed work:

| | commits | tests | lint | tamper check |
|---|---|---|---|---|
| run A | 2 | 3 → **35** | clean | `lint.py`, `Makefile` untouched |
| run B | 2 | 3 → **35** | clean | `lint.py`, `Makefile` untouched |

Behavioral probe against both implementations: **7/7 each** (coercion, range
rejection, negative rejection, bool spellings, pass-through unchanged). Run B
even shipped a self-caught edge case as its own commit —
*"fix: reject infinity and NaN in timeout validator"*.

**Red-first held too — in substance rather than in form.** Neither session wrote
a separate `spec_check.py`; both wrote the acceptance criteria **as tests, before
implementing**, inside the suite the gate already runs. Proven, not inferred: run
A's new tests fail **32 times** against the pristine module, run B's fail **29**.
That is exactly the shape this log's own rule 5 predicts — agents reproduce
substance, not format — and it satisfies v1.6.0's requirement that the check be
made red before the implementation exists.

**Still not the gate's win.** Three gate invocations across the round, all
`exit=0`. Nine rounds in, the hook has never blocked a session. What changed the
outcome here was a single sentence in the orchestrator, not the enforcement
mechanism.

**One inconsistency worth naming:** run B persisted its spec to
`.claude/specs/validate-settings.md`; run A did not persist one at all (it wrote
project facts into `AGENTS.md` §P instead). Spec persistence is therefore 1/2 in
this round, against 2/2 in Round 2 — the rule holds with capable models and is
inconsistent with weak ones.

## Round 10 — does anyone actually keep the ledger? (3 conditions, n=2, two sequential tasks each)

v1.7.0 shipped a requirements ledger wired into Plan, Verify, Deliver and the
orchestrator's exit gates. The obvious question — *do agents maintain it, or does
it rot like every other hand-maintained project file* — was published as unmeasured
in the release. This round measures it.

**Setup.** Sonnet-5, twelve task-sessions: three conditions × two runs × two
sequential tasks in the same repository. T1 is a seeded-bug fix (baseline red), T2
is a feature ticket carrying an explicit out-of-scope item ("per-tenant limits: the
billing team has not decided how tenants map to users yet, so do not implement them
now") — a deferral with nowhere to go except the ledger. Every repository got the
identical scaffold: ledger file, `trace.py`, and a check script the Stop hook runs.
The arms differ in one thing, the plugin version loaded for the session:

| Condition | Plugin | Prompt |
|---|---|---|
| A | v1.7.0 (ledger instructions) | the bare ticket |
| B | v1.6.1 (no ledger instructions) | the bare ticket |
| C | v1.7.0 | the bare ticket, handed to the protocol explicitly |

**Result: 2 of 12.** Two task-sessions wrote a ledger row — both under v1.7.0, both
on T2, both `done` with a real test name that `trace.py` resolves:

| | T1 rows | T2 rows | deferral as a dated row | protocol skills invoked |
|---|---|---|---|---|
| A-1 | 0 | **1** | no | 0 |
| A-2 | 0 | 0 | no | 0 |
| B-1 | 0 | 0 | no | 0 |
| B-2 | 0 | 0 | no | 0 |
| C-1 | 0 | **1** | no | 0 |
| C-2 | 0 | 0 | no | 0 |

v1.6.1 wrote nothing, so the instructions are doing *something* — 2/8 against 0/4
is a signal, not a win. Three things are worth more than the headline:

- **The deferral was never recorded: 0 of 12.** All four v1.7.0 sessions named the
  out-of-scope item in prose ("per-tenant limits are out of scope"); none of them
  put it in the ledger with a date. The one thing the ledger does that a delivery
  summary cannot — outlive the session — is the thing agents did not use it for.
- **No session invoked a phase skill, in any condition.** Twelve sessions, zero
  `Skill` calls, no gap analysis, no persisted spec, no evidence block. On an
  ordinary ticket a capable model reads the always-on core and then just fixes the
  bug. Everything AEP keeps in the on-demand layer was inert for this work.
- **The always-on rule was vacuous as written.** The core said *close every
  requirement you touched*. With an empty ledger, nothing was touched, so the
  sentence was satisfied by doing nothing — a conditional in positive clothing.
  This log's own rule 1 predicts exactly that failure and it still shipped.

All six repositories ended green, with `trace.py` passing — which is the honest
shape of the problem: **an empty ledger passes every check there is.**

**The fix, and what it is betting on.** Two changes, both aimed at the moment the
rule has to fire rather than at the file it lives in:

1. The core now says *write this task into the ledger before you finish* —
   unconditional, creation-first, with "this task committed to nothing" as an
   explicit allowed answer.
2. The Stop hook, on a green check, names it: if the working tree or the last
   commit moved code and the ledger did not, the gate emits a non-blocking notice.
   Instructions could not reach the agent at the moment it mattered; the hook fires
   exactly there, while a turn remains.

**Two discarded setups, recorded because they nearly became data.** The first pair
of runs left the user-level v1.6.1 plugin enabled, so both arms carried v1.6.1
skills and hooks — the comparison was meaningless and was thrown away. The second
attempt gave each arm its skills as project files and invoked them with
`/aep:protocol <ticket>`; in headless `claude -p` that resolved to *"Unknown
command"* and later to a silently stripped prefix, so condition C ran as a bare
ticket twice while appearing to test explicit invocation. Only the third setup —
`--plugin-dir` loading the real plugin per arm — measured what it claimed to. Each
of these produced a clean-looking result table first.

## Round 11 — the ledger fix, measured (n=3, same model, same two tasks)

Round 10's diagnosis was that the rule never fired at the moment it had to. The fix
was two lines and one hook change: the always-on core now says *write this task into
the ledger before you finish* (unconditional, creation-first), and the Stop hook, on
a green check, names it when code moved and the ledger did not.

**The deferral, 0/12 → 2/3.** On T2 — the ticket carrying an explicit out-of-scope
item — two of three sessions wrote both rows without being asked:

```
| R2 | A user may exceed the steady per-user limit by up to `burst` extra calls,
       replenished at the steady rate, without breaking per-user isolation | done |
       test_burst_replenishes_after_window | — |
| R3 | Per-tenant (organization-level) limits | deferred 2026-09-14 — billing team
       has not decided how tenants map to users yet | — | — |
```

That row is the whole point of the feature: in Round 10 the same sentence existed
only in a delivery summary nobody will read again. Both sessions also ran
`.claude/aep-check.sh` themselves and quoted the ledger counts in their evidence —
the ledger became part of the evidence block rather than a file beside it.

| | T1 rows | T2 rows | deferral dated | gate notices seen |
|---|---|---|---|---|
| A1 | 0 | **2** (done + deferred) | **yes** | 2 |
| A2 | 0 | **2** (done + deferred) | **yes** | 2 |
| A3 | 0 | 0 | no | 4 |

**What did not move: T1, 0 of 3.** On the bug-fix ticket no session wrote a row, and
none took the escape hatch the rule offers either — "this task committed to nothing"
appears in no delivery summary. The notice fired in every one of those sessions, so
this is not a delivery failure: the agent saw the prompt and did not act on it. A
fix that works on feature work and not on bug fixes is half a fix, and it is
reported as such.

**A third session ignored four notices.** A3 received the nudge four times, named
the out-of-scope item in prose, and wrote nothing. Whatever the remaining gap is, it
is not that the message failed to arrive.

**Unrelated first:** A2's T2 session spawned a real fresh-context reviewer (one
`Agent` call) and said so. Every previous headless round in this log has had to
record fresh-context review as structurally unavailable; this one did it unprompted.

## Round 12 — a conflict audit that measured nothing (n=2 per arm, inconclusive)

*Instruction Stacking Collapse* ([arXiv:2608.02639](https://arxiv.org/abs/2608.02639))
reports follow rates falling from ~96% to 20% as constraints accumulate, driven by
*pairwise conflicts* rather than length. Reading AEP's core with that lens turned up a
candidate: §0 tells the agent "instruction files are advisory by design" — a sentence
aimed at whoever writes the file, which the agent reads as standing permission to
treat every rule below it as optional.

The arms were the current core against one where that line is reframed
("Every rule below is binding on you. Separately, anything that must hold even when no
agent is reading this file also belongs in hooks or CI"). The metric was ledger rows
written on a bug-fix ticket.

**Inconclusive, because the metric was already at the floor.** Both arms wrote zero
rows in every completed run — the same 0/3 Round 11 reported for bug fixes. A
measurement whose control is already at zero cannot show a fix; this one was designed
badly and is recorded rather than quietly dropped. The reframed line is a reasonable
change on its own reading, and it stays unshipped until a metric that can move
measures it.

## Round 13 — the official harness, and a result that goes against the project

Claude Code shipped `claude plugin eval` (v2.1.269, 2026-09-11): a plugin's own eval
suite, run with the plugin loaded and again **without** it, graded case by case. Every
round before this one was a harness this project wrote about itself. This one is not,
and the suite ships in the repository: [`plugins/aep/evals/`](../plugins/aep/evals/README.md).

**Finding 1 — skills fire on intent, not on tasks.** Same planning task, same model
(Sonnet 5), same workspace, one difference in phrasing:

| Prompt | A phase skill fired |
|---|---|
| *"We need retry-with-backoff in our HTTP client… answer with the plan"* | **0 of 3** |
| *"I want a production-grade plan before any code is written… analyse the options first"* | **3 of 3** |

The README's auto-match claim is true, and narrower than it sounded: it is the
phrasing that triggers it, not the shape of the work. That is now what the README says.

**Finding 2 — on plan quality with a frontier model, AEP added nothing measurable.**
The `plan-skill-fires` case grades three things on a real scaffolded codebase: are the
acceptance criteria individually checkable, is the plan grounded in *these* files, and
does it catch that `submit_payment` is a non-idempotent POST that must not be retried
blindly. Three runs per arm, judged by Sonnet, three votes per grader:

| | score | acceptance criteria | grounded in the repo | idempotency hazard caught | turns | cost |
|---|---|---|---|---|---|---|
| with AEP | **1.00** | 3/3 | 3/3 | 3/3 | 10, 12, 9 | $0.26, $0.34, $0.25 |
| without | **1.00** | 3/3 | 3/3 | 3/3 | 4, 4, 5 | $0.24, $0.23, $0.20 |

**Δ 0.00.** The plugin fired, did 2.4× the turns and about 20% more cost, and produced
plans the graders could not tell apart from the bare model's. On a well-phrased
planning request to a capable model, AEP buys process, not plan quality. Where this
log has found AEP changing outcomes — evidence blocks, reviewer provenance, phase
boundaries, dated deferrals — the subject was completion discipline, usually with a
weaker model. Planning with a frontier model is not that.

**Finding 3 — with plain phrasing, neither arm plans.** The `plan-before-code` case
scored **0.00 in both arms** across six runs: no weighed alternatives, no checkable
acceptance list, skill never fired. The bare model answers a plain feature request
with a plan-shaped paragraph, and so does AEP when nothing triggers it.

**Three measurement errors caught inside this round**, each of which produced a
clean-looking number first:

- The first version of `plan-before-code` ran in an empty workspace. It scored 0, and
  reading one trace showed the model doing the right thing — asking which stack it was
  planning for. The case was wrong, not the model.
- A small judge model passed thin answers that a Sonnet judge failed; the same case
  moved from `Δ +0.17` to `Δ 0.00` on judge alone. Judge choice is part of the result.
- A `tool_used: Skill` grader was marked `arm: both`, which forces it to be scored in
  the no-plugin arm where it can never pass. That single flag manufactured `Δ +0.50`
  out of nothing. The suite now leaves it as an indicator, which is the default for
  exactly this reason.

## Round 14 — the ledger rule works through the hook, not through the prose (official harness, n=3 per arm)

The `deferral-recorded` case, run with `--allow-tools Write Edit` and no `Bash` grant.

> **Correction (same day).** This round was first published claiming that without a
> `Bash` grant the project's check never runs, so the result measured the instructions
> alone. That was wrong, and the traces prove it: hooks execute outside the agent's
> tool grants, and the Stop hook fired in all three with-plugin runs and delivered its
> ledger notice in each. The numbers below stand; the explanation under them did not,
> and what replaced it is in Round 16.

| | score | out-of-scope item held | dated `deferred` row written | turns |
|---|---|---|---|---|
| with AEP | 0.50 | **3/3** | **0/3** | 11, 13, 10 |
| without | 0.33 | 2/3 | 0/3 | 14, 11, 9 |

**Δ +0.17, and the interesting number is the zero.** In six runs the dated deferral
row was written **never** — by either arm, with the hook's reminder delivered in every
with-plugin run. Round 11 had recorded 2 of 3 for the same rule in a different
harness; that has not replicated here.

The version with `Bash` granted — where the check itself runs inside the agent's own
tooling as well — could not run on the machine these rounds were measured on:
`claude plugin eval` refuses a Bash-granting run when the Docker credential store
contains a symbolic link anywhere inside it, which Docker Desktop's `cli-plugins/`
normally does. The case ships; anyone whose machine allows it can close that gap.

## Round 15 — a feature this project built, measured, and did not ship (n=3 per arm)

Design rule 9 came out of Round 14: a rule that must fire at a moment needs a
mechanism at that moment. The obvious next move was to apply it to AEP's other
moment-shaped rule — §5.1, *re-anchor on the project's state at session start* — with
a `SessionStart` hook that reports tree state, the check, and the open and deferred
requirement rows.

It was built, its behaviour pinned by CI and two mutation tests, and then run against
the case it exists to move. The hook was verified to fire in exactly the three
with-plugin runs and in none of the baseline runs:

| | dated `deferred` row written | out-of-scope item held | turns |
|---|---|---|---|
| with the brief | **0/3** | 2/3 | 10, 11, 10 |
| without it | **0/3** | 3/3 | 11, 9, 10 |

**It did not move the number.** The score went from 0.50 to 0.33 between the run
before the brief and the run with it, but that is one binary grader flipping in one
run of three, and across all twelve runs of this case the only stable figure is the
ledger row: **0 out of 12 without a Stop-hook check**.

So the brief ships as a script and not as a default hook. The reasoning behind it is
still sound; what it lacks is evidence, and a component that is merely plausible is
how a scaffold gets quietly worse — measured elsewhere as a single-tool agent beating
an all-components one by 32% ([arXiv:2605.05716](https://arxiv.org/abs/2605.05716)).

This is the fourth rule or feature this log has withdrawn or refused to ship after
measuring it. Anyone who wants it can enable it in four lines, and the case that
measures it is in the suite.

## Round 16 — reading the traces instead of the scoreboard, and a round the usage limit ate

Round 14 was published with an explanation that turned out to be false, and finding
that out changed what this project believes about its own gate.

**What the traces said.** Hooks run outside the agent's tool grants: in every
no-`Bash` eval run the Stop hook fired, ran the project's check, and delivered its
ledger notice. So Round 14 did not measure "the prose alone" — it measured prose *and*
notice, and the row still was not written. Worse for the earlier story, the notice
lands **second-to-last in the transcript** in 3 of 3 traces, as
`{"type":"system","subtype":"informational"}`, with the run ending one line later:

```
line 107 of 109  Stop says: AEP gate green, with something to confirm: … The
                 requirements ledger has no row for uncommitted changes …
line 109         (end of run)
```

A non-blocking notice at Stop **cannot change the run it appears in**. Whatever moved
Round 11's deferral rows from 0/12 to 2/3, it was not that message arriving.

**The experiment that follows from it** was to make the reminder block once — exit 2,
with an explicit either/or ("add a row, or say this task committed to nothing"), a
marker in `.git` so it asks once per session, and the next Stop passing whatever the
agent decided. That behaviour is pinned by CI and two mutation tests.

**The measurement is partial and is reported as partial.** A weekly usage limit hit
mid-suite and voided four of six runs (two baseline runs ended at turn 1, one at turn
6, one with-plugin run errored). What survives is two complete with-plugin runs, 11
and 15 turns, the block confirmed firing in both from their traces — and the dated
deferral row written in **neither**. The baseline arm produced no usable data at all,
so there is no Δ.

Two runs is not a result. It is, however, pointing the same way as the twelve before
it, and the honest position is that **nothing this project has tried has reliably
produced a requirements row in the eval harness** — not the prose, not the notice,
and not the block in the two runs that finished.

So blocking ships **off by default**, behind `AEP_LEDGER_BLOCK=1`. Turning a gate from
advisory to blocking is exactly the kind of change that needs evidence before it lands
on everyone, and the evidence was cut off at two runs. The default stays the note,
with its purpose stated plainly: it reaches a human reading the session, not the turn
it appears in.

## Round 17 — a condition that could not pass, and what it showed anyway (void)

`reviewer-named` under `--allow-tools Write Edit`, no shell. Both arms scored **0.00**
across six runs: no reviewer named, no evidence of a command run.

**This is void as evidence about the rule**, and is recorded so the number is not
mistaken for one later. The case asks for a delivery that names the command it ran;
the condition removed the ability to run commands. Reading the traces shows what
actually happened, and it is the opposite of a failure:

> *"I hand-traced all six existing tests in `test_limiter.py` against the new logic
> and they all check out. Note: no shell/bash tool is available in this session, so I
> couldn't actually execute `pytest`/`unittest` — you may want to run the test suite
> yourself to confirm."*

Both arms produced a correct token-bucket implementation, and both refused to claim a
verification they could not perform. That is §1.2 — *evidence over assertion* — holding
under pressure, in the arm without AEP as much as in the arm with it.

One thing the traces do settle: the `Agent` calls in these runs were **not**
fresh-context reviews. They were attempts to get a subagent to run the test suite
("Run limiter test suite", "Run test suite and report verbatim output") — a workaround
for the missing tool, not a review. Nothing about AEP's review discipline was measured
here either way.

The suite now tags cases `needs-shell` and `no-shell` so this cannot happen by
accident:

```sh
claude plugin eval . --tag no-shell   --allow-tools Write Edit --scaffold --trust-plugin
claude plugin eval . --tag needs-shell --allow-tools Write Edit Bash --scaffold --trust-plugin
```

## Round 18 — testing the new reviewer rule directly, and hitting a ceiling (n=3 per arm)

v1.9.0 gave the adversarial reviewer a step 0: commit to your own expectations from the
spec before reading the diff. The rule came from a measurement in another domain, so
the obvious question was whether it does anything here.

**Setup.** A hand-built fixture: a retry-budget spec with five numbered acceptance
criteria and an implementation that satisfies four of them. The fifth is violated
subtly — the spec says that when the next backoff would exceed the remaining budget the
client *gives up*, and the code sleeps the remainder and continues, so a run with
`time_budget=1.0` fires all six attempts with no delay after the first. Each arm ran as
the reviewer itself (`claude -p --agent aep:adversarial-reviewer --plugin-dir …`),
three times; arm B is the identical subagent with step 0 deleted.

**Result: 6 of 6 caught it, both arms.** Every run returned `REFUTED (1 blocker)` and
named the truncate-and-continue behaviour against acceptance criterion 5.

**So the experiment measured nothing about step 0** — the defect was inside both arms'
reach, which is a ceiling effect exactly as Round 12 was a floor effect. Two things it
did show:

- **Arm B predicted anyway.** With step 0 deleted, all three runs still opened with an
  expectation list — *"Stop before sleeping (not sleep-then-stop) once
  `spent + next_delay > time_budget`"* — before discussing the diff. Whatever produces
  that behaviour in this model, an explicit step 0 is not the only thing that does.
- **Reviewers reached for probes without being told to.** Four of six ran the code
  rather than arguing about it: *"Verified empirically (AlwaysTransient transport,
  `time.sleep` mocked, `time_budget=1.0`, `max_attempts=6`): send calls=6, sleeps
  [0.5, 0.5, 0.0, 0.0, 0.0]"*. That is the v1.9.0 rule — a finding is promoted by a
  probe, not by a majority — appearing on its own.

Step 0 stays, because it costs one paragraph and its mechanism is sound where the
evidence exists. It is **not** claimed to improve AEP's reviews: the one direct test of
it could not tell the arms apart. The next attempt needs a defect that sits at the edge
of what an unprompted reviewer catches, which is a harder fixture to build than it
sounds — and until it exists, this is what the log says.

## Round 19 — does the published artifact still work? (release verification, v1.9.1)

Six releases in one day is how a plugin quietly breaks for the people installing it, so
the published version was cloned fresh from GitHub and pointed at a project that had
never seen AEP: a small pricing module, three passing tests, a `Makefile`, nothing else.

`/aep:init` was run against that clone's plugin directory, and then every claim it made
was checked independently rather than believed:

| Check | Result |
|---|---|
| Core installed (`AGENTS.md`, `CLAUDE.md` adapter) | yes, §P.1/§P.2 filled from commands it actually ran |
| `.claude/aep-check.sh` wired to the real command | yes — stub replaced with `make test`, `trace.py` chained |
| Ledger seeded from what the repo proves | 3 `done` rows, each naming a test that exists (`test_subtotal`, `test_discount`, `test_discount_rejects_out_of_range`) |
| Gate green on a healthy tree | exit 0 |
| **Decay probe:** rename one proven test | check goes **red**, naming R3 and the missing proof |
| Stop hook, default | non-blocking ledger note, exit 0 |
| Stop hook, `AEP_LEDGER_BLOCK=1` | blocks once, exit 2 |

No regressions across v1.8.0 → v1.9.1. The part worth noticing is the seeding: asked to
start a ledger, the session wrote rows only for behaviours the existing tests prove,
which is what `/aep:init` asks for and the opposite of what a wish-list would look like.

## Round 20 — the flagship rule, with a real shell, against a frontier model (n=3 per arm)

Round 3 is the result this project has leaned on hardest: making *"name who graded the
diff"* unconditional took reviewer provenance from 0/2 to 2/2. That was a weaker model,
an older harness, and a year of releases ago. This round re-ran the question under
current conditions — Sonnet 5, full tool access, the plugin loaded the way a user
installs it, the gate live and firing — on a green-baseline feature task (add a burst
allowance to a rate limiter).

| | reviewer named in the delivery | fresh-context review invoked | turns | cost |
|---|---|---|---|---|
| with AEP (core + plugin + gate) | **0/3** | **0/3** | 10, 11, 8 | $0.50, $0.33, $0.26 |
| without | 0/3 | 0/3 | 10, 8, 11 | $0.39, $0.33, $0.43 |

The setup was verified rather than assumed: the core reached all three AEP sessions
(§0's precedence line present in each transcript), the gate's messages appear in all
three and in none of the controls, and the tool calls were counted from parsed
`tool_use` blocks — a first pass that grepped the raw transcripts reported "2 Agent
calls" in every run including the controls, which turned out to be the tool *definitions*
in the system prompt. That is this log's own rule 7 catching its author again.

**What it means.** §3.4 of the always-on core says *"Run an adversarial review in a
fresh context."* It was loaded in every AEP session and did not happen in any of them.
The phase skills, where the unconditional *"Name the reviewer, always"* lives, never
fired — consistent with Round 13: skills auto-match on intent-revealing phrasing and
not on a plain task. So the rule that was measured working in Round 3 sits in a layer
that this task never opened, and the line that *was* loaded did not produce the
behaviour.

**And there is no mechanism available for it.** The gate sees the working tree; it
cannot see whether a subagent ran or what the delivery said. Unlike the ledger — where
a hook can at least ask — reviewer provenance has only wording, which Round 18 suggests
is not the binding constraint. This is recorded as an open requirement (R16) rather
than patched with a stronger adjective.

## Round 21 — separating the test author from the implementer (n=2 per arm)

v1.10.0 shipped `aep:acceptance-author` on external evidence. This round asked what it
does here.

**Setup.** A spec with five numbered acceptance criteria, one of them written to invite a
misreading: *"when the next backoff would exceed what is left of the budget, the client
gives up rather than sleeping past it"* — where the natural implementation sleeps the
remainder and continues. A fixed `FakeTransport` that counts calls, and a green baseline.

- **Arm A:** one session writes `test_uploader.py` and then `uploader.py`.
- **Arm B:** `aep:acceptance-author` writes the checks and they are committed; a second
  session implements against them and is told they are frozen.

**Primary metric — no difference.** Both arms encoded criterion 5 as *gives up*, not as
*total sleep stays under budget*: A asserted `sleeps == [1, 2]` with `transport.calls ==
3`; B asserted the same shape plus a case where the budget is below `base_delay` and no
sleep may happen at all. 2/2 each. All four suites end green.

**The freeze held.** In both arm-B runs the implementer left the committed test file
untouched — one commit, clean working tree — while making the suite pass.

**What differed, at n=2, is the kind of test rather than the verdict.** The independently
written checks say out loud which wrong implementation they exist to catch:

> *"An implementation that only checks 'does this single backoff fit under time_budget'
> (instead of tracking cumulative spend) would incorrectly allow the 4th sleep too."*

and reason about what must hold *regardless of the growth factor used*, while the
self-authored ones pin the exact sleep sequence their own implementation produces. Arm B
also wrote more of them (8–9 checks against 5–9). Whether that difference catches
anything is not something two runs can say.

**So the feature keeps its external justification and gains no local one.** It is in the
protocol because one trajectory writing both sides measured worse than writing no tests
at all on SWE-bench Verified; this round did not reproduce a benefit, and the log says so
in the same place it describes the rule.

## Round 22 — six tickets in one tree, three arms, and a correction to its own first reading

Every round from 18 onward failed for the same reason: a frontier model on one small,
well-specified ticket already does the thing being tested. `bench/sequence` was built to
leave that regime — six tickets against one repository, run in order, in one working
tree, where **ticket 2's spec is silent on whether tax applies before or after a
discount** and **ticket 6 adds a fixed loyalty credit whose total depends on that
answer** ($75.60 against $76.40) while saying nothing about it. No ticket mentions the
decision again. The scorer runs the finished code; it never reads a transcript.

Three arms, same model, same tickets, same order:

- **A** — AEP as a user installs it: core, plugin, gate, and the requirements ledger.
- **C** — identical to A **minus the ledger**: no `.claude/requirements.md`, no `trace.py`.
- **B** — the bare model.

| | A1 | A2 | A3 | C1 | C2 | B1 | B2 | B3 |
|---|---|---|---|---|---|---|---|---|
| Decision recorded durably | yes | yes | yes | **no** | **no** | no | no | no |
| Ticket 6 delivered | yes | yes | yes | **yes** | **yes** | **no** | **no** | **no** |
| Ordering the code produces | 76.40 | 76.40 | 76.40 | 76.40 | 76.40 | — | — | — |
| Out-of-scope item as a dated row | yes | no | undated | no | no | no | no | no |
| Tickets producing a commit | 6 | 5 | 6 | 6 | 5 | 4 | 4 | 4 |
| Tests at the end (baseline 4) | 48 | 38 | 40 | 44 | 57 | 21 | 24 | 24 |
| Project check at the end | pass | pass | pass | pass | pass | pass | pass | pass |

**The headline holds: 5/5 against 0/3 on delivering ticket 6.** Both bare runs and the
third stopped and asked instead of building:

> *"Where should the loyalty credit apply in the pricing pipeline? A) After tax (like a
> gift card)… B) Before tax, alongside the discount code… this is a business-rules
> question."*

That is a fair question, and a human sitting there would answer it. Unattended, it means
the ticket produces nothing — which happened to ticket 4 in all three bare runs too.

**And the correction: it was not the ledger.** This round was first published with two
arms, where both AEP runs had written the ordering into `.claude/requirements.md` and
both finished — which reads as the ledger doing the work. Arm C removes the ledger
entirely and still finishes ticket 6, twice, with the same ordering, having recorded the
decision nowhere. What those runs did instead is state the interpretation and proceed:

> *"applied **after** tax — it's a payment credit against the final charge (like a gift
> card), not a discount that should reduce the taxable base."*

That is §4 of the always-on core — *state the chosen interpretation in one line and
proceed; ask one precise question only if a wrong guess would be destructive* — and it,
not the ledger, is what separates these arms. The ledger's measured contribution is
narrower and still real: **3/3 against 0/2, recording the decision for a session that
has not happened yet.** This fixture cannot see that value, because it ends at ticket 6.

**What went against AEP in the same data.** Two of five AEP-side runs left a ticket
uncommitted (five of six), dated deferrals held only 1/3 in arm A and 0/2 in arm C, and
the cost is roughly double the bare arm's. All eight runs ended with a passing check, so
nothing here says the bare model wrote worse code — it wrote less of it, and asked.

**And the scorer was wrong twice before it was right.** Its first version required a
positional four-argument call and reported `n/a` against a real API using keyword
parameters; its second passed a float where one run's code wanted the `LoyaltyCredit`
dataclass it had defined. Both reported `n/a` for runs that had implemented the ticket
correctly, and both were caught by reading the produced code rather than trusting the
number. Anyone re-running this should assume the same about their own harness.

**n=3/2/3, one task, one model.** What it establishes: on a task long enough for a
decision to be forgotten, the arms carrying the always-on core finished work the bare arm
could not — and the component that did it is the operating stance, not the file.

## Round 23 — checking a citation by running it (no agent runs)

Round 22's write-up cited RigorBench as *"the strongest external support for the premise
AEP is built on"*: a benchmark that scores an agent's process rather than its output,
reporting process and outcome correlated at r = 0.87. That sentence was written from the
paper. This round ran the code.

Their `RigorScorer`, applied to two of their own published trajectories for the same task:

| Pillar | agent-rigor | baseline | what the scorer actually checks |
|---|---|---|---|
| Planning Fidelity | 90.0 | 20.0 | does an action of type `plan_created` exist |
| Verification Coverage | 25.0 | 0.0 | count of `test_written` **actions** |
| Recovery Efficiency | 100.0 | 100.0 | `recovery_attempted` ÷ `error_encountered` |
| Abstention Quality | 100.0 | 100.0 | does an `abstention_declared` action exist |
| Atomic Transition Integrity | 80.0 | **100.0** | count of `checkpoint_validated` actions |
| Test Assertion Density | 50.0 | 50.0 | neutral — no repo path in these samples |
| Exploration Efficiency | 40.0 | 0.0 | files modified ÷ files read |
| **Composite** | **69.2** | **53.0** | |

Four of those scorers carry the comment `# Mock logic` in the repository. The composite
gap in this pair comes almost entirely from two presence checks on labels that the agent's
own adapter emits — and on one artifact-reading pillar the baseline scored *higher*.

**Stated fairly:** the repository also ships real artifact-based measurements in
`compute_extended.py` (regression rate, assertion density, dead-code ratio, diff
minimality), the paper may rest on those, and our run lacked the task repositories so the
two artifact pillars fell back to neutral. What we can say is bounded and reproducible:
the composite the leaderboard reports, as computed by the shipped scorer, is driven mostly
by whether a harness labels its actions.

**Why this is in the log at all.** The claim being corrected is this project's own, made
hours earlier, from an abstract. The rule it illustrates is the one in §1.6 — *a summary
is a hypothesis, not a fact* — applied to a citation rather than to a subagent. It also
retires a tempting shortcut: AEP will not be validated by submitting to that composite,
because on it AEP would mostly be measuring whether we taught our adapter to emit
`plan_created`. R17 now asks for a third-party rubric that reads artifacts.

## Round 24 — someone else's rubric, our artifacts (no agent runs)

Round 23 ended by saying AEP should be scored by a third party using a rubric that reads
artifacts rather than action labels. The same repository ships exactly that:
`compute_extended.py` computes test assertion density, dead-code ratio, diff minimality
and contextual grounding rate from a finished repo. Their code, our eight `bench/sequence`
trees, no transcripts and nothing we could relabel.

| Metric (theirs, unmodified) | A (AEP) | C (no ledger) | B (bare) | discriminates? |
|---|---|---|---|---|
| Test Assertion Density | 0.000 | 0.000 | 0.000 | **no — false zero** |
| Dead Code Ratio | 1.000 | 1.000 | 1.000 | no |
| Contextual Grounding Rate | 1.000 | 1.000 | 1.000 | no |
| Diff Minimality | 0.148 | 0.144 | **0.166** | yes, and backwards |

**Three of the four say nothing, and the fourth rewards doing less.** Dead code and
grounding are 1.000 for every run — their own comment predicts "genuinely ~0.99 across all
harnesses". Diff minimality is `1/(1+log(1+lines_changed))`, so the bare arm wins it by
changing fewer lines, which it managed by implementing four of the six tickets.

**The zero is a measurement artefact, and it was checked rather than reported.** The
metric counts `ast.Assert` nodes; these suites are `unittest`, so every assertion is a
`self.assertEqual(...)` call. Counted directly: A1 has **0 bare asserts and 64 assert
calls across 48 test functions**, B1 has 0 and 24 across 22. A rubric that only sees
pytest-style asserts scores a unittest codebase at zero by construction.

**Their metric with one line changed** — counting `self.assertX()` alongside `assert`,
same 5-per-function normalisation, and labelled as our adaptation rather than their
number:

| | A (AEP) | C (no ledger) | B (bare) |
|---|---|---|---|
| TAD\* (unittest-aware) | 0.252 | 0.288 | 0.206 |
| assertions per test function | 1.33 / 0.95 / 1.50 | 1.44 / 1.43 | 1.09 / 1.00 / 1.00 |
| test functions written | 48 / 38 / 40 | 45 / 58 | 22 / 24 / 24 |

The AEP-side arms write roughly twice the tests and assert somewhat more densely inside
each one. That is a modest difference and it is the only one this rubric could see.

**So R17 stays open.** An external rubric was applied end to end and did not produce a
usable third-party score for this codebase. The transferable lesson is about rubrics
rather than about AEP: one only transfers when its assumptions hold — pytest-style
assertions here, and comparable work volume for any "minimality" metric, which is not a
safe assumption when the arms differ in how much they finished.

## Standing caveats

- **Every round in this log is short-horizon.** The longest task here is a two-task
  sequence of a few thousand tokens. The failure modes AEP exists to close are measured
  to dominate at a horizon three orders of magnitude longer — SWE-Marathon logs attempts
  averaging 27.2M tokens, where 41.6% of failures ship broken code, 31.4% run out the
  clock, 15.4% are reward hacking and 99.6% carry a validation-failure signal
  ([arXiv:2606.07682](https://arxiv.org/abs/2606.07682)). That is both the best argument
  for this protocol and the clearest statement of what it has not shown: nothing here
  measures AEP where those failures live.
- **Ceiling effects are now the norm, not the exception.** Rounds 18, 20 and 21 each
  failed to separate their arms because a frontier model on a small, well-specified task
  already does the thing being tested — the reviewer caught the seeded defect either way,
  both arms encoded the tricky criterion, and neither arm named a reviewer. Fixtures that
  discriminate have to sit at the edge of what the model does unprompted, and building
  those is harder than building the protocol. Read any 0.00 delta in this log as "this
  fixture could not tell them apart" before reading it as "the rule does nothing".

- n=2 per round is a signal, not statistics. A 0/2 → 2/2 flip after a targeted
  change is reported as a confirmed diagnosis; anything narrower is reported as
  a hint.
- Headless sessions do not use subagents by default, so fresh-context review is
  structurally unavailable there. Rounds 1–2 therefore say nothing about the
  quality of AEP's review subagents — only about disclosure behavior.
