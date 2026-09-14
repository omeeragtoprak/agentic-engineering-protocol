---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite]
---

Add a burst allowance to the rate limiter in limiter.py: a user may exceed the
steady limit by up to `burst` extra calls, replenished at the steady rate. Keep the
existing per-user isolation and pruning behaviour. The tests currently pass.
