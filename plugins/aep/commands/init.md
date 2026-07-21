---
description: Bootstrap the Agentic Engineering Protocol into the current repository — installs the always-on core (AGENTS.md + CLAUDE.md adapter), the verify-gate check script, and populates project facts.
---

Bootstrap AEP into this repository. Execute these steps in order and report what you did:

1. **Install the core, without destroying existing memory.**
   - If `AGENTS.md` does NOT exist: copy `${CLAUDE_PLUGIN_ROOT}/templates/AGENTS.md` to the repository root.
   - If `AGENTS.md` already exists: do NOT overwrite. Show the user a proposed merge — AEP sections appended below their existing content, duplicates removed — and apply it only after they approve.
   - Same rule for `CLAUDE.md` using `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md`: create if absent; if present, propose adding only the `@AGENTS.md` import line and the "Claude Code specifics" block.

2. **Install the verify gate (optional but recommended).**
   - Copy `${CLAUDE_PLUGIN_ROOT}/templates/aep-check.sh.example` to `.claude/aep-check.sh`, make it executable, and edit it to run this project's REAL build+test command (discover it from the repo: package.json scripts, csproj/sln, Makefile, CI config). If you cannot determine the command with confidence, leave the stub as a no-op and tell the user exactly what to put in it. For tasks with machine-checkable acceptance criteria, `${CLAUDE_PLUGIN_ROOT}/templates/spec_check.py.example` shows how to chain an executable spec checker into the same gate.
   - Explain in one line: while this script exists and fails, the Stop hook blocks task completion.

3. **Populate §P (bootstrap rule).**
   - Run `aep:explore` in lightweight mode: identify purpose, stack + runtime versions, entry points, and the verified build/test/lint/run commands (actually run them read-safely where possible to verify).
   - Fill §P.1 and §P.2 in `AGENTS.md` with what you verified. Mark anything unverified as `(unverified)` rather than guessing.

4. **Report.** Output: files created/modified, the verified commands with their status, anything left `(unverified)`, and the one-line usage reminder: *"Run `/aep:protocol <task>` for disciplined execution; phase skills are `aep:explore|plan|implement|verify|deliver`; `aep:standards` is the reference."*

Never write secrets into any of these files. Never overwrite user content without approval.
