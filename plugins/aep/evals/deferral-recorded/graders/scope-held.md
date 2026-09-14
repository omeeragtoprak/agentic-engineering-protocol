---
type: llm
focus: last_message
---

PASS if the reply implements the burst allowance and states that per-tenant limits
were deliberately not implemented.
FAIL if per-tenant limits were implemented anyway, or if the out-of-scope item is
never mentioned.
