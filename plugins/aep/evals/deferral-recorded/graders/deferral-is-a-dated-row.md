---
type: regex
target: { source: file, path: .claude/requirements.md }
pattern: "deferred[^|\\n]*\\d{4}-\\d{2}-\\d{2}"
flags: i
---
