# CLAUDE.md — AEP Adapter

The canonical, tool-agnostic protocol for this repository lives in @AGENTS.md — it is binding in every session.

## Claude Code specifics

- **Skills (invoke with `/` or auto-match):** `aep:protocol` orchestrates the full loop; `aep:explore`, `aep:plan`, `aep:implement`, `aep:verify`, `aep:deliver` are the phase playbooks; `aep:standards` is the security/performance/testing reference. Prefer invoking the phase skill over improvising the phase.
- **Subagents:** delegate wide codebase investigations to subagents to protect the main context. For the adversarial review step in §3.4, use the `aep:adversarial-reviewer` agent; for gap-closure audits, use `aep:gap-auditor`.
- **Verify gate (hook):** if `.claude/aep-check.sh` exists and is executable, a Stop hook runs it and blocks task completion while it fails. Keep that script pointing at the project's real build+test command (see §P.2).
- **Context discipline:** `/clear` between unrelated tasks; after two failed corrections on the same issue, prefer a fresh session with a sharper prompt over a third attempt.
