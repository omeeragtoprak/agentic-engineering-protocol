# AEP — Agentic Engineering Protocol (plugin)

Verification-driven operating protocol for AI coding agents. Full documentation, cross-tool
installation (Codex & others), and design rationale: see the repository root README.

Quick use after install: run `/aep:init` once per repository, then `/aep:protocol <task>`.
Phase skills: `aep:explore` · `aep:plan` · `aep:implement` · `aep:verify` · `aep:deliver` · reference: `aep:standards`.
Subagents: `aep:adversarial-reviewer`, `aep:gap-auditor`, `aep:security-auditor`, `aep:performance-auditor`. Hard gate: `.claude/aep-check.sh` + Stop hook.
