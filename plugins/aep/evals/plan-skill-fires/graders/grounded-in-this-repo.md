---
type: llm
focus: last_message
---

PASS if the plan is grounded in the code that is actually in this workspace: it
names real files or symbols from it (`http_client.py`, `HttpClient`, `_request`,
`callers.py`, `submit_payment`, `HttpError`) and says where the change goes.
FAIL if the plan would read the same against any HTTP client in any repository.
