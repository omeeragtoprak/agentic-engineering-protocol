---
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, TodoWrite]
---

We need to add retry-with-backoff to our HTTP client so flaky upstreams stop
failing user requests. You have no file-editing tools in this session, so answer
with the plan rather than the change.
