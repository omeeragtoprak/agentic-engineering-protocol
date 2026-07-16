---
name: deliver
description: Delivery discipline — evidence-backed summary, atomic commit etiquette, and updating the project's persistent memory (§P) with durable knowledge. Use when finishing a task, preparing commits or a PR, or when the user asks to wrap up, summarize, or commit the work.
---

# AEP Phase 5 — Deliver

## 1. Delivery summary (mandatory format)

```
## Delivered: <task>
What & why:  <1–3 sentences — the change and its rationale>
Evidence:    <reference the Verification Evidence block>
Trade-offs:  <what was consciously sacrificed and why>
Risks left:  <known residual risks + suggested mitigations>
Needs human: <decisions outside agent authority, if any>
Follow-ups:  <logged debt / deferred gaps, with §P.5 references>
```

Lead with the result. No filler, no self-congratulation — the evidence speaks.

## 2. Commit etiquette

- **Atomic:** one logical change per commit; the diff matches the spec's file list — nothing unrelated rides along.
- **Intent-revealing:** Conventional Commits unless §P.3 says otherwise (`fix: prevent double-charge on payment retry (#123)`); the body explains *why* when the title can't.
- **Never:** commit a red build · commit secrets, generated artifacts (unless repo convention), or debug leftovers · force-push shared branches · rewrite published history.
- Run `git status` and read the full staged diff before committing — staging surprises are how unrelated files leak in.

## 3. Persistent memory update (§P)

Ask after every task: *did this produce durable knowledge?* Update §P when yes:

| Learned | Goes to |
|---|---|
| A verified command that differs from the obvious | §P.2 Verified Commands |
| An architectural decision + rationale | §P.4 Decision Log — `YYYY-MM-DD — decision — rationale` |
| A pitfall, quirk, flaky area, do-not-touch zone | §P.5 Gotchas |
| An intentional convention deviation | §P.3 Conventions |
| Anything the user corrected twice, or re-explained | The matching subsection, as one imperative line |

**Discipline:** shortest concrete imperative that would have prevented the mistake · dated · delete contradicted/stale lines (a wrong memory is worse than none) · **announce every §P change in the delivery summary** · never store secrets or personal data · if a subsection passes ~15 lines, move detail to a path-scoped rule file and keep a pointer.

## Exit gate

Summary delivered with evidence · commits atomic and green · §P updated (or "no durable knowledge" stated). The task is now — and only now — complete.
