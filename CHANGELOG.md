# Changelog

All notable changes to AEP are documented here. Versions follow semver; the
plugin version in `plugins/aep/.claude-plugin/plugin.json` and the entry in
`.claude-plugin/marketplace.json` are bumped together on every release —
installed copies only update when this version changes.

## [1.9.1] - 2026-09-15

### Measured
- **Round 18 tested v1.9.0's new reviewer step 0 directly and could not tell the arms
  apart.** A retry-budget fixture with one subtly violated acceptance criterion, three
  runs per arm, the reviewer invoked as the session itself: 6 of 6 returned
  `REFUTED (1 blocker)` and named the defect, with and without step 0. A ceiling
  effect, recorded as one. Two side observations worth more than the null result: the
  arm *without* step 0 wrote an expectation list anyway in 3 of 3 runs, and four of six
  reviewers ran the code rather than arguing about it — the "promote by probe" rule
  appearing unprompted.
- Step 0 stays on its mechanism and its one-paragraph cost. It is not claimed to
  improve AEP's reviews, and `docs/validation-log.md` says so in the same place it
  describes the rule.

## [1.9.0] - 2026-09-15

Two changes to how AEP reviews work, both from primary sources, both with their limits
stated rather than hidden.

### Changed
- **The adversarial reviewer now commits to its own answer before reading the diff.**
  Step 0 of the method: from the spec alone, write down what a correct implementation
  must contain and what you expect to be missing — then open the diff and review
  against that list. A judge conditioned on a candidate scores how *plausible* it
  looks, not whether it is correct; committing first is what separates the two.
  Measured at 0.719 → 0.012 false accepts in
  [arXiv:2607.05904](https://arxiv.org/abs/2607.05904) — on grade-school maths with
  Qwen3 policies, not on code, so the protocol takes the mechanism and says so.
- **"Two reviewers is the floor" is gone.** Agreement between reviewers drawn from the
  same model is not evidence: *ten* dedicated reviewers unanimously endorsed a
  Bleichenbacher padding oracle that did not exist, and only running the attack
  refuted it ([arXiv:2604.19049](https://arxiv.org/abs/2604.19049)). The rule is now
  **add lenses, not votes**, with two consequences written into the skill — a finding
  is promoted by a probe and not by a majority, and AEP's own subagents share the
  blind spots of whichever model you run them on, which a third same-family reviewer
  does not fix.

### Added
- Eval cases are tagged `needs-shell` or `no-shell`, so a case that cannot pass without
  `Bash` is not run in a condition that guarantees zero. Round 17 records the one time
  that happened: both arms produced correct work, both said plainly that no shell was
  available and asked the user to run the tests, and a grader scored that honesty as a
  failure. Void as evidence, kept as a record.

## [1.8.3] - 2026-09-15

A correction, and a feature held back because its measurement was cut short.

### Corrected
- **Round 14's explanation was wrong, and design rule 9 with it.** That round was
  published claiming the Stop hook takes no part in a run with no `Bash` grant. Hooks
  run regardless of the agent's tool grants: the traces show the gate firing and
  delivering its ledger notice in every one of those runs. The numbers stood; the
  reasoning under them did not.
- **What the transcripts do prove** is narrower and more useful: a non-blocking notice
  at Stop lands on the *second-to-last line* of the run, in 3 of 3 traces. It cannot
  change the run it appears in. Design rule 9 now says that, and says plainly that the
  wider claim it used to make was withdrawn.

### Added, off by default
- `AEP_LEDGER_BLOCK=1` makes the requirements reminder **block once** — exit 2, with
  an either/or the agent can satisfy in one turn ("add a row, or say this task
  committed to nothing"), a marker in `.git` so it asks once per session, and a second
  Stop that passes whatever was decided. Pinned by CI and two mutation tests, both
  paths.
- It is off by default because Round 16's measurement was voided mid-suite by a weekly
  usage limit: four of six runs unusable, two complete with-plugin runs, the block
  confirmed firing in both, and the row written in neither. Turning a gate from
  advisory to blocking for everyone needs more than two runs.

## [1.8.2] - 2026-09-14

### Added, but deliberately not enabled
- **`scripts/session-brief.sh`** — a `SessionStart` hook that reports tree state, the
  project check and the open and deferred requirement rows, and stays silent in
  repositories with no AEP state. It follows directly from design rule 9, its
  behaviour is pinned by CI and two mutation tests, and it is **off by default**
  because the measurement did not support turning it on: on the case it exists to
  move, the dated deferral row was written 0/3 with it and 0/3 without it (Round 15;
  the hook was verified to fire in exactly the three with-plugin runs). Enabling it is
  four lines in `.claude/settings.json`, documented with the numbers in
  `plugins/aep/scripts/README.md`.

### Measured
- Round 15 is the fourth rule or feature this project has withdrawn or refused to ship
  after measuring it. A component that is merely plausible is how a scaffold gets
  quietly worse — the cross-component interference paper puts that at a single-tool
  agent beating an all-components one by 32%.

## [1.8.1] - 2026-09-14

### Measured
- **Round 14: the ledger rule works through the hook, not through the prose.** Run
  under the official harness with no shell — so the Stop hook never fires — the dated
  deferral row was written in **0 of 6** runs, by both arms. The same words with the
  hook participating produced it in 2 of 3 (Round 11). Not a controlled pair, but it
  points where design principle 1 always said it would. AEP holds an explicitly
  out-of-scope item 3/3 against the bare model's 2/3, and that is all the prose does
  on its own here.

### Added
- **Design rule 9 — a rule that must fire at a moment needs a mechanism at that
  moment**, with the corollary that bounds the rest of that document: wording is what
  you tune when a rule fires at no particular time.
- `docs/ecosystem.md`: cross-component interference
  ([arXiv:2605.05716](https://arxiv.org/abs/2605.05716)) — a single-tool agent beating
  an all-components one by 32%, and 56.3% of component subsets violating
  submodularity. AEP is itself a stack of components, which is why its eval suite
  reports each case with and without the plugin instead of reporting a total.
- The eval suite README now says which cases need a shell, and why a no-shell run
  measures the instruction layer alone.

## [1.8.0] - 2026-09-14

Claude Code shipped `claude plugin eval` three days before this release. Every round
in this project's log until now was a harness it wrote about itself; this release
moves the claims into the official one and publishes what came back, including the
part that goes against the project.

### Added
- **An eval suite you can run** (`plugins/aep/evals/`, six cases). Each case is a rule
  this project measured, run with the plugin and again without it:
  `plan-before-code`, `plan-skill-fires`, `reviewer-named`, `evidence-not-assurance`,
  `ledger-row`, `deferral-recorded`. `ledger-row` is expected to fail — the gap is
  real and published, and a suite containing only what already works measures nothing.
  Its README carries the cost, the reading guide, and one environment prerequisite
  that is easy to hit (a Docker credential store containing symlinks blocks
  Bash-granting runs on macOS).
- A CI step that checks the suite's structure — cases present, graders typed,
  scaffolds executable and parsing — without spending a model call. Mutation-tested.
- **A density budget for the always-on core**, enforced by `.claude/proofs/r12_core_density.sh`
  and recorded as R12: 98 lines and 49 imperative bullets today, capped at 120/60,
  with §1 required to stay in the first third of the file. IFScale
  ([arXiv:2507.11538](https://arxiv.org/abs/2507.11538)) measures instruction-following
  at 68% for the best frontier models at 500 simultaneous instructions, with a bias
  toward earlier ones; a published number that nothing checks is a number that drifts.
- `docs/ecosystem.md` gains OpenSpec and Spec Kit — the two closest spec-driven
  neighbours — and a **What the research says about this design** section with three
  primary sources, including the finding that compliance collapses through *pairwise
  conflicts* rather than length ([arXiv:2608.02639](https://arxiv.org/abs/2608.02639)).

### Changed
- **The README's auto-match claim is now the measured one.** Same task, same model:
  a request naming the intent ("a production-grade plan… analyse the options first")
  fired a phase skill in 3 of 3 runs; the same task phrased flatly fired one in 0 of 3.
  The claim was true and vaguer than the measurement.

### Measured, and not in AEP's favour
- On a well-phrased planning request to a frontier model, AEP scored **1.00 against
  the bare model's 1.00 — Δ 0.00** — on three graders including whether the plan
  catches a non-idempotent POST that must not be retried. It fired, took 2.4× the
  turns and ~20% more cost, and produced plans the graders could not tell apart.
  Round 13 in `docs/validation-log.md`, and the case ships so anyone can re-run it.
- Round 12 attempted a conflict audit of §0 and measured nothing, because its metric
  was already at zero in both arms. It is recorded as inconclusive rather than dropped.

## [1.7.1] - 2026-09-14

Rounds 10-11 measured the v1.7.0 ledger and refuted the part that mattered.

### Fixed
- **The ledger rule was vacuous.** The always-on core said *close every requirement
  you touched*; with an empty ledger nothing is touched, so the sentence was
  satisfied by doing nothing. Measured across twelve task-sessions: two rows
  written, and **zero** dated deferrals — the one thing the ledger does that a
  delivery summary cannot. The core now says *write this task into the ledger
  before you finish*, unconditional and creation-first, with "this task committed
  to nothing" as an explicitly allowed answer.
- **The gate now names it at the Stop.** On a green check, if the working tree or
  the last commit moved code and `.claude/requirements.md` did not, the hook emits
  a non-blocking notice. Instructions could not reach the agent at the moment it
  mattered; the hook fires exactly there, while a turn remains. Silent in
  repositories that keep no ledger.
- Measured after the change (n=3): dated deferrals went **0/12 → 2/3** on the task
  that had one, and both sessions quoted the ledger in their own evidence blocks.
  Bug-fix tickets are still **0/3** — the fix works on feature work and not yet on
  bug fixes, and `docs/validation-log.md` says so.

### Added
- `.github/PULL_REQUEST_TEMPLATE.md` — asks contributors for what AEP asks agents
  for: the command output, the reviewer's name, the requirement row.
- `.github/workflows/release.yml` — a tag that disagrees with either manifest is
  refused, and the release notes are published from the CHANGELOG section, so the
  tag, the manifests and the published notes cannot drift apart by hand.

## [1.7.0] - 2026-09-14

Project-level requirements management. AEP managed one task well and forgot what
the project had committed to; twenty tasks produced twenty orphan specs.

### Added
- **Requirements ledger** (`templates/requirements.md` → `.claude/requirements.md`).
  One row per requirement: id, one verifiable sentence, status, **proof**, source
  spec. Four statuses, each load-bearing: `open` (agreed, not built) · `done`
  (proof named and checkable) · `deferred` (needs a date *and* a reason) ·
  `dropped` (the row stays, so the decision is not re-litigated quarterly).
- **`templates/trace.py.example`** — the checker that makes the ledger fail when it
  stops being true: a `done` row whose proof left the tree, a `cmd:` proof that no
  longer exits 0, an unauditable deferral, a duplicate id, an unknown status, a
  missing source spec, a missing ledger. It chains into `.claude/aep-check.sh`, so
  the Stop hook that already guarded the tests now guards the ledger too. Eleven
  scenarios are pinned in CI, and two mutations of the checker were confirmed to
  turn that CI step red — a check that cannot fail is not a check.
- **`/aep:status`** — where the project stands, read from evidence rather than from
  session memory: check state, ledger counts + traceability, git working state,
  open decisions with their age, and one highest-value next action. Anything it
  could not determine is reported as unknown.
- **[docs/requirements.md](docs/requirements.md)** — the three things lost at the
  task boundary (deferrals, decayed proofs, re-litigation), what the checker
  enforces, and what this deliberately is not (no assignees, estimates or sprints —
  duplicating an issue tracker produces two sources of truth).

### Changed
- **The verify gate now watches its own inputs (v3).** A probe found the hole: given
  a check that exited 1, an agent edited the check to exit 0 and stopped, reporting
  that it had "fixed the verification gate issue". A hook cannot be deterministic
  about a script the agent may rewrite, so the gate now reports uncommitted changes
  to `.claude/aep-check.sh`, `.claude/trace.py` and `.claude/requirements.md` exactly
  as it already reported uncommitted test-file changes — visibility instead of a
  prohibition. Written up as design rule 8: *any enforcement an agent can edit is a
  convention, not a control.*
- `aep:plan` assigns a requirement ID to each acceptance criterion and records it
  as `open`; `aep:verify`'s evidence block gains a `Reqs:` line naming each ID
  closed and the proof that closes it; `aep:deliver` leaves no row `open` merely
  because the session ended, and the delivery summary carries a `Requirements:`
  line; `aep:protocol`'s Plan and Deliver exit gates enforce both ends.
- The always-on core (`AGENTS.md`) carries one sentence about closing the ledger —
  a deferral that lives only in a delivery summary is read once and lost, and that
  is the layer that is always visible.
- `/aep:init` starts the ledger from what the repository already proves (tests that
  exist), not from wishes, and wires `trace.py` into the check.

### Refuted before release
A fresh-context adversarial review of this release's own diff — the same pass AEP
asks of every significant change — refuted six of nine acceptance claims. All are
fixed and pinned by CI scenarios:

- The deferral rule searched the status cell **and the requirement text**, so the
  "reason" clause never fired: every deferral with a date anywhere passed, and a
  date living only in the requirement text satisfied a row with no date at all.
- A row that was not five cells was skipped as noise, so a single missing column
  hid a stale `done` proof and a duplicate ID from the count, silently.
- `done` with an empty `cmd:` proof passed, because `subprocess.run("")` exits 0.
- `.claude/ci.py` ran CI steps without `errexit` (GitHub uses `bash -e`), so two of
  seven steps could not fail locally — the opposite of what that file claims to do.
  It also imported PyYAML, an undeclared dependency that would have blocked every
  session on a fresh clone; it now parses the workflow with no dependencies.
- Five of AEP's own `done` rows were proven by naming a CI **step name**, so gutting
  a step's body kept the ledger green while the requirement was false. Each row now
  names a script in `.claude/proofs/` that exercises the behavior.
- The installer's scaffolded check only *recommended* chaining `trace.py`; it now
  runs it.

Two further defects were found while fixing those: a `cmd:` proof containing a `|`
was truncated at the pipe and misreported as a bad Source (pipes must now be escaped,
and an over-wide row is an error), and a proof could be satisfied by `trace.py`'s own
docstring mentioning it (the checker now excludes itself from the corpus).

### Security
- A `cmd:` proof is executed with the shell, so the ledger is trusted input at the
  same level as `.claude/aep-check.sh`. `AEP_TRACE_NO_CMD=1` (for CI running
  untrusted pull requests) skips command proofs and **names each one as
  unverified** rather than silently counting it as passing.

### Not yet measured
- Whether agents actually maintain the ledger across tasks, or whether it decays
  like every other hand-maintained project file. The checker's behavior is proven;
  the human-in-the-loop half is not. Round 10 in `docs/validation-log.md`.

## [1.6.1] - 2026-08-26

### Confirmed by Round 9 (2026-09-09)
- The phase-boundary sentence took the same model, task and budget from **0 of 4**
  sessions producing any code to **2 of 2** delivering committed, tested,
  lint-clean work (3 → 35 tests each, behavioral probe 7/7 on both). v1.6.0's
  red-first rule held in the same round *in substance*: both wrote the acceptance
  criteria as tests before implementing — proven, not inferred, by running those
  tests against the pristine module (32 and 29 failures).

### Fixed
- **A phase boundary is not a stopping point.** Measured across Rounds 7–8: four
  small-model sessions ended cleanly — no error, no turn-limit hit — right after
  writing "proceeding to Phase 3: Implement", having produced no code, and the
  gate allowed it because an untouched repo is green. The protocol's own phase
  reports read like finished answers. The orchestrator now says to announce the
  phase result and keep going in the same turn, with a closed list of legitimate
  stops: the Plan approval gate, an escalation trigger, or a completed Deliver.

### Not yet measurable
- v1.6.0's red-first rule remains unvalidated: neither Round-8 session reached
  implementation. One did plan the exact required sequence unprompted (write
  failing acceptance checks, wire them into the gate, confirm red, then
  implement), so the rule is legible — it has simply not been observed executing.

## [1.6.0] - 2026-08-25

Round 7 found the verify gate's blind spot. Record: `docs/validation-log.md`.

### Added
- **Red-first on a green baseline.** Measured: two sessions ran Explore and Plan
  faithfully, wrote no code at all, and the gate let both stop — the repo's
  baseline was already green, so an untouched tree passed the check and the
  harness reported success. A gate that cannot fail is not a gate. On a green
  baseline the protocol now requires the spec's acceptance criteria to be wired
  into the project check **before** implementing, with the check confirmed
  failing first. Enforced from the orchestrator's Plan exit gate, with matching
  rules in `aep:plan` and `aep:verify` ("a green check is only evidence if it
  could have been red").

### Measured
- Rounds 5–7 ran three controlled A/Bs of the gate itself (same task, same model,
  one file different). **The gate has not blocked once in six arms** — capable
  models running these instructions verify themselves, and the weak-model round
  failed in a way the gate structurally cannot catch. The README now says this
  plainly instead of implying the hook is what makes the difference.

## [1.5.0] - 2026-08-17

Round 5 tested the project's headline claim under control for the first time, and
found a hole in it. Record: `docs/validation-log.md`.

### Added
- **The gate now sees suppressed tests.** `@unittest.expectedFailure`, `xfail`,
  and skips satisfy a green exit code while the assertion behind them is not
  enforced — verified directly: a suite carrying a knowingly-broken contract test
  exited 0 and the gate passed it. The Stop hook now emits a non-blocking notice
  naming the suppressions (it stays non-blocking because these are legitimate
  techniques), and `aep:verify` requires each suppressed test to be named in the
  evidence block, unconditionally.
- `bench/hidden-breakage` — a task built to separate instructions from
  enforcement: implementing the ticket correctly breaks a contract test in a
  second file, so only the full suite sees red. Ships an A/B protocol
  (gate arm vs no-gate arm) and pre-registered metrics.

### Measured
- **The Stop hook fires in headless sessions** — two timestamped invocations
  logged. Previously the hook had only been tested in isolation.
- **On this task the gate changed nothing.** Both arms ended green, neither
  weakened a test, both escalated the deployment decision to a human with a
  stated rationale. The gate is insurance for the case where an agent *would*
  stop red; this round did not produce that case, and the log says so.

## [1.4.3] - 2026-07-29

Round-4 validation refuted the v1.4.2 budget rule. Record: `docs/validation-log.md`.

### Changed
- **Budget discipline now names a limit instead of a rule.** Two measured
  cutoffs (one before the v1.4.2 reframe, one after) left a red suite: a hard
  interrupt mid-edit lands wherever it lands, and "be in a green state at phase
  boundaries" is a *continuous property* an interrupt ignores — unlike the
  *discrete actions* that flipped 0/2 → 2/2 in earlier rounds. The protocol now
  says so plainly and asks only for what prose can deliver: **name the state of
  the tree whenever you stop** (committed / uncommitted-green / uncommitted-red),
  and **commit green checkpoints where repo convention allows**.

### Added
- `bench/retry-crossmodule` — a feature task rather than a bug hunt: one shared
  helper, two callers with opposite latency budgets, and a transient-failure
  classification question the repo cannot answer. Baseline green, so passing the
  suite is free and the differences appear in system mapping, research, and
  disclosure. Includes a behavioral scoring guide.

### Note on measurement
- Five string-matching metrics across four rounds produced false results on agent
  output — including scoring an exemplary run (fresh-context review, mutation
  testing, live-socket tests, human escalation) as a failure because it wrote
  "Graded by a fresh-context subagent" instead of "Reviewer:". The validation log
  now leads with this: read the artifact, never score by regex alone.

## [1.4.2] - 2026-07-28

Round-3 validation (n=2) confirmed the v1.4.1 fix and exposed one more rule with
an unfollowable shape. Record: `docs/validation-log.md`.

### Confirmed
- Reviewer provenance went **0/2 -> 2/2**. Both deliveries named the reviewer
  unprompted ("authoring context — weaker"), one offering to run a proper
  fresh-context review. Together with the spec-persistence flip, this establishes
  the design rule: **unconditional positives are followed; conditional negatives
  are dropped** — same layer, same wording budget, opposite adherence.

### Fixed
- **Budget discipline reframed.** The old rule ("when budget is nearly exhausted,
  prioritize green suite > committed state > reports") assumes the agent can see
  its remaining budget — it cannot, and sessions are cut off mid-phase without
  warning; one Round-3 session was killed leaving a red suite. Replaced with an
  unconditional positive that needs no hidden state: *leave a committable green
  state at every phase boundary; if a phase must end red, say so in one line.*

## [1.4.1] - 2026-07-28

Round-2 validation (v1.4.0, n=2, same cross-module task) confirmed one fix and
refuted the shape of another. Full record: `docs/validation-log.md`.

### Confirmed
- Spec persistence went **0/2 -> 2/2** once the rule moved into the orchestrator
  exit gate — moving load-bearing rules to the always-visible layer was the
  right diagnosis.

### Fixed
- **Reviewer provenance is now unconditional.** v1.4.0 asked agents to disclose
  *when* fresh-context review was impossible; that conditional negative was
  dropped 0/2. Every delivery now names who graded the diff
  (`fresh-context subagent` / `separate session` / `authoring context (weaker)`)
  with no branch to forget — the same unconditional-positive shape that worked
  for spec persistence.

### Added
- `docs/validation-log.md` — measured rounds with failures published next to
  wins, plus measurement discipline (count `tool_use` in the session transcript;
  probe behavior against the real interface, never by grepping source — three
  source-grep probes produced false failures during these rounds).

### Observed, not yet fixed
- Named template fields are not reproduced verbatim: both sessions produced an
  `## Evidence` section, neither emitted the `Review:` row or the
  delivery-summary field names. Agents reproduce substance, not format — so
  rules that exist only as a template row are unreliable. Load-bearing
  requirements belong in exit gates, phrased as unconditional actions.

## [1.4.0] - 2026-07-27

Fixes found by running v1.3.0 against a live cross-module task (two independent
sessions, same ticket, both green and behaviorally verified) — the protocol
audited by its own method.

### Fixed
- **Artifact rules now live in the orchestrator, not only in the phase skills.**
  An agent that runs the loop inline never loads a phase-skill body, so the
  spec-persistence and acceptance-list rules were invisible to it — observed:
  neither session persisted `.claude/specs/`. `aep:protocol`'s Plan and Verify
  exit gates now carry those rules, plus an explicit "artifacts are
  load-bearing" clause (compress under budget, never drop; keep block headings
  so tooling and later sessions can find them).
- **No-fresh-context fallback is now a rule.** When subagents are unavailable,
  the review still runs, is labeled *weaker evidence — the context that wrote
  the code graded it*, and is disclosed in the delivery summary. (One session
  invented exactly this behavior and disclosed the deviation; codifying it
  removes the coin flip.)
- **Spec persistence is unconditional about location:** create `.claude/specs/`
  if absent — "the repo has no docs directory" was an observed excuse for
  skipping it.

### Changed
- `bench/README.md` documents how to measure a run: count `tool_use` entries in
  the session transcript, not `usage.server_tool_use.web_search_requests` — that
  counter reads 0 for sessions that demonstrably ran several searches, and a
  single unreliable instrument produces confident wrong findings.

### Validation notes (both sessions, same ticket)
- Research reflex fired in both (7 searches + 6 fetches total), multi-angle and
  primary-source heavy (AWS analysis, Python docs, RFC 9110), with empirical
  runtime verification where sources were vague.
- Cross-module reasoning produced opposite latency budgets per caller —
  behaviorally verified: interactive 2 attempts / <=0.1 s backoff vs batch
  5-7 attempts / 2-3.7 s.
- Suites hardened 3 -> 37 and 3 -> 33 tests, green; permanent failures not
  retried; backward compatibility preserved by default.

## [1.3.0] - 2026-07-23

Research-grounded "engineering intelligence" release — every mechanism below maps
to verified findings from a 104-agent deep-research pass (citations in commit).

### Added
- **`aep:research`** — triangulated web-research protocol: sub-branch
  decomposition, multi-angle search (including the negative angle), >=2
  independent sources per decision-bearing claim, recency/version pinning,
  claim/evidence/opinion separation, mandatory `(unverified)` labeling, and
  evidence-before-confidence output ordering (FaR, ACL Findings 2024: -23.5% ECE).
- **`aep:orchestrate`** — lead-engineer delegation: seam-based decomposition,
  written briefs with acceptance-criteria contracts, deliberate context
  isolation, and behavioral verification of every subagent claim (~36.9% of
  multi-agent failures are inter-agent misalignment, arXiv 2503.13657; two
  agents agreeing is not evidence).
- **System map** step in `aep:explore`: mechanically built impact maps
  (callers/callees/data-flow/co-change/blast-radius via grep/LSP/git, never from
  memory) — structural maps beat similarity guessing on repo-level tasks
  (RepoGraph, ICLR 2025: avg +32.8% relative; CodexGraph, NAACL 2025).
- **Purpose-linked action** rule in the core (§1.7): restate the goal, and be
  able to state in one line how any non-trivial action serves it — targets the
  goal-drift/reasoning class of agent failures (arXiv 2509.18970).
- **Lead / Orchestrator** lens in §2; skill map and CLAUDE.md adapter updated.

### Changed
- `aep:verify`: reviewer isolation is now explicit — reviewers get the diff and
  spec, never the author's reasoning or expected verdict (factored verification
  beats joint on all tasks tested, CoVe, ACL Findings 2024).

### Design notes
- Deliberately NOT added: naive "answer Unknown when unsure" rules — explicit
  abstention options measurably backfire (-15.75pp, "Abstention Inflation",
  arXiv 2507.16199). Uncertainty in AEP stays externally checked (gate,
  reviewers, triangulation) rather than self-declared.

## [1.2.0] - 2026-07-22

### Added
- **Aspect-verifier pack:** two new fresh-context subagents — `aep:security-auditor`
  (attacker-mindset OWASP/boundary/secrets audit) and `aep:performance-auditor`
  (hot paths, N+1, allocations, unbounded growth). `aep:verify` now scales the
  review panel with the surface: two reviewers is the floor, not the ceiling.
- **AEP-Bench** (`bench/`): the seeded-bug task corpus behind the launch numbers,
  with `score.sh` (suite state, original-assertions tamper audit, tests added)
  and documented methodology — including the honest ties.
- **`install.sh`** for non-Claude-Code tools: `codex-project`, `codex-global`,
  `agents-md`, and generic Agent Skills targets.
- Community files: CONTRIBUTING.md (contributions follow the protocol),
  SECURITY.md, and issue templates (bug report, protocol change).

### Notes
- Official `claude plugin eval` cases are deferred until the feature exits early
  access; `bench/` is runnable today with any agent.

## [1.1.0] - 2026-07-21

### Added
- **Spec-anchored planning:** `aep:plan` now emits a numbered Acceptance list and
  persists the spec to `.claude/specs/<task-slug>.md` for non-trivial work — the
  diff converges to the spec, and Phase 4 walks the acceptance list with named
  proofs (new `Spec:` row in the evidence block).
- **Executable acceptance criteria:** `templates/spec_check.py.example` — a
  battle-tested checker pattern chained into the verify gate, with explicit
  guidance to prefer behavioral probes over keyword greps.
- **Budget discipline** in `aep:protocol`: compress artifacts, never skip phases;
  when budget is nearly exhausted, priority is green suite > committed state >
  reports.
- **UI craft rule** in `aep:implement`: one deliberate polish pass for
  user-facing surfaces once the gate is green — visual quality is part of
  production-grade.

## [1.0.1] - 2026-07-21

### Added
- **Verify gate v2 (tamper visibility):** the Stop hook now reports uncommitted
  changes to test files. On a red check the report is appended to the blocking
  feedback; on a green check it surfaces as a non-blocking notice to the user.
  Passing the gate by quietly weakening tests is no longer silent.
- **Test-integrity rule** in `aep:verify`: test changes must be named and
  justified in the delivery summary.
- **Repository CI** (GitHub Actions): shell syntax, JSON manifests, skill/agent
  frontmatter, plugin/marketplace version consistency, gate behavior tests, and
  `claude plugin validate`.
- This changelog.

### Fixed
- Release discipline: documented and enforced (CI check) that the plugin version
  must be bumped on every release, so marketplace installs actually receive
  updates.

## [1.0.0] - 2026-07-16

Initial release: AGENTS.md core + CLAUDE.md adapter, 7 phase skills
(protocol, explore, plan, implement, verify, deliver, standards), 2 fresh-context
review subagents (adversarial-reviewer, gap-auditor), deterministic Stop-hook
verify gate, `/aep:init` bootstrapper, plugin marketplace distribution.
