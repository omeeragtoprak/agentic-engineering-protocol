# Contributing to AEP

Contributions follow the protocol — this repo eats its own dog food.

## Protocol changes (core §0–§6, skill semantics, gate behavior)

Open an issue using the **Protocol change** template with:

1. **The problem observed** — a real failure or friction, not a hypothetical.
2. **The proposed rule** as the *shortest imperative that would have prevented it*.
3. **Evidence** — session transcript excerpts, diffs, or reproducible steps.

Rules earn their context cost: every always-on line must change behavior. Additions
that restate what a competent agent already does are declined regardless of quality.

## Everything else (bugs, docs, tooling, bench tasks)

Standard flow: issue → PR. Before opening a PR, run the same checks CI runs:

```sh
sh -n plugins/aep/scripts/verify-gate.sh
python3 -m json.tool .claude-plugin/marketplace.json > /dev/null
python3 -m json.tool plugins/aep/.claude-plugin/plugin.json > /dev/null
claude plugin validate .   # if you have Claude Code installed
```

## Releases (maintainers)

Bump the version in **both** `plugins/aep/.claude-plugin/plugin.json` and
`.claude-plugin/marketplace.json` (CI enforces they match), add a CHANGELOG
entry, tag `vX.Y.Z`, and publish a GitHub Release. Installed copies only update
when the declared version changes.
