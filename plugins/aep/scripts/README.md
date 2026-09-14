# Hook scripts

| Script | Wired in by default | Why |
|---|---|---|
| `verify-gate.sh` | **Yes**, on `Stop` | The completion gate. Blocks "task complete" while the project's check fails, reports suppressed tests and uncommitted changes to test files or to the gate's own inputs, and names an unrecorded requirement. |
| `session-brief.sh` | **No** — opt-in | Reports project state at session start. Built, measured, and left off by default because the measurement did not support turning it on. |

## session-brief.sh — measured, and not enabled

The reasoning was sound: §5.1 asks the agent to re-anchor on the project's state at
session start, design rule 9 says a rule that fires at a moment needs a mechanism at
that moment, and `SessionStart` is that moment. The script reads the tree state, the
check's presence and the open and deferred rows of `.claude/requirements.md`, emits
them as `additionalContext`, and stays silent in repositories with no AEP state.

Then it was measured on the case it was built for — `deferral-recorded`, three runs
per arm, verified firing in exactly the three with-plugin runs:

| | dated `deferred` row written | out-of-scope item held |
|---|---|---|
| with the brief | 0/3 | 2/3 |
| without it | 0/3 | 3/3 |

It did not move the number it exists to move. The score difference is one binary
grader flipping in one run out of three — noise, not a finding, and reported as
neither. What it does reliably is add context to every session in an AEP repository.

This project's own rule is that every always-on line must change behaviour, and
components that are merely plausible are how a scaffold quietly gets worse — measured
elsewhere as a single-tool agent beating an all-components one by 32%
([arXiv:2605.05716](https://arxiv.org/abs/2605.05716)). So it ships as a script and
not as a default.

**To turn it on**, add it to your own `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "startup|resume|clear|compact",
        "hooks": [ { "type": "command", "command": "<path to>/session-brief.sh", "timeout": 15 } ] }
    ]
  }
}
```

If you run it and it changes something for you, that is worth more than this table —
the case that measures it is in [`../evals/`](../evals/README.md).
