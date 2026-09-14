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

The `deferral-recorded` case, run with `--allow-tools Write Edit` and **no shell**.
That matters: without `Bash` the project's check never runs, so the Stop hook — and
the ledger notice v1.7.1 added to it — take no part in the result. This measures what
the instructions achieve on their own.

| | score | out-of-scope item held | dated `deferred` row written | turns |
|---|---|---|---|---|
| with AEP | 0.50 | **3/3** | **0/3** | 11, 13, 10 |
| without | 0.33 | 2/3 | 0/3 | 14, 11, 9 |

**Δ +0.17, and the interesting number is the zero.** In six runs the dated deferral
row was written **never** — by either arm. The same rule, in the same words, with the
Stop-hook notice participating, produced it in 2 of 3 sessions in Round 11.

The two are not a controlled pair: different harness, different n, and Round 11's runs
had a shell. Read it as pointing the same way as this project's first design
principle rather than as proof — *instruction files are advisory; hooks are
deterministic*. What the prose does on its own here is hold scope (3/3 against 2/3),
which is a weak signal, and nothing else.

The controlled version — the identical case with `Bash` granted, hook live — could not
run on the machine these rounds were measured on: `claude plugin eval` refuses a
Bash-granting run when the Docker credential store contains a symbolic link anywhere
inside it, which Docker Desktop's `cli-plugins/` normally does. The case ships; anyone
whose machine allows it can close this gap, and the number will be published either way.

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

## Standing caveats

- n=2 per round is a signal, not statistics. A 0/2 → 2/2 flip after a targeted
  change is reported as a confirmed diagnosis; anything narrower is reported as
  a hint.
- Headless sessions do not use subagents by default, so fresh-context review is
  structurally unavailable there. Rounds 1–2 therefore say nothing about the
  quality of AEP's review subagents — only about disclosure behavior.
