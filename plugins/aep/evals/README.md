# AEP eval suite

Every claim this project makes about agent behaviour was measured by hand first —
controlled arms, n=2 or 3, written up in [`docs/validation-log.md`](../../../docs/validation-log.md).
That is evidence you have to take on trust. This suite is the same claims as cases
you can run yourself:

```sh
claude plugin eval . --scaffold --trust-plugin \
  --allow-tools Write Edit Bash \
  --model claude-sonnet-5 --judge-model claude-sonnet-5
```

Each case runs with the plugin loaded and again **without it**, and reports the
difference. A case that scores the same in both arms is a case where AEP is not what
made it pass — which is exactly what you want to know before installing a protocol.

## What each case encodes

| Case | The claim it tests | Where it came from |
|---|---|---|
| `plan-before-code` | A plain feature request produces weighed alternatives and checkable acceptance criteria | Phase 2 exit gate |
| `plan-skill-fires` | The README's claim that phrasing like *"production-grade"* or *"analyse first"* auto-matches a phase skill without a slash command | README, Quick start |
| `reviewer-named` | Every delivery states who graded the diff | Round 3: 0/2 → 2/2 after the rule was made unconditional |
| `evidence-not-assurance` | A completion claim names the command that ran and what it returned | §1.2, the prime directive |
| `ledger-row` | A repository keeping `.claude/requirements.md` leaves the task recorded in it | Rounds 10–11 — **the weakest case in the suite: 0/3 on bug-fix tickets** |
| `deferral-recorded` | An explicitly out-of-scope item becomes a dated `deferred` row, not a sentence in a summary | Rounds 10–16. **Also expected to fail**: 2/3 in one harness, 0/12 here |

**Which cases need a shell.** `reviewer-named`, `evidence-not-assurance` and
`ledger-row` grade work that involves running the project's tests, so they need
`--allow-tools Bash`. `plan-before-code`, `plan-skill-fires` and `deferral-recorded`
run with `--allow-tools Write Edit` or nothing at all.

This distinction is not only about convenience. **Without `Bash`, the Stop hook's
check never runs**, so the gate — and the ledger notice v1.7.1 added to it — take no
part in the result. A no-shell run measures the instruction layer alone, which is the
condition under which Round 10 measured 0/12. Read a no-shell score as "what the
prose achieves by itself".

`ledger-row` and `deferral-recorded` are both expected to fail. They are in the suite
because the gap is real and published, and a suite that only contains what already
works measures nothing. If either starts passing for you, that is a finding worth
sending back.

## Cost and shape

Six cases × 3 runs × 2 arms is 36 agent runs plus judge calls. Narrow it while
iterating:

```sh
claude plugin eval . --case ledger-row --runs 1 --ablation none --scaffold --trust-plugin \
  --allow-tools Write Edit Bash --max-cost-usd 5
```

`--ablation none` drops the no-plugin arm and halves the cost; use it for iterating
on graders, not for reporting a result, since Δ is the number that means something.

## Prerequisites, including one that is easy to hit

- **Claude Code ≥ 2.1.269** (`claude plugin eval` shipped in it).
- **A working Bash sandbox** for the four cases that run tests. On macOS this is
  built in — but a run is refused outright if `~/.docker` contains a symbolic link
  anywhere inside it, which Docker Desktop's `cli-plugins/` directory normally does:

  ```
  error: the Docker (~/.docker, DOCKER_CONFIG) credential store on this machine holds
  a symbolic link inside it, so the Bash sandbox cannot reliably exclude it — a
  Bash-granting evaluation cannot run here
  ```

  `DOCKER_CONFIG` does not move the check. The two `plan-*` cases need no shell and
  run anywhere; the rest need a machine whose Docker credential store is a plain
  directory, or a Linux runner with `bubblewrap` and `socat`.
- **Your own credentials.** Runs and judge calls bill to your plan; `--max-cost-usd`
  is the ceiling worth setting.

## Why this suite is not in AEP's CI

`claude plugin eval` runs in CI — the [docs](https://code.claude.com/docs/en/plugin-evals)
show the flags, and this repository's CI checks the suite's *structure* on every push.
What it does not do is run the cases, for two reasons worth stating rather than
hiding: every run bills to somebody's credentials, and a six-case suite at three runs
per arm is a real cost per push; and a judge model is a noisy instrument, so a
threshold gate on a small suite fails builds for reasons that have nothing to do with
the change. The suite is run deliberately, by hand, when a rule changes — and the
numbers land in [`docs/validation-log.md`](../../../docs/validation-log.md) with the
round that produced them.

## Reading a result honestly

- A `tool_used: Skill` grader can never pass without the plugin, so it is reported as
  an indicator and left out of the score in both arms. When it fails in the with-arm,
  the skill did not fire — which is a finding, not a bug in the case.
- A judge model is a measurement instrument with its own error. This suite was
  written with a small judge and produced a `Δ +0.17` that disappeared to `Δ 0.00`
  under a stronger one; the weak judge had been passing thin answers. Report the
  stronger judge's number, and read one trace before believing either.
- `--keep-temp` keeps each run's workspace and `trace.jsonl`. Read the trace before
  concluding anything about a low score: the first version of `plan-before-code`
  scored 0 because its workspace was empty and the model — correctly — asked what
  stack it was planning for.
