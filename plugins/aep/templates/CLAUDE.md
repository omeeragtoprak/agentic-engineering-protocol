# CLAUDE.md — AEP Adapter

The canonical, tool-agnostic protocol for this repository lives in @AGENTS.md — it is binding in every session.

## Claude Code specifics

- **Skills (invoke with `/` or auto-match):** `aep:protocol` orchestrates the full loop; `aep:explore`, `aep:plan`, `aep:implement`, `aep:verify`, `aep:deliver` are the phase playbooks; `aep:standards` is the security/performance/testing reference; `aep:research` is the triangulated web-research protocol; `aep:orchestrate` is the subagent-delegation playbook. Prefer invoking the phase skill over improvising the phase.
- **Subagents:** delegate wide codebase investigations to subagents to protect the main context. For the adversarial review step in §3.4, use the `aep:adversarial-reviewer` agent; for gap-closure audits, `aep:gap-auditor`; for security-sensitive or hot-path diffs, add `aep:security-auditor` / `aep:performance-auditor`. Brief reviewers with the diff and spec only — never your conclusions.
- **Verify gate (hook):** if `.claude/aep-check.sh` exists and is executable, a Stop hook runs it and blocks task completion while it fails. Keep that script pointing at the project's real build+test command (see §P.2).
- **Context discipline:** `/clear` between unrelated tasks; after two failed corrections on the same issue, prefer a fresh session with a sharper prompt over a third attempt.
