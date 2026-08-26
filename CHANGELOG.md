# Changelog

All notable changes to AEP are documented here. Versions follow semver; the
plugin version in `plugins/aep/.claude-plugin/plugin.json` and the entry in
`.claude-plugin/marketplace.json` are bumped together on every release —
installed copies only update when this version changes.

## [1.6.1] - 2026-08-26

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
