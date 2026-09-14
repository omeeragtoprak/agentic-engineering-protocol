<!-- AEP asks contributors for what it asks agents for: evidence, not assurance. -->

## What changes, and why

<!-- One or two sentences. Lead with the result. -->

## Evidence

<!-- Commands you ran and what they printed. "Tests pass" is not evidence; the output is. -->

```
Check:   ./.claude/aep-check.sh → 
Review:  <fresh-context subagent | separate session | authoring context (weaker)> → 
```

## If this changes protocol text (skills, AGENTS.md, hooks)

Instruction changes are claims about agent behavior, so they are held to the
project's own standard — see [CONTRIBUTING.md](../CONTRIBUTING.md):

- [ ] The failure mode it fixes was **observed**, not imagined — say where.
- [ ] A measurement is proposed or included (arms, n, what would refute it).
- [ ] The rule is in the layer that can carry it (always-on core vs. on-demand skill).
- [ ] If it changes a shipped behavior, `docs/validation-log.md` or
      `docs/design-rules.md` is updated — including if the evidence went against it.

## Requirements

<!-- If this closes or defers a row in .claude/requirements.md, name it here:
     R7 done — proof: <test or cmd>   /   R9 deferred YYYY-MM-DD — <reason> -->
