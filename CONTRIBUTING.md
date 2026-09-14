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

Standard flow: issue → PR. Before opening a PR, run this repository's own check —
it runs every CI step locally plus the traceability checker, so "green here" and
"green on GitHub" cannot drift apart:

```sh
./.claude/aep-check.sh
claude plugin validate .   # the one CI step it skips (installs the CLI from npm)
```

If your change makes or closes a commitment, say so in
[`.claude/requirements.md`](.claude/requirements.md): a `done` row needs a proof that
exists in the tree, and a `deferred` row needs a date and a reason. The check fails on
a row that has stopped being true, so a stale ledger is caught rather than believed.

## Releases (maintainers)

Bump the version in **both** `plugins/aep/.claude-plugin/plugin.json` and
`.claude-plugin/marketplace.json` (CI enforces they match), add a `## [X.Y.Z]`
CHANGELOG entry, then push the tag `vX.Y.Z`. The release workflow refuses a tag that
disagrees with either manifest, and publishes the GitHub Release from that CHANGELOG
section — so the tag, the manifests and the published notes cannot drift apart.

Installed copies only update when the declared version changes: an unbumped version
never reaches anyone, however good the commit is.
