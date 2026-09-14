# Ecosystem: what AEP is not, and what to reach for instead

AEP is one layer — a verification-driven operating protocol. It is deliberately
not a memory system, not a knowledge base, not a UI toolkit, not an MCP server
collection. This page maps the neighbours honestly, including the ones that
overlap with AEP and might suit you better.

**AEP installs none of them.** Everything here is something *you* choose,
install, and own. That is a deliberate position, explained at the bottom.

*Repository figures below were read from the GitHub API on 2026-09-14 and will
drift. Re-check before trusting any of them — the vetting checklist is the
durable part of this page.*

---

## Same territory as AEP — read these before choosing

If you are looking for "make my coding agent work in a disciplined way", these
compete with AEP. Pick one as your primary protocol; running two at once is the
main way people break both (see *Composing* below).

| Project | What it is | How AEP differs |
|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) (MIT, active) | An agentic skills framework and development methodology: plan before touching a file, TDD, two-stage self-review. Much larger skill library than AEP. | AEP is smaller and narrower, and its rules are published with the measurements that produced them ([validation-log](validation-log.md)). Superpowers gives you far more breadth; AEP gives you a thin always-on core plus a deterministic completion gate. |
| [affaan-m/ECC](https://github.com/affaan-m/ECC) — "Everything Claude Code" (MIT, active) | A large configuration framework: dozens of agents, ~100+ skills, hooks, security scanning, memory, across Claude Code / Cursor / Codex / OpenCode. | Different philosophy. ECC is a comprehensive toolkit you adopt wholesale; AEP is ~9 skills and one hook, designed so the always-on core stays small because bloated cores get ignored. |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT, active) | A skill system that pushes agents toward the *smallest* possible change — a YAGNI decision ladder ("does this need to exist? is it in stdlib? can it be one line?"). | Orthogonal and genuinely complementary: ponytail constrains *what gets written*, AEP constrains *what counts as done*. Of everything on this page, this is the one most worth running alongside AEP. |
| [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) (active) | Spec-driven development on a delta model: `propose → apply → archive`. Change proposals carry spec deltas; archiving merges them into `openspec/specs/`, which becomes the source of truth for current behaviour. | The closest neighbour to AEP's requirements ledger, and the difference is what gets re-checked. `openspec validate` "validate[s] changes and specs for structural issues, and check[s] a change's MODIFIED requirements against the main specs they would replace" — spec against spec. AEP's `trace.py` checks a requirement against the **tree**: a `done` row whose named test no longer exists fails the project's check. Specs describe; proofs decay. |
| [github/spec-kit](https://github.com/github/spec-kit) (active) | The most widely adopted spec-driven toolkit: `/specify → /plan → /tasks → /implement`, multi-agent, template-driven. | Much larger surface and a real community. AEP is not a spec toolkit — it is a completion discipline with one hook, and it publishes the measurements behind each rule. If you want spec artefacts as the centre of gravity, Spec Kit is the better fit; the two overlap on planning and will fight over the loop if you run both. |
| GSD — "Get Shit Done" | A spec-driven meta-prompting system for Claude Code. | **Read this before adopting:** the original repository (`gsd-build/get-shit-done`) is **archived** (last push 2026-05-31) following ownership/trust concerns in the community; development continued in community forks. Evaluate the fork you are pointed at on its own merits, not the original's reputation. |


## What the research says about this design

Three findings from outside this project bear directly on how AEP is built, and two
of them cut against the instinct to write more rules.

- **Instruction-following degrades with density.** IFScale ([arXiv:2507.11538](https://arxiv.org/abs/2507.11538))
  stacks up to 500 simultaneous instructions across 20 models and seven providers;
  the best frontier models reach **68% at 500**, with a measured bias toward
  *earlier* instructions. AEP's always-on core is 98 lines and 49 imperative bullets,
  which is why the depth lives in skills that load on demand — and why the
  load-bearing rules sit early in the file. The caveat is real: IFScale's task is
  keyword inclusion in a business report, not an agent following behavioural rules,
  so it bounds the design rather than proving it.
- **Conflicts collapse compliance faster than length does.** *Instruction Stacking
  Collapse* ([arXiv:2608.02639](https://arxiv.org/abs/2608.02639)) stacks 24
  verifier-checked instructions and reports the follow rate falling from ~96% to as
  low as 20%, "driven by a structured and reproducible set of pairwise conflicts" —
  one `output JSON` constraint being jointly unsatisfiable with nine others. The
  lesson AEP takes: audit the core for rules that contradict each other, not just for
  length. Its own prompt-compilation remedy is **capability-graded** (+11 points for
  weaker models, no measurable change for stronger ones), which matches what this
  project keeps measuring — the rules that help most are the ones weak models drop.
- **Stacking scaffolding components can make an agent worse.** *More Is Not Always
  Better* ([arXiv:2605.05716](https://arxiv.org/abs/2605.05716)) measures cross-component
  interference across planning, tools, memory, self-reflection and retrieval: a
  single-tool agent beat the all-components system by 32% on HotpotQA (F1 0.233 vs
  0.177), an optimal three-component subset beat all-components by 79% on GSM8K, and
  **56.3% of the 325 subsets violated submodularity** — so adding a component that
  helps on its own can still hurt in combination, and greedy "add another skill"
  selection is unreliable. At 70B, combinations that hurt at 8B became beneficial,
  yet all-components still lost to the best subset at both scales. AEP is itself a
  stack — core, nine skills, four subagents, a hook, a ledger — so this is a warning
  it has to take about itself, and the reason the [eval suite](../plugins/aep/evals/README.md)
  reports each case with and without the plugin rather than reporting a total.

- **Process frameworks converge, and none covers everything.** A 2026 taxonomy of
  agent development frameworks ([arXiv:2606.04967](https://arxiv.org/abs/2606.04967))
  compares Spec Kit, OpenSpec, BMAD, GSD, Spec Kitty and Reversa across six
  dimensions — specification, context, roles, execution, validation, portability —
  and finds no framework strong in all six, with a structural tension between process
  depth and agent portability. It also names **"absent benchmarks for complete
  processes"** as an open risk. AEP sits deliberately at the validation/portability
  end: thin core, one hook, an [eval suite](../plugins/aep/evals/README.md) you can
  run, and a [log of the rounds that went against it](validation-log.md).

## Complements — different layer, composes cleanly

| Project | Layer it covers | Why it composes with AEP |
|---|---|---|
| [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) (Apache-2.0) | Automatic cross-session memory: captures and re-injects context. | AEP's `§P` is deliberately hand-maintained, human-readable and git-native — durable project *invariants*. An automatic memory layer covers the other half: what happened recently. They answer different questions. |
| [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) (MIT) | Agent skills for working inside an Obsidian vault (Markdown, Bases, JSON Canvas). | Knowledge work, not code delivery. Useful if your specs and decisions live in a vault rather than in `.claude/specs/`. |
| [czlonkowski/n8n-mcp](https://github.com/czlonkowski/n8n-mcp) (MIT) | An MCP server exposing n8n workflow automation to agents. | Gives an agent real actions outside the repo. AEP's rule still applies unchanged: a tool result is an unverified claim until you check it. |
| [HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) (MIT) | A knowledge-graph RAG framework — a standalone Python service, **not** a Claude Code plugin. | Relevant when your agent needs to reason over a large private corpus. Treat anything it returns as a source to triangulate, per [`aep:research`](../plugins/aep/skills/research/SKILL.md). |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | A curated index of the wider ecosystem. | The place to look for whatever this page does not cover. |

## Composing AEP with another protocol framework

Two protocol frameworks running at once is the most common way to get worse
results than either alone. They collide in three places:

1. **Both want the loop.** Superpowers, GSD-style systems and AEP each define
   their own plan → implement → verify cycle. Two cycles means the agent
   arbitrates between them mid-task. Pick one as primary and disable the
   other's orchestrator.
2. **Both want the always-on core.** `AGENTS.md` / `CLAUDE.md` is a shared
   resource, and every line costs adherence for every other line. If another
   framework writes a large core, AEP's thin-core assumption no longer holds.
3. **Both want the Stop hook.** Multiple `Stop` hooks all run; a second gate
   that blocks on different criteria can deadlock a session that the first one
   would have released. Check `/hooks` after installing anything.

**Safe combinations, in practice:** one protocol framework (AEP *or* a
neighbour) + as many *layer* tools as you like (memory, knowledge, MCP servers,
UI/design skills). Ponytail is the exception noted above — it changes code-size
bias, not the loop, so it stacks.

## Before you install any agent plugin — a vetting checklist

This page's figures will rot. This checklist will not. It is the same procedure
that caught the archived project above.

1. **Read the repo through the API, not the landing page.**
   `curl -s https://api.github.com/repos/OWNER/NAME | python3 -m json.tool | grep -E '"(archived|pushed_at|license|stargazers_count)"'`
   Archived or stale-by-a-year is a different risk profile than the README suggests.
2. **Know what it executes.** Hooks and MCP servers run code on your machine
   with your credentials. Read `hooks.json` and any `.mcp.json` before install,
   not after. A plugin that only ships skills is a document; a plugin that ships
   hooks is software.
3. **Know what it sends.** Any MCP server or RAG backend is an egress path.
   Decide explicitly what may leave the machine — AEP's own rule is that
   proprietary code never goes to a free gateway.
4. **Check for namespace and loop collisions** against the three failure modes
   above, before you need to debug them mid-task.
5. **Confirm it is removable.** `/plugin uninstall` should leave no hooks behind.
   If removal is undocumented, treat installation as permanent.
6. **Prefer pinned versions.** A marketplace entry without a version pin updates
   underneath you; that is convenient until it is not.

## Why AEP installs none of this

Four reasons, stated so you can disagree with them deliberately:

- **The security posture is a promise.** [SECURITY.md](../SECURITY.md) says AEP
  bundles no network services and executes only what your own repository
  provides. Auto-installing third-party plugins would silently void that.
- **The supply chain is real.** One of the projects users most often ask about
  here was archived after trust concerns. A curated installer would have kept
  installing it.
- **Scope.** AEP is a protocol, not a package manager. A protocol that installs
  software has to maintain compatibility with everything it installs.
- **Composition is a judgement call.** Which framework leads, what your core
  looks like, what may leave your machine — these are yours to make, and this
  page exists to make them well.
