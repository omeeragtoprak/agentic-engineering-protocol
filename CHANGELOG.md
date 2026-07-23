# Changelog

All notable changes to AEP are documented here. Versions follow semver; the
plugin version in `plugins/aep/.claude-plugin/plugin.json` and the entry in
`.claude-plugin/marketplace.json` are bumped together on every release —
installed copies only update when this version changes.

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
