# Agentic Engineering Protocol (AEP)

**A verification-driven operating protocol for AI coding agents.**
Explore → Plan → Implement → Verify → Deliver — with skeptical brainstorming loops, gap analysis, adversarial review, closed feedback loops, and a hard verify gate.

AEP does not make your model smarter. It systematically closes the failure modes that waste your time with any coding agent: solving the wrong problem, declaring "done" without evidence, grading its own work, silently drifting out of scope, and forgetting what it learned last session.

Works with **Claude Code** (full plugin: skills + subagents + Stop-hook gate + commands) and with **any tool that reads the open Agent Skills standard or AGENTS.md** — OpenAI Codex, Cursor, Gemini CLI, GitHub Copilot / VS Code, and others.

---

## Architecture: the right rule in the right layer

Monolithic instruction files degrade: the longer the always-loaded file, the more the agent ignores. AEP splits the protocol across layers so detail is abundant where it's free and discipline is enforced where it matters:

| Layer | Mechanism | Loaded | Carries |
|---|---|---|---|
| Always-on core | `AGENTS.md` (+ thin `CLAUDE.md` adapter) | Every session, in full | Operating stance, non-negotiables, protocol summary, project memory (§P) |
| Phase playbooks | 7 skills (`aep:*`) | On demand (name+description always visible; body loads when invoked/matched) | Deep procedural detail: checklists, templates, loop algorithms |
| Fresh-context review | 2 subagents | On delegation, isolated context | Adversarial review & gap audit — the author never grades its own work |
| Hard enforcement | Stop hook (`verify-gate.sh`) | Deterministic, outside the model | Blocks "task complete" while the project's check fails |
| Bootstrap | `/aep:init` command | Manual | Installs the core + gate into any repository, populates project facts |

## Quick start — Claude Code

```bash
# 1. Add the marketplace
/plugin marketplace add omeeragtoprak/agentic-engineering-protocol

# 2. Install the plugin
/plugin install aep@agentic-engineering

# 3. Bootstrap any repository
/aep:init
```

Then run disciplined tasks:

```
/aep:protocol implement rate limiting on the upload endpoint
```

Or invoke phases directly: `/aep:explore`, `/aep:plan`, `/aep:verify`, … The skills also auto-match — asking for "a production-grade fix" or "analyze before changing" triggers the right phase without the slash.

**The verify gate:** `/aep:init` creates `.claude/aep-check.sh`. Point it at your real build+test command. While it exists and fails, a Stop hook blocks the agent from declaring the task complete (with a built-in safety override after repeated blocks, so a broken check can't dead-lock a session).

## Quick start — Codex & other agents

Skills follow the **Agent Skills open standard** (a directory with a `SKILL.md`: `name` + `description` frontmatter, markdown body — no tool-specific extensions), so they are portable:

```bash
# Codex CLI — per project (whole team gets it via git):
mkdir -p .agents/skills && cp -r plugins/aep/skills/* .agents/skills/

# Codex CLI — personal/global:
mkdir -p ~/.codex/skills && cp -r plugins/aep/skills/* ~/.codex/skills/
```

Then install the always-on core into the repository root:

```bash
cp plugins/aep/templates/AGENTS.md ./AGENTS.md
```

Codex reads `AGENTS.md` natively; Claude Code reads it through the `CLAUDE.md` adapter (`@AGENTS.md` import). One canonical core, every tool. Hooks and subagents are Claude Code enhancements — on other tools, the skills themselves instruct the agent to run the equivalent steps (fresh-context review, evidence blocks) manually.

## What's inside

```
agentic-engineering-protocol/
├── .claude-plugin/marketplace.json      # marketplace catalog
└── plugins/aep/
    ├── .claude-plugin/plugin.json       # plugin manifest (slug: aep, immutable)
    ├── commands/init.md                 # /aep:init — bootstrap a repository
    ├── skills/
    │   ├── protocol/    # full-loop orchestrator with phase exit gates
    │   ├── explore/     # read-only ingestion + As-Is/To-Be gap analysis + premise check
    │   ├── plan/        # generate→critique→refine brainstorming loop + tech spec + approval gates
    │   ├── implement/   # production-grade coding standards, atomic scope
    │   ├── verify/      # closed feedback loop, regression tests, adversarial review, gap closure, evidence block
    │   ├── deliver/     # delivery summary, commit etiquette, persistent-memory (§P) updates
    │   └── standards/   # security (OWASP-aligned) + performance/DB + testing reference
    ├── agents/
    │   ├── adversarial-reviewer.md      # tries to REFUTE the diff against its spec, fresh context
    │   └── gap-auditor.md               # certifies every gap closed/deferred/open, with evidence
    ├── hooks/hooks.json + scripts/verify-gate.sh   # deterministic completion gate
    └── templates/                       # AGENTS.md core, CLAUDE.md adapter, aep-check.sh.example
```

## Design principles (opinionated, evidence-based)

1. **Instruction files are advisory; hooks are deterministic.** Anything that must be *guaranteed* lives in the Stop hook or your CI — never only in prose.
2. **Lean always-on, rich on-demand.** The core stays small because bloated always-loaded files reduce adherence; the depth lives in skills whose bodies load only when needed (progressive disclosure).
3. **The author never grades its own work.** Verification runs in fresh context — subagents on Claude Code, a fresh session elsewhere.
4. **Evidence over assertion.** Completion requires commands + outputs, a regression test that failed before the fix, and a closed gap list.
5. **Two-strike loop discipline.** Two iterations without progress means reassess the hypothesis — never a third identical attempt.
6. **Memory is maintained, not accumulated.** §P grows with dated, imperative one-liners and shrinks when entries go stale; every change is announced.

## Updating

Push to `main`; users refresh with `/plugin marketplace update agentic-engineering`. The plugin slug `aep` is immutable — renaming a published plugin breaks installs. **Every release bumps the version in both manifests** (CI enforces they match): installed copies only update when the declared version changes. See [CHANGELOG.md](CHANGELOG.md).

## Contributing

Issues and PRs welcome. Protocol changes to the core (§0–§6 / skill semantics) require: the problem observed, the proposed rule as the *shortest imperative that would have prevented it*, and evidence. That is, contributions follow the protocol.

## License

MIT © 2026 [Ömer Faruk (omeeragtoprak)](https://github.com/omeeragtoprak)
