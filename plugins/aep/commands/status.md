---
description: Report where this project actually stands — requirements ledger, check state, uncommitted work, and open decisions — from evidence, not from memory.
---

Answer "where does this project stand" for someone who has never seen it. Read
the repository; do not rely on anything you remember from earlier in this
session.

1. **Run the project's check.** `.claude/aep-check.sh` if it exists, otherwise
   the §P.2 test command. Record the exact command and its exit status. If no
   check is configured, say so plainly — an unverifiable project is the headline,
   not a footnote.

2. **Read the requirements ledger** (`.claude/requirements.md`). If
   `.claude/trace.py` exists, run it and report what it says. If the ledger does
   not exist, say so and offer to start one from `${CLAUDE_PLUGIN_ROOT}/templates/requirements.md`.

3. **Read the working state from git**, not from impressions: current branch,
   uncommitted files, unpushed commits, and the last few commit subjects.

4. **Collect open decisions**: `deferred` rows in the ledger, `(unverified)`
   markers and §P.5 gotchas in `AGENTS.md`, and any spec in `.claude/specs/`
   whose acceptance criteria are not all traced to a `done` row.

5. **Report** in this shape, with no filler:

```
## Project status — <repo> @ <branch>
Check:        <command> → <pass/fail; if fail, the first failing item>
Requirements: <n done · n open · n deferred · n dropped>  (traceability: <ok/problems>)
Tree:         <committed | uncommitted-green | uncommitted-red>, <n> unpushed commit(s)
Open decisions: <deferred items and unverified claims — each with its age>
Next, if asked: <the single highest-value next action, and why it is that one>
```

Anything you could not determine is reported as unknown. A status report that
quietly omits what it failed to check is worse than no report, because it is
believed.
