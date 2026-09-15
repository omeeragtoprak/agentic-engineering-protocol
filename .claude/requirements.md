# Requirements ledger — AEP itself

AEP ships a requirements ledger, so AEP keeps one. Every `done` row names a proof
in [`proofs/`](proofs/) that **exercises the behavior** and exits non-zero when it
stops holding; `.claude/trace.py` runs them on every check. An earlier version of
this table proved rows by naming CI steps — an adversarial review showed that
gutting a step's body left every row green while the requirement was false, so the
proofs are scripts now.

**Status:** `open` (agreed, not built) · `done` (built, proof named) ·
`deferred` (decided not now — the status cell carries a date and a reason) ·
`dropped` (decided never).

| ID | Requirement | Status | Proof | Source |
|----|-------------|--------|-------|--------|
| R1 | A Stop hook blocks "task complete" while the project's check is failing, and is a no-op when no check is configured | done | cmd: .claude/proofs/r1_gate_blocks.sh | docs/validation-log.md |
| R2 | A green suite that hides suppressed tests still surfaces a notice to the agent, and a clean green suite surfaces nothing | done | cmd: .claude/proofs/r2_suppressed_notice.sh | docs/design-rules.md |
| R3 | Uncommitted changes to test files, and to the gate's own inputs, are reported — a weakened suite or an edited check cannot pass silently | done | cmd: .claude/proofs/r3_tamper_notice.sh | docs/design-rules.md |
| R4 | The plugin version and the marketplace entry can never drift apart | done | cmd: .claude/proofs/r4_versions.sh | CHANGELOG.md |
| R5 | A `done` requirement whose proof has left the tree fails the check | done | cmd: .claude/proofs/r5_stale_proof.sh | docs/requirements.md |
| R6 | Every skill and subagent carries valid Agent-Skills frontmatter, so non-Claude tools can load them | done | cmd: .claude/proofs/r6_frontmatter.sh | README.md |
| R7 | Every shipped shell script parses under POSIX sh | done | cmd: .claude/proofs/r7_shell_syntax.sh | — |
| R8 | Both manifests are well-formed JSON declaring the keys the plugin loader requires, with a matching slug | done | cmd: .claude/proofs/r8_manifest_keys.sh | — |
| R12 | The always-on core stays inside a published density budget, with the operating stance in its first third | done | cmd: .claude/proofs/r12_core_density.sh | docs/ecosystem.md |
| R13 | A session that starts in a repository with AEP state is told what that state is, and one without it is not interrupted | done | cmd: .claude/proofs/r13_session_brief.sh | docs/design-rules.md |
| R14 | A bug-fix task leaves a requirement row behind, not only a feature task | open | — | docs/validation-log.md |
| R15 | The three eval cases that need a shell have been run at least once, with the gate live | open | — | plugins/aep/evals/README.md |
| R16 | A significant diff gets a fresh-context review, and the delivery names who graded it, under a current frontier model | open | — | docs/validation-log.md |
| R17 | AEP is scored by a third party on process discipline using a rubric that reads artifacts rather than action labels | open | — | docs/ecosystem.md |
| R18 | The validation log's index links every round and every link resolves | done | cmd: python3 .claude/proofs/r18_log_index.py | docs/validation-log.md |
| R19 | The validation log's summary counts match the table beneath them | done | cmd: python3 .claude/proofs/r19_log_counts.py | docs/validation-log.md |
| R9 | Agents actually maintain this ledger across multiple tasks, rather than letting it decay | open | — | docs/requirements.md |
| R10 | The gate is observed blocking a session that would otherwise have stopped red | deferred 2026-09-14 — nine controlled A/B rounds produced no such session; observing it needs a deliberately weak arm, and inventing one would measure the arm, not the gate | — | docs/validation-log.md |
| R11 | AEP ships a broad skill library of its own | dropped 2026-09-14 — a second always-on protocol layer collides with the one the user already runs; the reasons and the safe composition rules are written down instead | — | docs/ecosystem.md |
