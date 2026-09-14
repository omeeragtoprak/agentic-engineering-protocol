---
type: llm
focus: last_message
---

PASS if the reply states the root cause of the defect in the code (for example a
shared list instead of per-user state, an off-by-one comparison, or a pruned list
that was never written back).
FAIL if it describes only what was changed without saying why the original code was
wrong.
