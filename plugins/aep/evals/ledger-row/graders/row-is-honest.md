---
type: llm
focus: { source: file, path: .claude/requirements.md }
---

PASS if the ledger contains a row covering the work this session did (the rate
limiter defect), and that row's status is one of open / done / deferred / dropped
with a proof named when the status is done.
FAIL if the ledger is unchanged from its seeded single row, or if a row claims
`done` with no proof named.
