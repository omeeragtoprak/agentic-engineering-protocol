# Agentic Engineering Protocol (AEP)

**A verification-driven operating protocol for AI coding agents.**
Explore → Plan → Implement → Verify → Deliver — with skeptical brainstorming loops, gap analysis, adversarial review, closed feedback loops, and a hard verify gate.

AEP does not make your model smarter. It systematically closes the failure modes that waste your time with any coding agent: solving the wrong problem, declaring "done" without evidence, grading its own work, silently drifting out of scope, and forgetting what it learned last session.

Works with **Claude Code** (full plugin: skills + subagents + Stop-hook gate + commands) and with **any tool that reads the open Agent Skills standard or AGENTS.md** — OpenAI Codex, Cursor, Gemini CLI, GitHub Copilot / VS Code, and others.

AEP is not the only project in this space, and it is small on purpose. If you want a
large skill library or a full toolkit, [docs/ecosystem.md](docs/ecosystem.md) names the
neighbours, says plainly where they are the better choice, and explains why running two
protocol frameworks at once breaks both.

## What twenty-four measured rounds say about when this pays

Everything below is in [docs/validation-log.md](docs/validation-log.md) with the runs
behind it. Read this before installing — it is the part most projects leave out.

**What holds up:**

- **The deterministic parts do what they claim**, and CI proves it on every push: the
  Stop hook blocks completion while your check fails, reports suppressed tests and
  uncommitted edits to the check itself, and the traceability checker turns a
  requirement red when the test that proved it leaves the tree. These are not model
  behaviour; they are scripts with mutation-tested assertions.
- **The rules that changed outcomes did so with weaker models.** One sentence about
  phase boundaries took a small model from 0 of 4 sessions producing any code to 2 of
  2 delivering committed, tested work. Making "name who reviewed this" unconditional
  went 0/2 → 2/2 in the same conditions — though **re-run against a frontier model on a
  small feature task, neither arm named a reviewer or ran one at all** (0/3 vs 0/3,
  Round 20). The rule lives in a skill layer that a plain task prompt never opens.

**What does not, or is not yet shown:**

- **With a frontier model on a well-phrased request, the deltas go to zero.** Measured:
  on a planning task, AEP scored 1.00 against the bare model's 1.00 — same acceptance
  criteria, same grounding in the repo, same catch of a non-idempotent retry hazard —
  for 2.4× the turns. That matches the wider finding that scaffolding gains shrink as
  base models improve ([docs/ecosystem.md](docs/ecosystem.md) cites the work).
- **The requirements ledger does not maintain itself.** Agents wrote rows in 2 of 12
  task-sessions and dated deferrals in 0 of 12; the one condition that worked has not
  replicated. Keep the rows yourself and the checker keeps them true — that part works.
- **The gate has never blocked a real session** in eighteen rounds. It is insurance for
  the tail case, not a performance multiplier.

**Where it measurably pays, once:** on a six-ticket sequence in one repository — long
enough for a decision to be forgotten — every run carrying AEP's always-on core delivered
the final ticket, and **every bare run stopped to ask a business-rules question and
shipped nothing for it** (5/5 against 0/3, about 2× the cost and roughly double the
tests). A third arm isolated the cause: with the requirements ledger removed the runs
still finished, stating their interpretation and proceeding, so it is the operating
stance doing the work and not the file. One task, one model, and the first fixture in
this log that could tell the arms apart at all.

**Where it probably also pays, unmeasured:** the failure categories AEP targets are the
ones that dominate *long-horizon* agent work — 41.6% shipping broken code, 31.4% running
out the clock, 15.4% reward hacking, and a validation-failure signal in 99.6% of failures
across attempts averaging 27.2M tokens ([SWE-Marathon](https://arxiv.org/abs/2606.07682)).
Every measurement in this repository is short-horizon, where a capable model needs none
of that. So the honest shape of the claim is: the problem is real and measured, AEP aims
at it, and AEP has not been measured there.

**So: install AEP if you want enforcement you can audit** — a completion gate, a
traceability checker, evidence blocks, and a protocol whose every claim is published
with the round that produced it, including the four rules this project withdrew after
measuring them. **Do not install it expecting a capable model to get better at
planning**; on that, the measurement says it does not.

---

## Architecture: the right rule in the right layer

Monolithic instruction files degrade: the longer the always-loaded file, the more the agent ignores. AEP splits the protocol across layers so detail is abundant where it's free and discipline is enforced where it matters:

| Layer | Mechanism | Loaded | Carries |
|---|---|---|---|
| Always-on core | `AGENTS.md` (+ thin `CLAUDE.md` adapter) | Every session, in full | Operating stance, non-negotiables, protocol summary, project memory (§P) |
| Playbooks | 9 skills (`aep:*`) | On demand (name+description always visible; body loads when invoked/matched) | Deep procedural detail: 5 phases + standards + triangulated research + orchestration |
| Fresh-context review | 5 subagents | On delegation, isolated context | Adversarial review, gap audit, security & performance audits — the author never grades its own work |
| Hard enforcement | Stop hook (`verify-gate.sh`) | Deterministic, outside the model | Blocks "task complete" while the project's check fails |
| State at the right moment | SessionStart hook (`session-brief.sh`) | **Opt-in, off by default** | Reports tree state, check presence and open/deferred requirements. Built, measured, and left off because the measurement did not support turning it on — [why](plugins/aep/scripts/README.md) |
| Bootstrap | `/aep:init` command | Manual | Installs the core + gate into any repository, populates project facts |
| Project memory across tasks | `.claude/requirements.md` + `trace.py` | Read by the gate and by `/aep:status` | What the project has committed to and what proves it — survives the session that agreed to it |

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

Ask where things stand at any point:

```
/aep:status
```

Or invoke phases directly: `/aep:explore`, `/aep:plan`, `/aep:verify`, …

**Auto-matching works, but it is the phrasing that does it.** Measured with the eval
suite below, same task and model: a request that names the intent — *"I want a
production-grade plan before any code is written… analyse the options first"* — fired
a phase skill in **3 of 3** runs. The same task phrased flatly fired one in **0 of 3**.
If you want the protocol and you are not typing the slash command, say what you want
from it.

**What the gate is, measured:** in controlled A/B rounds (same task, same model, one file different) the gate has **not blocked once** — capable models running these instructions verify themselves, and the hook found nothing to catch. Treat it as insurance for the tail case (an agent that *would* stop red), not as a performance multiplier; the numbers are in [docs/validation-log.md](docs/validation-log.md).

**Requirements outlive the session that agreed to them** (measured: see the ledger
entry under [Validation](#validation) before you trust it). A spec answers *what are we
building now*; after twenty tasks you have twenty orphan spec files and no answer to
*what has this project committed to, and what proves it*. `/aep:init` starts
`.claude/requirements.md` — one row per requirement: id, one verifiable sentence,
status, **proof**, source spec — and `.claude/trace.py`, which fails the check when a
`done` row's proof no longer exists, when a deferral has no date and reason, or when a
`cmd:` proof stops exiting 0. A ledger that cannot fail is decoration.
See [docs/requirements.md](docs/requirements.md).

**The verify gate:** `/aep:init` creates `.claude/aep-check.sh`. Point it at your real build+test command. While it exists and fails, a Stop hook blocks the agent from declaring the task complete (with a built-in safety override after repeated blocks, so a broken check can't dead-lock a session).

When the check is *green* the gate can still have something to say — a suppressed
test, an uncommitted edit to the check itself, a requirement nobody recorded — and it
says it as a non-blocking note. Measured honestly: that note lands on the
second-to-last line of the transcript, so **it reaches the human reading the session,
not the turn it appears in**. Set `AEP_LEDGER_BLOCK=1` to make the requirements
reminder block once instead; it is off by default because the measurement that would
justify blocking everyone was cut short at two runs ([Round 16](docs/validation-log.md)).

## Quick start — Codex & other agents

Skills follow the **Agent Skills open standard** (a directory with a `SKILL.md`: `name` + `description` frontmatter, markdown body — no tool-specific extensions), so they are portable:

```bash
./install.sh codex-project   # skills -> ./.agents/skills, core -> ./AGENTS.md
./install.sh codex-global    # skills -> ~/.codex/skills
./install.sh agents-md       # AGENTS.md core only (any AGENTS.md-reading tool)
```

Each of those also installs the always-on core (`./AGENTS.md`) and the project
scaffold the protocol refers to by name — `.claude/requirements.md` (the ledger),
`.claude/trace.py` (its checker) and `.claude/aep-check.sh` (your build+test
command). Existing files are never overwritten. Without the scaffold, "close the
ledger" and "run the check" are instructions pointing at nothing.

Codex reads `AGENTS.md` natively; Claude Code reads it through the `CLAUDE.md` adapter (`@AGENTS.md` import). One canonical core, every tool. Hooks and subagents are Claude Code enhancements — on other tools, the skills themselves instruct the agent to run the equivalent steps (fresh-context review, evidence blocks) manually.

## What's inside

```
agentic-engineering-protocol/
├── .claude/                             # AEP running its own protocol on itself:
│                                        #   requirements.md ledger, trace.py, aep-check.sh
├── .claude-plugin/marketplace.json      # marketplace catalog
├── bench/                               # AEP-Bench: seeded-bug tasks + scorer, plus `sequence/`,
│                                        #   a six-ticket task where a decision must survive six tickets
├── install.sh                           # installer for Codex & other AGENTS.md/Agent Skills tools
└── plugins/aep/
    ├── .claude-plugin/plugin.json       # plugin manifest (slug: aep, immutable)
    ├── commands/init.md                 # /aep:init — bootstrap a repository
    ├── commands/status.md               # /aep:status — where the project stands, from evidence
    ├── skills/
    │   ├── protocol/    # full-loop orchestrator with phase exit gates
    │   ├── explore/     # read-only ingestion + As-Is/To-Be gap analysis + premise check
    │   ├── plan/        # generate→critique→refine loop + spec-anchored tech spec (.claude/specs/) + approval gates
    │   ├── implement/   # production-grade coding standards, atomic scope
    │   ├── verify/      # closed feedback loop, regression tests, isolated adversarial review, gap closure, evidence block
    │   ├── deliver/     # delivery summary, commit etiquette, persistent-memory (§P) updates
    │   ├── standards/   # security (OWASP-aligned) + performance/DB + testing reference
    │   ├── research/    # sub-branch decomposition, multi-angle search, source triangulation, (unverified) labeling
    │   └── orchestrate/ # seam-based decomposition, delegation contracts, behavioral verification of subagents
    ├── agents/
    │   ├── adversarial-reviewer.md      # tries to REFUTE the diff against its spec, fresh context
    │   ├── gap-auditor.md               # certifies every gap closed/deferred/open, with evidence
    │   ├── security-auditor.md          # attacker-mindset audit: OWASP, boundaries, secrets
    │   └── performance-auditor.md       # scale hazards: hot paths, N+1, allocations
    ├── hooks/hooks.json                 # Stop + SessionStart
    ├── scripts/verify-gate.sh           # deterministic completion gate
    ├── scripts/session-brief.sh         # session-start state brief (opt-in, see scripts/README.md)
    ├── evals/                           # the claims as runnable eval cases
    └── templates/                       # AGENTS.md core, CLAUDE.md adapter, aep-check.sh.example,
                                        # spec_check.py.example, requirements.md ledger + trace.py.example
```

## Validation

AEP is measured on real tasks, and the failures are published next to the wins —
twenty-four rounds so far in [docs/validation-log.md](docs/validation-log.md), including
the ones that went against the project:

- Three rules confirmed by targeted flips (spec persistence and reviewer provenance 0/2 → 2/2; one sentence about phase boundaries took a weak model from 0/4 sessions producing code to 2/2 delivering committed, tested work).
- Two rules **withdrawn or rewritten** after the evidence refuted them.
- Three controlled A/Bs of the gate itself, in which **it never blocked** — capable
  models running these instructions verify themselves, so the hook is insurance for
  the tail case, not a performance multiplier.
- One measured blind spot that changed the protocol: on a task whose baseline is
  already green, two sessions produced *nothing* and were allowed to finish, because
  a check that cannot fail is not a gate.
- On a well-phrased **planning** request to a frontier model, AEP measured **Δ 0.00**
  against no plugin at all — same acceptance criteria, same grounding in the repo,
  same catch of a non-idempotent retry hazard, for 2.4× the turns. Where AEP has
  changed outcomes it has been completion discipline, usually with a weaker model.
  That case ships in the eval suite so you can re-run it.
- The requirements ledger shipped, was measured, and **failed**: 2 rows written in
  12 task-sessions and not one dated deferral. The rule was vacuous — "close every
  requirement you touched" is satisfied by an empty ledger. After moving it into the
  always-on core as a creation rule and having the Stop hook name it, dated
  deferrals went 0/12 → 2/3 in one harness — and then **did not replicate**: 0 of 12
  runs under the official eval harness, where the same reminder fires every time.
  [docs/requirements.md](docs/requirements.md) has the full table, including the four
  conditions that produced nothing.

**AEP runs its own protocol on itself.** This repository keeps
[`.claude/requirements.md`](.claude/requirements.md) — eleven of its own commitments,
including one `open`, one dated `deferred` and one `dropped` — and its check runs the
full CI suite plus `trace.py` on every gate. Renaming the Stop hook's tamper message
in a scratch copy turns AEP's own ledger red; that is the property being claimed, and
it was tested by breaking it.

Those rounds also produced something reusable beyond AEP:
**[docs/design-rules.md](docs/design-rules.md) — nine findings on which rule shapes
agents actually follow**, each with the measurement behind it.
Task corpus and scorer: [bench/](bench/).

**Run the evidence yourself.** The claims above are also an eval suite — six cases,
each one a rule this project measured, run with the plugin and again without it:

```bash
claude plugin eval plugins/aep --scaffold --trust-plugin \
  --allow-tools Write Edit Bash --model claude-sonnet-5 --judge-model claude-sonnet-5
```

A case that scores the same in both arms is a case where AEP is not what made it
pass. One case in the suite — `ledger-row` — is expected to fail, because the gap it
covers is real and published. See [plugins/aep/evals/README.md](plugins/aep/evals/README.md)
for what each case encodes, the cost, and the one environment prerequisite that is
easy to hit.

## Documentation

| Document | What it answers |
|---|---|
| [docs/worked-example.md](docs/worked-example.md) | What AEP actually produces — the spec, evidence block and delivery summary from one measured session, verbatim |
| [docs/validation-log.md](docs/validation-log.md) | Every measured round, with the rounds that went against the project |
| [docs/design-rules.md](docs/design-rules.md) | Which rule shapes agents follow, and which they drop — nine findings with their measurements |
| [docs/requirements.md](docs/requirements.md) | How a project's commitments are tracked across sessions — the ledger, what the checker enforces, and what it deliberately is not |
| [docs/ecosystem.md](docs/ecosystem.md) | What AEP is *not*, which neighbours overlap, how to compose them safely, and how to vet any agent plugin |
| [bench/](bench/) | The task corpus and scorer behind the numbers |

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
