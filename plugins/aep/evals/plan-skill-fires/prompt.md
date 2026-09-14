---
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, TodoWrite]
---

I want a production-grade plan before any code is written: we need retry-with-backoff
in our HTTP client so flaky upstreams stop failing user requests. Analyse the options
first and give me the plan with acceptance criteria.
