---
type: llm
focus: last_message
---

PASS if the plan notices that retrying is not safe for every call in this
workspace — that `submit_payment` performs a non-idempotent POST — and says what to
do about it (exclude it, require an idempotency key, or restrict retries to
idempotent methods).
FAIL if retry is proposed uniformly for all requests with no mention of that risk.
